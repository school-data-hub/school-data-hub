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
    book = fields.Nested("BookSchema", attribute="library_book.book")

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


class TagsInBookSchema(Schema):
    name = fields.String()

    class Meta:
        fields = ("name",)


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
    reading_pupils = fields.List(fields.Nested(PupilBookOutSchema))
    book_tags = fields.List(fields.Nested(TagsInBookSchema))

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
            "book_tags",
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
    book = fields.Nested(BookSchema, attribute="library_book.book")

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


class BookLocationSchema(Schema):
    location = fields.String()

    class Meta:
        fields = ("location",)


book_location_schema = BookLocationSchema()
book_locations_schema = BookLocationSchema(many=True)


class BookTagSchema(Schema):
    name = fields.String()
    created_by = fields.String()

    class Meta:
        fields = (
            "name",
            "created_by",
        )


book_tag_schema = BookTagSchema()
book_tags_schema = BookTagSchema(many=True)


class TagsInBookSchema(Schema):
    name = fields.String()

    class Meta:
        fields = ("name",)


tag_in_book_schema = TagsInBookSchema()
tags_in_books_schema = TagsInBookSchema(many=True)


# - BOOK SCHEMA
##############


class NewLibraryBookSchema(Schema):
    book_id = fields.String()
    isbn = fields.Integer()
    title = fields.String()
    author = fields.String()
    description = fields.String()
    location = fields.String()
    reading_level = fields.String()
    description = fields.String()
    book_tags = fields.List(fields.Nested(TagsInBookSchema))

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
            "book_tags",
        )


new_book_schema = NewLibraryBookSchema()
new_book_schemas = NewLibraryBookSchema(many=True)


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
    reading_pupils = fields.List(fields.Nested(PupilBookOutSchema))
    book_tags = fields.List(fields.Nested(TagsInBookSchema))

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
            "book_tags",
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
    book_tags = fields.List(fields.Nested(TagsInBookSchema))

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
            "book_tags",
        )


book_flat_schema = BookFlatSchema()
books_flat_schema = BookFlatSchema(many=True)


class NewBookWithFileSchema(Schema):
    book = fields.Nested(NewLibraryBookSchema)
    file = fields.File()
