from models.shared import db


class LibraryBookLocation(db.Model):
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
    db.Column("book_isbn", db.Integer, db.ForeignKey("book.isbn"), primary_key=True),
    db.Column(
        "book_tag_id", db.Integer, db.ForeignKey("book_tag.id"), primary_key=True
    ),
)

## many to many & association proxy: https://youtu.be/IlkVu_LWGys


class Book(db.Model):
    isbn = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(50))
    author = db.Column(db.String(20))
    description = db.Column(db.String(800), nullable=True)
    reading_level = db.Column(db.String(10))
    image_id = db.Column(db.String(50), nullable=True)
    image_url = db.Column(db.String(50), nullable=True)

    # - RELATIONSHIP TO TAGS MANY-TO-MANY
    book_tags = db.relationship(
        "BookTag",
        secondary=book_tags,
        lazy="subquery",
        backref=db.backref("books", lazy=True),
    )

    # - RELATIONSHIP TO LIBRARY BOOKS ONE-TO-MANY

    library_books = db.relationship(
        "LibraryBook", back_populates="book", cascade="all, delete-orphan"
    )

    def __init__(
        self,
        isbn,
        title,
        author,
        description,
        reading_level,
        image_url,
        image_id,
    ):
        self.isbn = isbn
        self.title = title
        self.author = author
        self.description = description
        self.reading_level = reading_level
        self.image_url = image_url
        self.image_id = image_id


class LibraryBook(db.Model):
    book_id = db.Column(db.String(20), primary_key=True)
    available = db.Column(db.Boolean, default=True)
    location = db.Column(db.String(20))

    # - RELATIONSHIP TO PUPIL BOOKS ONE-TO-MANY
    reading_pupils = db.relationship(
        "PupilBook", back_populates="library_book", cascade="all, delete-orphan"
    )

    # - RELATIONSHIP TO BOOK MANY-TO-ONE

    book_isbn = db.Column("book_isbn", db.Integer, db.ForeignKey("book.isbn"))
    book = db.relationship("Book", back_populates="library_books")

    def __init__(self, book_id, available, location, book_isbn):
        self.book_id = book_id
        self.available = available
        self.location = location
        self.book_isbn = book_isbn


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

    # - RELATIONSHIP TO LIBRARYBOOK MANY-TO-ONE
    book_id = db.Column("book_id", db.String(50), db.ForeignKey("library_book.book_id"))
    library_book = db.relationship("LibraryBook", back_populates="reading_pupils")

    # - RELATIONSHIP TO PUPIL BOOK FILES ONE-TO-MANY
    pupil_book_files = db.relationship(
        "PupilBookFile", back_populates="pupil_book", cascade="all, delete-orphan"
    )

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


class PupilBookFile(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    file_id = db.Column(db.String(50), nullable=False)
    file_url = db.Column(db.String(50), nullable=False)
    extension = db.Column(db.String(4), nullable=False)
    uploaded_at = db.Column(db.Date, nullable=False)
    uploaded_by = db.Column(db.String(20), nullable=False)

    # - RELATIONSHIP TO PUPIL BOOK MANY-TO-ONE
    lending_id = db.Column(
        "lending_id", db.String(50), db.ForeignKey("pupil_book.lending_id")
    )
    pupil_book = db.relationship("PupilBook", back_populates="pupil_book_files")

    def __init__(
        self, file_id, file_url, extension, uploaded_at, uploaded_by, lending_id
    ):
        self.file_id = file_id
        self.file_url = file_url
        self.extension = extension
        self.uploaded_at = uploaded_at
        self.uploaded_by = uploaded_by
        self.lending_id = lending_id
