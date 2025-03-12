# pylint: disable=missing-module-docstring
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
from schemas.authorization_schemas import (
    authorization_in_group_schema,
    authorization_in_schema,
    authorization_schema,
    authorizations_flat_schema,
    authorizations_schema,
)
from schemas.pupil_schemas import pupils_schema

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
def add_authorization_all(current_user: User, json_data: dict):
    """
    Create a new authorization and pupil authorizations for all pupils in the database.

    Args:
        current_user (User): The current authenticated user.
        json_data (dict): The JSON data from the request body.

    Returns:
        List[Pupil]: A list of all pupils with the new authorization.
    """
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

    all_pupils: List[Pupil] = Pupil.query.all()
    new_pupil_authorizations: List[PupilAuthorization] = []
    for pupil in all_pupils:
        new_pupil_authorizations.append(
            PupilAuthorization(
                status=None,
                comment=None,
                created_by=None,
                file_url=None,
                file_id=None,
                origin_authorization=authorization_id,
                pupil_id=pupil.internal_id,
            )
        )

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
def new_authorization_with_group(current_user: User, json_data: dict):
    """ "
    Create a new authorization and pupil authorizations for a group of pupils.

    Args:
        current_user (User): The current authenticated user.
        json_data (dict): The JSON data from the request body.

    Returns:
        Authorization: The new authorization.
    """

    authorization_name: str = json_data["authorization_name"]
    authorization_description: str = json_data["authorization_description"]
    existing_authorization = get_authorization_by_name(authorization_name)
    if existing_authorization:
        abort(400, "Diese Einwilligung existiert schon!")

    authorization_id = str(uuid.uuid4().hex)

    created_by: str = current_user.name

    new_authorization = Authorization(
        authorization_id, authorization_name, authorization_description, created_by
    )
    db.session.add(new_authorization)

    pupil_id_list: List[int] = json_data["pupils"]

    def create_pupil_authorization(pupil_id: int) -> Optional[PupilAuthorization]:
        pupil = get_pupil_by_id(pupil_id)
        if pupil is not None:
            return PupilAuthorization(
                origin_authorization=authorization_id,
                pupil_id=pupil_id,
                status=None,
                comment=None,
                created_by=None,
                file_url=None,
                file_id=None,
            )
        return None

    new_pupil_authorizations = [
        pupil_auth
        for pupil_id in pupil_id_list
        if (pupil_auth := create_pupil_authorization(pupil_id)) is not None
    ]

    db.session.bulk_save_objects(new_pupil_authorizations)

    # -We have to create the list to populate it with pupils.
    # -This is why it is created even if pupils are wrong and the list remains empty.

    # pupils: List[Pupil] = []

    # for pupil_id in pupil_id_list:
    #     pupil = get_pupil_by_id("")
    #     if pupil is not None:
    #         pupils.append(pupil)
    #         origin_authorization = authorization_id
    #         status = None
    #         comment = None
    #         created_by = None
    #         new_pupil_authorization = PupilAuthorization(
    #             origin_authorization=origin_authorization,
    #             pupil_id=pupil_id,
    #             status=status,
    #             comment=comment,
    #             created_by=created_by,
    #             file_url=None,
    #             file_id=None,
    #         )
    #         db.session.add(new_pupil_authorization)
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
def get_authorizations():
    """
    Get all authorizations with authorized pupils.

    Args:
        current_user (User): The current authenticated user.

    Returns:
        List[Authorization]: A list of all authorizations.
    """

    all_authorizations = Authorization.query.all()

    return all_authorizations


# - GET AUTHORIZATION BY ID


@authorization_api.route("/<auth_id>", methods=["GET"])
@authorization_api.output(authorization_schema)
@authorization_api.doc(
    security="ApiKeyAuth", tags=["Authorizations"], summary="Get an authorization by ID"
)
@token_required
def get_authorization(auth_id: str):
    """
    Get an authorization by ID.

    Args:
        auth_id (str): The authorization ID.

    Returns:
        Authorization: The authorization.
    """

    authorization = get_authorization_by_id(auth_id)

    if authorization is None:
        abort(404, "This authorization does not exist!")

    return authorization


# - GET ALL AUTHORIZATIONS FLAT


@authorization_api.route("/all/flat", methods=["GET"])
@authorization_api.output(authorizations_flat_schema)
@authorization_api.doc(
    security="ApiKeyAuth", tags=["Authorizations"], summary="Get all authorizations"
)
@token_required
def get_authorizations_flat():
    """
    Get all authorizations without nested objects.

    Args:
        current_user (User): The current authenticated user.

    Returns:
        List[Authorization]: A list of all authorizations.
    """

    all_authorizations = Authorization.query.all()

    return all_authorizations


# -DELETE AUTHORIZATION


@authorization_api.route("/<auth_id>", methods=["DELETE"])
@authorization_api.doc(
    security="ApiKeyAuth", tags=["Authorizations"], summary="Delete an authorization"
)
@token_required
def delete_authorization(current_user: User, auth_id: str):
    """
    Delete an authorization.

    Args:
        current_user (User): The current authenticated user.
        auth_id (str): The authorization ID.

    Returns:
        dict: A message that the authorization was deleted.
    """

    authorization = get_authorization_by_id(auth_id)
    if authorization is None:
        abort(404, "This authorization does not exist!")

    if not current_user.admin or current_user.name != authorization.created_by:
        abort(403, "Keine Berechtigung!")

    db.session.delete(authorization)
    # - Log entry
    create_log_entry(current_user, request, {"data": "none"})
    db.session.commit()
    return jsonify({"message": "The authorization was deleted!"}), 200


# - PATCH AUTHORIZATION


@authorization_api.route("/<auth_id>", methods=["PATCH"])
@authorization_api.input(authorization_in_schema)
@authorization_api.output(authorization_schema)
@authorization_api.doc(
    security="ApiKeyAuth", tags=["Authorizations"], summary="Patch an authorization"
)
@token_required
def patch_authorization(current_user: User, auth_id: str, json_data: dict):
    """
    Patch an authorization.

    Args:
        current_user (User): The current authenticated user.
        auth_id (str): The authorization ID.
        json_data (dict): The JSON data from the request body.

    Returns:
        Authorization: The patched authorization

    """

    existing_authorization = get_authorization_by_id(auth_id)
    if existing_authorization is None:
        abort(404, "Diese Einwilligung existiert nicht!")

    if not current_user.admin or current_user.name != existing_authorization.created_by:
        abort(403, "Keine Berechtigung!")

    authorization_name: str = json_data["authorization_name"]
    authorization_description: str = json_data["authorization_description"]
    existing_authorization.authorization_name = authorization_name
    existing_authorization.authorization_description = authorization_description

    # - Log entry
    create_log_entry(current_user, request, json_data)
    db.session.commit()

    return existing_authorization
