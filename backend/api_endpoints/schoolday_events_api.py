import os
import uuid
from datetime import datetime

from apiflask import APIBlueprint, FileSchema, abort
from flask import current_app, request, send_file
from sqlalchemy.sql import exists

from auth_middleware import token_required
from helpers.db_helpers import (
    get_pupil_by_id,
    get_schoolday_by_day,
    get_schoolday_event_by_id,
)
from helpers.log_entries import create_log_entry
from models.log_entry import LogEntry
from models.pupil import Pupil
from models.schoolday import Schoolday, SchooldayEvent
from models.shared import db
from schemas.log_entry_schemas import ApiFileSchema
from schemas.pupil_schemas import *
from schemas.schoolday_event_schemas import *
from sse_announcer import announcer, format_sse

schoolday_event_api = APIBlueprint(
    "schoolday_events_api", __name__, url_prefix="/api/schoolday_events"
)


# - POST SCHOOLDAY EVENT
##################
@schoolday_event_api.route("/new", methods=["POST"])
@schoolday_event_api.input(
    schoolday_event_in_schema,
    # example={
    #     "schoolday_event_day": "2023-08-07",
    #     "schoolday_event_pupil_id": 1234,
    #     "schoolday_event_reason": "kodiert",
    #     "schoolday_event_type": "kodiert",
    #     "processed": False,
    #     "processed_at": None,
    #     "processed_by": None,
    # },
)
@schoolday_event_api.output(pupil_schema)
@schoolday_event_api.doc(
    security="ApiKeyAuth", tags=["Schoolday Events"], summary="Post an schoolday event"
)
@token_required
def add_schoolday_event(current_user, json_data):
    created_by = current_user.name
    schoolday_event_pupil_id = json_data["schoolday_event_pupil_id"]
    if get_pupil_by_id(schoolday_event_pupil_id) == None:
        abort(404, "Dieser/diese Schüler:in existiert nicht!")

    schoolday_event_day = json_data["schoolday_event_day"]
    this_schoolday = get_schoolday_by_day(schoolday_event_day)
    if this_schoolday == None:
        abort(404, "Dieser Schultag existiert nicht!")

    schoolday_event_day_id = this_schoolday.schoolday
    schoolday_event_id = str(uuid.uuid4().hex)
    schoolday_event_type = json_data["schoolday_event_type"]
    schoolday_event_reason = json_data["schoolday_event_reason"]
    processed = False
    processed_by = None
    processed_at = None
    file_url = None
    file_id = None
    processed_file_url = None
    processed_file_id = None
    new_schoolday_event = SchooldayEvent(
        schoolday_event_id=schoolday_event_id,
        schoolday_event_pupil_id=schoolday_event_pupil_id,
        schoolday_event_day_id=schoolday_event_day_id,
        schoolday_event_type=schoolday_event_type,
        schoolday_event_reason=schoolday_event_reason,
        created_by=created_by,
        processed=processed,
        processed_by=processed_by,
        processed_at=processed_at,
        file_url=file_url,
        file_id=file_id,
        processed_file_url=processed_file_url,
        processed_file_id=processed_file_id,
    )
    db.session.add(new_schoolday_event)
    create_log_entry(current_user, request, json_data)
    db.session.commit()

    pupil = get_pupil_by_id(schoolday_event_pupil_id)
    msg = format_sse(pupil_schema.dump(pupil), event="new_schoolday_event")
    announcer.announce(msg=msg)
    return pupil


# - GET SCHOOLDAY EVENTS
##################
@schoolday_event_api.route("/all", methods=["GET"])
@schoolday_event_api.output(schoolday_events_schema)
@schoolday_event_api.doc(
    security="ApiKeyAuth", tags=["Schoolday Events"], summary="Get all schoolday events"
)
@token_required
def get_schoolday_events(current_user):
    all_schoolday_events = SchooldayEvent.query.all()

    return all_schoolday_events


# - GET ONE SCHOOLDAY EVENT
#####################
@schoolday_event_api.route("/<schoolday_event_id>", methods=["GET"])
@schoolday_event_api.output(schoolday_event_schema)
@schoolday_event_api.doc(
    security="ApiKeyAuth",
    tags=["Schoolday Events"],
    summary="Get schoolday event by id",
)
@token_required
def get_schoolday_event(current_user, schoolday_event_id):
    this_schoolday_event = get_schoolday_event_by_id(schoolday_event_id)
    if this_schoolday_event == None:
        abort(404, "Dieses Ereignis existiert nicht!")

    return this_schoolday_event


# - PATCH SCHOOLDAY EVENT
###################
@schoolday_event_api.route("/<schoolday_event_id>/patch", methods=["PATCH"])
@schoolday_event_api.input(schoolday_event_patch_schema)
@schoolday_event_api.output(pupil_schema)
@schoolday_event_api.doc(
    security="ApiKeyAuth", tags=["Schoolday Events"], summary="Patch an schoolday event"
)
@token_required
def patch_schoolday_event(current_user, schoolday_event_id, json_data):
    schoolday_event = get_schoolday_event_by_id(schoolday_event_id)
    if schoolday_event is None:
        abort(404, "A schoolday event with this date and this student does not exist!")

    data = json_data
    for key in data:
        match key:
            case "schoolday_event_type":
                schoolday_event.schoolday_event_type = data[key]
            case "schoolday_event_reason":
                schoolday_event.schoolday_event_reason = data[key]
            case "processed":
                schoolday_event.processed = data[key]
            case "processed_by":
                schoolday_event.processed_by = data[key]
            case "processed_at":
                schoolday_event.processed_at = data[key]
            case "created_by":
                schoolday_event.created_by = data[key]
            case "schoolday_event_day":
                schoolday_event_day = json_data["schoolday_event_day"]
                this_schoolday = get_schoolday_by_day(schoolday_event_day)
                if this_schoolday == None:
                    abort(404, "Dieser Schultag existiert nicht!")

                schoolday_event.schoolday_event_day_id = this_schoolday.schoolday
            # - we handle the file upload separately
            # case 'file_url':
            #     schoolday_event.file_url = data[key]
            # case 'processed_file_url':
            #     schoolday_event.processed_file_url = data[key]

    # - LOG ENTRY
    create_log_entry(current_user, request, json_data)
    db.session.commit()
    pupil = get_pupil_by_id(schoolday_event.schoolday_event_pupil_id)
    return pupil


# - PATCH SCHOOLDAY EVENT FILE
########################
@schoolday_event_api.route("/<schoolday_event_id>/file", methods=["PATCH"])
@schoolday_event_api.input(ApiFileSchema, location="files")
@schoolday_event_api.output(pupil_schema)
@schoolday_event_api.doc(
    security="ApiKeyAuth",
    tags=["Schoolday Events"],
    summary="PATCH-POST a file to document a given pupil schoolday event",
)
@token_required
def upload_schoolday_event_file(current_user, schoolday_event_id, files_data):
    schoolday_event = get_schoolday_event_by_id(schoolday_event_id)
    if schoolday_event is None:
        abort(
            404,
            "Ein Ereignis an diesem Tag mit diesem/dieser Schüler:in existiert nicht!",
        )

    if "file" not in files_data:
        abort(400, message="Keine Datei angegeben!")
    file = files_data["file"]
    file_id = str(uuid.uuid4().hex)
    filename = file_id + ".jpg"
    file_url = current_app.config["UPLOAD_FOLDER"] + "/admn/" + filename
    file.save(file_url)
    if len(str(schoolday_event.file_url)) > 4:
        os.remove(str(schoolday_event.file_url))
    schoolday_event.file_id = file_id
    schoolday_event.file_url = file_url
    # - LOG ENTRY
    create_log_entry(current_user, request, {"data": "file"})
    db.session.commit()
    pupil = get_pupil_by_id(schoolday_event.schoolday_event_pupil_id)
    return pupil


# - PATCH SCHOOLDAY EVENT PROCESSED FILE
##################################
@schoolday_event_api.route("/<schoolday_event_id>/processed_file", methods=["PATCH"])
@schoolday_event_api.input(ApiFileSchema, location="files")
@schoolday_event_api.output(pupil_schema)
@schoolday_event_api.doc(
    security="ApiKeyAuth",
    tags=["Schoolday Events"],
    summary="PATCH-POST a file to document a given pupil processed schoolday event",
)
@token_required
def upload_schoolday_event_processed_file(current_user, schoolday_event_id, files_data):
    schoolday_event = get_schoolday_event_by_id(schoolday_event_id)
    if schoolday_event is None:
        abort(
            404,
            "Ein Ereignis an diesem Tag mit diesem/dieser Schüler:in existiert nicht!",
        )

    if "file" not in files_data:
        abort(400, message="Keine Datei angegeben!")
    file = files_data["file"]
    processed_file_id = str(uuid.uuid4().hex)
    filename = processed_file_id + ".jpg"
    file_url = current_app.config["UPLOAD_FOLDER"] + "/admn/" + filename
    file.save(file_url)
    if len(str(schoolday_event.processed_file_url)) > 4:
        os.remove(str(schoolday_event.processed_file_url))
    schoolday_event.processed_file_id = processed_file_id
    schoolday_event.processed_file_url = file_url
    # - LOG ENTRY
    create_log_entry(current_user, request, {"data": "file"})
    db.session.commit()
    pupil = get_pupil_by_id(schoolday_event.schoolday_event_pupil_id)
    return pupil


# - GET SCHOOLDAY EVENT FILE
######################
@schoolday_event_api.route("/<schoolday_event_id>/file", methods=["GET"])
@schoolday_event_api.output(FileSchema, content_type="image/jpeg")
@schoolday_event_api.doc(
    security="ApiKeyAuth",
    tags=["Schoolday Events"],
    summary="Get file of a given schoolday event",
)
@token_required
def download_schoolday_event_file(current_user, schoolday_event_id):
    schoolday_event = get_schoolday_event_by_id(schoolday_event_id)
    if schoolday_event == None:
        abort(
            404,
            message="A schoolday event with this date and this pupil does not exist!",
        )
    if len(str(schoolday_event.file_url)) < 5:
        abort(404, message="This schoolday event has no file!")
    url_path = schoolday_event.file_url
    return send_file(url_path, mimetype="image/jpg")


# - GET SCHOOLDAY EVENT PROCESSED FILE
################################
@schoolday_event_api.route("/<schoolday_event_id>/processed_file", methods=["GET"])
@schoolday_event_api.output(FileSchema, content_type="image/jpeg")
@schoolday_event_api.doc(
    security="ApiKeyAuth",
    tags=["Schoolday Events"],
    summary="Get file of a given processed schoolday event",
)
@token_required
def download_schoolday_event_processed_file(current_user, schoolday_event_id):
    schoolday_event = get_schoolday_event_by_id(schoolday_event_id)
    if schoolday_event == None:
        abort(
            404,
            message="An schoolday event with this date and this pupil does not exist!",
        )
    if len(str(schoolday_event.processed_file_url)) < 5:
        abort(404, message="This schoolday event has no processed file!")
    url_path = schoolday_event.processed_file_url
    return send_file(url_path, mimetype="image/jpg")


# - DELETE SCHOOLDAY EVENT FILE
#########################
@schoolday_event_api.route("/<schoolday_event_id>/file", methods=["DELETE"])
@schoolday_event_api.output(pupil_schema)
@schoolday_event_api.doc(
    security="ApiKeyAuth",
    tags=["Schoolday Events"],
    summary="Delete schoolday event file of a given schoolday event",
)
@token_required
def delete_schoolday_event_file(current_user, schoolday_event_id):
    if not current_user:
        abort(404, message="Bitte erneut einloggen!")
    schoolday_event = get_schoolday_event_by_id(schoolday_event_id)
    if schoolday_event is None:
        abort(
            404,
            message="Ein Ereignis an diesem Tag mit diesem/dieser Schüler:in existiert nicht!",
        )

    if len(str(schoolday_event.file_url)) < 5:
        abort(404, message="This schoolday event has no file!")
    if len(str(schoolday_event.file_url)) > 4:
        os.remove(str(schoolday_event.file_url))
    schoolday_event.file_url = None
    schoolday_event.file_id = None
    # - LOG ENTRY
    create_log_entry(current_user, request, {"data": "file"})

    db.session.commit()
    pupil = get_pupil_by_id(schoolday_event.schoolday_event_pupil_id)
    return pupil


# - DELETE SCHOOLDAY EVENT PROCESSED FILE
###################################
@schoolday_event_api.route("/<schoolday_event_id>/processed_file", methods=["DELETE"])
@schoolday_event_api.output(pupil_schema)
@schoolday_event_api.doc(
    security="ApiKeyAuth",
    tags=["Schoolday Events"],
    summary="Delete schoolday event processed file of a given processed schoolday event",
)
@token_required
def delete_schoolday_event_processed_file(current_user, schoolday_event_id):
    if not current_user:
        abort(404, message="Bitte erneut einloggen!")
    schoolday_event = get_schoolday_event_by_id(schoolday_event_id)
    if schoolday_event is None:
        abort(
            404,
            message="Ein Ereignis an diesem Tag mit diesem/dieser Schüler:in existiert nicht!",
        )
    if len(str(schoolday_event.processed_file_url)) < 5:
        abort(404, message="Dieses Ereignis hat keine Datei zur Bearbeitung!")
    if len(str(schoolday_event.processed_file_url)) > 4:
        os.remove(str(schoolday_event.processed_file_url))
    schoolday_event.processed_file_url = None
    schoolday_event.processed_file_id = None
    # - LOG ENTRY
    create_log_entry(current_user, request, {"data": "none"})
    db.session.commit()
    pupil = get_pupil_by_id(schoolday_event.schoolday_event_pupil_id)
    return pupil


# - DELETE SCHOOLDAY EVENT
####################
@schoolday_event_api.route("/<schoolday_event_id>/delete", methods=["DELETE"])
@schoolday_event_api.output(pupil_schema)
@schoolday_event_api.doc(
    security="ApiKeyAuth",
    tags=["Schoolday Events"],
    summary="Delete an schoolday event and eventual files",
)
@token_required
def delete_schoolday_event(current_user, schoolday_event_id):
    schoolday_event = get_schoolday_event_by_id(schoolday_event_id)
    if schoolday_event is None:
        abort(
            404,
            message="Ein Ereignis an diesem Tag mit diesem/dieser Schüler:in existiert nicht!",
        )

    pupil = get_pupil_by_id(schoolday_event.schoolday_event_pupil_id)
    if schoolday_event.file_url is not None:
        os.remove(str(schoolday_event.file_url))
    if schoolday_event.processed_file_url is not None:
        os.remove(str(schoolday_event.processed_file_url))
    db.session.delete(schoolday_event)
    # - LOG ENTRY
    create_log_entry(current_user, request, {"data": "none"})
    db.session.commit()
    return pupil
