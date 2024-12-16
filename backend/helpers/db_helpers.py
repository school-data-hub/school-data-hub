from datetime import datetime
from typing import List, Optional

from sqlalchemy import or_

from models.authorization import Authorization
from models.book import Book
from models.pupil import Pupil
from models.school_list import SchoolList
from models.schoolday import MissedClass, Schoolday, SchooldayEvent
from models.shared import db
from models.support_category import SupportCategory, SupportGoal
from models.workbook import Workbook

## date as datetime


def date_string_to_date(date_string: str) -> datetime:
    return datetime.strptime(date_string, "%Y-%m-%d").date()


def now_as_date() -> datetime:
    return datetime.strptime(datetime.now().strftime("%Y-%m-%d"), "%Y-%m-%d").date()


## Authorizations


def get_authorization_by_id(authorization_id: str) -> Optional[Authorization]:
    return (
        db.session.query(Authorization)
        .filter_by(authorization_id=authorization_id)
        .scalar()
    )


def get_authorization_by_name(authorization_name: str) -> Optional[Authorization]:
    return (
        db.session.query(Authorization)
        .filter_by(authorization_name=authorization_name)
        .scalar()
    )


## Support goals


def get_support_goal_by_id(goal_id: str) -> Optional[SupportGoal]:
    return SupportGoal.query.filter_by(goal_id=goal_id).first()


## Support categories


def get_support_category_by_id(category_id: str) -> Optional[SupportCategory]:
    return db.session.query(SupportCategory).filter_by(category_id=category_id).scalar()


## Pupil


def get_pupil_by_id(pupil_id: int) -> Optional[Pupil]:
    return db.session.query(Pupil).filter_by(internal_id=pupil_id).scalar()


## Schoolday


def get_schoolday_by_day(schoolday: datetime) -> Optional[Schoolday]:
    return db.session.query(Schoolday).filter(Schoolday.schoolday == schoolday).first()


def get_missed_class_by_pupil_and_schoolday(
    pupil_id: int, schoolday_id: int
) -> Optional[MissedClass]:
    return (
        db.session.query(MissedClass)
        .filter(
            MissedClass.missed_pupil_id == pupil_id,
            MissedClass.missed_day_id == schoolday_id,
        )
        .first()
    )


## Schoolday Events


def get_schoolday_event_by_id(schoolday_event_id: str) -> Optional[SchooldayEvent]:
    return (
        db.session.query(SchooldayEvent)
        .filter(SchooldayEvent.schoolday_event_id == schoolday_event_id)
        .first()
    )


## School lists


def get_authorized_school_lists(user_name: str) -> Optional[List[SchoolList]]:
    combined_query = SchoolList.query.filter(
        or_(
            SchoolList.created_by == user_name,
            SchoolList.authorized_users.contains(user_name),
            SchoolList.visibility == "public",
        )
    ).distinct()

    all_lists = combined_query.all()
    return all_lists


## Workbooks


def get_workbook_by_isbn(isbn: int) -> Optional[Workbook]:
    return db.session.query(Workbook).filter(Workbook.isbn == isbn).first()


## Books


def get_book_by_id(book_id: str) -> Optional[Book]:
    return db.session.query(Book).filter_by(book_id=book_id).scalar()
