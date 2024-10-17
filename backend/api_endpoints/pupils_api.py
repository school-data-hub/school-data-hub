import os
import uuid
from datetime import datetime

from apiflask import APIBlueprint, FileSchema, abort
from flask import current_app, json, jsonify, request, send_file

from app import db
from helpers.db_helpers import date_string_to_date, get_pupil_by_id
from helpers.error_message_helpers import pupil_not_found
from helpers.log_entries import create_log_entry
from models.log_entry import LogEntry
from schemas.log_entry_schemas import ApiFileSchema

pupil_api = APIBlueprint("pupils_api", __name__, url_prefix="/api/pupils")

from auth_middleware import token_required
from models.pupil import CreditHistoryLog, Pupil, SupportLevel
from schemas.pupil_schemas import *


# - POST PUPIL
###############
@pupil_api.route("/new", methods=["POST"])
@pupil_api.input(
    pupil_flat_schema,
    example={
        "avatar_url": None,
        "communication_pupil": None,
        "communication_tutor1": None,
        "communication_tutor2": None,
        "contact": None,
        "credit": 0,
        "credit_earned": 0,
        "five_years": None,
        "latest_support_level": 0,
        "internal_id": 1234,
        "ogs": True,
        "ogs_info": None,
        "parents_contact": None,
        "pick_up_time": None,
        "preschool_revision": 0,
        "special_information": None,
    },
)
@pupil_api.output(pupil_schema)
@pupil_api.doc(security="ApiKeyAuth", tags=["Pupil"], summary="Create new Pupil")
@token_required
def add_pupil(current_user, json_data):
    data = json_data  # request.get_json()
    internal_id = data["internal_id"]
    exists = get_pupil_by_id(internal_id) is not None
    if exists == True:
        return (
            jsonify({"message": "This pupil exists already - please update the page!"}),
            400,
        )
    else:
        contact = data["contact"]
        parents_contact = data["parents_contact"]
        credit = data["credit"]
        credit_earned = 0
        ogs = data["ogs"]
        pick_up_time = data["pick_up_time"]
        ogs_info = data["ogs_info"]
        five_years = date_string_to_date(data["five_years"])
        latest_support_level = data["latest_support_level"]
        communication_pupil = data["communication_pupil"]
        communication_tutor1 = data["communication_tutor1"]
        communication_tutor2 = data["communication_tutor2"]
        preschool_revision = data["preschool_revision"]
        avatar_url = data["avatar_url"]
        special_information = data["special_information"]

        new_pupil = Pupil(
            internal_id,
            contact,
            parents_contact,
            credit,
            credit_earned,
            ogs,
            pick_up_time,
            ogs_info,
            latest_support_level,
            five_years,
            communication_pupil,
            communication_tutor1,
            communication_tutor2,
            preschool_revision,
            avatar_url,
            special_information,
        )
        db.session.add(new_pupil)

        # - LOG ENTRY
        create_log_entry(current_user, request, data)

        db.session.commit()

        return new_pupil  # response


# - PATCH PUPIL
###############


@pupil_api.route("/<internal_id>", methods=["PATCH"])
@pupil_api.input(pupil_flat_schema)
@pupil_api.output(pupil_schema)
@pupil_api.doc(security="ApiKeyAuth", tags=["Pupil"], summary="Patch a Pupil")
@token_required
def update_pupil(current_user, internal_id, json_data):
    pupil = get_pupil_by_id(internal_id)
    if pupil == None:
        return jsonify({"message": "This pupil does not exist!"}), 404
    data = json_data  # request.get_json()
    for key in data:
        match key:
            case "credit":
                new_credit = data[key]
                if new_credit < 0:
                    pupil.credit = pupil.credit + new_credit
                    if pupil.credit < 0:
                        abort(400, message="Nicht genug Guthaben auf dem Kinderkonto!")
                        # return jsonify({'message' : 'Nicht genug Guthaben auf dem Kinderkonto!'}), 400
                if new_credit > 0:
                    pupil.credit = pupil.credit + new_credit
                    pupil.credit_earned = pupil.credit_earned + new_credit
                    current_user.credit = current_user.credit - new_credit
                    if current_user.credit < 0:
                        abort(400, message="Nicht genug Guthaben auf dem Userkonto!")
                        # return jsonify({'message' : 'Nicht genug Guthaben auf dem Userkonto!'}), 400
                new_credit_history_log = CreditHistoryLog(
                    operation=new_credit,
                    created_by=current_user.name,
                    created_at=datetime.now().date(),
                    pupil_id=pupil.internal_id,
                    credit=pupil.credit,
                )
                db.session.add(new_credit_history_log)
            case "contact":
                pupil.contact = data[key]
            case "parents_contact":
                pupil.parents_contact = data[key]
            case "ogs":
                pupil.ogs = data[key]
            case "pick_up_time":
                pupil.pick_up_time = data[key]
            case "ogs_info":
                pupil.ogs_info = data[key]
            case "five_years":
                pupil.five_years = date_string_to_date(data[key])
            case "special_needs":
                pupil.special_needs = data[key]
            # - individual_development_plan is handled in a separate endpoint
            case "communication_pupil":
                pupil.communication_pupil = data[key]
            case "communication_tutor1":
                pupil.communication_tutor1 = data[key]
            case "communication_tutor2":
                pupil.communication_tutor2 = data[key]
            case "preschool_revision":
                pupil.preschool_revision = data[key]
            case "special_information":
                pupil.special_information = data[key]
            case "emergency_care":
                pupil.emergency_care = data[key]

    # - LOG ENTRY
    create_log_entry(current_user, request, data)

    db.session.commit()
    return pupil


# - PATCH SIBLING PUPILS
#######################


@pupil_api.route("/patch_siblings", methods=["PATCH"])
@pupil_api.input(pupil_siblings_patch_schema)
@pupil_api.output(pupils_schema)
@pupil_api.doc(
    security="ApiKeyAuth", tags=["Pupil"], summary="patch siblings with common value"
)
@token_required
def update_siblings(current_user, json_data):
    internal_id_list = json_data["pupils"]

    sibling_pupils = []
    for item in internal_id_list:
        this_pupil = get_pupil_by_id(item)
        if this_pupil != None:
            sibling_pupils.append(this_pupil)
    if sibling_pupils == []:
        return jsonify({"error": "None of the given pupils found!"}), 400
    data = json_data  # request.get_json()
    for pupil in sibling_pupils:
        for key in data:
            match key:
                case "parents_contact":
                    pupil.parents_contact = data[key]
                case "communication_tutor1":
                    pupil.communication_tutor1 = data[key]
                case "communication_tutor2":
                    pupil.communication_tutor2 = data[key]
                case "emergency_care":
                    pupil.emergency_care = data[key]

    # - LOG ENTRY
    create_log_entry(current_user, request, data)
    db.session.commit()

    return sibling_pupils


# - GET ALL PUPILS
#################


@pupil_api.route("/all", methods=["GET"])
@pupil_api.output(pupils_schema)
@pupil_api.doc(security="ApiKeyAuth", tags=["Pupil"], summary="Fetch all pupils")
@token_required
def get_pupils(current_user):
    if not current_user:
        abort(404, message="Bitte erneut einloggen!")
    all_pupils = Pupil.query.all()
    if all_pupils == []:
        return jsonify({"message": "No pupils found!"}), 404
    # result = pupils_schema.dump(all_pupils)
    # return jsonify(result)
    return all_pupils


# - GET ALL PUPILS FLAT
######################


@pupil_api.route("/all/flat", methods=["GET"])
@pupil_api.output(pupils_flat_schema)
@pupil_api.doc(
    security="ApiKeyAuth",
    tags=["Pupil"],
    summary="Fetch all pupils without list objects",
)
@token_required
def get_pupils_only(current_user):
    if not current_user:
        abort(404, message="Bitte erneut einloggen!")
    all_pupils = Pupil.query.all()
    if all_pupils == []:
        return jsonify({"error": "No pupils found!"}), 404
    result = pupils_flat_schema.dump(all_pupils)
    return jsonify(result)


# - GET PUPILS GIVEN IN ARRAY
############################


@pupil_api.route("/list", methods=["POST"])
@pupil_api.input(pupil_id_list_schema)
@pupil_api.output(pupils_schema)
@pupil_api.doc(
    security="ApiKeyAuth", tags=["Pupil"], summary="Fetch pupils in a given ids array"
)
@pupil_api.output(PupilSchema)
@token_required
def get_given_pupils(current_user, json_data):
    if not current_user:
        abort(404, message="Bitte erneut einloggen!")
    internal_id_list = json_data["pupils"]  # request.json['pupils']
    pupils = []
    for item in internal_id_list:
        this_pupil = get_pupil_by_id(item)
        if this_pupil != None:
            pupils.append(this_pupil)
    if pupils == []:
        return jsonify({"error": "None of the given pupils found!"}), 400
    result = pupils_schema.dump(pupils)
    return jsonify(result)


# - GET ONE PUPIL
################


@pupil_api.route("/<internal_id>", methods=["GET"])
@pupil_api.output(pupil_schema)
@pupil_api.doc(security="ApiKeyAuth", tags=["Pupil"], summary="Fetch given pupil")
@token_required
def get_pupil(current_user, internal_id):

    this_pupil = get_pupil_by_id(internal_id)
    if this_pupil == None:
        return jsonify({"message": "This pupil does not exist!"}), 400
    return this_pupil


# - DELETE PUPIL
###############


@pupil_api.route("/<internal_id>", methods=["DELETE"])
@pupil_api.doc(security="ApiKeyAuth", tags=["Pupil"], summary="delete given pupil")
@token_required
def delete_pupil(current_user, internal_id):
    if not current_user.admin:
        return jsonify({"message": "Keine Berechtigung!"}), 403
    pupil = get_pupil_by_id(internal_id)
    if pupil == None:
        return jsonify({"message": "Der Schüler/die Schülerin existiert nicht!"}), 404

    if len(str(pupil.avatar_url)) > 4:
        os.remove(str(pupil.avatar_url))
    db.session.delete(pupil)
    # - LOG ENTRY
    create_log_entry(current_user, request, {"data": "none"})

    db.session.commit()

    return jsonify({"message": "Schüler/Schülerin gelöscht!"}), 200


# - PATCH IMAGE PUPIL AVATAR
###########################


@pupil_api.route("/<internal_id>/avatar", methods=["PATCH"])
@pupil_api.input(ApiFileSchema, location="files")
@pupil_api.output(pupil_schema)
@pupil_api.doc(
    security="ApiKeyAuth",
    tags=["Pupil"],
    summary="PATCH-POST an avatar image of a given pupil",
)
@token_required
def upload_avatar(current_user, internal_id, files_data):
    pupil = get_pupil_by_id(internal_id)
    if pupil == None:
        return jsonify({"error": "This pupil does not exist!"})
    if "file" not in files_data:
        return jsonify({"error": "No file attached!"}), 400
    file = files_data["file"]
    file_id = str(uuid.uuid4().hex)
    filename = file_id + ".jpg"
    avatar_url = current_app.config["UPLOAD_FOLDER"] + "/avtr/" + filename
    file.save(avatar_url)
    if len(str(pupil.avatar_url)) > 4:
        os.remove(str(pupil.avatar_url))
    pupil.avatar_url = avatar_url
    pupil.avatar_id = file_id
    # - LOG ENTRY
    create_log_entry(current_user, request, {"data": "file"})

    db.session.commit()
    return pupil


# - GET IMAGE PUPIL AVATAR
#########################


@pupil_api.route("/<internal_id>/avatar", methods=["GET"])
@pupil_api.output(FileSchema, content_type="image/jpeg")
@pupil_api.doc(
    security="ApiKeyAuth", tags=["Pupil"], summary="Get avatar image of a given pupil"
)
@token_required
def download_avatar(current_user, internal_id):
    if not current_user:
        abort(404, message="Bitte erneut einloggen!")
    pupil = get_pupil_by_id(internal_id)
    if pupil == None:
        return jsonify({"error": "This pupil does not exist!"})
    if len(str(pupil.avatar_url)) < 5:
        return jsonify({"error": "This pupil has no avatar!"})
    url_path = pupil.avatar_url
    return send_file(url_path, mimetype="image/jpg")


# - DELETE IMAGE PUPIL AVATAR
############################


@pupil_api.route("/<internal_id>/avatar", methods=["DELETE"])
@pupil_api.doc(
    security="ApiKeyAuth",
    tags=["Pupil"],
    summary="Delete avatar image of a given pupil",
)
@token_required
def delete_avatar(current_user, internal_id):
    if not current_user:
        abort(404, message="Bitte erneut einloggen!")
    pupil = get_pupil_by_id(internal_id)
    if pupil == None:
        abort(404, message="Der Schüler/die Schülerin existiert nicht!")

    if len(str(pupil.avatar_url)) < 5:
        abort(404, message="Der Schüler/die Schülerin hat keinen Avatar!")

    if len(str(pupil.avatar_url)) > 4:
        os.remove(str(pupil.avatar_url))
    pupil.avatar_url = None
    # - LOG ENTRY
    create_log_entry(current_user, request, {"data": "none"})

    db.session.commit()

    return jsonify({"message": "Avatar gelöscht!"}), 200


# - UPDATE SUPPORT LEVEL
####################################
@pupil_api.route("/<internal_id>/support_level", methods=["PATCH"])
@pupil_api.input(support_level_in_schema)
@pupil_api.output(pupil_schema)
@pupil_api.doc(
    security="ApiKeyAuth",
    tags=["Support Level"],
    summary="Update support level of a given pupil",
)
@token_required
def update_support_level(current_user, internal_id, json_data):
    pupil = get_pupil_by_id(internal_id)
    if pupil == None:
        return jsonify({"message": "This pupil does not exist!"}), 404
    data = json_data
    created_by = current_user.name
    created_at = data["created_at"]
    level = data["level"]
    comment = data["comment"]
    support_level_id = str(uuid.uuid4().hex)
    new_support_level = SupportLevel(
        pupil_id=internal_id,
        support_level_id=support_level_id,
        created_by=created_by,
        created_at=created_at,
        level=level,
        comment=comment,
    )
    pupil.support_level_history.append(new_support_level)
    pupil.latest_support_level = level
    db.session.add(new_support_level)
    # - LOG ENTRY
    create_log_entry(current_user, request, data)
    db.session.commit()
    return pupil


# - DELETE SUPPORT LEVEL
####################################
@pupil_api.route("/<internal_id>/support_level/<support_level_id>", methods=["DELETE"])
@pupil_api.doc(
    security="ApiKeyAuth",
    tags=["Support Level"],
    summary="Delete support level of a given pupil",
)
@pupil_api.output(pupil_schema)
@token_required
def delete_support_level(current_user, internal_id, support_level_id):

    support_level = (
        db.session.query(SupportLevel)
        .filter(SupportLevel.support_level_id == support_level_id)
        .first()
    )
    db.session.delete(support_level)
    pupil = get_pupil_by_id(internal_id)
    if pupil == None:
        return jsonify({"message": "This pupil does not exist!"}), 404
    latest_support_level = (
        db.session.query(SupportLevel)
        .filter(SupportLevel.pupil_id == internal_id)
        .order_by(SupportLevel.id.desc())
        .first()
    )
    if latest_support_level == None:
        pupil.latest_support_level = 0
    else:
        pupil.latest_support_level = latest_support_level.level
    # - LOG ENTRY
    create_log_entry(current_user, request, {"data": "none"})
    db.session.commit()
    return pupil
