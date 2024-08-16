from apiflask import APIBlueprint, abort
from flask import jsonify
from app import db
from auth_middleware import token_required
from models.support_category import SupportCategory
from schemas.support_schemas import *

support_category_api = APIBlueprint('goal_categories_api', __name__, url_prefix='/api/support_categories')

#- GET SUPPORT CATEGORIES 
#########################

@support_category_api.route('/all', methods=['GET'])
@support_category_api.doc(security='ApiKeyAuth', tags=['Support Categories'], summary='Get support categories')
@token_required
def get_categories(current_user):
    if not current_user:
        abort(404, message='Bitte erneut einloggen!')
    root = {
        "category_id": 0,
        "category_name": "development_goal_categories",
        "subcategories": [],
    }
    dict = {0: root}
    all_categories = SupportCategory.query.all()
    if all_categories == []:
        abort(404, message="No categories found!")
    for item in all_categories:
        dict[item.category_id] = current = {
            "category_id": item.category_id,
            "parent_category": item.parent_category,
            "category_name": item.category_name,
            "subcategories": [],
        }
        # Adds actual category to the subcategories list of the parent
        parent = dict.get(item.parent_category, root)
        parent["subcategories"].append(current)

    return jsonify(root)

#- GET CATEGORIES FLAT
######################

@support_category_api.route('/all/flat', methods=['GET'])
@support_category_api.output(support_categories_flat_schema)
@support_category_api.doc(security='ApiKeyAuth', tags=['Support Categories'], summary='Get support categories in flat JSON')

@token_required
def get_flat_categories(current_user):
    if not current_user:
        abort(404, message='Bitte erneut einloggen!')
    all_categories = SupportCategory.query.all()
    if all_categories == None:
        return jsonify({'error': 'No categories found!'})
    # result = support_categories_flat_schema.dump(all_categories)
    return all_categories    


#! TODO: Add rest of categories API