from models.shared import db


class OldPupil(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    internal_id = db.Column(db.Integer, nullable=False, unique=True)
    credit = db.Column(db.Integer, default=0)
    credit_earned = db.Column(db.Integer, default=0)
    ogs = db.Column(db.Boolean)
    latest_support_level = db.Column(db.Integer, default=0)
    five_years = db.Column(db.String(2), nullable=True)
    communication_pupil = db.Column(db.String(8), nullable=True)
    communication_tutor1 = db.Column(db.String(8), nullable=True)
    communication_tutor2 = db.Column(db.String(8), nullable=True)
    preschool_revision = db.Column(db.Integer, default=0)
    date_created = db.Column(db.Date, nullable=False)

    def __init__(
        self,
        internal_id,
        credit,
        credit_earned,
        ogs,
        latest_support_level,
        five_years,
        communication_pupil,
        communication_tutor1,
        communication_tutor2,
        preschool_revision,
        date_created,
    ):
        self.internal_id = internal_id
        self.credit = credit
        self.credit_earned = credit_earned
        self.ogs = ogs
        self.latest_support_level = latest_support_level
        self.five_years = five_years
        self.communication_pupil = communication_pupil
        self.communication_tutor1 = communication_tutor1
        self.communication_tutor2 = communication_tutor2
        self.preschool_revision = preschool_revision
        self.date_created = date_created


class ProspectivePupil(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    internal_id = db.Column(db.Integer, nullable=False, unique=True)
    contact = db.Column(db.String(50), nullable=True, unique=True)
    parents_contact = db.Column(db.String(50), nullable=True, unique=False)
    ogs = db.Column(db.Boolean)
    ogs_info = db.Column(db.String(50), nullable=True)
    individual_development_plan = db.Column(db.Integer, default=0)
    communication_pupil = db.Column(db.String(8), nullable=True)
    communication_tutor1 = db.Column(db.String(8), nullable=True)
    communication_tutor2 = db.Column(db.String(8), nullable=True)
    preschool_revision = db.Column(db.Integer, default=0)
    preschool_attendance = db.Column(db.String(50), nullable=True)
    avatar_id = db.Column(db.String(50), nullable=True)
    avatar_url = db.Column(db.String(50), nullable=True)
    special_information = db.Column(db.String(200), nullable=True)
    emergency_care = db.Column(db.Boolean, default=False)
    date_created = db.Column(db.Date, nullable=False)

    def __init__(
        self,
        internal_id,
        contact,
        parents_contact,
        ogs,
        ogs_info,
        individual_development_plan,
        communication_pupil,
        communication_tutor1,
        communication_tutor2,
        preschool_revision,
        preschool_attendance,
        avatar_id,
        avatar_url,
        special_information,
        emergency_care,
        date_created,
    ):
        self.internal_id = internal_id
        self.contact = contact
        self.parents_contact = parents_contact
        self.ogs = ogs
        self.ogs_info = ogs_info
        self.individual_development_plan = individual_development_plan
        self.communication_pupil = communication_pupil
        self.communication_tutor1 = communication_tutor1
        self.communication_tutor2 = communication_tutor2
        self.preschool_revision = preschool_revision
        self.preschool_attendance = preschool_attendance
        self.avatar_id = avatar_id
        self.avatar_url = avatar_url
        self.special_information = special_information
        self.emergency_care = emergency_care
        self.date_created = date_created


class Pupil(db.Model):
    id: int = db.Column(db.Integer, primary_key=True)
    internal_id: int = db.Column(db.Integer, nullable=False, unique=True)
    contact = db.Column(db.String(50), nullable=True, unique=True)
    parents_contact = db.Column(db.String(50), nullable=True, unique=False)
    credit = db.Column(db.Integer, default=0)
    credit_earned = db.Column(db.Integer, default=0)
    ogs = db.Column(db.Boolean)
    pick_up_time = db.Column(db.String(5), nullable=True)
    ogs_info = db.Column(db.String(50), nullable=True)
    # - latest_support_level is the last value of a list of SupportLevel objects
    latest_support_level = db.Column(db.Integer, default=0)
    five_years = db.Column(db.Date, nullable=True)
    communication_pupil = db.Column(db.String(8), nullable=True)
    communication_tutor1 = db.Column(db.String(8), nullable=True)
    communication_tutor2 = db.Column(db.String(8), nullable=True)
    preschool_revision = db.Column(db.Integer, default=0)
    preschool_attendance = db.Column(db.String(50), nullable=True)
    avatar_id = db.Column(db.String(50), nullable=True)
    avatar_url = db.Column(db.String(50), nullable=True)
    avatar_auth = db.Column(db.Boolean, default=False)
    avatar_auth_id = db.Column(db.String(50), nullable=True)
    avatar_auth_url = db.Column(db.String(50), nullable=True)
    public_media_auth = db.Column(db.Integer, default=0)
    public_media_auth_id = db.Column(db.String(50), nullable=True)
    public_media_auth_url = db.Column(db.String(50), nullable=True)
    special_information = db.Column(db.String(200), nullable=True)
    emergency_care = db.Column(db.Boolean, default=False)

    # - RELATIONSHIPS ONE-TO-MANY
    pupil_missed_classes = db.relationship(
        "MissedClass", back_populates="missed_pupil", cascade="all, delete-orphan"
    )
    pupil_schoolday_events = db.relationship(
        "SchooldayEvent",
        back_populates="schoolday_event_pupil",
        cascade="all, delete-orphan",
    )
    # - TO-DO: DOUBLE CHECK DELETE ORPHAN
    support_goals = db.relationship(
        "SupportGoal", back_populates="pupil", cascade="all, delete-orphan"
    )
    competence_goals = db.relationship(
        "CompetenceGoal", back_populates="pupil", cascade="all, delete-orphan"
    )
    support_category_statuses = db.relationship(
        "SupportCategoryStatus", back_populates="pupil", cascade="all, delete-orphan"
    )
    pupil_workbooks = db.relationship(
        "PupilWorkbook", back_populates="pupil", cascade="all, delete-orphan"
    )
    pupil_books = db.relationship(
        "PupilBook", back_populates="pupil", cascade="all, delete-orphan"
    )
    pupil_lists = db.relationship(
        "PupilList", back_populates="listed_pupil", cascade="all, delete-orphan"
    )
    competence_checks = db.relationship(
        "CompetenceCheck", back_populates="pupil", cascade="all, delete-orphan"
    )
    competence_reports = db.relationship(
        "CompetenceReport", back_populates="pupil", cascade="all, delete-orphan"
    )
    competence_report_checks = db.relationship(
        "CompetenceReportCheck", back_populates="pupil", cascade="all, delete-orphan"
    )
    authorizations = db.relationship(
        "PupilAuthorization", back_populates="pupil", cascade="all, delete-orphan"
    )
    credit_history_logs = db.relationship(
        "CreditHistoryLog", back_populates="pupil", cascade="all, delete-orphan"
    )
    support_level_history = db.relationship(
        "SupportLevel", back_populates="pupil", cascade="all, delete-orphan"
    )

    def __init__(
        self,
        internal_id: int,
        contact: str,
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
        preschool_attendance,
        avatar_id,
        avatar_url,
        avatar_auth,
        avatar_auth_id,
        avatar_auth_url,
        public_media_auth,
        public_media_auth_id,
        public_media_auth_url,
        special_information,
        emergency_care,
    ):
        self.internal_id = internal_id
        self.contact = contact
        self.parents_contact = parents_contact
        self.credit = credit
        self.credit_earned = credit_earned
        self.ogs = ogs
        self.pick_up_time = pick_up_time
        self.ogs_info = ogs_info
        self.latest_support_level = latest_support_level
        self.five_years = five_years
        self.communication_pupil = communication_pupil
        self.communication_tutor1 = communication_tutor1
        self.communication_tutor2 = communication_tutor2
        self.preschool_revision = preschool_revision
        self.preschool_attendance = preschool_attendance
        self.avatar_id = avatar_id
        self.avatar_url = avatar_url
        self.avatar_auth = avatar_auth
        self.avatar_auth_id = avatar_auth_id
        self.avatar_auth_url = avatar_auth_url
        self.public_media_auth = public_media_auth
        self.public_media_auth_id = public_media_auth_id
        self.public_media_auth_url = public_media_auth_url
        self.special_information = special_information
        self.emergency_care = emergency_care


class CreditHistoryLog(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    operation = db.Column(db.Integer, nullable=False)
    created_by = db.Column(db.String(20), nullable=False)
    created_at = db.Column(db.Date, nullable=False)
    credit = db.Column(db.Integer, nullable=True)

    # - RELATIONSHIP TO PUPIL MANY-TO-ONE
    pupil_id = db.Column("pupil_id", db.Integer, db.ForeignKey("pupil.internal_id"))
    pupil = db.relationship("Pupil", back_populates="credit_history_logs")

    def __init__(self, pupil_id, operation, created_by, created_at, credit):
        self.pupil_id = pupil_id
        self.operation = operation
        self.created_by = created_by
        self.created_at = created_at
        self.credit = credit


class SupportLevel(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    support_level_id = db.Column(db.String(50), nullable=False)
    created_by = db.Column(db.String(20), nullable=False)
    created_at = db.Column(db.Date, nullable=False)
    level = db.Column(db.String(20), nullable=False)
    comment = db.Column(db.String(200), nullable=False)

    # - RELATIONSHIP TO PUPIL MANY-TO-ONE
    pupil_id = db.Column("pupil_id", db.Integer, db.ForeignKey("pupil.internal_id"))
    pupil = db.relationship("Pupil", back_populates="support_level_history")

    def __init__(
        self, pupil_id, support_level_id, created_by, created_at, level, comment
    ):
        self.pupil_id = pupil_id
        self.support_level_id = support_level_id
        self.created_by = created_by
        self.created_at = created_at
        self.level = level
        self.comment = comment
