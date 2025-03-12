# pylint: disable=missing-module-docstring, missing-function-docstring, missing-class-docstring

import os
import uuid
from typing import Optional

from apiflask import APIBlueprint, abort
from flask import current_app, request, send_file

from auth_middleware import token_required
from helpers.db_helpers import (
    get_library_book_by_id,
    get_pupil_book_by_lending_id,
    get_pupil_by_id,
    now_as_date,
)
from helpers.log_entries import create_log_entry
from models.book import PupilBook, PupilBookFile
from models.pupil import Pupil
from models.shared import db
from models.user import User
from schemas.log_entry_schemas import ApiFileSchema
from schemas.pupil_book_schemas import pupil_book_out_schema
from schemas.pupil_schemas import pupil_schema

pupil_book_api = APIBlueprint("pupil_book_api", __name__, url_prefix="/api/pupil_book")


# - POST PUPIL BOOK


@pupil_book_api.route("/<internal_id>/book/<book_id>", methods=["POST"])
@pupil_book_api.output(pupil_schema)
@pupil_book_api.doc(security="ApiKeyAuth", tags=["Pupil Books"])
@token_required
def create_pupil_book(current_user: User, internal_id: int, book_id: str):
    this_pupil: Optional[Pupil] = get_pupil_by_id(internal_id)
    if this_pupil is None:
        abort(404, message="Schüler nicht gefunden!")

    pupil_id = this_pupil.internal_id
    this_library_book = get_library_book_by_id(book_id)
    if this_library_book is None:
        abort(404, message="Buch nicht gefunden!")

    if this_library_book.available is False:
        abort(404, message="Dieses Buch ist nicht verfügbar - gib es zuerst zurück!")

    state = None
    rating = None
    lent_by = current_user.name
    now = now_as_date()
    lending_id = str(uuid.uuid4().hex)
    lent_at = now
    returned_at = None
    received_by = None
    new_pupil_book = PupilBook(
        pupil_id=pupil_id,
        book_id=book_id,
        lending_id=lending_id,
        state=state,
        rating=rating,
        lent_at=lent_at,
        lent_by=lent_by,
        returned_at=returned_at,
        received_by=received_by,
    )
    db.session.add(new_pupil_book)
    this_library_book.available = False
    db.session.commit()

    return this_pupil


# - PATCH PUPIL BOOK


@pupil_book_api.route("/<lending_id>", methods=["PATCH"])
@pupil_book_api.input(pupil_book_out_schema)
@pupil_book_api.output(pupil_schema)
@pupil_book_api.doc(
    security="ApiKeyAuth", tags=["Pupil Books"], summary="Patch a pupil book"
)
@token_required
def update_pupil_book(current_user: User, lending_id: str, json_data: dict):
    pupil_book = get_pupil_book_by_lending_id(lending_id)

    if pupil_book is None:
        abort(404, message="Diese Ausleihe existiert nicht!")

    for key in json_data:
        match key:

            case "lent_at":
                if current_user.admin is True:
                    pupil_book.lent_at = json_data[key]
            case "lent_by":
                if current_user.admin is True:
                    pupil_book.lent_by = json_data[key]
            case "state":
                pupil_book.state = json_data[key]
            case "rating":
                pupil_book.rating = json_data[key]
            case "returned_at":
                borrowed_book = get_library_book_by_id(pupil_book.book_id)

                borrowed_book.available = True
                pupil_book.returned_at = json_data[key]

            case "received_by":
                pupil_book.received_by = json_data[key]

    db.session.commit()

    pupil = get_pupil_by_id(pupil_book.pupil_id)
    return pupil


# - POST PUPIL BOOK FILE


@pupil_book_api.route("/<lending_id>/file", methods=["POST"])
@pupil_book_api.input(ApiFileSchema, location="files")
@pupil_book_api.output(pupil_book_out_schema)
@pupil_book_api.doc(
    security="ApiKeyAuth",
    tags=["Pupil Books"],
    summary="Post file for pupil book from a given pupil",
)
@token_required
def post_pupil_book_file(current_user: User, lending_id: str, files_data: dict):
    pupil_book = get_pupil_book_by_lending_id(lending_id)

    if pupil_book is None:
        abort(404, message="Diese Ausleihe existiert nicht!")

    file_id = str(uuid.uuid4().hex)
    if "file" not in files_data:
        abort(400, "Keine Datei vorhanden!")

    file = files_data["file"]
    file_extension = os.path.splitext(file.filename)[1]
    filename = file_id + file_extension
    file_url = os.path.join(current_app.config["UPLOAD_FOLDER"], "chck", filename)

    # Save the file
    file.save(file_url)

    new_pupil_book_file = PupilBookFile(
        file_id=file_id,
        file_url=file_url,
        extension=file_extension,
        uploaded_at=now_as_date(),
        uploaded_by=current_user.name,
        lending_id=lending_id,
    )
    db.session.add(new_pupil_book_file)
    # - LOG ENTRY
    create_log_entry(current_user, request, {"file": file_id})
    db.session.commit()
    return pupil_book


# - GET PUPIL BOOK FILE


@pupil_book_api.route("/file/<file_id>", methods=["GET"])
@pupil_book_api.doc(
    security="ApiKeyAuth",
    tags=["Pupil Books"],
    summary="Get file associated to a pupil book from a given pupil",
)
@token_required
def get_pupil_book_file(file_id: str):
    pupil_book_file: Optional[PupilBookFile] = PupilBookFile.query.filter_by(
        file_id=file_id
    ).first()
    if pupil_book_file is None:
        abort(404, message="Diese Datei existiert nicht!")
    url_path = pupil_book_file.file_url
    return send_file(url_path, mimetype="audio/mp3")


# - DELETE PUPIL BOOK FILE


@pupil_book_api.route("/file/<file_id>", methods=["DELETE"])
@pupil_book_api.output(pupil_schema)
@pupil_book_api.doc(
    security="ApiKeyAuth",
    tags=["Pupil Books"],
    summary="Delete a file associated to a pupil book from a given pupil",
)
@token_required
def delete_pupil_book_file(current_user: User, file_id: str):
    pupil_book_file: Optional[PupilBookFile] = PupilBookFile.query.filter_by(
        file_id=file_id
    ).first()
    if pupil_book_file is None:
        abort(404, message="Diese Datei existiert nicht!")
    os.remove(str(pupil_book_file.file_url))
    db.session.delete(pupil_book_file)

    # - LOG ENTRY
    create_log_entry(current_user, request, {"file": file_id})
    db.session.commit()
    return pupil_book_file


# - DELETE PUPIL BOOK


@pupil_book_api.route("/<lending_id>", methods=["DELETE"])
@pupil_book_api.output(pupil_schema)
@pupil_book_api.doc(
    security="ApiKeyAuth", tags=["Pupil Books"], summary="delete a pupil book"
)
@token_required
def delete_PupilBook(current_user: User, lending_id: str):
    this_book = get_pupil_book_by_lending_id(lending_id)
    if this_book is None:
        abort(404, message="Diese Ausleihe existiert nicht!")

    if not current_user.admin or this_book.lent_by != current_user.name:
        abort(403, message="Nicht autorisiert!")

    pupil = get_pupil_by_id(this_book.pupil_id)
    db.session.delete(this_book)
    db.session.commit()
    return pupil
