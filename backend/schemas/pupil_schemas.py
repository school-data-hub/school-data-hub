from apiflask import Schema, fields
from apiflask.fields import String
from schemas.schoolday_event_schemas import SchooldayEventSchema
from schemas.authorization_schemas import PupilAuthorizationSchema
from schemas.book_schemas import PupilBookSchema
from schemas.competence_schemas import CompetenceCheckSchema, CompetenceGoalSchema, CompetenceReportSchema
from schemas.credit_schema import CreditHistoryLogSchema
from schemas.support_schemas import SupportCategoryStatusSchema, SupportGoalSchema
from schemas.missed_class_schemas import MissedClassSchema
from schemas.school_list_schemas import PupilProfileListSchema
from schemas.workbook_schemas import PupilWorkbookSchema

class SupportLevelInSchema(Schema):
    comment = fields.String()
    created_by = fields.String()
    created_at = fields.Date()
    level = fields.Integer()
    class Meta:
        fields = ('level', 'comment', 'created_by', 'created_at')

support_level_in_schema = SupportLevelInSchema()
support_levels_in_schema = SupportLevelInSchema(many = True)

class SupportLevelOutSchema(Schema):
    support_level_id = fields.String()
    comment = fields.String()
    created_by = fields.String()
    created_at = fields.Date()
    level = fields.Integer()
    class Meta:
        fields = ('support_level_id', 'level', 'comment', 'created_by', 'created_at')

support_level_in_schema = SupportLevelInSchema()
support_levels_in_schema = SupportLevelInSchema(many = True)

class PupilSchema(Schema):
    avatar_id = fields.String(metadata={'nullable': True})
    internal_id = fields.Integer(metadata={'required': True})
    name = fields.String(required = True)
    contact =  fields.String(metadata={'nullable': True})
    parents_contact = fields.String(metadata={'nullable': True})
    credit = fields.Integer()
    credit_earned = fields.Integer()
    ogs = fields.Boolean()
    pick_up_time = fields.String()
    ogs_info = fields.String()
    latest_support_level = fields.Integer()
    five_years = fields.String()
    communication_pupil = fields.String(allow_none=True)
    communication_tutor1 = fields.String(allow_none=True)
    communication_tutor2 = fields.String(allow_none=True)
    preschool_revision = fields.Integer()
    support_level_history = fields.List(fields.Nested(SupportLevelOutSchema))
    pupil_missed_classes = fields.List(fields.Nested(MissedClassSchema))
    pupil_schoolday_events = fields.List(fields.Nested(SchooldayEventSchema))
    support_goals = fields.List(fields.Nested(SupportGoalSchema))
    competence_goals = fields.List(fields.Nested(CompetenceGoalSchema))
    support_category_statuses = fields.List(fields.Nested(SupportCategoryStatusSchema))
    pupil_workbooks = fields.List(fields.Nested(PupilWorkbookSchema))
    pupil_books = fields.List(fields.Nested(PupilBookSchema))
    pupil_lists = fields.List(fields.Nested(PupilProfileListSchema))
    competence_checks = fields.List(fields.Nested(CompetenceCheckSchema))
    competence_reports = fields.List(fields.Nested(CompetenceReportSchema))
    # authorizations = fields.List(fields.Nested(PupilAuthorizationSchema))
    credit_history_logs = fields.List(fields.Nested(CreditHistoryLogSchema))
    special_information = fields.String(allow_none=True)
    emergency_care = fields.Boolean(allow_none=True)
    class Meta:
        fields = (
            'avatar_id', 'internal_id', 'name', 'contact', 'parents_contact','credit', 'credit_earned', 'ogs',
            'pick_up_time', 'ogs_info', 'latest_support_level', 'five_years', 'communication_pupil', 'communication_tutor1',
            'communication_tutor2', 'preschool_revision', 'support_level_history', 'pupil_missed_classes', 'pupil_schoolday_events', 'support_goals',
            'competence_goals', 'support_category_statuses', 'pupil_workbooks', 'pupil_books', 'pupil_lists', 'competence_checks',
            'competence_reports', 
            # 'authorizations', 
            'credit_history_logs', 'special_information', 'emergency_care')
            
pupil_schema = PupilSchema()
pupils_schema = PupilSchema(many = True)

class PupilFlatSchema(Schema):
    
    internal_id = fields.Integer()
    contact =  String(allow_none=True)
    parents_contact = String(allow_none=True)
    credit = fields.Integer()
    credit_earned = fields.Integer()
    ogs = fields.Boolean()
    pick_up_time = fields.String(allow_none=True)
    ogs_info = fields.String(allow_none=True)
    individual_development_plan = fields.Integer()
    five_years = fields.String(allow_none=True)
    communication_pupil = fields.String(allow_none=True)
    communication_tutor1 = fields.String(allow_none=True)
    communication_tutor2 = fields.String(allow_none=True)
    preschool_revision = fields.Integer(allow_none=True)
    avatar_id = fields.String(allow_none=True)
    special_information = fields.String(allow_none=True)
    emergency_care = fields.Boolean(allow_none=True)
    class Meta:
        fields = ('internal_id', 'contact', 'parents_contact','credit', 
                  'credit_earned', 'ogs', 'pick_up_time', 'ogs_info', 
                  'individual_development_plan', 'five_years', 
                   'communication_pupil', 'communication_tutor1', 
                   'communication_tutor2', 'preschool_revision', 
                   'avatar_id', 'special_information', 'emergency_care')

pupil_flat_schema = PupilFlatSchema()
pupils_flat_schema = PupilFlatSchema(many = True)

class PupilOnlyGoalSchema(Schema):
    internal_id = fields.String()   
    support_goals = fields.List(fields.Nested(SupportGoalSchema))    
    class Meta:
        fields = ('internal_id', 'support_goals')

pupil_only_goal_schema = PupilOnlyGoalSchema()
pupils_only_goal_schema = PupilOnlyGoalSchema(many = True)

class PupilIdListSchema(Schema):
    pupils = fields.List(fields.Integer())
    
pupil_id_list_schema = PupilIdListSchema()

class PupilSiblingsPatchSchema(Schema):
    pupils = fields.List(fields.Integer())
    communication_tutor1 = fields.String(allow_none=True)
    communication_tutor2 = fields.String(allow_none=True)    
    parents_contact = String(allow_none=True)
    emergency_care = fields.Boolean(allow_none=True)

pupil_siblings_patch_schema = PupilSiblingsPatchSchema()

class ProspectivePupilSchema(Schema):
    internal_id = fields.Integer(required = True)
    contact =  fields.String(metadata={'nullable': True})
    parents_contact = fields.String(metadata={'nullable': True})
    ogs = fields.Boolean()
    ogs_info = fields.String()
    individual_development_plan = fields.Integer()
    communication_pupil = fields.String(allow_none=True)
    communication_tutor1 = fields.String(allow_none=True)
    communication_tutor2 = fields.String(allow_none=True)
    preschool_revision = fields.Integer()
    avatar_id = fields.String(allow_none=True)
    avatar_url = fields.String(allow_none=True)
    special_information = fields.String(allow_none=True)
    emergency_care = fields.Boolean(allow_none=True)
    date_created = fields.Date()
    class Meta:
        fields = ('internal_id', 'contact', 'parents_contact', 'ogs', 'ogs_info', 'individual_development_plan',
                  'communication_pupil', 'communication_tutor1', 'communication_tutor2', 'preschool_revision',
                  'avatar_id', 'avatar_url', 'special_information', 'emergency_care', 'date_created')
    
prospective_pupil_schema = ProspectivePupilSchema()
prospective_pupils_schema = ProspectivePupilSchema(many = True)
