from sqlalchemy import Boolean, Column, ForeignKey, Integer, String
from sqlalchemy.orm import relationship

from models.shared import db


class Authorization(db.Model):
    """
    Class for the Authorization model.

    """

    id: int = Column(Integer, primary_key=True)
    authorization_id: str = Column(String(50), unique=True)
    authorization_name: str = Column(String(20), nullable=False)
    authorization_description: str = Column(String(100), nullable=False)
    created_by: str = Column(String(5), nullable=False)

    authorized_pupils = relationship(
        "PupilAuthorization",
        back_populates="authorized_pupil",
        cascade="all, delete-orphan",
    )

    def __init__(
        self,
        authorization_id: str,
        authorization_name: str,
        authorization_description: str,
        created_by: str,
    ):
        self.authorization_id = authorization_id
        self.authorization_name = authorization_name
        self.authorization_description = authorization_description
        self.created_by = created_by


class PupilAuthorization(db.Model):
    """
    Class for the PupilAuthorization model.

    """

    id: int = Column(Integer, primary_key=True)
    status: Boolean = Column(Boolean, nullable=True)
    comment: str = Column(String(50), nullable=True)
    created_by: str = Column(String(5), nullable=True)
    file_id: str = Column(String(50), nullable=True)
    file_url: str = Column(String(50), nullable=True)

    # - RELATIONSHIP TO AUTHORIZATION MANY-TO-ONE
    origin_authorization = Column(
        String(50), ForeignKey("authorization.authorization_id"), unique=True
    )
    authorized_pupil = relationship("Authorization", back_populates="authorized_pupils")

    # - RELATIONSHIP TO PUPIL MANY-TO-ONE
    pupil_id = Column(Integer, ForeignKey("pupil.internal_id"))
    pupil = relationship("Pupil", back_populates="authorizations")

    def __init__(
        self,
        pupil_id,
        origin_authorization,
        status,
        comment,
        created_by,
        file_id,
        file_url,
    ):
        self.pupil_id = pupil_id
        self.origin_authorization = origin_authorization
        self.status = status
        self.comment = comment
        self.created_by = created_by
        self.file_id = file_id
        self.file_url = file_url
