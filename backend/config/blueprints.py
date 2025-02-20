from api_endpoints.authorizations_api import authorization_api
from api_endpoints.books.books_api import book_api
from api_endpoints.books.library_books_api import library_book_api
from api_endpoints.books.pupil_books_api import pupil_book_api
from api_endpoints.competence_checks_api import competence_check_api
from api_endpoints.competence_goals_api import competence_goal_api
from api_endpoints.competence_reports_api import competence_report_api
from api_endpoints.competences_api import competence_api
from api_endpoints.import_from_file_api import import_file_api
from api_endpoints.log_api import log_api
from api_endpoints.missed_classes_api import missed_class_api
from api_endpoints.pupil_authorizations_api import pupil_authorization_api
from api_endpoints.pupil_lists_api import pupil_list_api
from api_endpoints.pupil_workbooks_api import pupil_workbook_api
from api_endpoints.pupils_api import pupil_api
from api_endpoints.school_lists_api import school_list_api
from api_endpoints.school_semester_api import school_semester_api
from api_endpoints.schoolday_events_api import schoolday_event_api
from api_endpoints.schooldays_api import schoolday_api
from api_endpoints.support_categories_api import support_category_api
from api_endpoints.support_category_statuses_api import support_category_status_api
from api_endpoints.support_goals_api import support_goals_api
from api_endpoints.users_api import user_api
from api_endpoints.workbooks_api import workbook_api


def register_blueprints(app):
    app.register_blueprint(user_api, url_prefix="/api/users")
    app.register_blueprint(pupil_api, url_prefix="/api/pupils")
    app.register_blueprint(workbook_api, url_prefix="/api/workbooks")
    app.register_blueprint(pupil_workbook_api, url_prefix="/api/pupil_workbooks")
    app.register_blueprint(book_api, url_prefix="/api/books")
    app.register_blueprint(library_book_api, url_prefix="/api/library_books")
    app.register_blueprint(pupil_book_api, url_prefix="/api/pupil_books")
    app.register_blueprint(support_category_api, url_prefix="/api/support_categories")
    app.register_blueprint(competence_api, url_prefix="/api/competences")
    app.register_blueprint(competence_goal_api, url_prefix="/api/competence_goals")
    app.register_blueprint(competence_check_api, url_prefix="/api/competence_checks")
    app.register_blueprint(competence_report_api, url_prefix="/api/competence_reports")
    app.register_blueprint(schoolday_api, url_prefix="/api/schooldays")
    app.register_blueprint(import_file_api, url_prefix="/api/import")
    app.register_blueprint(schoolday_event_api, url_prefix="/api/schoolday_events")
    app.register_blueprint(
        support_category_status_api, url_prefix="/api/support_category/statuses"
    )
    app.register_blueprint(school_list_api, url_prefix="/api/school_lists")
    app.register_blueprint(pupil_list_api, url_prefix="/api/pupil_lists")
    app.register_blueprint(missed_class_api, url_prefix="/api/missed_classes")
    app.register_blueprint(authorization_api, url_prefix="/api/authorizations")
    app.register_blueprint(
        pupil_authorization_api, url_prefix="/api/pupil_authorizations"
    )
    app.register_blueprint(school_semester_api, url_prefix="/api/school_semesters")
    app.register_blueprint(support_goals_api, url_prefix="/api/support_goals")
    app.register_blueprint(log_api, url_prefix="/api")
