import os
import uuid

from apiflask import APIBlueprint, abort
from flask import current_app, jsonify, request, send_file

from auth_middleware import token_required
from helpers.db_helpers import get_book_by_id, get_workbook_by_isbn
from helpers.log_entries import create_log_entry
from models.book import Book, BookLocation
from models.shared import db
from models.user import User
from schemas.book_schemas import *
from schemas.log_entry_schemas import ApiFileSchema

book_api = APIBlueprint("book_api", __name__, url_prefix="/api/books")

# - GET BOOK LOCATIONS


@book_api.route("/locations", methods=["GET"])
@book_api.output(book_locations_schema)
@book_api.doc(security="ApiKeyAuth", tags=["Books"], summary="Get all book locations")
@token_required
def get_book_locations(current_user):
    locations = BookLocation.query.all()
    return locations


# - ADD BOOK LOCATION


@book_api.route("/locations/new", methods=["POST"])
@book_api.input(book_location_schema)
@book_api.output(book_locations_schema)
@book_api.doc(security="ApiKeyAuth", tags=["Books"], summary="Add a new book location")
@token_required
def add_book_location(current_user, json_data):
    location = json_data["location"]
    if db.session.query(BookLocation).filter_by(location=location).scalar() is not None:
        abort(400, "This location already exists!")
    new_location = BookLocation(location=location)
    db.session.add(new_location)
    db.session.commit()
    return BookLocation.query.all()


# - DELETE BOOK LOCATION


@book_api.route("/locations/<location>", methods=["DELETE"])
@book_api.output(book_locations_schema)
@book_api.doc(security="ApiKeyAuth", tags=["Books"], summary="Delete a book location")
@token_required
def delete_book_location(current_user, location):
    if not current_user.admin:
        abort(401, "Not authorized!")

    this_location = BookLocation.query.filter_by(location=location).first()
    if this_location == None:
        abort(404, "This location does not exist!")

    db.session.delete(this_location)
    db.session.commit()
    return BookLocation.query.all()


# - GET BOOKS


@book_api.route("/all", methods=["GET"])
@book_api.output(books_schema)
@book_api.doc(
    security="ApiKeyAuth",
    tags=["Books"],
    summary="get all books including reading pupils",
)
@token_required
def get_books(current_user):

    all_books = Book.query.all()
    if all_books == []:
        abort(404, "No books found!")

    return all_books


# - GET BOOKS FLAT


@book_api.route("/all/flat", methods=["GET"])
@book_api.output(books_flat_schema)
@book_api.doc(
    security="ApiKeyAuth",
    tags=["Books"],
    summary="get all books without nested elements",
)
@token_required
def get_books_flat(current_user):
    if not current_user:
        abort(404, "Bitte erneut einloggen!")

    all_books = Book.query.all()
    # if all_books == []:
    #   abort(404, "No books found!")

    return all_books


# - POST BOOK


@book_api.route("/new", methods=["POST"])
@book_api.input(new_book_schema)
@book_api.output(book_flat_schema)
@book_api.doc(security="ApiKeyAuth", tags=["Books"])
@token_required
def create_book(current_user, json_data):
    book_id = json_data["book_id"]
    if db.session.query(Book).filter_by(book_id=book_id).scalar() is not None:
        abort(400, "This book already exists!")

    isbn = json_data["isbn"]
    location = json_data["location"]
    title = json_data["title"]
    author = json_data["author"]
    reading_level = json_data["reading_level"]
    description = json_data["description"]

    new_book = Book(
        book_id=book_id,
        isbn=isbn,
        title=title,
        author=author,
        location=location,
        reading_level=reading_level,
        image_url=None,
        image_id=None,
        description=description,
        available=True,
    )
    db.session.add(new_book)
    # - Log entry
    create_log_entry(current_user, request, request.json)
    db.session.commit()

    return new_book


# - PATCH BOOK


@book_api.route("/<book_id>", methods=["PATCH"])
@book_api.input(book_patch_schema)
@book_api.output(book_flat_schema)
@book_api.doc(security="ApiKeyAuth", tags=["Books"], summary="Patch an existing book")
@token_required
def patch_book(current_user, book_id, json_data):
    book = db.session.query(Book).filter_by(book_id=book_id).scalar()

    if book is None:
        abort(404, "This book does not exist!")

    data = json_data
    for key in data:
        match key:
            case "title":
                book.title = data["title"]
            case "author":
                book.author = data["author"]
            case "location":
                book.location = data["location"]
            case "reading_level":
                book.reading_level = data["reading_level"]
            case "description":
                book.description = data["description"]
            case "available":
                book.available = data["available"]

    # - LOG ENTRY

    create_log_entry(current_user, request, data)

    db.session.commit()

    return book


# # - POST BOOK WITH FILE
## - TODO: implement posting a book with a file to avoid two requests


# - PATCH BOOK FILE


@book_api.route("/<book_id>/file", methods=["PATCH"])
@book_api.input(ApiFileSchema, location="files")
@book_api.output(book_flat_schema)
@book_api.doc(
    security="ApiKeyAuth", tags=["Books"], summary="PATCH-POST a file for a given book"
)
@token_required
def upload_book_file(current_user, book_id, files_data):
    book = db.session.query(Book).filter_by(book_id=book_id).scalar()
    if book is None:
        return jsonify({"message": "Das Buch existiert nicht!"}), 404
    if "file" not in files_data:
        return jsonify({"error": "No file attached!"}), 400
    file = files_data["file"]
    image_id = str(uuid.uuid4().hex)
    filename = image_id + ".jpg"
    file_url = current_app.config["UPLOAD_FOLDER"] + "/book/" + filename
    file.save(file_url)
    if len(str(book.image_url)) > 4:
        os.remove(str(book.image_url))
    book.image_id = image_id
    book.image_url = file_url
    # - LOG ENTRY
    create_log_entry(current_user, request, {"file": filename})
    db.session.commit()

    return book


# - GET BOOK IMAGE
#####################


@book_api.get("/<book_id>/file")
@book_api.output(ApiFileSchema, content_type="image/jpeg")
@book_api.doc(security="ApiKeyAuth", tags=["Books"], summary="Get book image")
@token_required
def get_book_image(current_user: User, book_id):
    book = get_book_by_id(book_id=book_id)
    if book is None:
        return jsonify({"message": "Das Buch existiert nicht!"}), 404
    if len(str(book.image_url)) < 5:
        abort(404, message="Keine Datei vorhanden!")
    return send_file(str(book.image_url), mimetype="image/jpg")


# - DELETE BOOK


@book_api.route("/<book_id>", methods=["DELETE"])
@book_api.doc(security="ApiKeyAuth", tags=["Books"])
@token_required
def delete_book(current_user, book_id):
    if not current_user.admin:
        abort(401, "Not authorized!")

    this_book = Book.query.filter_by(book_id=book_id).first()
    if this_book == None:
        abort(404, "This book does not exist!")

    if len(str(this_book.image_url)) > 4:
        os.remove(str(this_book.image_url))
    db.session.delete(this_book)
    # - Log entry
    create_log_entry(current_user, request, {"data": "none"})
    db.session.commit()

    return jsonify({"message": "Book deleted!"}), 200
