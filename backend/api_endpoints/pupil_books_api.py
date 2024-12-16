import uuid
from datetime import datetime
from typing import Optional

from apiflask import APIBlueprint
from flask import jsonify, request
from sqlalchemy.sql import exists

from auth_middleware import token_required
from helpers.db_helpers import get_pupil_by_id
from models.book import Book, PupilBook
from models.pupil import Pupil
from models.shared import db
from models.user import User
from schemas.book_schemas import *
from schemas.pupil_schemas import pupil_schema

pupil_book_api = APIBlueprint("pupil_book_api", __name__, url_prefix="/api/pupil_book")


# - POST PUPIL BOOK
##################
@pupil_book_api.route("/<internal_id>/book/<book_id>", methods=["POST"])
@pupil_book_api.output(pupil_schema)
@pupil_book_api.doc(security="ApiKeyAuth", tags=["Pupil Books"])
@token_required
def add_book_to_pupil(current_user: User, internal_id, book_id):
    this_pupil: Optional[Pupil] = get_pupil_by_id(pupil_id=internal_id)
    if this_pupil == None:
        return jsonify({"error": "Pupil not found!"}), 404
    pupil_id = this_pupil.internal_id
    this_book: Optional[Book] = Book.query.filter_by(book_id=book_id).first()
    if this_book == None:
        return jsonify({"error": "Book not found!"}), 401
    if this_book.available == False:
        return jsonify({"error": "This book is not available - return it first!"})
    # # - TODO: Do we need to check if the pupil has already borrowed this book?
    # if (
    #     db.session.query(
    #         exists().where(
    #             PupilBook.book_id == book_id
    #             and PupilBook.pupil_id == internal_id
    #             and PupilBook.returned_at != None
    #         )
    #     ).scalar()
    #     == True
    # ):
    #     return jsonify({"error": "This pupil book exists already!"})
    state = None
    rating = None
    lent_by = current_user.name
    now = datetime.strptime(datetime.now().strftime("%Y-%m-%d"), "%Y-%m-%d")
    lending_id = str(uuid.uuid4().hex)
    lent_at = now
    returned_at = None
    received_by = None
    new_pupil_book = PupilBook(
        pupil_id,
        book_id,
        lending_id,
        state,
        rating,
        lent_at,
        lent_by,
        returned_at,
        received_by,
    )
    db.session.add(new_pupil_book)
    this_book.available = False
    db.session.commit()

    return this_pupil


# - PATCH PUPIL BOOK
###################
@pupil_book_api.route("/<lending_id>", methods=["PATCH"])
@pupil_book_api.input(pupil_book_schema)
@pupil_book_api.output(pupil_schema)
@pupil_book_api.doc(
    security="ApiKeyAuth", tags=["Pupil Books"], summary="Patch a pupil book"
)
@token_required
def update_PupilBook(current_user: User, lending_id, json_data):
    pupil_book: Optional[PupilBook] = PupilBook.query.filter_by(
        lending_id=lending_id
    ).first()
    if pupil_book == None:
        return jsonify({"error": "This pupil book does not exist!"})

    for key in json_data:
        match key:

            case "lent_at":
                if current_user.admin == True:
                    pupil_book.lent_at = json_data[key]
            case "lent_by":
                if current_user.admin == True:
                    pupil_book.lent_by = json_data[key]
            case "state":
                pupil_book.state = json_data[key]
            case "rating":
                pupil_book.rating = json_data[key]
            case "returned_at":
                borrowed_book: Optional[Book] = Book.query.filter_by(
                    book_id=pupil_book.book_id
                ).first()

                borrowed_book.available = True
                pupil_book.returned_at = json_data[key]
                print("Case returned_at")
                print(pupil_book.returned_at)
            case "received_by":
                pupil_book.received_by = json_data[key]
                print("Case received_by")
                print(pupil_book.received_by)

    db.session.commit()

    print(pupil_book.received_by)
    print(pupil_book.returned_at)
    print(pupil_book.book_id)
    pupil = get_pupil_by_id(pupil_book.pupil_id)
    return pupil


# - DELETE PUPIL BOOK
####################
@pupil_book_api.route("/<lending_id>", methods=["DELETE"])
@pupil_book_api.doc(
    security="ApiKeyAuth", tags=["Pupil Books"], summary="delete a pupil book"
)
@token_required
def delete_PupilBook(current_user: User, lending_id):
    if not current_user.admin:
        return jsonify({"message": "Not authorized!"})
    this_book: Optional[PupilBook] = PupilBook.query.filter_by(
        lending_id=lending_id
    ).first()
    db.session.delete(this_book)
    db.session.commit()
    return jsonify({"message": "Das ausgeliehene Buch wurde gelöscht!"}), 200
