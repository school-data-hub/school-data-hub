from models.shared import db


class BookLocation(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    location = db.Column(db.String(20), nullable=False, unique=True)

    def __init__(self, location):
        self.location = location


class BookTag(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(50), nullable=False, unique=True)
    created_by = db.Column(db.String(20), nullable=False)

    def __init__(self, name, created_by):
        self.name = name
        self.created_by = created_by


book_tags = db.Table(
    "book_tags",
    db.Column("book_id", db.Integer, db.ForeignKey("book.id"), primary_key=True),
    db.Column(
        "book_tag_id", db.Integer, db.ForeignKey("book_tag.id"), primary_key=True
    ),
)


class Book(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    book_id = db.Column(db.String(50), nullable=False, unique=True)
    isbn = db.Column(db.Integer, nullable=False)
    title = db.Column(db.String(50))
    author = db.Column(db.String(20))
    description = db.Column(db.String(800), nullable=True)
    available = db.Column(db.Boolean, default=True)
    location = db.Column(db.String(20))
    reading_level = db.Column(db.String(10))
    image_url = db.Column(db.String(50), nullable=True)
    image_id = db.Column(db.String(50), nullable=True)

    # - RELATIONSHIP TO PUPIL BOOKS ONE-TO-MANY
    reading_pupils = db.relationship(
        "PupilBook", back_populates="book", cascade="all, delete-orphan"
    )

    # - RELATIONSHIP TO TAGS MANY-TO-MANY
    book_tags = db.relationship(
        "BookTag",
        secondary=book_tags,
        lazy="subquery",
        backref=db.backref("books", lazy=True),
    )

    def __init__(
        self,
        book_id,
        isbn,
        title,
        author,
        description,
        available,
        location,
        reading_level,
        image_url,
        image_id,
    ):
        self.book_id = book_id
        self.isbn = isbn
        self.title = title
        self.author = author
        self.description = description
        self.available = available
        self.location = location
        self.reading_level = reading_level
        self.image_url = image_url
        self.image_id = image_id


## many to many & association proxy: https://youtu.be/IlkVu_LWGys


class PupilBook(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    lending_id = db.Column(db.String(50), nullable=False, unique=True)
    state = db.Column(db.String(100), nullable=True)
    rating = db.Column(db.Integer, nullable=True)
    lent_at = db.Column(db.Date, nullable=False)
    lent_by = db.Column(db.String(20), nullable=False)
    returned_at = db.Column(db.Date, nullable=True)
    received_by = db.Column(db.String(20), nullable=True)

    # - RELATIONSHIP TO PUPIL MANY-TO-ONE
    pupil_id = db.Column("pupil_id", db.Integer, db.ForeignKey("pupil.internal_id"))
    pupil = db.relationship("Pupil", back_populates="pupil_books")

    # - RELATIONSHIP TO BOOK MANY-TO-ONE
    book_id = db.Column("book_id", db.String(50), db.ForeignKey("book.book_id"))
    book = db.relationship("Book", back_populates="reading_pupils")

    def __init__(
        self,
        pupil_id,
        book_id,
        lending_id,
        state,
        rating,
        lent_at,
        lent_by,
        returned_at,
        received_by,
    ):
        self.pupil_id = pupil_id
        self.lending_id = lending_id
        self.book_id = book_id
        self.state = state
        self.rating = rating
        self.lent_at = lent_at
        self.lent_by = lent_by
        self.returned_at = returned_at
        self.received_by = received_by
