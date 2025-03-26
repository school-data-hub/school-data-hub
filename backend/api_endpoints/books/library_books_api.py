# pylint: disable=missing-module-docstring, missing-function-docstring, missing-class-docstring

from typing import List, Optional

from apiflask import APIBlueprint, abort
from flask import request

from auth_middleware import token_required
from helpers.db_helpers import get_book_by_isbn, get_library_book_by_isbn
from helpers.log_entries import create_log_entry
from models.book import LibraryBook, LibraryBookLocation
from models.shared import db
from models.user import User
from schemas.book_schemas import (
    book_location_schema,
    book_locations_schema,
    library_book_out_schema,
    library_books_out_schema,
    new_library_book_schema,
)

library_book_api = APIBlueprint(
    "library_book_api", __name__, url_prefix="/api/library_books"
)

# - GET LIBRARY BOOK LOCATIONS


@library_book_api.route("/locations", methods=["GET"])
@library_book_api.output(book_locations_schema)
@library_book_api.doc(
    security="ApiKeyAuth",
    tags=["Library Books"],
    summary="Get all library book locations",
)
@token_required
def get_book_locations():
    locations: List[LibraryBookLocation] = LibraryBookLocation.query.all()
    return locations


# - ADD LIBRARY BOOK LOCATION


@library_book_api.route("/locations/new", methods=["POST"])
@library_book_api.input(book_location_schema)
@library_book_api.output(book_locations_schema)
@library_book_api.doc(
    security="ApiKeyAuth",
    tags=["Library Books"],
    summary="Add a new book location",
)
@token_required
def add_book_location(json_data: dict):
    location = json_data["location"]
    if (
        db.session.query(LibraryBookLocation).filter_by(location=location).scalar()
        is not None
    ):
        abort(400, "This location already exists!")
    new_location = LibraryBookLocation(location=location)
    db.session.add(new_location)
    db.session.commit()
    return LibraryBookLocation.query.all()


# - DELETE LIBRARY BOOK LOCATION


@library_book_api.route("/locations/<location>", methods=["DELETE"])
@library_book_api.output(book_locations_schema)
@library_book_api.doc(
    security="ApiKeyAuth",
    tags=["Library Books"],
    summary="Delete a book location",
)
@token_required
def delete_book_location(current_user, location):

    this_location = LibraryBookLocation.query.filter_by(location=location).first()
    if this_location is None:
        abort(404, "This location does not exist!")

    if not current_user.admin or current_user.name != this_location.created_by:
        abort(403, "Keine Berechtigung!")

    db.session.delete(this_location)
    db.session.commit()
    return LibraryBookLocation.query.all()


# - GET LIBRARY BOOKS


@library_book_api.route("/all", methods=["GET"])
@library_book_api.output(library_books_out_schema)
@library_book_api.doc(
    security="ApiKeyAuth",
    tags=["Library Books"],
    summary="get all library books including respective book data",
)
@token_required
def get_library_books():

    all_books = LibraryBook.query.all()

    return all_books



# - GET LIBRARY BOOKS MATCHING QUERY
#- TODO: Implement this function
@library_book_api.route("/search", methods=["GET"])
@library_book_api.output(library_books_out_schema)
@library_book_api.doc(
    security="ApiKeyAuth",
    tags=["Library Books"],
    summary="get all library books matching query",
    description="This function is not yet implemented"
)
@token_required
def get_library_books_matching_query():
    #- json_data should provide query parameters
    #- endpoint should return all library books matching the query
    #- query parameters should include:
    #-- title
    #-- author
    #-- isbn
    #-- location
    #-- available

    #- caution: for consistency, all library books with the same isbn
    #- should be served in one batch
    # - that means isbn should have priority for batching

    #- with pagination (50 books per page)

    abort(501, "This function is not yet implemented")

# - GET LIBRARY BOOK BY ID


@library_book_api.route("/<book_id>", methods=["GET"])
@library_book_api.output(library_book_out_schema)
@library_book_api.doc(
    security="ApiKeyAuth",
    tags=["Library Books"],
    summary="Get a library book by id",
)
@token_required
def fetch_library_book_by_id(book_id: str):

    this_book = LibraryBook.query.filter_by(book_id=book_id).first()
    if this_book is None:
        abort(404, "This book does not exist!")

    return this_book


# - POST LIBRARY BOOK


@library_book_api.route("/new", methods=["POST"])
@library_book_api.input(new_library_book_schema)
@library_book_api.output(library_book_out_schema)
@library_book_api.doc(
    security="ApiKeyAuth",
    tags=["Library Books"],
    summary="Add a new library book to the library",
)
@token_required
def post_library_book(current_user, json_data):
    book_id = json_data["book_id"]
    if db.session.query(LibraryBook).filter_by(book_id=book_id).scalar() is not None:
        abort(400, "This book already exists!")

    isbn = json_data["book_isbn"]
    location = json_data["location"]

    new_library_book = LibraryBook(
        book_id=book_id,
        book_isbn=isbn,
        location=location,
        available=True,
    )

    db.session.add(new_library_book)
    # - Log entry
    create_log_entry(current_user, request, request.json)
    db.session.commit()

    return new_library_book


# - PATCH LIBRARY BOOK


@library_book_api.route("/<book_id>", methods=["PATCH"])
@library_book_api.input(library_book_out_schema)
@library_book_api.output(library_book_out_schema)
@library_book_api.doc(
    security="ApiKeyAuth", tags=["Library Books"], summary="Patch a library book"
)
@token_required
def patch_library_book(book_id, json_data):
    this_book: Optional[LibraryBook] = LibraryBook.query.filter_by(
        book_id=book_id
    ).first()
    if this_book is None:
        abort(404, "This library book does not exist!")

    for key in json_data:
        match key:
            case "available":
                this_book.available = json_data[key]
            case "location":
                this_book.location = json_data[key]

    db.session.commit()
    return this_book


# - DELETE LIBRARY BOOK


@library_book_api.route("/<book_id>", methods=["DELETE"])
@library_book_api.output(library_books_out_schema)
@library_book_api.doc(
    security="ApiKeyAuth",
    tags=["Library Books"],
    summary="Delete a library book",
)
@token_required
def delete_library_book(current_user: User, book_id):

    this_book: LibraryBook = LibraryBook.query.filter_by(book_id=book_id).first()
    if this_book is None:
        abort(404, "This book does not exist!")

    isbn = this_book.book_isbn

    db.session.delete(this_book)
    # if this was the last library book of this book, delete the book
    library_book_same_isbn = get_library_book_by_isbn(isbn)
    if library_book_same_isbn is None:

        orphan_book = get_book_by_isbn(isbn)
        db.session.delete(orphan_book)

    # - Log entry
    create_log_entry(current_user, request, request.json)
    db.session.commit()

    return LibraryBook.query.all()
