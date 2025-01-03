from apiflask import Schema, fields

# - SUPPORT GOAL CHECK FILE SCHEMA
##################################


class SupportGoalCheckFileSchema(Schema):

    file_id = fields.String()

    check_id = fields.String()

    class Meta:
        fields = ("file_id", "check_id")


# - SUPPORT GOAL CHECK SCHEMA
#############################


class SupportGoalCheckInSchema(Schema):

    achieved = fields.Integer()
    comment = fields.String()

    class Meta:
        fields = ("comment", "achieved")


support_goal_check_in_schema = SupportGoalCheckInSchema()
support_goal_checks_in_schema = SupportGoalCheckInSchema(many=True)


class SupportGoalCheckSchema(Schema):

    created_by = fields.String()
    created_at = fields.Date()
    comment = fields.String()
    goal_id = fields.String()
    check_id = fields.String()
    achieved = fields.Integer()
    support_goal_check_files = fields.List(fields.Nested(SupportGoalCheckFileSchema))

    class Meta:
        fields = (
            "created_by",
            "created_at",
            "comment",
            "goal_id",
            "check_id",
            "achieved",
            "support_goal_check_files",
        )


support_goal_check_schema = SupportGoalCheckSchema()
support_goal_checks_schema = SupportGoalCheckSchema(many=True)

# - SUPPORT GOAL SCHEMA
######################


class SupportGoalInSchema(Schema):
    goal_id = fields.String()
    support_category_id = fields.Integer()
    created_by = fields.String()
    created_at = fields.Date()
    achieved = fields.Integer()
    achieved_at = fields.Date(allow_none=True)
    description = fields.String()
    strategies = fields.String()

    class Meta:
        fields = (
            "goal_id",
            "support_category_id",
            "created_by",
            "created_at",
            "achieved",
            "achieved_at",
            "description",
            "strategies",
        )


support_goal_in_schema = SupportGoalInSchema()
support_goals_in_schema = SupportGoalInSchema(many=True)


class SupportGoalSchema(Schema):
    goal_id = fields.String()
    pupil_id = fields.Integer()
    support_category_id = fields.Integer()
    created_by = fields.String()
    created_at = fields.Date()
    achieved = fields.Integer()
    achieved_at = fields.Date(allow_none=True)
    description = fields.String()
    strategies = fields.String()
    goal_checks = fields.List(fields.Nested(SupportGoalCheckSchema))

    class Meta:
        fields = (
            "goal_id",
            "pupil_id",
            "support_category_id",
            "created_by",
            "created_at",
            "achieved",
            "achieved_at",
            "description",
            "strategies",
            "goal_checks",
        )


support_goal_schema = SupportGoalSchema()
support_goals_schema = SupportGoalSchema(many=True)

# - SUPPORT CATEGORY STATUS SCHEMA
#################################


class SupportCategoryStatusInSchema(Schema):
    state = fields.String()
    comment = fields.String(allow_none=True)

    created_by = fields.String(allow_none=True)
    created_at = fields.Date(allow_none=True)

    class Meta:
        fields = ("state", "comment", "created_by", "created_at")


support_category_status_in_schema = SupportCategoryStatusInSchema()
support_category_statuses_in_schema = SupportCategoryStatusInSchema(many=True)


class SupportCategoryStatusSchema(Schema):
    support_category_id = fields.Integer()
    status_id = fields.String()
    state = fields.String()
    comment = fields.String(allow_none=True)
    file_url = fields.String(allow_none=True)
    created_by = fields.String()
    created_at = fields.Date()

    class Meta:
        fields = (
            "support_category_id",
            "status_id",
            "state",
            "comment",
            "file_url",
            "created_by",
            "created_at",
        )


support_category_status_schema = SupportCategoryStatusSchema()
support_category_statuses_schema = SupportCategoryStatusSchema(many=True)

# - SUPPORT CATEGORY SCHEMA
##########################


class SupportCategorySchema(Schema):
    category_id = fields.Integer()
    category_name = fields.String()
    category_goals = fields.List(fields.Nested(SupportGoalSchema))
    category_statuses = fields.List(fields.Nested(SupportCategoryStatusSchema))

    class Meta:
        fields = ("category_id", "category_name", "category_goals", "category_statuses")


support_category_schema = SupportCategorySchema()
support_categories_schema = SupportCategorySchema(many=True)

# - SUPPORT CATEGORY SCHEMA FLAT
###############################


class SupportCategoryFlatSchema(Schema):
    category_id = fields.Integer()
    category_name = fields.String()
    parent_category = fields.Integer()

    class Meta:
        fields = ("category_id", "category_name", "parent_category")


support_category_flat_schema = SupportCategoryFlatSchema()
support_categories_flat_schema = SupportCategoryFlatSchema(many=True)
