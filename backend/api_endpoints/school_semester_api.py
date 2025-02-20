from datetime import datetime

from apiflask import APIBlueprint, abort
from flask import request

from auth_middleware import token_required
from helpers.log_entries import create_log_entry
from models.schoolday import Schoolday, SchoolSemester
from models.shared import db
from schemas.schoolday_schemas import *

school_semester_api = APIBlueprint(
    "school_semester_api", __name__, url_prefix="/api/school_semester"
)


# - POST SCHOOL SEMESTER
########################
@school_semester_api.route("/new", methods=["POST"])
@school_semester_api.doc(
    security="ApiKeyAuth", tags=["School Semester"], summary="Post a school semester"
)
@school_semester_api.input(school_semester_schema)
@school_semester_api.output(school_semester_schema)
@token_required
def add_school_semester(current_user, json_data):
    start_date = json_data["start_date"]
    end_date = json_data["end_date"]
    class_conference_date = json_data["class_conference_date"]
    report_conference_date = json_data["report_conference_date"]

    # Check for date overlap with existing school semesters
    if check_date_overlap(start_date, end_date):
        abort(400, "Der Zeitbereich überlappt sich mit einem existierenden Semester.")

    # Retrieve Schoolday records for start and end dates
    start_date_schoolday = (
        db.session.query(Schoolday).filter(Schoolday.schoolday == start_date).first()
    )
    end_date_schoolday = (
        db.session.query(Schoolday).filter(Schoolday.schoolday == end_date).first()
    )
    if start_date_schoolday is None or end_date_schoolday is None:
        abort(404, "Ein oder beide Tage existieren nicht in der Datenbank!")

    # Create a new school semester
    is_first = json_data["is_first"]
    new_school_semester = SchoolSemester(
        start_date=start_date_schoolday.schoolday,
        end_date=end_date_schoolday.schoolday,
        class_conference_date=class_conference_date,
        report_conference_date=report_conference_date,
        is_first=is_first,
    )
    db.session.add(new_school_semester)
    # - LOG ENTRY
    create_log_entry(current_user, request, json_data)
    db.session.commit()
    return new_school_semester


def check_date_overlap(start_date, end_date):
    existing_semesters = db.session.query(SchoolSemester).filter(
        (
            (start_date >= SchoolSemester.start_date)
            & (start_date <= SchoolSemester.end_date)
        )
        | (
            (end_date >= SchoolSemester.start_date)
            & (end_date <= SchoolSemester.end_date)
        )
    )
    return existing_semesters.count() > 0


# - GET SCHOOL SEMESTERS
########################
@school_semester_api.route("/all", methods=["GET"])
@school_semester_api.output(school_semesters_schema)
@school_semester_api.doc(
    security="ApiKeyAuth", tags=["School Semester"], summary="Get all school semesters"
)
@token_required
def get_school_semesters(current_user):
    all_semesters = db.session.query(SchoolSemester).all()

    return all_semesters
