from apiflask import Schema, fields

# - PUPIL BOOK SCHEMA
####################


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
            "lending_id",
            "state",
            "rating",
            "lent_at",
            "lent_by",
            "returned_at",
            "received_by",
        )


class PupilBookSchema(Schema):
    pupil_id = fields.Integer()
    book_id = fields.String()
    lending_id = fields.String()
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
            "lending_id",
            "state",
            "rating",
            "lent_at",
            "lent_by",
            "returned_at",
            "received_by",
        )


pupil_book_schema = PupilBookSchema()
pupil_books_schema = PupilBookSchema(many=True)


# class PupilBookListSchema(Schema):
#     pupil_id = fields.Integer()
#     book_id = fields.String()
#     state = fields.String()
#     lent_at = fields.Date()
#     lent_by = fields.String()
#     returned_at = fields.Date()
#     received_by = fields.String()

#     class Meta:
#         fields = (
#             "pupil_id",
#             "state",
#             "lent_at",
#             "lent_by",
#             "returned_at",
#             "received_by",
#         )


# pupil_book_list_schema = PupilBookListSchema()
# pupil_books_list_schema = PupilBookListSchema(many=True)

# - BOOK SCHEMA
##############


class NewBookSchema(Schema):
    book_id = fields.String()
    isbn = fields.Integer()
    title = fields.String()
    author = fields.String()
    description = fields.String()
    location = fields.String()
    reading_level = fields.String()
    description = fields.String()

    class Meta:
        fields = (
            "book_id",
            "isbn",
            "title",
            "author",
            "description",
            "location",
            "reading_level",
            "description",
        )


new_book_schema = NewBookSchema()
new_book_schemas = NewBookSchema(many=True)


class BookPatchSchema(Schema):

    title = fields.String()
    author = fields.String()
    description = fields.String()
    image_id = fields.String()
    location = fields.String()
    reading_level = fields.String()

    class Meta:
        fields = (
            "title",
            "author",
            "description",
            "image_id",
            "location",
            "reading_level",
        )


book_patch_schema = BookPatchSchema()
book_patches_schema = BookPatchSchema(many=True)


class BookSchema(Schema):
    book_id = fields.String()
    isbn = fields.Integer()
    title = fields.String()
    author = fields.String()
    description = fields.String()
    available = fields.Boolean()
    location = fields.String()
    reading_level = fields.String()
    image_id = fields.String(allow_none=True)
    reading_pupils = fields.List(fields.Nested(PupilBookSchema))

    class Meta:
        fields = (
            "book_id",
            "isbn",
            "title",
            "author",
            "description",
            "available",
            "location",
            "reading_level",
            "image_id",
            "reading_pupils",
        )


book_schema = BookSchema()
books_schema = BookSchema(many=True)


class BookFlatSchema(Schema):
    author = fields.String()
    available = fields.Boolean(allow_none=True)
    book_id = fields.String()
    description = fields.String(allow_none=True)
    image_id = fields.String(allow_none=True)
    isbn = fields.Integer()
    location = fields.String()
    reading_level = fields.String()
    title = fields.String()

    class Meta:
        fields = (
            "book_id",
            "isbn",
            "title",
            "author",
            "description",
            "available",
            "location",
            "reading_level",
            "image_id",
        )


book_flat_schema = BookFlatSchema()
books_flat_schema = BookFlatSchema(many=True)
