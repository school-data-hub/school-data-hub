import uuid
from datetime import datetime, timedelta

import jwt
from apiflask import APIBlueprint, abort
from flask import current_app, json, jsonify, request
from sqlalchemy.sql import exists
from werkzeug.security import check_password_hash, generate_password_hash

from auth_middleware import token_required
from helpers.log_entries import create_log_entry
from models.log_entry import LogEntry
from models.shared import db
from models.user import User
from schemas.user_schemas import *

user_api = APIBlueprint("users_api", __name__, url_prefix="/api/user")


# - GET USER LOGIN
#################
@user_api.route("login", methods=["GET"])
@user_api.doc(security="basicAuth", tags=["Auth"])
def login():
    auth = request.authorization
    if not auth or not auth.username or not auth.password:
        abort(401, message="Zugangsdaten unvollständig!")
    user = User.query.filter_by(name=auth.username).first()
    if not user:
        abort(401, message="Benutzer/Benutzerin existiert nicht!")
    if user.admin:
        isAdmin = True
    else:
        isAdmin = False
    if user:
        token = jwt.encode(
            {"public_id": user.public_id, "exp": datetime.now() + timedelta(hours=120)},
            current_app.config["SECRET_KEY"],
        )
        return (
            jsonify(
                {
                    "name": user.name,
                    "public_id": user.public_id,
                    "token": token,
                    "admin": isAdmin,
                    "role": user.role,
                    "credit": user.credit,
                    "tutoring": user.tutoring,
                    "time_units": user.time_units,
                    "contact": user.contact,
                }
            ),
            200,
        )
    return jsonify({"message": "Falsches Passwort!"}), 401


# - GET USERS
############
@user_api.route("/all", methods=["GET"])
@user_api.output(users_schema)
@user_api.doc(security="ApiKeyAuth", tags=["User"])
@token_required
def get_all_users(current_user):
    if not current_user:
        abort(404, message="Bitte erneut einloggen!")
    if not current_user.admin:
        abort(401, message="Keine Berechtigung!")
    users = User.query.all()
    if users == []:
        abort(404, message="Keine Benutzer/Benutzerin gefunden!")
    return users


# - GET SELF USER
################
@user_api.route("/me", methods=["GET"])
@user_api.output(user_schema)
@user_api.doc(security="ApiKeyAuth", tags=["User"])
@token_required
def get_self_user(current_user):
    if not current_user:
        abort(404, message="Bitte erneut einloggen!")
    return current_user


# - INCREASE USER CREDIT
#######################
@user_api.route("/all/credit", methods=["GET"])
@user_api.output(users_schema)
@user_api.doc(
    security="ApiKeyAuth", tags=["User"], summary="Increase credit of all users"
)
@token_required
def increase_users_credit(current_user):
    if not current_user.admin:
        abort(401, message="Keine Berechtigung!")
    users = User.query.all()
    if users == []:
        abort(404, message="Keine Benutzer/Benutzerin gefunden!")
    for user in users:
        credit = user.time_units
        user.credit = user.credit + credit
    db.session.commit()
    return users


# - POST USER
############
@user_api.route("/new", methods=["POST"])
@user_api.doc(security="ApiKeyAuth", tags=["User"])
@user_api.input(
    new_user_schema,
    example={
        "name": "USERNAME",
        "password": "PASSWORD",
        "admin": True,
        "role": "teacher",
        "tutoring": "D2",
        "contact": "@user:example.com",
        "credit": 0,
        "time_units": 0,
    },
)
@user_api.output(user_schema)
@token_required
def create_user(current_user, json_data):
    if not current_user.admin:
        abort(401, message="Keine Berechtigung!")
        # return jsonify({'message' : 'Keine Berechtigung!'}), 401
    # if json_data['admin'] == None or json_data['name'] == None or json_data['password'] == None:
    if (
        json_data.get("admin") == None
        or json_data.get("name") == None
        or json_data.get("password") == None
    ):
        print(json_data)
        print("Falsche Parameter!")
        return jsonify({"message": "Falsche Parameter!"}), 400
    data = json_data
    if db.session.query(exists().where(User.name == data["name"])).scalar() == True:
        return jsonify({"message": "Benutzer/Benutzerin existiert schon!"}), 400
    is_admin = data["admin"]
    role = data["role"]
    credit = data["credit"]
    time_units = data["time_units"]
    tutoring = data["tutoring"]
    contact = data["contact"]
    hashed_password = generate_password_hash(data["password"], method="scrypt")
    new_user = User(
        public_id=str(uuid.uuid4().hex),
        name=data["name"],
        password=hashed_password,
        admin=is_admin,
        role=role,
        tutoring=tutoring,
        contact=contact,
        credit=credit,
        time_units=time_units,
    )
    db.session.add(new_user)
    # - LOG ENTRY
    create_log_entry(current_user, request, json_data)

    db.session.commit()
    user_data = {}
    user_data["public_id"] = new_user.public_id
    user_data["name"] = new_user.name
    user_data["credit"] = new_user.credit
    user_data["admin"] = new_user.admin
    user_data["role"] = new_user.role
    user_data["time_units"] = new_user.time_units
    user_data["contact"] = new_user.contact
    user_data["tutoring"] = new_user.tutoring
    return jsonify(user_data)


# - PATCH USER
#############
@user_api.route("/<public_id>", methods=["PATCH"])
@user_api.doc(security="ApiKeyAuth", tags=["User"])
@user_api.input(
    user_schema,
    example={
        "name": "USERNAME",
        "password": "PASSWORD",
        "admin": True,
        "role": "teacher",
        "tutoring": "D2",
        "contact": "@user:example.com",
        "credit": 0,
        "time_units": 0,
    },
)
@user_api.output(user_schema)
@token_required
def patch_user(current_user, public_id, json_data):
    if not current_user.admin:
        return jsonify({"message": "Keine Berechtigung!"}), 403
    user = User.query.filter_by(public_id=public_id).first()
    if not user:
        return jsonify({"message": "Benutzer/Benutzerin nicht gefunden!"}), 404
    data = json_data
    # data = request.get_json()
    for key in data:
        match key:
            case "admin":
                user.admin = data[key]
            case "credit":
                new_credit = data[key]
                if user.credit + new_credit < 0:
                    abort(403, message="Nicht genug Guthaben auf dem Konto!")
                user.credit = user.credit + new_credit
            case "role":
                user.role = data[key]
            case "time_units":
                user.time_units = data[key]
            case "tutoring":
                user.tutoring = data[key]
            case "contact":
                user.contact = data[key]
    # - LOG ENTRY
    create_log_entry(current_user, request, json_data)

    db.session.commit()
    return user


# - CHANGE USER PASSWORD
#######################
@user_api.route("/<public_id>/new_password", methods=["PATCH"])
@user_api.doc(security="ApiKeyAuth", tags=["User"], summary="Change User Password")
@user_api.input(user_new_password_schema)
@user_api.output(user_schema)
@token_required
def change_user_password(current_user, public_id, json_data):
    user = User.query.filter_by(public_id=public_id).first()
    if not user:
        return jsonify({"message": "Benutzer/Benutzerin nicht gefunden!"}), 404

    if user != current_user:
        if current_user.admin == False:
            abort(403, message="Keine Berechtigung!")

    data = json_data
    # data = request.get_json()
    if user == current_user:
        if not check_password_hash(user.password, data["old_password"]):
            abort(403, message="Falsches Passwort!")
        hashed_password = generate_password_hash(data["new_password"], method="scrypt")
        user.password = hashed_password
    else:
        hashed_password = generate_password_hash(data["new_password"], method="scrypt")
        user.password = hashed_password
    # - LOG ENTRY
    create_log_entry(current_user, request, {"data": "password changed"})

    db.session.commit()
    return user


# - DELETE USER
##############
@user_api.route("/<public_id>", methods=["DELETE"])
@user_api.doc(security="ApiKeyAuth", tags=["User"])
@token_required
def delete_user(current_user, public_id):
    if not current_user.admin:
        return jsonify({"message": "Keine Berechtigung!"}), 401
    user = User.query.filter_by(public_id=public_id).first()
    if not user:
        return jsonify({"message": "Benutzer/in nicht gefunden!"}), 404
    db.session.delete(user)

    # - LOG ENTRY
    create_log_entry(current_user, request, {"data": "none"})

    db.session.commit()
    return jsonify({"message": "Benutzer/Benutzerin gelöscht"}), 200
