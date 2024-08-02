from models.shared import db

class SchoolSemester(db.Model):
    id = db.Column(db.Integer, primary_key = True)
    start_date = db.Column(db.Date, db.ForeignKey('schoolday.schoolday'), nullable = False, )
    end_date = db.Column(db.Date, db.ForeignKey('schoolday.schoolday'), nullable = False, )
    class_conference_date = db.Column(db.Date, nullable = True)
    report_conference_date = db.Column(db.Date, nullable = True)
    is_first = db.Column(db.Boolean)
    #- RELATIONSHIP WITH SCHOOLDAY
    start = db.relationship('Schoolday', foreign_keys=[start_date], backref='start_semester', uselist=False)
    end = db.relationship('Schoolday', foreign_keys=[end_date], backref='end_semester', uselist=False)

    # #- RELATIONSHIP COMPETENCE REPORT ONE-TO-MANY
    # competence_reports = db.relationship('CompetenceReport', back_populates='school_semester',
    #                                 cascade="all, delete-orphan")
    def __init__(self, start_date, end_date, class_conference_date, report_conference_date, is_first):
        self.start_date = start_date
        self.end_date = end_date
        self.class_conference_date = class_conference_date
        self.report_conference_date = report_conference_date
        self.is_first = is_first

class Schoolday(db.Model):
    schoolday = db.Column(db.Date, nullable = False, primary_key = True)
    
    #- RELATIONSHIPS ONE-TO-MANY
    missed_classes = db.relationship('MissedClass', back_populates='missed_day',
                                    cascade="all, delete-orphan")
    schoolday_events = db.relationship('SchooldayEvent', back_populates='schoolday_event_day',
                                  cascade="all, delete-orphan")
    def __init__(self, schoolday):
        self.schoolday = schoolday    

class MissedClass(db.Model):
    id = db.Column(db.Integer, primary_key = True)
    missed_type = db.Column(db.String(10), nullable = False)
    excused = db.Column(db.Boolean)
    contacted = db.Column(db.String(20), nullable=True)
    returned = db.Column(db.Boolean, nullable=True)
    written_excuse = db.Column(db.Boolean, nullable=True)
    minutes_late = db.Column(db.Integer, nullable=True)
    returned_at = db.Column(db.String(10), nullable=True)
    created_by = db.Column(db.String(20), nullable=False)
    modified_by = db.Column(db.String(20), nullable=True)
    comment = db.Column(db.String(100), nullable=True)

    #- RELATIONSHIP TO PUPIL MANY-TO-ONE
    missed_pupil_id = db.Column(db.Integer, db.ForeignKey('pupil.internal_id'))
    missed_pupil = db.relationship('Pupil', back_populates='pupil_missed_classes')

    #- RELATIONSHIP TO SCHOOLDAY MANY-TO-ONE
    missed_day_id = db.Column(db.Date, db.ForeignKey('schoolday.schoolday'))
    missed_day = db.relationship('Schoolday', back_populates='missed_classes')
    
    def __init__(self, missed_pupil_id, missed_day_id, missed_type, excused,
                 contacted, returned, written_excuse, minutes_late, returned_at,
                 created_by, modified_by, comment):
        self.missed_pupil_id = missed_pupil_id
        self.missed_day_id = missed_day_id
        self.missed_type = missed_type
        self.excused = excused
        self.contacted = contacted
        self.returned = returned
        self.written_excuse = written_excuse
        self.minutes_late = minutes_late
        self.returned_at = returned_at
        self.created_by = created_by
        self.modified_by = modified_by
        self.comment = comment

## We need to document schoolday_events to monitor adequate educational measures
class SchooldayEvent(db.Model):
    id = db.Column(db.Integer, primary_key = True)
    schoolday_event_id = db.Column(db.String(50), unique=True)   
    schoolday_event_type = db.Column(db.String(10), nullable = False)
    schoolday_event_reason = db.Column(db.String(200), nullable = False)
    created_by = db.Column(db.String(10), nullable = False)
    processed = db.Column(db.Boolean)
    processed_by = db.Column(db.String(10), nullable = True)
    processed_at = db.Column(db.Date, nullable = True)
    file_id = db.Column(db.String(50), nullable = True)
    file_url = db.Column(db.String(50), nullable = True)
    processed_file_id = db.Column(db.String(50), nullable = True)
    processed_file_url = db.Column(db.String(50), nullable = True)

    #- RELATIONSHIP TO PUPIL MANY-TO-ONE
    schoolday_event_pupil_id = db.Column('schoolday_event_pupil', db.Integer,
                                   db.ForeignKey('pupil.internal_id'))
    schoolday_event_pupil = db.relationship('Pupil', back_populates="pupil_schoolday_events")
    
    #- RELATIONSHIP TO SCHOOLDAY MANY-TO-ONE
    schoolday_event_day_id = db.Column('schoolday_event_day', db.Date,
                                  db.ForeignKey('schoolday.schoolday'))
    schoolday_event_day = db.relationship('Schoolday', back_populates="schoolday_events")

    def __init__(self, schoolday_event_id, schoolday_event_pupil_id, schoolday_event_day_id,
                 schoolday_event_type, schoolday_event_reason, created_by, processed, processed_by, processed_at, file_id, file_url, processed_file_id, processed_file_url):
        self.schoolday_event_id = schoolday_event_id
        self.schoolday_event_pupil_id = schoolday_event_pupil_id
        self.schoolday_event_day_id = schoolday_event_day_id
        self.schoolday_event_type = schoolday_event_type
        self.schoolday_event_reason = schoolday_event_reason
        self.created_by = created_by
        self.processed = processed
        self.processed_by = processed_by
        self.processed_at = processed_at
        self.file_id = file_id
        self.file_url = file_url
        self.processed_file_id = processed_file_id
        self.processed_file_url = processed_file_url


