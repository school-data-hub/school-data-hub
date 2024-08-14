from datetime import datetime
import os
import uuid
from apiflask import APIBlueprint, FileSchema, abort
from flask import current_app, jsonify, request, send_file
from app import db
from auth_middleware import token_required
from helpers.db_helpers import get_pupil_by_id, get_support_category_by_id
from helpers.log_entries import create_log_entry
from schemas.pupil_schemas import *
from schemas.support_schemas import *
from models.pupil import Pupil
from models.support_category import SupportCategoryStatus, SupportCategory
from schemas.log_entry_schemas import ApiFileSchema

support_category_status_api = APIBlueprint('support_category_status_api', __name__, url_prefix='/api/support_category/statuses')

#- POST SUPPORT GATEGORY STATUS
###############################

@support_category_status_api.route('/<internal_id>/<category_id>', methods=['POST'])
@support_category_status_api.input(support_category_status_in_schema)
@support_category_status_api.output(pupil_schema)
@support_category_status_api.doc(security='ApiKeyAuth', tags=['Support Category Statuses'], summary='Post a status for a given catagory from a given pupil')
@token_required
def add_support_category_status(current_user, internal_id, category_id, json_data):
    this_pupil = get_pupil_by_id(internal_id) 
    if this_pupil == None:
        abort(400, message="Diese/r Schüler/in existiert nicht!")
    pupil_id = internal_id
    this_category = get_support_category_by_id(category_id)

    if this_category == None:
        abort(400, message="Diese Kategorie existiert nicht!")
    goal_category_id = this_category.category_id
    # category_status_exists = db.session.query(SupportCategoryStatus).filter(SupportCategoryStatus.pupil_id == internal_id, SupportCategoryStatus.goal_category_id == category_id ).first() is not None
    # if category_status_exists == True :
    #     return jsonify( {"message": "This category status exists already - please update instead!"}), 400
    
    status_id = uuid.uuid4().hex
    data = json_data
    state = data['state']
    comment = data['comment']
    created_at = datetime.strptime(datetime.now().strftime('%Y-%m-%d'), '%Y-%m-%d').date() 
    created_by = current_user.name
    # created_at = datetime.strptime(created_at, '%Y-%m-%d').date()
    print(goal_category_id)
    new_category_status = SupportCategoryStatus(pupil_id= pupil_id, support_category_id= goal_category_id, status_id= status_id, state= state, created_by= created_by, created_at= created_at, comment= comment, file_url= None)
    db.session.add(new_category_status)
    #- LOG ENTRY
    create_log_entry(current_user, request, json_data)
    db.session.commit()
    return this_pupil
    
#- PATCH GATEGORY STATUS
########################
@support_category_status_api.route('/<status_id>', methods=['PATCH'])
@support_category_status_api.input(support_category_status_in_schema)
@support_category_status_api.output(pupil_schema)
@support_category_status_api.doc(security='ApiKeyAuth', tags=['Support Category Statuses'], summary='Patch a status for a given catagory from a given pupil')
@token_required
def put_category_state(current_user, status_id, json_data):

    status = SupportCategoryStatus.query.filter_by(status_id = status_id).first()
    if status == None:
        abort(400, message="Dieser Kategoriestatus existiert nicht!")
    pupil = get_pupil_by_id(status.pupil_id)
    if pupil == None:
        abort(400, message="Dieser Schüler existiert nicht!")
    data = json_data
    for key in data:
        match key:
            case 'state':
                status.state = data['state']
            case 'comment':
                status.comment = data['comment']
            case 'created_by':
                status.created_by = data['created_by']
            case 'created_at':
                status.created_at = data['created_at']
    #- LOG ENTRY
    create_log_entry(current_user, request, json_data)
    db.session.commit()
    return pupil

#- PATCH FILE CATEGORY STATUS 
#############################
@support_category_status_api.route('/<status_id>/file', methods=['PATCH'])
@support_category_status_api.input(ApiFileSchema, location='files')
@support_category_status_api.output(support_category_status_schema)
@support_category_status_api.doc(security='ApiKeyAuth', tags=['Support Category Statuses'], summary='PATCH-POST a file to document a given pupil category status')
@token_required
def upload_category_status_file(current_user, status_id, files_data):
    status = SupportCategoryStatus.query.filter_by(status_id = status_id).first()
    if status == None:
        abort(400, message="Dieser Kategoriestatus existiert nicht!")
    if 'file' not in files_data:
        abort(400, message="Keine Datei angegeben!")
    file = files_data['file']   
    filename = str(uuid.uuid4().hex) + '.jpg'
    file_url = current_app.config['UPLOAD_FOLDER'] + '/catg/' + filename
    file.save(file_url)
    if len(str(status.file_url)) > 4:
        os.remove(str(status.file_url))
    status.file_url = file_url
    #- LOG ENTRY
    create_log_entry(current_user, request, {'data': 'file'})
    db.session.commit()
    return status

#- GET CATEGORY STATUS FILE  
###########################
@support_category_status_api.route('/<status_id>/file', methods=['GET'])
@support_category_status_api.output(FileSchema, content_type='image/jpeg')
@support_category_status_api.doc(security='ApiKeyAuth', tags=['Support Category Statuses'], summary='Get file of a given pupil category status')
@token_required
def download_category_status_file(current_user, status_id):
    status = SupportCategoryStatus.query.filter_by(status_id = status_id).first()
    if status == None:
        abort(400, message="Dieser Kategoriestatus existiert nicht!")
    if len(str(status.file_url)) < 5:
        abort(400, message="Dieser Kategoriestatus hat keine Datei!")
       
    url_path = status.file_url
    return send_file(url_path, mimetype='image/jpg')

#- DELETE GATEGORY STATUS
#########################
@support_category_status_api.route('/<status_id>/delete', methods=['DELETE'])
@support_category_status_api.output(pupil_schema, 200)
@support_category_status_api.doc(security='ApiKeyAuth', tags=['Support Category Statuses'], summary='Delete a status for a given catagory from a given pupil')
@token_required
def delete_category_status(current_user, status_id):
    status = SupportCategoryStatus.query.filter_by(status_id = status_id).first()
    if status == None:
        abort(400, message="Dieser Kategoriestatus existiert nicht!")
    pupil = get_pupil_by_id(status.pupil_id)
    db.session.delete(status)
    #- LOG ENTRY
    create_log_entry(current_user, request, {'data': 'none'})
    db.session.commit()
    return pupil
