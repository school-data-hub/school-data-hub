from datetime import datetime

from apiflask import APIBlueprint, abort
from flask import jsonify, request
from sqlalchemy import and_
from sqlalchemy.sql import exists

from auth_middleware import token_required
from models.pupil import Pupil
from models.shared import db
from models.workbook import PupilWorkbook, Workbook
from schemas.pupil_schemas import *
from schemas.workbook_schemas import *

pupil_workbook_api = APIBlueprint(
    "pupil_workbooks_api", __name__, url_prefix="/api/pupil_workbooks"
)


# - GET ALL PUPIL WORKBOOKS
##########################
@pupil_workbook_api.route("/all", methods=["GET"])
@pupil_workbook_api.output(pupil_workbooks_schema)
@pupil_workbook_api.doc(security="ApiKeyAuth", tags=["Pupil Workbooks"])
@token_required
def get_all_pupil_workbooks(current_user):
    all_pupil_workbooks = PupilWorkbook.query.all()
    return all_pupil_workbooks


# - GET ALL PUPIL WORKBOOKS BY PUPIL ID
#######################################
@pupil_workbook_api.route("/<internal_id>", methods=["GET"])
@pupil_workbook_api.output(pupil_workbooks_schema)
@pupil_workbook_api.doc(security="ApiKeyAuth", tags=["Pupil Workbooks"])
@token_required
def get_all_pupil_workbooks_by_pupil_id(current_user, internal_id):
    all_pupil_workbooks = PupilWorkbook.query.filter_by(pupil_id=internal_id).all()
    return all_pupil_workbooks


# - GET ALL PUPIL WORKBOOKS BY WORKBOOK ISBN
#######################################
@pupil_workbook_api.route("/isbn/<isbn>", methods=["GET"])
@pupil_workbook_api.output(pupil_workbooks_schema)
@pupil_workbook_api.doc(security="ApiKeyAuth", tags=["Pupil Workbooks"])
@token_required
def get_all_pupil_workbooks_by_workbook_isbn(current_user, isbn):
    all_pupil_workbooks = PupilWorkbook.query.filter_by(workbook_isbn=isbn).all()
    return all_pupil_workbooks


# - POST PUPIL WORKBOOK
######################
@pupil_workbook_api.route("/<internal_id>/<isbn>", methods=["POST"])
@pupil_workbook_api.output(pupil_schema)
@pupil_workbook_api.doc(security="ApiKeyAuth", tags=["Pupil Workbooks"])
@token_required
def add_workbook_to_pupil(current_user, internal_id, isbn):
    this_pupil = Pupil.query.filter_by(internal_id=internal_id).first()
    if this_pupil == None:
        return jsonify({"message": "This pupil does not exist!"}), 404
    pupil_id = internal_id
    this_workbook = Workbook.query.filter_by(isbn=isbn).first()
    if this_workbook == None:
        return jsonify({"message": "This workbook does not exist!"}), 404
    isbn = isbn
    if (
        db.session.query(
            exists().where(
                and_(
                    PupilWorkbook.workbook_isbn == isbn,
                    PupilWorkbook.pupil_id == internal_id,
                )
            )
        ).scalar()
        == True
    ):
        abort(406, "Dieses zugewiesene Arbeitsheft existiert schon!")
    # if db.session.query(exists().where(PupilWorkbook.workbook_isbn == isbn and PupilWorkbook.pupil_id == internal_id)).scalar() == True:
    #     return jsonify({'error': 'This pupil workbook exists already!'}), 404

    created_by = current_user.name
    created_at = datetime.now().date()
    new_pupil_workbook: PupilWorkbook = PupilWorkbook(
        pupil_id=pupil_id,
        workbook_isbn=isbn,
        comment=None,
        status=None,
        created_by=created_by,
        created_at=created_at,
        finished_at=None,
    )
    db.session.add(new_pupil_workbook)
    db.session.commit()
    return this_pupil


# - PATCH PUPIL WORKBOOK
#######################
@pupil_workbook_api.route("/<internal_id>/<isbn>", methods=["PATCH"])
@pupil_workbook_api.input(pupil_workbook_schema)
@pupil_workbook_api.output(pupil_schema)
@pupil_workbook_api.doc(security="ApiKeyAuth", tags=["Pupil Workbooks"])
@token_required
def update_PupilWorkbook(current_user, internal_id, isbn, json_data):
    pupil_workbook: PupilWorkbook = PupilWorkbook.query.filter_by(
        pupil_id=internal_id, workbook_isbn=isbn
    ).first()
    if pupil_workbook == None:
        abort(404, message="Dieses zugewiesene Arbeitsheft existiert nicht!")

    data = json_data
    for key in data:
        match key:
            case "comment":
                pupil_workbook.comment = data[key]
            case "status":
                pupil_workbook.status = data[key]
            case "created_by":
                pupil_workbook.created_by = data[key]
            case "created_at":
                pupil_workbook.created_at = datetime.strptime(
                    data[key], "%Y-%m-%d"
                ).date()
            case "finished_at":
                pupil_workbook.finished_at = datetime.strptime(
                    data[key], "%Y-%m-%d"
                ).date()
    db.session.commit()
    pupil = Pupil.query.filter_by(internal_id=internal_id).first()
    return pupil


# - DELETE PUPIL WORKBOOK
########################
@pupil_workbook_api.route("/<internal_id>/<isbn>", methods=["DELETE"])
@pupil_workbook_api.output(pupil_schema)
@pupil_workbook_api.doc(security="ApiKeyAuth", tags=["Pupil Workbooks"])
@token_required
def delete_PupilWorkbook(current_user, internal_id, isbn):

    this_workbook = PupilWorkbook.query.filter_by(
        pupil_id=internal_id, workbook_isbn=isbn
    ).first()
    if this_workbook == None:
        abort(404, message="Dieses zugewiesene Arbeitsheft existiert nicht!")
    if current_user.name != this_workbook.created_by or not current_user.admin:
        abort(403, message="Nicht autorisiert!")
    db.session.delete(this_workbook)
    pupil = Pupil.query.filter_by(internal_id=internal_id).first()
    db.session.commit()
    pupil = Pupil.query.filter_by(internal_id=internal_id).first()
    return pupil
