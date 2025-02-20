import os
import uuid
from datetime import datetime

from apiflask import APIBlueprint, FileSchema, abort
from flask import current_app, request, send_file

from auth_middleware import token_required
from helpers.db_helpers import get_workbook_by_isbn
from helpers.log_entries import create_log_entry
from models.log_entry import LogEntry
from models.shared import db
from models.workbook import Workbook
from schemas.log_entry_schemas import ApiFileSchema
from schemas.workbook_schemas import *

workbook_api = APIBlueprint("workbooks_api", __name__, url_prefix="/api/workbooks")

# - GET WORKBOOKS
################


@workbook_api.route("/all", methods=["GET"])
@workbook_api.output(workbooks_schema)
@workbook_api.doc(
    security="ApiKeyAuth",
    tags=["Workbooks"],
    summary="get workbooks with nested working pupils",
)
@token_required
def get_workbooks(current_user):

    all_workbooks = Workbook.query.all()
    return all_workbooks


# - GET WORKBOOKS FLAT
#####################


@workbook_api.route("/all/flat", methods=["GET"])
@workbook_api.output(workbooks_flat_schema)
@workbook_api.doc(
    security="ApiKeyAuth",
    tags=["Workbooks"],
    summary="get workbooks without nested working pupils",
)
@token_required
def get_workbooks_flat(current_user):

    all_workbooks = Workbook.query.all()

    return all_workbooks


# - GET ONE WORKBOOK
###################


@workbook_api.route("/<isbn>", methods=["GET"])
@workbook_api.output(workbook_flat_schema)
@workbook_api.doc(security="ApiKeyAuth", tags=["Workbooks"], summary="Get one workbook")
@token_required
def get_one_workbook(current_user, isbn):

    workbook = Workbook.query.filter_by(isbn=isbn).first()
    if workbook == None:
        abort(404, message="Dieses Arbeitsheft existiert nicht!")

    return workbook


# - POST WORKBOOK
################


@workbook_api.route("/new", methods=["POST"])
@workbook_api.input(workbook_flat_schema)
@workbook_api.output(workbook_flat_schema)
@workbook_api.doc(
    security="ApiKeyAuth", tags=["Workbooks"], summary="Post a new workbook"
)
@token_required
def create_workbook(current_user, json_data):

    data = json_data
    if db.session.query(Workbook).filter(Workbook.isbn == data["isbn"]).first():
        abort(409, message="Das Arbeitsheft existiert schon!")

    isbn = data["isbn"]
    name = data["name"]
    subject = data["subject"]
    level = data["level"]
    amount = data["amount"]
    image_url = data["image_url"]

    new_workbook = Workbook(isbn, name, subject, level, amount, image_url)
    db.session.add(new_workbook)

    # - LOG ENTRY
    create_log_entry(current_user, request, json_data)

    db.session.commit()
    return new_workbook


# - PATCH WORKBOOK
#################


@workbook_api.route("/<isbn>", methods=["PATCH"])
@workbook_api.input(workbook_flat_schema)
@workbook_api.output(workbook_flat_schema)
@workbook_api.doc(
    security="ApiKeyAuth", tags=["Workbooks"], summary="Patch an existing workbook"
)
@token_required
def patch_workbook(current_user, isbn, json_data):
    workbook = db.session.query(Workbook).filter(Workbook.isbn == isbn).first()
    if workbook is None:
        abort(404, message="Das Arbeitsheft existiert nicht!")

    data = json_data
    for key in data:
        match key:
            case "name":
                workbook.name = data["name"]
            case "subject":
                workbook.subject = data["subject"]
            case "level":
                workbook.level = data["level"]
            case "amount":
                workbook.amount = data["amount"]
            case "image_url":
                workbook.image_url = data["image_url"]
    # - LOG ENTRY
    create_log_entry(current_user, request, json_data)

    db.session.commit()
    return workbook


# - PATCH WORKBOOK WITH IMAGE
############################


@workbook_api.route("/<isbn>/image", methods=["PATCH"])
@workbook_api.input(ApiFileSchema, location="files")
@workbook_api.output(workbook_flat_schema)
@workbook_api.doc(
    security="ApiKeyAuth",
    tags=["Workbooks"],
    summary="Patch an existing workbook with image",
)
@token_required
def patch_workbook_image(current_user, isbn, files_data):
    workbook = get_workbook_by_isbn(isbn)
    if workbook is None:
        abort(404, message="Das Arbeitsheft existiert nicht!")

    if "file" not in files_data:
        abort(400, message="Keine Datei angegeben!")
    file = files_data["file"]
    file_id = str(uuid.uuid4().hex)
    file_url = current_app.config["UPLOAD_FOLDER"] + "/wrk/" + file_id + ".jpg"
    file.save(file_url)
    if len(str(workbook.image_url)) > 4:
        os.remove(str(workbook.image_url))
    workbook.image_url = file_url

    # - LOG ENTRY
    create_log_entry(current_user, request, {"data": "file"})

    db.session.commit()
    return workbook


# - DELETE WORKBOOK IMAGE


@workbook_api.route("/<isbn>/image", methods=["DELETE"])
@workbook_api.output(workbook_flat_schema)
@workbook_api.doc(
    security="ApiKeyAuth", tags=["Workbooks"], summary="Delete workbook image"
)
@token_required
def delete_workbook_image(current_user, isbn):
    workbook = get_workbook_by_isbn(isbn)
    if workbook is None:
        abort(404, message="Das Arbeitsheft existiert nicht!")

    if len(str(workbook.image_url)) < 5:
        abort(404, message="Keine Datei vorhanden!")

    os.remove(str(workbook.image_url))
    workbook.image_url = None
    db.session.commit()
    return workbook


# - GET WORKBOOK IMAGE
#####################


@workbook_api.get("/<isbn>/image")
@workbook_api.output(FileSchema, content_type="image/jpeg")
@workbook_api.doc(
    security="ApiKeyAuth", tags=["Workbooks"], summary="Get workbook image"
)
@token_required
def get_workbook_image(current_user, isbn):
    workbook = get_workbook_by_isbn(isbn)
    if workbook is None:
        abort(404, message="Das Arbeitsheft existiert nicht!")

    if len(str(workbook.image_url)) < 5:
        abort(404, message="Keine Datei vorhanden!")
    return send_file(str(workbook.image_url), mimetype="image/jpg")


# - DELETE WORKBOOK
##################


@workbook_api.route("/<isbn>", methods=["DELETE"])
@workbook_api.output(workbooks_flat_schema)
@workbook_api.doc(
    security="ApiKeyAuth", tags=["Workbooks"], summary="Delete a workbook"
)
@token_required
def delete_workbook(current_user, isbn):
    workbook = get_workbook_by_isbn(isbn)
    if workbook == None:
        abort(404, message="Dieses Arbeitsheft existiert nicht!")

    if not current_user.admin or current_user.name != workbook.created_by:
        abort(403, message="Keine Berechtigung!")

    if workbook.image_url is not None:
        os.remove(str(workbook.image_url))
    db.session.delete(workbook)
    # - LOG ENTRY
    create_log_entry(current_user, request, {"data": "none"})
    db.session.commit()
    all_workbooks = Workbook.query.all()

    return all_workbooks
