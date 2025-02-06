import csv
import os
from datetime import datetime
from io import TextIOWrapper

from apiflask import APIBlueprint, abort
from flask import json, jsonify, request
from sqlalchemy.sql import exists

from auth_middleware import token_required
from helpers.log_entries import create_log_entry
from models.competence import Competence
from models.pupil import *
from models.schoolday import Schoolday
from models.shared import db
from models.support_category import SupportCategory
from schemas.competence_schemas import *
from schemas.log_entry_schemas import ApiFileSchema
from schemas.pupil_schemas import *
from schemas.schoolday_schemas import *
from schemas.support_schemas import *

import_file_api = APIBlueprint("import_file_api", __name__, url_prefix="/api/import")

## CSV imports from https://gist.github.com/dasdachs/69c42dfcfbf2107399323a4c86cdb791


# - IMPORT PUPILS TXT
####################
@import_file_api.route("/pupils/txt", methods=["POST"])
@import_file_api.input(ApiFileSchema, location="files")
@import_file_api.output(pupils_schema)
@import_file_api.doc(
    security="ApiKeyAuth",
    tags=["File Imports"],
    summary="Import pupils from a .txt file, save to json and delete pupils in the database if not present in the file ",
)
@token_required
def upload_pupils_txt(current_user, files_data):

    if "file" not in files_data:
        abort(400, message="Keine Datei angegeben!")

    # open txt file and extract data as string
    # each line of text should have the internal id and the ogs value separated by a comma
    txt_file = TextIOWrapper(files_data["file"], encoding="utf-8-sig")
    txt_reader = txt_file.read()
    txt_lines = txt_reader.splitlines()
    pupils_modified = 0
    new_pupils = 0
    internal_ids = []
    for line in txt_lines:
        values = line.strip().split(",")
        # prepare a list of all internal_ids
        internal_ids.append(values[0])
        # if the pupil doesn't exist, we create one
        if (
            db.session.query(exists().where(Pupil.internal_id == values[0])).scalar()
            == False
        ):
            # transform ogs value to true / false
            if values[1] == True or values[1] == "true" or values[1] == "OFFGANZ":
                ogs_value = True
            else:
                ogs_value = False
            # create new pupil with id and ogs and write default values
            pupil: Pupil = Pupil(
                internal_id=values[0],
                contact=None,
                parents_contact=None,
                credit=0,
                credit_earned=0,
                ogs=ogs_value,
                pick_up_time=None,
                ogs_info=None,
                latest_support_level=None,
                five_years=None,
                communication_pupil=None,
                communication_tutor1=None,
                communication_tutor2=None,
                preschool_revision=None,
                preschool_attendance=None,
                avatar_url=None,
                avatar_id=None,
                special_information=None,
                emergency_care=False,
                avatar_auth=False,
                avatar_auth_id=None,
                avatar_auth_url=None,
                public_media_auth=0,
                public_media_auth_id=None,
                public_media_auth_url=None,
            )

            new_pupils = new_pupils + 1
            db.session.add(pupil)
        else:
            # If the pupil exists, we only care for the ogs values
            # Since this data is the newest, we overwrite it
            pupil = Pupil.query.filter_by(internal_id=values[0]).first()
            if values[1] == True or values[1] == "true" or values[1] == "OFFGANZ":
                ogs_value = True
            else:
                ogs_value = False
            pupil.ogs = ogs_value

            pupils_modified = pupils_modified + 1
    # Commit changes to the database

    # Export and delete pupils with no matches checking against the internal_ids list
    pupils_to_delete = (
        db.session.query(Pupil).filter(~Pupil.internal_id.in_(internal_ids)).all()
    )
    if pupils_to_delete != None:
        # Ensure the directory *old_pupils* exists, if not create it
        old_pupils_folder = "old_pupils"
        if not os.path.exists(old_pupils_folder):
            os.makedirs(old_pupils_folder)
        for pupil in pupils_to_delete:
            old_pupil = OldPupil(
                internal_id=pupil.internal_id,
                credit=pupil.credit,
                credit_earned=pupil.credit_earned,
                ogs=pupil.ogs,
                latest_support_level=pupil.latest_support_level,
                five_years=pupil.five_years,
                communication_pupil=pupil.communication_pupil,
                communication_tutor1=pupil.communication_tutor1,
                communication_tutor2=pupil.communication_tutor2,
                preschool_revision=pupil.preschool_revision,
                date_created=datetime.strptime(
                    datetime.now().strftime("%Y-%m-%d %H:%M:%S"), "%Y-%m-%d %H:%M:%S"
                ),
            )

            with open(
                os.path.join(old_pupils_folder, f"pupil_{pupil.internal_id}.json"), "w"
            ) as f:
                json.dump(pupil_schema.dump(pupil), f)
            db.session.add(old_pupil)
            db.session.delete(pupil)
            print(f"Pupil {pupil.internal_id} exported and deleted")

        # Commit changes to the database
    # - LOG ENTRY
    create_log_entry(current_user, request, {"data": "none"})
    db.session.commit()
    # Fetch all pupils from the database and return them
    pupils = Pupil.query.all()
    return pupils


# - IMPORT PUPILS CSV
####################
@import_file_api.route("/pupils/csv", methods=["POST"])
@import_file_api.input(ApiFileSchema, location="files")
@import_file_api.doc(
    security="ApiKeyAuth",
    tags=["File Imports"],
    summary="Import pupils from a .csv file",
    deprecated=True,
)
@token_required
def upload_pupils_csv(current_user, files_data):

    if request.method == "POST":
        csv_file = files_data["file"]  # request.files['file']
        csv_file = TextIOWrapper(csv_file, encoding="utf-8-sig")
        csv_reader = csv.reader(csv_file, delimiter=";")
        new_pupils = 0
        pupils_modified = 0
        first_row = True
        for row in csv_reader:
            # Check if it's the first row
            if first_row:
                first_row = False
                continue  # Skip it
            # if the pupil doesn't exist, we create one
            if (
                db.session.query(exists().where(Pupil.internal_id == row[0])).scalar()
                == False
            ):
                # transform ogs value to true / false
                if row[1] == "1":
                    ogs_value = True
                else:
                    ogs_value = False
                # because it is a new pupil, it gets default values
                pupil = Pupil(
                    internal_id=row[0],
                    contact=None,
                    parents_contact=None,
                    credit=0,
                    credit_earned=0,
                    ogs=ogs_value,
                    pick_up_time=None,
                    ogs_info=None,
                    latest_support_level=None,
                    five_years=None,
                    communication_pupil=None,
                    communication_tutor1=None,
                    communication_tutor2=None,
                    preschool_revision=None,
                    avatar_url=None,
                    special_information=None,
                    emergency_care=False,
                )
                new_pupils = new_pupils + 1
                db.session.add(pupil)
            else:
                # If the pupil exists, we only care for the ogs values
                # Since this data is the newest, we overwrite it
                pupil = Pupil.query.filter_by(internal_id=row[0]).first()
                # transform ogs value to true / false
                if row[1] == "1":
                    ogs_value = True
                else:
                    ogs_value = False
                pupil.ogs = ogs_value

                pupils_modified = pupils_modified + 1

        db.session.commit()
        # if new_pupils == []:
        return (
            jsonify(
                {
                    "message": str(new_pupils)
                    + " new pupils, "
                    + str(pupils_modified)
                    + " pupils modified!"
                }
            ),
            404,
        )
        # return pupils_schema.jsonify(new_pupils)


# - GET IMPORT CATEGORIES
########################
@import_file_api.route("/categories/csv", methods=["POST"])
@import_file_api.input(ApiFileSchema, location="files")
@import_file_api.output(support_categories_schema, 200)
@import_file_api.doc(
    security="ApiKeyAuth",
    tags=["File Imports"],
    summary="Import goal categories from .csv file",
)
@token_required
def upload_categories_csv(current_user, files_data):
    new_categories = []
    if request.method == "POST":

        csv_file = files_data["file"]  # request.files['file']
        csv_file = TextIOWrapper(csv_file, encoding="utf-8-sig")
        csv_reader = csv.reader(csv_file, delimiter=";")
        first_row = True
        for row in csv_reader:
            # Check if it's the first row
            if first_row:
                first_row = False
                continue  # Skip it
            if (
                db.session.query(
                    exists().where(SupportCategory.category_id == row[0])
                ).scalar()
                == False
            ):
                if row[1] == "":
                    this_parent_category = None
                else:
                    this_parent_category = row[1]
                category = SupportCategory(
                    category_id=row[0],
                    parent_category=this_parent_category,
                    category_name=row[2],
                )
                new_categories.append(category)
                db.session.add(category)
            if new_categories == []:
                abort(404, "Keine neuen Kategorien gefunden!")

        db.session.commit()
        return new_categories


# - GET IMPORT COMPETENCES
#########################
@import_file_api.route("/competences/csv", methods=["POST"])
@import_file_api.input(ApiFileSchema, location="files")
@import_file_api.doc(
    security="ApiKeyAuth",
    tags=["File Imports"],
    summary="Import competences from .csv file",
)
@token_required
def upload_competences_csv(current_user, files_data):
    new_competences = []
    if request.method == "POST":

        csv_file = files_data["file"]  # request.files['file']
        csv_file = TextIOWrapper(csv_file, encoding="utf-8-sig")
        csv_reader = csv.reader(csv_file, delimiter=";", skipinitialspace=True)
        first_row = True
        for row in csv_reader:
            # Check if it's the first row
            if first_row:
                first_row = False
                continue  # Skip the first row

            if (
                db.session.query(
                    exists().where(Competence.competence_id == row[0])
                ).scalar()
                == False
            ):
                if row[1] == "":
                    this_parent_competence = None
                else:
                    this_parent_competence = row[1]
                if row[2] == "":
                    this_competence_level = None
                else:
                    this_competence_level = row[2]
                if row[3] == "":
                    this_indicators = None
                else:
                    this_indicators = row[3]

                competence = Competence(
                    competence_id=row[0],
                    parent_competence=this_parent_competence,
                    competence_level=this_competence_level,
                    indicators=this_indicators,
                    competence_name=row[4],
                )
                new_competences.append(competence)
            if new_competences == []:
                abort(404, "Keine neuen Kompetenzen gefunden!")

            db.session.add(competence)

        db.session.commit()
        return competences_schema.jsonify(new_competences)


# - POST IMPORT SCHOOLDAYS
#########################
@import_file_api.route("/schooldays/csv", methods=["POST"])
@import_file_api.input(ApiFileSchema, location="files")
@import_file_api.output(schooldays_only_schema)
@import_file_api.doc(
    security="ApiKeyAuth",
    tags=["File Imports"],
    summary="Import schooldays from .csv file",
)
@token_required
def upload_schooldays_csv(current_user, files_data):
    new_schooldays = []
    if request.method == "POST":

        csv_file = files_data["file"]  # request.files['file']
        csv_file = TextIOWrapper(csv_file, encoding="utf-8-sig")
        csv_reader = csv.reader(csv_file, delimiter=";")
        first_row = True
        for row in csv_reader:
            # Check if it's the first row
            if first_row:
                first_row = False
                continue  # Skip the first row
            this_schoolday = datetime.strptime(row[0], "%Y-%m-%d").date()
            if (
                db.session.query(
                    exists().where(Schoolday.schoolday == this_schoolday)
                ).scalar()
                == False
            ):
                new_schoolday = Schoolday(schoolday=this_schoolday)
                new_schooldays.append(new_schoolday)
                db.session.add(new_schoolday)
            if new_schooldays == []:
                abort(404, "Keine neuen Schultage gefunden!")

        db.session.commit()

        return new_schooldays
