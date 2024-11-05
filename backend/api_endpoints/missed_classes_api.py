from datetime import datetime

from apiflask import APIBlueprint, abort
from flask import jsonify, request

from auth_middleware import token_required
from helpers.db_helpers import (
    get_missed_class_by_pupil_and_schoolday,
    get_pupil_by_id,
    get_schoolday_by_day,
)
from helpers.log_entries import create_log_entry
from models.pupil import Pupil
from models.schoolday import MissedClass, Schoolday
from models.shared import db
from schemas.missed_class_schemas import *
from schemas.pupil_schemas import *

missed_class_api = APIBlueprint(
    "missed_class_api", __name__, url_prefix="/api/missed_classes"
)


# - POST MISSED CLASS
#####################
@missed_class_api.route("/new", methods=["POST"])
@missed_class_api.input(
    missed_class_in_schema,
    example={
        "contacted": None,
        "excused": False,
        "minutes_late": None,
        "missed_day": "2023-11-20",
        "missed_pupil_id": 1234,
        "missed_type": "missed",
        "returned": None,
        "returned_at": None,
        "written_excuse": None,
        "comment": None,
    },
)
@missed_class_api.output(pupil_schema)
@missed_class_api.doc(
    security="ApiKeyAuth", tags=["Missed Classes"], summary="Post a missed class"
)
@token_required
def add_missed_class(current_user, json_data):
    data = json_data
    this_missed_pupil_id = data["missed_pupil_id"]
    missed_pupil = get_pupil_by_id(this_missed_pupil_id)
    if missed_pupil == None:
        abort(404, "Schüler/Schülerin nicht im System!")
    missed_day = data["missed_day"]

    this_schoolday = (
        db.session.query(Schoolday).filter(Schoolday.schoolday == missed_day).first()
    )
    if this_schoolday == None:
        abort(404, "Dieser Schultag existiert nicht!")

    this_missed_day_id = this_schoolday.schoolday
    existing_missed_class = get_missed_class_by_pupil_and_schoolday(
        this_missed_pupil_id, this_missed_day_id
    )
    if existing_missed_class != None:
        abort(403, "This missed class exists already - please update instead!")

    missed_type = data["missed_type"]
    excused = data["excused"]
    contacted = data["contacted"]
    returned = data["returned"]
    returned_at = data["returned_at"]
    minutes_late = data["minutes_late"]
    written_excuse = data["written_excuse"]
    created_by = current_user.name
    modified_by = None
    comment = None
    new_missed_class = MissedClass(
        this_missed_pupil_id,
        this_missed_day_id,
        missed_type,
        excused,
        contacted,
        returned,
        written_excuse,
        minutes_late,
        returned_at,
        created_by,
        modified_by,
        comment,
    )
    db.session.add(new_missed_class)
    # - LOG ENTRY
    create_log_entry(current_user, request, json_data)
    db.session.commit()
    return missed_pupil


# - POST LIST OF MISSED CLASSES
##############################
@missed_class_api.route("/list", methods=["POST"])
@missed_class_api.input(
    missed_classes_in_schema,
    example=[
        {
            "contacted": None,
            "excused": False,
            "minutes_late": None,
            "missed_day": "2023-11-20",
            "missed_pupil_id": 1234,
            "missed_type": "missed",
            "returned": None,
            "returned_at": None,
            "written_excuse": None,
            "comment": None,
        },
        {
            "contacted": None,
            "excused": False,
            "minutes_late": None,
            "missed_day": "2023-11-21",
            "missed_pupil_id": 1234,
            "missed_type": "missed",
            "returned": None,
            "returned_at": None,
            "written_excuse": None,
            "comment": None,
        },
    ],
)
@missed_class_api.output(pupil_schema, 200)
@missed_class_api.doc(
    security="ApiKeyAuth",
    tags=["Missed Classes"],
    summary="Post a list of missed classes",
)
@token_required
def add_missed_class_list(current_user, json_data):
    missed_class_list = json_data
    commited_missed_classes = []
    for entry in missed_class_list:
        missed_pupil_id = entry["missed_pupil_id"]
        missed_pupil = get_pupil_by_id(missed_pupil_id)
        if missed_pupil == None:
            abort(404, "Schüler/Schülerin nicht im System!")
        missed_day = entry["missed_day"]
        missed_schoolday = (
            db.session.query(Schoolday)
            .filter(Schoolday.schoolday == missed_day)
            .first()
        )

        if missed_schoolday == None:
            abort(404, "Dieser Schultag existiert nicht!")

        missed_class = get_missed_class_by_pupil_and_schoolday(
            missed_pupil_id, missed_schoolday.schoolday
        )
        if missed_class != None:
            for key in entry:
                match key:
                    case "missed_type":
                        missed_class.missed_type = entry[key]
                    case "excused":
                        missed_class.excused = entry[key]
                    case "contacted":
                        missed_class.contacted = entry[key]
                    case "returned":
                        missed_class.returned = entry[key]
                    case "written_excuse":
                        missed_class.written_excuse = entry[key]
                    case "minutes_late":
                        missed_class.minutes_late = entry[key]
                    case "returned_at":
                        missed_class.returned_at = entry[key]
                    case "modified_by":
                        missed_class.modified_by = entry[key]
                    case "comment":
                        missed_class.comment = entry[key]

            commited_missed_classes.append(missed_class)
        else:
            missed_type = entry["missed_type"]
            excused = entry["excused"]
            contacted = entry["contacted"]
            returned = False
            returned_at = None
            minutes_late = None
            written_excuse = None
            created_by = current_user.name
            modified_by = None
            comment = None
            new_missed_class = MissedClass(
                missed_pupil_id,
                missed_schoolday,
                missed_type,
                excused,
                contacted,
                returned,
                written_excuse,
                minutes_late,
                returned_at,
                created_by,
                modified_by,
                comment,
            )
            db.session.add(new_missed_class)
            commited_missed_classes.append(new_missed_class)
    # - LOG ENTRY
    create_log_entry(current_user, request, json_data)
    db.session.commit()

    return missed_pupil


# - GET ALL MISSED CLASSES
#########################
@missed_class_api.route("/all", methods=["GET"])
@missed_class_api.output(missed_classes_schema, 200)
@missed_class_api.doc(
    security="ApiKeyAuth", tags=["Missed Classes"], summary="Get all missed classes"
)
@token_required
def get_missed_classes(current_user):
    all_missed_classes = MissedClass.query.all()
    if all_missed_classes == []:
        abort(404, "There are no missed classes!")
    return all_missed_classes


# - GET MISSED CLASSES ON A SCHOOL DAY
#####################################
@missed_class_api.route("/schoolday/<date>", methods=["GET"])
@missed_class_api.output(missed_classes_schema, 200)
@missed_class_api.doc(
    security="ApiKeyAuth",
    tags=["Missed Classes"],
    summary="Get missed classes on a school day",
)
@token_required
def get_missed_classes_on_schoolday(current_user, date):
    this_schoolday = get_schoolday_by_day(date)
    if this_schoolday == None:
        abort(404, "This school day does not exist!")
    all_missed_classes = (
        db.session.query(MissedClass)
        .filter(MissedClass.missed_day_id == this_schoolday.schoolday)
        .all()
    )
    if all_missed_classes == []:
        abort(404, "There are no missed classes on this school day!")
    return all_missed_classes


# - GET ONE MISSED CLASS
#######################
@missed_class_api.route("/<missed_class_id>", methods=["GET"])
@missed_class_api.doc(
    security="ApiKeyAuth",
    tags=["Missed Classes"],
    summary="Get ONE missed class by id",
    deprecated=True,
)
@token_required
def get_missed_class(current_user, missed_class_id):
    this_missed_class = db.session.query(MissedClass).get(missed_class_id)
    if this_missed_class == None:
        abort(404, "This missed class does not exist!")

    return missed_class_schema.jsonify(this_missed_class)


# - PATCH MISSED CLASS
#####################
@missed_class_api.route("/<pupil_id>/<date>", methods=["PATCH"])
@missed_class_api.input(missed_class_in_schema)
@missed_class_api.output(pupil_schema, 200)
@missed_class_api.doc(
    security="ApiKeyAuth",
    tags=["Missed Classes"],
    summary="Patch a missed class by pupil_id and date",
)
@token_required
def update_missed_class(current_user, pupil_id, date, json_data):
    missed_pupil = db.session.query(Pupil).filter(Pupil.internal_id == pupil_id).first()
    missed_schoolday = get_schoolday_by_day(date)
    if missed_schoolday == None:
        abort(401, "This schoolday does not exist!")

    missed_class = (
        db.session.query(MissedClass)
        .filter(
            MissedClass.missed_day_id == missed_schoolday.schoolday,
            MissedClass.missed_pupil_id == pupil_id,
        )
        .first()
    )
    if missed_class == None:
        abort(401, "This missed class does not exist!")

    data = json_data
    for key in data:
        match key:
            case "missed_type":
                missed_class.missed_type = data[key]
                print("sent value: " + data[key])
            case "excused":
                missed_class.excused = data[key]
                print("sent value: " + str(data[key]))
            case "contacted":
                missed_class.contacted = data[key]
            case "returned":
                missed_class.returned = data[key]
                print("sent return value: " + str(data[key]))
            case "written_excuse":
                missed_class.written_excuse = data[key]
            case "minutes_late":
                missed_class.minutes_late = data[key]
            case "returned_at":
                returned_time = data[key]
                missed_class.returned_at = returned_time
            case "modified_by":
                missed_class.modified_by = data[key]
            case "comment":
                missed_class.comment = data[key]
    # - LOG ENTRY
    create_log_entry(current_user, request, json_data)
    db.session.commit()
    return missed_pupil


# - DELETE MISSED CLASS
######################


@missed_class_api.route("/<pupil_id>/<date>", methods=["DELETE"])
@missed_class_api.output(pupil_schema, 200)
@missed_class_api.doc(
    security="ApiKeyAuth",
    tags=["Missed Classes"],
    summary="Delete a missed class by pupil_id and date",
)
@token_required
def delete_missed_class_with_date(current_user, pupil_id, date):
    missed_pupil = get_pupil_by_id(pupil_id)

    if missed_pupil == None:
        abort(404, "Schüler/Schülerin nicht im System!")

    schoolday = get_schoolday_by_day(date)

    if schoolday == None:
        abort(404, "Dieser Schultag existiert nicht!")

    missed_day_id = schoolday.schoolday
    missed_class = (
        db.session.query(MissedClass)
        .filter(
            MissedClass.missed_day_id == missed_day_id,
            MissedClass.missed_pupil_id == pupil_id,
        )
        .first()
    )
    if missed_class == None:
        abort(401, "Diese Fehlzeit existiert nicht!")
    db.session.delete(missed_class)
    # - LOG ENTRY
    create_log_entry(current_user, request, {"data": "none"})
    db.session.commit()
    return missed_pupil
