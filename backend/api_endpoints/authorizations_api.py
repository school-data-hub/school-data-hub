import uuid
from typing import List, Optional

from apiflask import APIBlueprint, abort
from flask import jsonify, request

from auth_middleware import token_required
from helpers.db_helpers import (
    get_authorization_by_id,
    get_authorization_by_name,
    get_pupil_by_id,
)
from helpers.log_entries import create_log_entry
from models.authorization import Authorization, PupilAuthorization
from models.pupil import Pupil
from models.shared import db
from models.user import User
from schemas.authorization_schemas import *
from schemas.pupil_schemas import *

authorization_api = APIBlueprint(
    "authorizations_api", __name__, url_prefix="/api/authorizations"
)

# - POST AUTHORIZATION WITH ALL PUPILS


@authorization_api.route("/new/all", methods=["POST"])
@authorization_api.input(authorization_in_schema)
@authorization_api.output(pupils_schema)
@authorization_api.doc(
    security="ApiKeyAuth",
    tags=["Authorizations"],
    summary="Post an authorization including ALL pupils in the database",
)
@token_required
def add_authorization_all(current_user: User, json_data):
    authorization_id = str(uuid.uuid4().hex)
    authorization_name = json_data["authorization_name"]
    authorization_description = json_data["authorization_description"]
    existing_authorization = get_authorization_by_id(authorization_id)
    if existing_authorization:
        abort(400, "Diese Einwilligung existiert schon!")

    user_name = current_user.name
    new_authorization = Authorization(
        authorization_id, authorization_name, authorization_description, user_name
    )
    db.session.add(new_authorization)
    db.session.flush()

    all_pupils = Pupil.query.all()
    new_pupil_authorizations = [
        PupilAuthorization(
            status=None,
            comment=None,
            created_by=None,
            file_url=None,
            origin_authorization=authorization_id,
            pupil_id=pupil.internal_id,
        )
        for pupil in all_pupils
    ]
    db.session.bulk_save_objects(new_pupil_authorizations)
    # - Log entry
    create_log_entry(current_user, request, json_data)

    db.session.commit()
    return all_pupils


# - POST AUTHORIZATION WITH LIST OF PUPILS


@authorization_api.route("/new/list", methods=["POST"])
@authorization_api.input(authorization_in_group_schema)
@authorization_api.output(authorization_schema)
@authorization_api.doc(
    security="ApiKeyAuth",
    tags=["Authorizations"],
    summary="Post an authorization including pupils from an array",
)
@token_required
def add_authorization_group(current_user, json_data):
    data = json_data
    authorization_name = data["authorization_name"]
    authorization_description = data["authorization_description"]
    existing_authorization = get_authorization_by_name(authorization_name)
    if existing_authorization:
        abort(400, "Diese Einwilligung existiert schon!")

    authorization_id = str(uuid.uuid4().hex)

    new_authorization = Authorization(
        authorization_id, authorization_name, authorization_description, created_by
    )
    db.session.add(new_authorization)
    pupil_id_list = data["pupils"]
    # -We have to create the list to populate it with pupils.
    # -This is why it is created even if pupils are wrong and the list remains empty.
    pupils = []
    for pupil_id in pupil_id_list:
        pupil = get_pupil_by_id(pupil_id)
        if pupil is not None:
            pupils.append(pupil)
            origin_authorization = authorization_id
            status = None
            comment = None
            created_by = None
            new_pupil_authorization = PupilAuthorization(
                origin_authorization=origin_authorization,
                pupil_id=pupil_id,
                status=status,
                comment=comment,
                created_by=created_by,
                file_url=None,
                file_id=None,
            )
            db.session.add(new_pupil_authorization)
    # - Log entry
    create_log_entry(current_user, request, json_data)
    db.session.commit()

    return new_authorization


# - GET ALL AUTHORIZATIONS


@authorization_api.route("/all", methods=["GET"])
@authorization_api.output(authorizations_schema)
@authorization_api.doc(
    security="ApiKeyAuth",
    tags=["Authorizations"],
    summary="Get all authorizations with authorized pupils",
)
@token_required
def get_authorizations(current_user):
    all_authorizations = Authorization.query.all()
    if all_authorizations == []:
        abort(404, "There are no authorizations!")
    return all_authorizations


# - GET AUTHORIZATION BY ID


@authorization_api.route("/<auth_id>", methods=["GET"])
@authorization_api.output(authorization_schema)
@authorization_api.doc(
    security="ApiKeyAuth", tags=["Authorizations"], summary="Get an authorization by ID"
)
@token_required
def get_authorization(current_user, auth_id):
    authorization = get_authorization_by_id(auth_id)
    if authorization == None:
        abort(404, "This authorization does not exist!")

    return authorization


# - GET ALL AUTHORIZATIONS FLAT


@authorization_api.route("/all/flat", methods=["GET"])
@authorization_api.output(authorizations_flat_schema)
@authorization_api.doc(
    security="ApiKeyAuth", tags=["Authorizations"], summary="Get all authorizations"
)
@token_required
def get_authorizations_flat(current_user):
    all_authorizations = Authorization.query.all()
    if all_authorizations == []:
        abort(404, "There are no authorizations!")

    return all_authorizations


# -DELETE AUTHORIZATION


@authorization_api.route("/<auth_id>", methods=["DELETE"])
@authorization_api.doc(
    security="ApiKeyAuth", tags=["Authorizations"], summary="Delete an authorization"
)
@token_required
def delete_authorization(current_user, auth_id):
    if not current_user.admin:
        abort(401, "Keine Berechtigung!")

    authorization = get_authorization_by_id(auth_id)
    if authorization == None:
        abort(404, "This authorization does not exist!")

    db.session.delete(authorization)
    # - Log entry
    create_log_entry(current_user, request, {"data": "none"})
    db.session.commit()

    abort(200, "The authorization was deleted!")


# - PATCH AUTHORIZATION


@authorization_api.route("/<auth_id>", methods=["PATCH"])
@authorization_api.input(authorization_in_schema)
@authorization_api.output(authorization_schema)
@authorization_api.doc(
    security="ApiKeyAuth", tags=["Authorizations"], summary="Patch an authorization"
)
@token_required
def patch_authorization(current_user, auth_id, json_data):
    if not current_user.admin:
        abort(401, "Keine Berechtigung!")

    data = json_data
    existing_authorization = get_authorization_by_id(auth_id)
    if existing_authorization is None:
        abort(404, "Diese Einwilligung existiert nicht!")

    authorization_name = data["authorization_name"]
    authorization_description = data["authorization_description"]
    existing_authorization.authorization_name = authorization_name
    existing_authorization.authorization_description = authorization_description

    # - Log entry
    create_log_entry(current_user, request, json_data)
    db.session.commit()

    return existing_authorization
