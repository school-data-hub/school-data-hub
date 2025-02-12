from apiflask import Schema, fields
from marshmallow import post_dump

from schemas.log_entry_schemas import ApiFileSchema

# - COMPETENCE CHECK FILE SCHEMA
###############################


class CompetenceCheckFileSchema(Schema):
    check_id = fields.String()
    file_id = fields.String()

    class Meta:
        fields = ("check_id", "file_id")


competence_check_file_schema = CompetenceCheckFileSchema()
competence_check_files_schema = CompetenceCheckFileSchema(many=True)

# - COMPETENCE GOAL SCHEMA
#########################


class CompetenceGoalInSchema(Schema):
    competence_goal_id = fields.String()
    achieved = fields.Integer(allow_none=True)
    achieved_at = fields.Date(allow_none=True)
    description = fields.String()
    strategies = fields.String()
    competence_id = fields.Integer()
    modified_by = fields.String(allow_none=True)

    class Meta:
        fields = (
            "achieved",
            "achieved_at",
            "description",
            "strategies",
            "competence_id",
            "modified_by",
        )


competence_goal_in_schema = CompetenceGoalInSchema()
competence_goals_in_schema = CompetenceGoalInSchema(many=True)


class CompetenceGoalOutSchema(Schema):
    competence_goal_id = fields.String()
    created_by = fields.String()
    created_at = fields.Date()
    achieved = fields.Integer(allow_none=True)
    achieved_at = fields.Date(allow_none=True)
    description = fields.String()
    strategies = fields.String()
    competence_id = fields.Integer()
    modified_by = fields.String(allow_none=True)

    class Meta:
        fields = (
            "competence_goal_id",
            "created_by",
            "created_at",
            "achieved",
            "achieved_at",
            "description",
            "strategies",
            "competence_id",
            "modified_by",
        )


competence_goal_out_schema = CompetenceGoalOutSchema()
competence_goals_out_schema = CompetenceGoalOutSchema(many=True)


class CompetenceGoalSchema(Schema):
    competence_goal_id = fields.String()
    created_by = fields.String()
    created_at = fields.Date()
    achieved = fields.Integer(allow_none=True)
    achieved_at = fields.Date(allow_none=True)
    description = fields.String()
    strategies = fields.String()
    pupil_id = fields.Integer()
    competence_id = fields.Integer()
    modified_by = fields.String(allow_none=True)

    class Meta:
        fields = (
            "competence_goal_id",
            "created_by",
            "created_at",
            "achieved",
            "achieved_at",
            "description",
            "strategies",
            "pupil_id",
            "competence_id",
            "modified_by",
        )


competence_goal_schema = CompetenceGoalSchema()
competence_goals_schema = CompetenceGoalSchema(many=True)

# - COMPETENCE CHECK SCHEMA
############################


class CompetenceCheckInSchema(Schema):
    is_report = fields.Boolean()
    report_id = fields.String(allow_none=True)
    competence_status = fields.Integer()
    comment = fields.String()
    created_at = fields.Date()
    created_by = fields.String()
    competence_id = fields.Integer()
    value_factor = fields.Float(allow_none=True)
    group_id = fields.String(allow_none=True)
    group_name = fields.String(allow_none=True)

    class Meta:
        fields = (
            "is_report",
            "report_id",
            "competence_status",
            "comment",
            "competence_id",
            "created_at",
            "created_by",
            "report_id",
            "value_factor",
            "group_id",
            "group_name",
        )


competence_check_in_schema = CompetenceCheckInSchema()
competence_checks_in_schema = CompetenceCheckInSchema(many=True)


class CompetenceChceckInWithFilesSchema(Schema):
    competence_status = fields.Integer()
    comment = fields.String()
    created_at = fields.Date()
    created_by = fields.String()
    competence_id = fields.Integer()
    value_factor = fields.Float(allow_none=True)
    group_id = fields.String(allow_none=True)
    group_name = fields.String(allow_none=True)
    competence_check_file = ApiFileSchema()

    class Meta:
        fields = (
            "competence_status",
            "comment",
            "created_at",
            "created_by",
            "competence_id",
            "value_factor",
            "group_id",
            "group_name",
            "competence_check_file",
        )


competence_check_file_schema = CompetenceChceckInWithFilesSchema()
competence_check_files_schema = CompetenceChceckInWithFilesSchema(many=True)


class CompetenceCheckSchema(Schema):
    check_id = fields.String()
    created_by = fields.String()
    created_at = fields.Date()
    competence_status = fields.Integer()
    comment = fields.String()
    pupil_id = fields.Integer()
    competence_id = fields.Integer()
    value_factor = fields.Float(allow_none=True)
    group_id = fields.String(allow_none=True)
    group_name = fields.String(allow_none=True)
    competence_check_files = fields.List(fields.Nested(CompetenceCheckFileSchema))

    class Meta:
        fields = (
            "check_id",
            "created_by",
            "created_at",
            "competence_status",
            "comment",
            "pupil_id",
            "competence_id",
            "value_factor",
            "group_id",
            "group_name",
            "report_id",
            "competence_check_files",
        )


competence_check_schema = CompetenceCheckSchema()
competence_checks_schema = CompetenceCheckSchema(many=True)

# - COMPETENCE REPORT CHECK SCHEMAS


class CompetenceReportCheckInSchema(Schema):
    competence_status = fields.Integer()
    comment = fields.String()

    class Meta:
        fields = ("competence_status", "comment")


competence_report_check_in_schema = CompetenceReportCheckInSchema()
competence_report_checks_in_schema = CompetenceReportCheckInSchema(many=True)


class CompetenceReportCheckSchema(Schema):
    report_check_id = fields.String()
    created_by = fields.String()
    created_at = fields.Date()
    competence_status = fields.Integer()
    comment = fields.String()

    class Meta:
        fields = (
            "check_id",
            "created_by",
            "created_at",
            "competence_status",
            "comment",
        )


competence_report_check_schema = CompetenceReportCheckSchema()
competence_report_checks_schema = CompetenceReportCheckSchema(many=True)


# - COMPETENCE REPORT SCHEMA
############################


class CompetenceReportInSchema(Schema):

    created_by = fields.String()
    created_at = fields.Date()
    pupil_id = fields.Integer()
    school_semester_id = fields.Integer()

    class Meta:
        fields = (
            "report_id",
            "created_by",
            "created_at",
            "pupil_id",
            "school_semester_id",
        )


competence_report_in_schema = CompetenceReportInSchema()
competence_reports_in_schema = CompetenceReportInSchema(many=True)


class CompetenceReportSchema(Schema):
    report_id = fields.String()
    created_by = fields.String()
    created_at = fields.Date()
    pupil_id = fields.Integer()
    school_semester_id = fields.Integer()
    competence_report_checks = fields.List(fields.Nested(CompetenceReportCheckSchema))

    class Meta:
        fields = (
            "report_id",
            "created_by",
            "created_at",
            "pupil_id",
            "school_semester_id",
            "competence_report_checks",
        )

    # @post_dump(pass_many=False)
    # def filter_report_checks(self, data, **kwargs):

    #     if "competence_checks" in data:

    #         data["competence_checks"] = [
    #             check
    #             for check in data["competence_checks"]
    #             if (check["is_report"] == True)
    #         ]

    #     return data


competence_report_schema = CompetenceReportSchema()
competence_reports_schema = CompetenceReportSchema(many=True)


class CompetenceReportFlatSchema(Schema):
    report_id = fields.String()
    created_by = fields.String()
    created_at = fields.Date()
    pupil_id = fields.Integer()
    school_semester_id = fields.Integer()

    class Meta:
        fields = (
            "report_id",
            "created_by",
            "created_at",
            "pupil_id",
            "school_semester_id",
        )


competence_report_flat_schema = CompetenceReportFlatSchema()
competence_reports_flat_schema = CompetenceReportFlatSchema(many=True)

# - COMPETENCE SCHEMA
############################


class CompetenceSchema(Schema):
    competence_id = fields.Integer()
    competence_name = fields.String()
    competence_level = fields.String(allow_none=True)
    parent_competence = fields.Integer(allow_none=True)
    indicators = fields.String(allow_none=True)
    competence_goals = fields.List(fields.Nested(CompetenceGoalSchema))
    competence_checks = fields.List(fields.Nested(CompetenceCheckSchema))
    order = fields.Integer(allow_none=True)

    class Meta:
        fields = (
            "competence_id",
            "competence_name",
            "competence_level",
            "parent_competence",
            "indicators",
            "competence_goals",
            "competence_checks",
            "order",
        )


competence_schema = CompetenceSchema()
competences_schema = CompetenceSchema(many=True)

# - COMPETENCE FLAT SCHEMA
##########################


class CompetenceFlatSchema(Schema):
    competence_id = fields.Integer()
    competence_name = fields.String(allow_none=True)
    competence_level = fields.String(allow_none=True)
    parent_competence = fields.Integer(allow_none=True)
    indicators = fields.String(allow_none=True)
    order = fields.Integer(allow_none=True)

    class Meta:
        fields = (
            "competence_id",
            "parent_competence",
            "competence_name",
            "competence_level",
            "indicators",
            "order",
        )


competence_flat_schema = CompetenceFlatSchema()
competences_flat_schema = CompetenceFlatSchema(many=True)
