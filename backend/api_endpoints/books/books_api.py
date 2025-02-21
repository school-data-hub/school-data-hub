import os
import uuid
from typing import List

from apiflask import APIBlueprint, abort
from flask import current_app, jsonify, request, send_file

from auth_middleware import token_required
from helpers.db_helpers import (
    get_book_by_isbn,
    get_library_book_by_id,
    get_workbook_by_isbn,
)
from helpers.isbn_data import get_isbn_api_data
from helpers.log_entries import create_log_entry
from models.book import Book, BookTag
from models.shared import db
from models.user import User
from schemas.book_schemas import *
from schemas.log_entry_schemas import ApiFileSchema
from schemas.pupil_book_schemas import *

book_api = APIBlueprint("book_api", __name__, url_prefix="/api/books")


# - GET BOOK
#####################

# A library book request will ask for a book by its ISBN.
# If the book is found in the database, the book data will be returned.
# If the book is not found in the database, the ISBN API will be queried for the book data.
# If the book is not found in the ISBN API, a 404 error will be raised.
# If the book is found in the ISBN API, the book data will be first saved to the database and then returned to the user.


@book_api.route("/<isbn>", methods=["GET"])
@book_api.output(book_flat_schema)
@book_api.doc(
    security="ApiKeyAuth",
    tags=["Books"],
    summary="Get book by ISBN",
)
@token_required
def get_book(current_user, isbn):
    isbn = isbn.replace("-", "")
    book = get_book_by_isbn(isbn)
    if book is not None:
        return book

    try:
        isbn_data = get_isbn_api_data(isbn)
        if isbn_data is None:
            abort(404, "This book is not available through the API!")
    except Exception as e:
        abort(404, f"Error: {e}")

    file = isbn_data.image
    image_id = str(uuid.uuid4().hex)
    filename = image_id + ".jpg"
    file_url = current_app.config["UPLOAD_FOLDER"] + "/book/" + filename
    # Save the image bytes to a file
    with open(file_url, "wb") as f:
        f.write(file)
    new_book = Book(
        isbn=isbn_data.isbn,
        title=isbn_data.title,
        author=isbn_data.author,
        description=isbn_data.description,
        reading_level=0,
        image_url=file_url,
        image_id=image_id,
    )
    db.session.add(new_book)
    db.session.commit()
    return new_book


# - GET BOOKS FLAT
#####################


@book_api.route("/all/flat", methods=["GET"])
@book_api.output(books_flat_schema)
@book_api.doc(
    security="ApiKeyAuth",
    tags=["Books"],
    summary="get all books without library books",
)
@token_required
def get_books_flat(current_user):

    all_books = Book.query.all()

    return all_books


# - PATCH BOOK
#####################


@book_api.route("/<isbn>", methods=["PATCH"])
@book_api.input(book_patch_schema)
@book_api.output(book_flat_schema)
@book_api.doc(security="ApiKeyAuth", tags=["Books"], summary="Patch an existing book")
@token_required
def patch_book(current_user, isbn, json_data):
    book: Book = db.session.query(Book).filter_by(isbn=isbn).scalar()

    if book is None:
        abort(404, "This book does not exist!")

    data = json_data
    for key in data:
        match key:
            case "title":
                book.title = data["title"]
            case "author":
                book.author = data["author"]
            case "description":
                book.description = data["description"]
            case "reading_level":
                book.reading_level = data["reading_level"]
            # If there are book tags in the request, delete the old ones
            # and add the new ones
            case "book_tags":
                book_tags = data["book_tags"]
                book.book_tags = []
                for tag_data in book_tags:
                    tag_name = tag_data["name"]
                    tag = db.session.query(BookTag).filter_by(name=tag_name).first()
                    if tag is None:
                        abort(400, f"Tag '{tag_name}' does not exist!")
                    book.book_tags.append(tag)

    # - LOG ENTRY

    create_log_entry(current_user, request, data)

    db.session.commit()

    return book


# - PATCH BOOK WITH IMAGE
#########################


@book_api.route("/<isbn>/file", methods=["PATCH"])
@book_api.input(ApiFileSchema, location="files")
@book_api.output(book_flat_schema)
@book_api.doc(
    security="ApiKeyAuth", tags=["Books"], summary="PATCH-POST a file for a given book"
)
@token_required
def upload_book_image(current_user, isbn: int, files_data):
    book: Book = db.session.query(Book).filter_by(isbn=isbn).scalar()
    if book is None:
        abort(404, "Das Buch existiert nicht!")

    if "file" not in files_data:
        abort(400, "Keine Datei angehängt!")

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


@book_api.get("/<isbn>/file")
@book_api.output(ApiFileSchema, content_type="image/jpeg")
@book_api.doc(security="ApiKeyAuth", tags=["Books"], summary="Get book image")
@token_required
def get_book_image(current_user: User, isbn: int):
    book = get_book_by_isbn(isbn=isbn)
    if book is None:
        abort(404, "Das Buch existiert nicht!")

    if len(str(book.image_url)) < 5:
        abort(404, message="Keine Datei vorhanden!")
    return send_file(str(book.image_url), mimetype="image/jpg")


# - DELETE BOOK
#####################


@book_api.route("/<isbn>", methods=["DELETE"])
@book_api.doc(security="ApiKeyAuth", tags=["Books"])
@token_required
def delete_book(current_user, isbn):
    this_book: Book = Book.query.filter_by(isbn=isbn).first()
    if this_book == None:
        abort(404, "This book does not exist!")

    if not current_user.admin or current_user.name != this_book.created_by:
        abort(403, "Keine Berechtigung!")

    if len(str(this_book.image_url)) > 4:
        os.remove(str(this_book.image_url))
    db.session.delete(this_book)
    # - Log entry
    create_log_entry(current_user, request, {"data": "none"})
    db.session.commit()
    return jsonify({"message": "Buch gelöscht!"}), 200


## - BOOK TAGS - ##

# - GET BOOK TAGS


@book_api.route("/tags", methods=["GET"])
@book_api.output(book_tags_out_schema)
@book_api.doc(security="ApiKeyAuth", tags=["Book Tags"], summary="Get all book tags")
@token_required
def get_book_tags(current_user):
    tags = BookTag.query.all()
    return tags


## - ADD BOOK TAG


@book_api.route("/tags/new", methods=["POST"])
@book_api.input(book_tag_schema)
@book_api.output(book_tags_out_schema)
@book_api.doc(security="ApiKeyAuth", tags=["Book Tags"], summary="Add a new book tag")
@token_required
def add_book_tag(current_user, json_data):
    tag_name = json_data["name"]
    created_by = json_data["created_by"]
    if db.session.query(BookTag).filter_by(name=tag_name).scalar() is not None:
        abort(400, "This tag already exists!")
    new_tag = BookTag(name=tag_name, created_by=created_by)
    db.session.add(new_tag)
    db.session.commit()
    return BookTag.query.all()


## - PATCH BOOK TAG


@book_api.route("/tags/<tag_name>", methods=["PATCH"])
@book_api.input(book_tag_schema)
@book_api.output(book_tags_out_schema)
@book_api.doc(security="ApiKeyAuth", tags=["Book Tags"], summary="Patch a book tag")
@token_required
def patch_book_tag(current_user, tag_name, json_data):
    this_tag = BookTag.query.filter_by(name=tag_name).first()
    if this_tag == None:
        abort(404, "This tag does not exist!")

    data = json_data
    for key in data:
        match key:
            case "name":
                this_tag.name = data["name"]

    db.session.commit()
    return BookTag.query.all()


## - DELETE BOOK TAG


@book_api.route("/tags/<tag_name>", methods=["DELETE"])
@book_api.output(book_tags_out_schema)
@book_api.doc(security="ApiKeyAuth", tags=["Book Tags"], summary="Delete a book tag")
@token_required
def delete_book_tag(current_user, tag_name):
    this_tag = BookTag.query.filter_by(name=tag_name).first()
    if this_tag == None:
        abort(404, "This tag does not exist!")

    if not current_user.admin or current_user.name != this_tag.created_by:
        abort(403, "Keine Berechtigung!")

    db.session.delete(this_tag)
    db.session.commit()
    return BookTag.query.all()
