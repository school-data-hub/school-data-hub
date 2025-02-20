from apiflask import Schema, fields

# - PUPIL BOOK SCHEMA
####################


class PupilBookOutFileSchema(Schema):
    file_id = fields.String()
    extension = fields.String()
    uploaded_at = fields.Date()
    uploaded_by = fields.String()

    class Meta:
        fields = (
            "file_id",
            "extension",
            "uploaded_at",
            "uploaded_by",
        )


class PupilBookInSchema(Schema):
    book_id = fields.String()
    pupil_id = fields.Integer()
    state = fields.String()
    rating = fields.Integer()
    lent_at = fields.Date()
    lent_by = fields.String()
    returned_at = fields.Date()
    received_by = fields.String()

    class Meta:
        fields = (
            "pupil_id",
            "book_id",
            "state",
            "rating",
            "lent_at",
            "lent_by",
            "returned_at",
            "received_by",
        )


class PupilBookOutSchema(Schema):
    pupil_id = fields.Integer()
    book_id = fields.String()
    lending_id = fields.String()
    state = fields.String()
    rating = fields.Integer()
    lent_at = fields.Date()
    lent_by = fields.String()
    returned_at = fields.Date()
    received_by = fields.String()
    pupil_book_files = fields.List(fields.Nested(PupilBookOutFileSchema))
    book = fields.Nested("BookFlatSchema", attribute="library_book.book")

    class Meta:
        fields = (
            "pupil_id",
            "book_id",
            "lending_id",
            "state",
            "rating",
            "lent_at",
            "lent_by",
            "returned_at",
            "received_by",
            "pupil_book_files",
        )


pupil_book_out_schema = PupilBookOutSchema()
pupil_books_out_schema = PupilBookOutSchema(many=True)
