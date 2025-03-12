# pylint: disable=missing-module-docstring
# pylint: disable=missing-class-docstring
# pylint: disable=missing-function-docstring
import os
import uuid
from datetime import datetime
from typing import List

from apiflask import APIBlueprint, FileSchema, abort
from flask import current_app, request, send_file
from werkzeug.datastructures import FileStorage

from auth_middleware import token_required
from helpers.db_helpers import (
    get_authorization_by_id,
    get_pupil_authorization,
    get_pupil_by_id,
)
from models.authorization import PupilAuthorization
from models.log_entry import LogEntry
from models.shared import db
from models.user import User
from schemas.authorization_schemas import (
    authorization_schema,
    pupil_authorization_in_schema,
)
from schemas.log_entry_schemas import ApiFileSchema
from schemas.pupil_schemas import pupil_id_list_schema

pupil_authorization_api = APIBlueprint(
    "pupil_authorizations", __name__, url_prefix="/api/pupil_authorizations"
)


# -POST PUPIL AUTHORIZATION
#############################
@pupil_authorization_api.route("/<pupil_id>/<auth_id>/new", methods=["POST"])
@pupil_authorization_api.output(authorization_schema)
@pupil_authorization_api.doc(
    security="ApiKeyAuth",
    tags=["Pupil Authorizations"],
    summary="Post authorization for a given pupil and a given authorization",
)
@token_required
def post_pupil_authorization(pupil_id: int, auth_id: str):
    """
    Post a new pupil authorization for a given pupil and a given authorization.

    """

    pupil = get_pupil_by_id(pupil_id)
    if pupil is None:
        abort(400, message="This pupil does not exist!")

    origin_authorization = get_authorization_by_id(auth_id)
    if origin_authorization is None:
        abort(400, message="This authorization does not exist!")

    duplicate = get_pupil_authorization(pupil_id, auth_id)

    if duplicate is not None:
        abort(400, message="This pupil authorization already exists!")

    # - TO DO: check this HACKY FIX - this should be a nullable modified_by
    created_by = ""
    pupil_authorization = PupilAuthorization(
        status=None,
        comment=None,
        created_by=created_by,
        file_id=None,
        file_url=None,
        origin_authorization=auth_id,
        pupil_id=pupil_id,
    )
    db.session.add(pupil_authorization)
    db.session.commit()
    return origin_authorization


# - POST PUPIL AUTHORIZATIONS FROM LIST OF PUPILS
################################################
@pupil_authorization_api.route("/<auth_id>/list", methods=["POST"])
@pupil_authorization_api.input(pupil_id_list_schema)
@pupil_authorization_api.output(authorization_schema)
@pupil_authorization_api.doc(
    security="ApiKeyAuth",
    tags=["Pupil Authorizations"],
    summary="Add pupils to an existing authorization",
)
@token_required
def add_pupils_to_authorization(auth_id: str, json_data: dict):
    """
    Add pupils to an existing authorization.
    """
    existing_authorization = get_authorization_by_id(auth_id)

    if existing_authorization is None:
        abort(404, message="Diese Einwilligung existiert nicht!")

    pupil_id_list: List[int] = json_data["pupils"]

    if pupil_id_list == []:
        abort(404, message="Keine Schueler angegeben!")

    added_pupils = []

    for pupil_id in pupil_id_list:
        pupil = get_pupil_by_id(pupil_id)

        if pupil is None:
            abort(404, message="Dieser Schueler existiert nicht!")

        duplicate = get_pupil_authorization(pupil_id, auth_id)

        if duplicate is not None:
            abort(400, message="This pupil authorization already exists!")

        origin_authorization = get_authorization_by_id(auth_id)

        status = None

        comment = None

        # - HACKY FIX - this should be a nullable modified_by
        # - this created_by is not relevant, the first entry later on is
        created_by = ""
        new_pupil_authorization = PupilAuthorization(
            origin_authorization=auth_id,
            pupil_id=pupil_id,
            status=status,
            comment=comment,
            created_by=created_by,
            file_url=None,
            file_id=None,
        )
        db.session.add(new_pupil_authorization)
        added_pupils.append(pupil)
    db.session.commit()
    return origin_authorization


# - DELETE PUPIL AUTHORIZATION
#############################
@pupil_authorization_api.route("/<pupil_id>/<auth_id>", methods=["DELETE"])
@pupil_authorization_api.output(authorization_schema)
@pupil_authorization_api.doc(
    security="ApiKeyAuth",
    tags=["Pupil Authorizations"],
    summary="Delete a given authorization for a given pupil",
)
@token_required
def delete_pupil_authorization(pupil_id: int, auth_id: str):
    """
    Delete a given authorization for a given pupil.
    """
    pupil = get_pupil_by_id(pupil_id)
    if pupil is None:
        abort(400, message="This pupil does not exist!")

    authorization = get_pupil_authorization(pupil_id, auth_id)
    if authorization is None:
        abort(400, message="This pupil authorization does not exist!")

    # if there is a linked file, delete it
    if len(str(authorization.file_url)) > 4:
        os.remove(str(authorization.file_url))

    db.session.delete(authorization)
    db.session.commit()

    origin_authorization = get_authorization_by_id(auth_id)

    return origin_authorization


# - PATCH PUPIL AUTHORIZATION
#############################
@pupil_authorization_api.route("/<pupil_id>/<auth_id>", methods=["PATCH"])
@pupil_authorization_api.input(pupil_authorization_in_schema)
@pupil_authorization_api.output(authorization_schema)
@pupil_authorization_api.doc(
    security="ApiKeyAuth",
    tags=["Pupil Authorizations"],
    summary="Patch an authorization for a given pupil",
)
@token_required
def patch_pupil_authorization(
    current_user: User,
    pupil_id: int,
    auth_id: str,
    json_data: dict,
):
    """ "
    Patch an authorization for a given pupil.
    """
    pupil_authorization = get_pupil_authorization(pupil_id, auth_id)

    if pupil_authorization is None:
        abort(404, message="Diese Einwilligung existiert nicht!")

    for key in json_data:
        match key:
            case "comment":
                pupil_authorization.comment = json_data[key]
            case "status":
                pupil_authorization.status = json_data[key]
    # - HACKY FIX - it should be a nullable modified_by
    pupil_authorization.created_by = current_user.name
    db.session.commit()

    origin_authorization = get_authorization_by_id(auth_id)

    return origin_authorization


# - PATCH FILE TO PUPIL AUTHORIZATION
####################################
@pupil_authorization_api.route("/<pupil_id>/<origin_auth_id>/file", methods=["PATCH"])
@pupil_authorization_api.input(ApiFileSchema, location="files")
@pupil_authorization_api.output(authorization_schema)
@pupil_authorization_api.doc(
    security="ApiKeyAuth",
    tags=["Pupil Authorizations"],
    summary="PATCH-POST a file to document a given pupil authorization",
)
@token_required
def upload_pupil_authorization_file(
    current_user: User,
    pupil_id: int,
    origin_auth_id: str,
    files_data: dict,
):
    """
    Patch a file to document a given pupil authorization.
    """
    pupil_authorization = get_pupil_authorization(pupil_id, origin_auth_id)
    origin_authorization = get_authorization_by_id(origin_auth_id)
    if pupil_authorization is None:
        abort(404, message="Diese Einwilligung existiert nicht!")

    if "file" not in files_data:
        # this means the user wants to delete the file
        if len(str(pupil_authorization.file_url)) > 4:
            os.remove(str(pupil_authorization.file_url))

        return origin_authorization

    file: FileStorage = files_data["file"]
    filename = file.filename
    if filename != "":
        file_ext = os.path.splitext(filename)[1]
        if file_ext not in current_app.config["UPLOAD_EXTENSIONS"]:
            abort(400, message="Filetype not allowed!")
    file_id = str(uuid.uuid4().hex)
    filename = file_id + file_ext
    file_url = current_app.config["UPLOAD_FOLDER"] + "/auth/" + filename
    file.save(file_url)

    # - if there is a previous linked file, delete it
    if len(str(pupil_authorization.file_url)) > 4:
        os.remove(str(pupil_authorization.file_url))
    # assign new file to pupil authorization
    pupil_authorization.file_url = file_url
    pupil_authorization.file_id = file_id
    # - HACKY FIX - it should be a nullable modified_by
    pupil_authorization.created_by = current_user.name
    db.session.commit()
    return origin_authorization


# - GET PUPIL AUTHORIZATION FILE
###############################
@pupil_authorization_api.route("/<pupil_id>/<origin_auth_id>/file", methods=["GET"])
@pupil_authorization_api.output(FileSchema, content_type="image/jpeg")
@pupil_authorization_api.doc(
    security="ApiKeyAuth",
    tags=["Pupil Authorizations"],
    summary="Get file of a given pupil authorization",
)
@token_required
def download_pupil_authorization_file(pupil_id: int, origin_auth_id: str):
    """ "
    Get file of a given pupil authorization.
    """
    pupil_authorization = get_pupil_authorization(pupil_id, origin_auth_id)

    if pupil_authorization is None:
        abort(404, message="Diese Einwilligung existiert nicht!")

    if len(str(pupil_authorization.file_url)) < 5:
        abort(404, message="Diese Einwilligung hat keine Datei!")

    url_path = pupil_authorization.file_url
    return send_file(url_path, mimetype="image/jpg")


##- TO-DO: REST OF AUTHORIZATION AND PUPIL AUTHORIZATION ENDPOINTS


# - DELETE PUPIL AUTHORIZATION FILE
@pupil_authorization_api.route("/<pupil_id>/<auth_id>/file", methods=["DELETE"])
@pupil_authorization_api.output(authorization_schema)
@pupil_authorization_api.doc(
    security="ApiKeyAuth",
    tags=["Pupil Authorizations"],
    summary="Delete file of a given pupil authorization",
)
@token_required
def delete_pupil_authorization_file(current_user: User, pupil_id: int, auth_id: str):
    """ "
    Delete file of a given pupil authorization.
    """
    pupil_authorization = get_pupil_authorization(pupil_id, auth_id)

    if pupil_authorization is None:
        abort(404, message="Diese Einwilligung existiert nicht!")
    if len(str(pupil_authorization.file_url)) < 5:
        pupil_authorization.file_url = None
        abort(404, message="Diese Einwilligung hat keine Datei!")
    if len(str(pupil_authorization.file_url)) > 4:
        os.remove(str(pupil_authorization.file_url))
    pupil_authorization.file_url = None
    pupil_authorization.file_id = None
    log_datetime = datetime.strptime(
        datetime.now().strftime("%Y-%m-%d %H:%M:%S"), "%Y-%m-%d %H:%M:%S"
    )
    user = current_user.name
    endpoint = request.method + ": " + request.path
    payload = "none"
    new_log_entry = LogEntry(
        datetime=log_datetime, user=user, endpoint=endpoint, payload=payload
    )
    db.session.add(new_log_entry)
    origin_authorization = get_authorization_by_id(auth_id)
    db.session.commit()
    return origin_authorization
