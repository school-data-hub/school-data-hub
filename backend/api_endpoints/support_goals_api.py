import uuid
from datetime import datetime

from apiflask import APIBlueprint, abort
from flask import jsonify, request

from auth_middleware import token_required
from helpers.db_helpers import (
    get_pupil_by_id,
    get_support_category_by_id,
    get_support_goal_by_id,
)
from helpers.log_entries import create_log_entry
from models.pupil import Pupil
from models.shared import db
from models.support_category import SupportCategory, SupportGoal, SupportGoalCheck
from schemas.pupil_schemas import *
from schemas.support_schemas import *

support_goals_api = APIBlueprint(
    "support_goals_api", __name__, url_prefix="/api/support_goals"
)


# - POST GOAL
############
@support_goals_api.route("/<internal_id>/new", methods=["POST"])
@support_goals_api.input(support_goal_in_schema)
@support_goals_api.output(pupil_schema)
@support_goals_api.doc(
    security="ApiKeyAuth",
    tags=["Support Goals"],
    summary="Post a goal for a given support gategory",
)
@token_required
def add_goal(current_user, internal_id, json_data):
    data = json_data
    pupil = get_pupil_by_id(internal_id)
    if pupil == None:
        abort(404, message="Schüler/Schülerin existiert nicht!")
    pupil_id = pupil.internal_id
    goal_category_id = data["support_category_id"]
    goal_category = get_support_category_by_id(goal_category_id)
    if goal_category == None:
        abort(404, message="Diese Kategorie existiert nicht!")
    goal_id = str(uuid.uuid4().hex)
    created_by = current_user.name
    created_at = data["created_at"]
    # created_at_datetime = datetime.strptime(created_at, '%Y-%m-%d').date()
    achieved = data["achieved"]
    achieved_at = data["achieved_at"]
    # if achieved_at:
    #     achieved_at = datetime.strptime(achieved_at, '%Y-%m-%d').date()
    # else:
    #     achieved_at = None
    description = data["description"]
    strategies = data["strategies"]
    new_goal = SupportGoal(
        pupil_id,
        goal_category_id,
        goal_id,
        created_by,
        created_at,
        achieved,
        achieved_at,
        description,
        strategies,
    )
    db.session.add(new_goal)
    # - LOG ENTRY
    create_log_entry(current_user, request, json_data)
    db.session.commit()
    return pupil


# - PATCH GOAL
#############
@support_goals_api.route("/<goal_id>", methods=["PATCH"])
@support_goals_api.input(support_goal_in_schema)
@support_goals_api.output(support_goal_schema)
@support_goals_api.doc(
    security="ApiKeyAuth",
    tags=["Support Goals"],
    summary="Patch a goal for a given support gategory from a given pupil",
)
@token_required
def put_goal(current_user, goal_id, json_data):
    goal = get_support_goal_by_id(goal_id)
    if goal == None:
        return jsonify({"error": "This goal does not exist!"})
    data = json_data
    for key in data:
        match key:
            case "created_at":
                goal.created_at = data[key]
            case "achieved":
                goal.achieved = data[key]
            case "achieved_at":
                goal.achieved_at = data[
                    key
                ]  # datetime.strptime(data[key], '%Y-%m-%d').date()
            case "description":
                goal.description = data[key]
            case "strategies":
                goal.strategies = data[key]
    # - LOG ENTRY
    create_log_entry(current_user, request, json_data)
    db.session.commit()
    return goal


# - DELETE GOAL
##############
@support_goals_api.delete("/<goal_id>/delete")
@support_goals_api.output(pupil_schema)
@support_goals_api.doc(
    security="ApiKeyAuth",
    tags=["Support Goals"],
    summary="Delete a goal for a given support gategory from a given pupil",
)
@token_required
def delete_goal(current_user, goal_id):
    goal = get_support_goal_by_id(goal_id)
    if goal == None:
        abort(404, message="This goal does not exist!")
    pupil = get_pupil_by_id(goal.pupil_id)
    db.session.delete(goal)
    # - LOG ENTRY
    create_log_entry(current_user, request, {"data": "none"})
    db.session.commit()
    return pupil


# - POST GOAL CHECK
##################
@support_goals_api.route("/<goal_id>/check/new", methods=["POST"])
@support_goals_api.input(support_goal_check_in_schema)
@support_goals_api.output(pupil_schema)
@support_goals_api.doc(
    security="ApiKeyAuth",
    tags=["Support Goal Checks"],
    summary="Post a check for a given support goal from a given pupil",
)
@token_required
def add_goalcheck(current_user, goal_id, json_data):
    this_goal = get_support_goal_by_id(goal_id)
    if this_goal == None:
        abort(404, message="Dieses Ziel existiert nicht!")
    pupil = get_pupil_by_id(this_goal.pupil_id)
    if pupil == None:
        abort(404, message="Dieser Schüler existiert nicht!")
    this_goal_id = goal_id
    check_id = str(uuid.uuid4().hex)
    created_by = current_user.name
    created_at = datetime.now().date()
    achieved = json_data["achieved"]
    comment = json_data["comment"]
    new_goalcheck = SupportGoalCheck(
        this_goal_id, check_id, created_by, created_at, achieved, comment
    )
    db.session.add(new_goalcheck)
    # - LOG ENTRY
    create_log_entry(current_user, request, json_data)
    db.session.commit()
    return pupil


# - PATCH GOAL CHECK
###################
@support_goals_api.route("/check/<check_id>", methods=["PATCH"])
@support_goals_api.input(support_goal_check_in_schema)
@support_goals_api.output(support_goal_check_schema)
@support_goals_api.doc(
    security="ApiKeyAuth",
    tags=["Support Goal Checks"],
    summary="Patch a check for a given goal from a given pupil",
)
@token_required
def patch_goalcheck(current_user, check_id, json_data):
    goal_check = SupportGoalCheck.query.filter_by(check_id=check_id).first()
    if goal_check == None:
        return jsonify({"error": "This goal check does not exist!"})
    data = json_data
    for key in data:
        match key:
            case "created_at":
                goal_check.created_at = datetime.strptime(data[key], "%Y-%m-%d").date()
            case "created_by":
                goal_check.created_by = data[key]
            case "comment":
                goal_check.comment = data[key]
            case "achieved":
                goal_check.achieved = data[key]
    # - LOG ENTRY
    create_log_entry(current_user, request, data)
    db.session.commit()
    return goal_check


#! TODO: DELETE GOAL CHECK API ENDPOINT
