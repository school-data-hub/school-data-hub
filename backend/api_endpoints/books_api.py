import io
import os
import uuid
import isbnlib
import requests
import qrcode
from flask_marshmallow.fields import File
from werkzeug.utils import secure_filename

from helpers.log_entries import create_log_entry
from models.book import Book
from schemas.book_schemas import *
from apiflask import APIBlueprint, abort, FileSchema
from flask import current_app, jsonify, request, send_file
from app import db

from apiflask import APIBlueprint, abort
from flask import current_app, jsonify, request

from auth_middleware import token_required
from helpers.log_entries import create_log_entry
from models.book import Book
from models.shared import db
from schemas.book_schemas import *
from schemas.log_entry_schemas import ApiFileSchema

book_api = APIBlueprint('book_api', __name__, url_prefix='/api/books')

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
    #if all_books == []:
    #    abort(404, 'No books found!')

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
    #if all_books == []:
    #    abort(404, 'No books found!')

    return all_books

#- GET BOOK IMAGE
#####################

@book_api.get('/<isbn>/image')
@book_api.output(FileSchema, content_type='image/jpeg')
@book_api.doc(security='ApiKeyAuth', tags=['Books'], summary='Get book image')
@token_required
def get_book_image(current_user, isbn):
    book = db.session.query(Book).filter(Book.isbn == isbn).first()
    if book is None:
        return jsonify({'message': 'Das Buch existiert nicht!'}), 404
    if len(str(book.image_url)) < 5:
        abort(404, message="Keine Datei vorhanden!")
    return send_file(str(book.image_url), mimetype='image/jpeg')

@book_api.get('/<book_id>/qrcode')
@book_api.output(FileSchema, content_type='image/png')
@book_api.doc(security='ApiKeyAuth', tags=['Books'], summary='Get book QR code')
@token_required
def get_book_qr_code(current_user, book_id):
    book = db.session.query(Book).filter(Book.book_id == book_id).first()
    if book is None:
        return jsonify({'message': 'Das Buch existiert nicht!'}), 404
    if not book.qr_code_url or len(str(book.qr_code_url)) < 5:
        abort(404, message="Keine QR-Code-Datei vorhanden!")
    return send_file(str(book.qr_code_url), mimetype='image/png')


#- POST BOOK


@book_api.route("/new", methods=["POST"])
@book_api.input(book_flat_schema)
@book_api.output(book_flat_schema)
@book_api.doc(security="ApiKeyAuth", tags=["Books"])
@token_required
def create_book(current_user, json_data):
    book_id = json_data['book_id']
    if db.session.query(Book).filter_by(book_id= book_id).scalar() is not None:
        abort(400, 'This book already exists!')

    isbn = str(json_data['isbn'])

    if not (isbnlib.is_isbn10(isbn) or isbnlib.is_isbn13(isbn)):
        return jsonify({"error": "Invalid ISBN format"}), 400

    try:
        book = isbnlib.meta(isbn)
        if not book:
            return jsonify({"error": "Book metadata not found for this ISBN"}), 404

        cover = isbnlib.cover(isbn)
        cover_url = cover.get('thumbnail') if cover else None
        response = requests.get(cover_url)
        filename = str(uuid.uuid4().hex)+'.jpg'
        file_url = current_app.config['UPLOAD_FOLDER'] + '/book/' + filename
        os.makedirs(os.path.dirname(file_url), exist_ok=True)
        with open(file_url, 'wb') as f:
            f.write(response.content)
        title = book.get('Title', 'Unknown Title')
        authors = book.get('Authors', [])
        author = authors[0] if authors else 'Unknown Author'

    except Exception as e:
        return jsonify({"error": f"Error fetching book details: {str(e)}"}), 500

    qr_data = f'Book ID: {book_id}, ISBN: {isbn}, Title: {title}'
    qr_img = qrcode.make(qr_data)
    qr_filename = f"{secure_filename(book_id)}.png"
    qr_file_path = os.path.join(current_app.config['UPLOAD_FOLDER'], 'qr_codes', qr_filename)
    os.makedirs(os.path.dirname(qr_file_path), exist_ok=True)

    # Save QR code image
    qr_img.save(qr_file_path)

    location = json_data['location']
    reading_level = json_data['reading_level']
    image_url = file_url
    qr_code_url = os.path.join(current_app.config['UPLOAD_FOLDER'], 'qr_codes', qr_filename)
    new_book = Book(book_id, isbn, title, author, location, reading_level, image_url, qr_code_url)
    db.session.add(new_book)
    # - Log entry
    create_log_entry(current_user, request, request.json)
    db.session.commit()

    return new_book


# - PATCH BOOK


@book_api.route("/<book_id>", methods=["PATCH"])
@book_api.input(book_flat_schema)
@book_api.output(book_flat_schema)
@book_api.doc(security="ApiKeyAuth", tags=["Books"], summary="Patch an existing book")
@token_required
def patch_book(current_user, book_id, json_data):
    book = db.session.query(Book).filter_by(book_id= book_id).scalar()
    if book is None:
        abort(404, 'This book does not exist!')

    data = request.get_json()
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
            case "image_url":
                book.image_url = data["image_url"]
    # - LOG ENTRY
    create_log_entry(current_user, request, data)
    db.session.commit()

    return book


# - PATCH BOOK FILE


@book_api.route("/<book_id>/file", methods=["PATCH"])
@book_api.input(ApiFileSchema, location="files")
@book_api.output(book_flat_schema)
@book_api.doc(
    security="ApiKeyAuth", tags=["Books"], summary="PATCH-POST a file for a given book"
)
@token_required
def upload_book_file(current_user, book_id):
    book = db.session.query(Book).filter_by(book_id=book_id).scalar()
    if book is None:
        return jsonify({'message': 'Das Buch existiert nicht!'}), 404
    if 'file' not in request.files:
        return jsonify({'error': 'No file attached!'}), 400
    file = request.files['file']
    filename = str(uuid.uuid4().hex) + '.jpg'
    file_url = current_app.config['UPLOAD_FOLDER'] + '/book/' + filename
    file.save(file_url)
    if len(str(book.image_url)) > 4:
        os.remove(str(book.image_url))
    book.image_url = file_url
    # - LOG ENTRY
    create_log_entry(current_user, request, {"file": filename})
    db.session.commit()

    return book


# - DELETE BOOK


@book_api.route("/<book_id>", methods=["DELETE"])
@book_api.doc(security="ApiKeyAuth", tags=["Books"])
@token_required
def delete_book(current_user, book_id):
    if not current_user.admin:
        abort(401, 'Not authorized!')

    this_book = Book.query.filter_by(book_id = book_id).first()
    if this_book == None:
        abort(404, 'This book does not exist!')

    if len(str(this_book.image_url)) > 4:
        os.remove(str(this_book.image_url))
    db.session.delete(this_book)
    # - Log entry
    create_log_entry(current_user, request, {"data": "none"})
    db.session.commit()

    return jsonify({"message": "Book deleted!"}), 200


