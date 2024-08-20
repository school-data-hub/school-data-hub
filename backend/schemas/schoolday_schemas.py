from apiflask import Schema, fields
from apiflask.fields import File, String, Integer

from schemas.schoolday_event_schemas import SchooldayEventSchema
from schemas.missed_class_schemas import MissedClassNoMissedDaySchema


class SchooldaySchema(Schema):
    schoolday = fields.String()
    missed_classes = fields.List(fields.Nested(MissedClassNoMissedDaySchema))
    schoolday_events = fields.List(fields.Nested(SchooldayEventSchema))
    class Meta:
        fields = ('schoolday', 'missed_classes', 'schoolday_events')

schoolday_schema = SchooldaySchema()
schooldays_schema = SchooldaySchema(many = True)

class SchooldayOnlySchema(Schema):
    schoolday = fields.String()
    class Meta:
        fields = ('schoolday',)

schoolday_only_schema = SchooldayOnlySchema()
schooldays_only_schema = SchooldayOnlySchema(many = True)

class SchooldaysListSchema(Schema):
    schooldays = fields.List(fields.String())
schooldays_list_schema = SchooldaysListSchema()

##########################
#- SCHOOL SEMESTER SCHEMA
##########################

class SchoolSemesterSchema(Schema):
    start_date = fields.Date()
    end_date = fields.Date()
    class_conference_date = fields.Date()
    report_conference_date = fields.Date()
    is_first = fields.Boolean()
    class Meta:
        fields = ('start_date', 'end_date', 'class_conference_date', 'report_conference_date' ,'is_first')

school_semester_schema = SchoolSemesterSchema()
school_semesters_schema = SchoolSemesterSchema(many=True)
