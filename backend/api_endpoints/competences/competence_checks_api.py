import os
import uuid
from datetime import datetime

from apiflask import APIBlueprint, FileSchema, abort
from flask import current_app, request, send_file

from auth_middleware import token_required
from helpers.db_helpers import date_string_to_date, get_pupil_by_id, now_as_date
from helpers.log_entries import create_log_entry
from models.competence import Competence, CompetenceCheck, CompetenceCheckFile
from models.pupil import Pupil
from models.shared import db
from schemas.competence_schemas import *
from schemas.log_entry_schemas import ApiFileSchema
from schemas.pupil_schemas import *

competence_check_api = APIBlueprint(
    "competence_check_api", __name__, url_prefix="/api/competence_checks"
)

# - POST COMPETENCE CHECK


@competence_check_api.route("/<internal_id>/new", methods=["POST"])
@competence_check_api.input(competence_check_in_schema)
@competence_check_api.output(pupil_schema)
@competence_check_api.doc(
    security="ApiKeyAuth",
    tags=["Competence Checks"],
    summary="Post check for a competence from a given pupil",
)
@token_required
def post_competence_check(current_user, internal_id, json_data):
    pupil = get_pupil_by_id(internal_id)
    if pupil == None:
        abort(400, "Diese/r Schüler/in existiert nicht!")
    data = json_data
    competence_id = data["competence_id"]
    competence = Competence.query.filter_by(competence_id=competence_id).first()
    if competence == None:
        abort(400, "Diese Kompetenz existiert nicht!")
    check_id = str(uuid.uuid4().hex)
    created_by = current_user.name
    created_at = now_as_date()
    competence_status = data["competence_status"]
    comment = data["comment"]
    value_factor = json_data.get("value_factor")
    group_id = json_data.get("group_id")
    group_name = json_data.get("group_name")

    new_competence_check = CompetenceCheck(
        check_id,
        created_by,
        created_at,
        competence_status,
        comment,
        internal_id,
        competence_id,
        value_factor,
        group_id,
        group_name,
    )
    db.session.add(new_competence_check)
    # - LOG ENTRY
    create_log_entry(current_user, request, json_data)
    db.session.commit()
    return pupil


# - POST EMPTY COMPETENCE CHECK WITH FILE


@competence_check_api.route(
    "/<internal_id>/<competence_id>/<group_id>/new", methods=["POST"]
)
@competence_check_api.input(ApiFileSchema, location="files")
@competence_check_api.output(pupil_schema)
@competence_check_api.doc(
    security="ApiKeyAuth",
    tags=["Competence Checks"],
    summary="Post group check with file for a competence from a given pupil",
)
@token_required
def post_competence_check_with_file(
    current_user, internal_id, competence_id, group_id, files_data
):
    pupil = get_pupil_by_id(internal_id)
    if pupil == None:
        abort(400, "Diese/r Schüler/in existiert nicht!")

    competence = Competence.query.filter_by(competence_id=competence_id).first()
    if competence == None:
        abort(400, "Diese Kompetenz existiert nicht!")
    check_id = str(uuid.uuid4().hex)
    created_by = current_user.name
    created_at = now_as_date()
    competence_status = 0
    comment = ""
    value_factor = None
    group_name = None

    file_id = str(uuid.uuid4().hex)
    if "file" not in files_data:
        abort(400, "Keine Datei vorhanden!")

    file = files_data["file"]
    filename = file_id + ".jpg"
    file_url = current_app.config["UPLOAD_FOLDER"] + "/chck/" + filename
    file.save(file_url)
    new_competence_check_file = CompetenceCheckFile(check_id, file_id, file_url)
    db.session.add(new_competence_check_file)

    new_competence_check = CompetenceCheck(
        check_id,
        created_by,
        created_at,
        competence_status,
        comment,
        internal_id,
        competence_id,
        value_factor,
        group_id,
        group_name,
    )
    db.session.add(new_competence_check)
    # - LOG ENTRY
    create_log_entry(current_user, request, {"file": file_id})
    db.session.commit()
    return pupil


# - PATCH COMPETENCE CHECK


@competence_check_api.route("/<check_id>", methods=["PATCH"])
@competence_check_api.input(competence_check_in_schema)
@competence_check_api.output(pupil_schema)
@competence_check_api.doc(
    security="ApiKeyAuth",
    tags=["Competence Checks"],
    summary="Patch check of a competence from a given pupil",
)
@token_required
def patch_competence_check(current_user, check_id, json_data):
    competence_check = CompetenceCheck.query.filter_by(check_id=check_id).first()
    if competence_check == None:
        abort(400, "Dieser Kompetenz-Check existiert nicht!")
    pupil = get_pupil_by_id(competence_check.pupil_id)
    data = json_data
    for key in data:
        match key:
            case "competence_status":
                competence_check.competence_status = data[key]
            case "comment":
                competence_check.comment = data[key]
            case "created_at":
                competence_check.created_at = data[key]

            case "value_factor":
                competence_check.value_factor = data[key]
            case "group_id":
                competence_check.group_id = data[key]
            case "group_name":
                competence_check.group_name = data[key]

    # - LOG ENTRY
    create_log_entry(current_user, request, json_data)
    db.session.commit()
    return pupil


# - POST COMPETENCE CHECK FILE


@competence_check_api.route("/<check_id>/file", methods=["POST"])
@competence_check_api.input(ApiFileSchema, location="files")
@competence_check_api.output(pupil_schema, 200)
@competence_check_api.doc(
    security="ApiKeyAuth",
    tags=["Competence Checks"],
    summary="Post file for a check of a competence from a given pupil",
)
@token_required
def upload_competence_image(current_user, check_id, files_data):
    competence_check = CompetenceCheck.query.filter_by(check_id=check_id).first()
    if competence_check == None:
        abort(400, "Diese Kompetenz Check existiert nicht!")

    file_id = str(uuid.uuid4().hex)
    if "file" not in files_data:
        abort(400, "Keine Datei vorhanden!")

    file = files_data["file"]
    filename = file_id + ".jpg"
    file_url = current_app.config["UPLOAD_FOLDER"] + "/chck/" + filename
    file.save(file_url)
    new_competence_check_file = CompetenceCheckFile(check_id, file_id, file_url)
    db.session.add(new_competence_check_file)
    # - LOG ENTRY
    create_log_entry(current_user, request, {"file": file_id})
    db.session.commit()
    pupil = get_pupil_by_id(competence_check.pupil_id)
    return pupil


# - DELETE COMPETENCE CHECK FILE


@competence_check_api.route("/file/<file_id>", methods=["DELETE"])
@competence_check_api.output(pupil_schema, 200)
@competence_check_api.doc(
    security="ApiKeyAuth",
    tags=["Competence Checks"],
    summary="Delete an image associated to a check of a competence from a given pupil",
)
@token_required
def delete_competence_image(current_user, file_id):
    competence_check_file = CompetenceCheckFile.query.filter_by(file_id=file_id).first()
    check_id = competence_check_file.check_id
    if competence_check_file == None:
        abort(400, "This competence check file does not exist!")

    os.remove(str(competence_check_file.file_url))
    db.session.delete(competence_check_file)
    # - LOG ENTRY
    create_log_entry(current_user, request, {"file": file_id})
    db.session.commit()
    competence_check = CompetenceCheck.query.filter_by(check_id=check_id).first()
    pupil = get_pupil_by_id(competence_check.pupil_id)

    return pupil


# - GET COMPETENCE CHECK IMAGE


@competence_check_api.route("/<file_id>", methods=["GET"])
@competence_check_api.output(FileSchema, content_type="image/jpeg")
@competence_check_api.doc(
    security="ApiKeyAuth",
    tags=["Competence Checks"],
    summary="Get file associated to a check of a competence from a given pupil",
)
@token_required
def download_competence_image(current_user, file_id):
    competence_check_file = CompetenceCheckFile.query.filter_by(file_id=file_id).first()
    if competence_check_file == None:
        abort(400, "This competence check file does not exist!")

    url_path = competence_check_file.file_url

    return send_file(url_path, mimetype="image/jpg")


# - DELETE COMPETENCE CHECK


@competence_check_api.route("/<check_id>", methods=["DELETE"])
@competence_check_api.output(pupil_schema, 200)
@competence_check_api.doc(
    security="ApiKeyAuth",
    tags=["Competence Checks"],
    summary="Delete check of a competence from a given pupil",
)
@token_required
def delete_competence_check(current_user, check_id):
    competence_check = CompetenceCheck.query.filter_by(check_id=check_id).first()
    pupil = get_pupil_by_id(competence_check.pupil_id)
    if not competence_check:
        abort(400, "Diese Kompetenz Check existiert nicht!")

    if competence_check.competence_check_files != []:
        for check_file in competence_check.competence_check_files:
            os.remove(str(check_file.file_url))
            db.session.delete(check_file)
    db.session.delete(competence_check)
    # - LOG ENTRY
    create_log_entry(current_user, request, {"data": "none"})
    db.session.commit()

    return pupil
