import os
from datetime import datetime

from apiflask import APIBlueprint, abort
from flask import jsonify, request

from auth_middleware import token_required
from helpers.db_helpers import date_string_to_date, get_schoolday_by_day
from helpers.log_entries import create_log_entry
from models.schoolday import *
from models.shared import db
from schemas.schoolday_schemas import *

schoolday_api = APIBlueprint("schooldays_api", __name__, url_prefix="/api/schoolday")

# - POST SCHOOLDAY


@schoolday_api.route("/new", methods=["POST"])
@schoolday_api.input(schoolday_only_schema)
@schoolday_api.output(schoolday_only_schema)
@schoolday_api.doc(
    security="ApiKeyAuth", tags=["Schooldays"], summary="Post a schoolday"
)
@token_required
def add_schoolday(current_user, json_data):
    schoolday = json_data["schoolday"]
    date_as_datetime = date_string_to_date(schoolday)
    exists = get_schoolday_by_day(date_as_datetime) is not None
    if exists == True:
        abort(400, "Dieser Schultag existiert schon!")
    else:
        new_schoolday = Schoolday(date_as_datetime)
        db.session.add(new_schoolday)
        # - LOG ENTRY
        create_log_entry(current_user, request, json_data)
        db.session.commit()

        return new_schoolday


# - POST SCHOOLDAYS


@schoolday_api.route("/new/list", methods=["POST"])
@schoolday_api.input(schooldays_list_schema)
@schoolday_api.output(schooldays_only_schema)
@schoolday_api.doc(
    security="ApiKeyAuth", tags=["Schooldays"], summary="Post multiple schooldays"
)
@token_required
def add_schooldays(current_user, json_data):
    schooldays = json_data["schooldays"]
    new_schooldays = []
    for schoolday in schooldays:
        date_as_datetime = date_string_to_date(schoolday)
        exists = get_schoolday_by_day(date_as_datetime) is not None
        if exists == True:
            abort(400, "Dieser Schultag existiert schon!")
        else:
            new_schoolday = Schoolday(date_as_datetime)
            db.session.add(new_schoolday)
            new_schooldays.append(new_schoolday)
    # - LOG ENTRY
    create_log_entry(current_user, request, json_data)
    db.session.commit()

    return new_schooldays


# - GET ALL SCHOOLDAYS


@schoolday_api.route("/all", methods=["GET"])
@schoolday_api.output(schooldays_schema)
@schoolday_api.doc(
    security="ApiKeyAuth", tags=["Schooldays"], summary="Get all schooldays"
)
@token_required
def get_schooldays(current_user):
    if not current_user:
        abort(404, "Bitte erneut einloggen!")
    all_schooldays = db.session.query(Schoolday).all()
    if all_schooldays == []:
        abort(404, "No schooldays found!")

    return all_schooldays


# - GET ALL SCHOOLDAYS FLAT


@schoolday_api.route("/all/flat", methods=["GET"])
@schoolday_api.output(schooldays_only_schema)
@schoolday_api.doc(
    security="ApiKeyAuth",
    tags=["Schooldays"],
    summary="Get a list of schooldays without nesting",
)
@token_required
def get_schooldays_only(current_user):
    if not current_user:
        abort(404, "Bitte erneut einloggen!")
    all_schooldays = db.session.query(Schoolday).all()
    if all_schooldays == []:
        abort(404, "No schooldays found!")

    return all_schooldays


# - GET ONE SCHOOLDAY WITH CHILDREN


@schoolday_api.route("/<date>", methods=["GET"])
@schoolday_api.output(schoolday_schema)
@schoolday_api.doc(
    security="ApiKeyAuth",
    tags=["Schooldays"],
    summary="Get a schoolday with nested elements",
)
@token_required
def get_schooday(current_user, date):

    date_as_datetime = date_string_to_date(date)
    this_schoolday = get_schoolday_by_day(date_as_datetime)

    if this_schoolday == None:
        abort(404, "Dieser Schultag existiert nicht!")

    return this_schoolday


# - DELETE ONE SCHOOLDAY


@schoolday_api.route("/<date>", methods=["DELETE"])
@schoolday_api.doc(
    security="ApiKeyAuth",
    tags=["Schooldays"],
    summary="Delete a schoolday with nested elements",
)
@token_required
def delete_schoolday(current_user, date):
    if not current_user.admin:
        abort(401, "Keine Berechtigung!")

    this_schoolday = get_schoolday_by_day(date)
    if this_schoolday == None:
        abort(404, "Dieser Schultag existiert nicht!")

    # - avoid orphaned files when cascading delete of associated schoolday_events
    for schoolday_event in this_schoolday.schoolday_events:
        if schoolday_event.file_url != None:
            os.remove(schoolday_event.file_url)
        if schoolday_event.processed_image_url != None:
            os.remove(schoolday_event.processed_image_url)

    db.session.delete(this_schoolday)
    # - LOG ENTRY
    create_log_entry(current_user, request, {"data": "none"})
    db.session.commit()
    return jsonify({"message": "The schoolday was deleted!"}), 200


# - DELETE LIST OF SCHOOLDAYS


@schoolday_api.route("/delete/list", methods=["DELETE"])
@schoolday_api.input(schooldays_only_schema)
@schoolday_api.doc(
    security="ApiKeyAuth", tags=["Schooldays"], summary="Delete multiple Schooldays"
)
@token_required
def delete_schooldays(current_user, json_data):
    if not current_user.admin:
        return jsonify({"message": "Not authorized!"}), 401
    schooldays = json_data["schooldays"]
    for schoolday in schooldays:
        date_as_datetime = date_string_to_date(schoolday)
        this_schoolday = get_schoolday_by_day(date_as_datetime)
        if this_schoolday == None:
            continue
        # - avoid orphaned files when cascading delete of associated schoolday_events
        for schoolday_event in this_schoolday.schoolday_events:
            if schoolday_event.file_url != None:
                os.remove(schoolday_event.file_url)
            if schoolday_event.processed_image_url != None:
                os.remove(schoolday_event.processed_image_url)
        db.session.delete(this_schoolday)
    # - LOG ENTRY
    create_log_entry(current_user, request, json_data)
    db.session.commit()
    return jsonify({"message": "The schooldays were deleted!"}), 200
