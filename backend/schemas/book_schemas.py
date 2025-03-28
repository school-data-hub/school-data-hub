from apiflask import Schema, fields
from marshmallow import EXCLUDE


# - BOOK TAGS SCHEMAS
####################


class TagInBookSchema(Schema):
    name = fields.String()

    class Meta:
        fields = ("name",)


tag_in_book_schema = TagInBookSchema()
tags_in_books_schema = TagInBookSchema(many=True)


class BookTagSchema(Schema):
    name = fields.String()

    class Meta:
        fields = ("name",)


book_tag_schema = BookTagSchema()
book_tags_schema = BookTagSchema(many=True)


class BookTagOutSchema(Schema):
    name = fields.String()

    class Meta:
        fields = ("name",)


book_tag_out_schema = BookTagOutSchema()
book_tags_out_schema = BookTagOutSchema(many=True)


# - BOOK LOCATION SCHEMAS
#########################


class BookLocationSchema(Schema):
    location = fields.String()

    class Meta:
        fields = ("location",)


book_location_schema = BookLocationSchema()
book_locations_schema = BookLocationSchema(many=True)

# - BOOK SCHEMA
################


class BookWithLibraryBooksSchema(Schema):
    isbn = fields.Integer()
    title = fields.String()
    author = fields.String()
    description = fields.String()
    reading_level = fields.String()
    image_id = fields.String(allow_none=True)
    book_tags = fields.List(fields.Nested(TagInBookSchema))
    library_books = fields.List(fields.Nested("LibraryBookSchema"))

    class Meta:
        fields = (
            "isbn",
            "title",
            "author",
            "description",
            "reading_level",
            "image_id",
            "book_tags",
            "library_books",
        )


book_schema = BookWithLibraryBooksSchema()
books_schema = BookWithLibraryBooksSchema(many=True)


class BookFlatSchema(Schema):
    isbn = fields.Integer()
    title = fields.String()
    author = fields.String()
    description = fields.String()
    reading_level = fields.String()
    image_id = fields.String(allow_none=True)
    book_tags = fields.List(fields.Nested(TagInBookSchema))

    class Meta:
        fields = (
            "isbn",
            "title",
            "author",
            "description",
            "reading_level",
            "image_id",
            "book_tags",
        )


book_flat_schema = BookFlatSchema()
books_flat_schema = BookFlatSchema(many=True)


class BookPatchSchema(Schema):

    title = fields.String(allow_none=True)
    author = fields.String(allow_none=True)
    description = fields.String(allow_none=True)
    reading_level = fields.String(allow_none=True)
    book_tags = fields.List(fields.Nested(TagInBookSchema), allow_none=True)

    class Meta:
        fields = (
            "title",
            "author",
            "description",
            "reading_level",
            "book_tags",
        )


book_patch_schema = BookPatchSchema()
book_patches_schema = BookPatchSchema(many=True)

# - LIBRARY BOOK SCHEMA
#######################

# We send the book object as a nested field in the library book schema


class LibraryBookOutSchema(Schema):
    book_id = fields.String()
    available = fields.Boolean()
    location = fields.String()
    book = fields.Nested(BookFlatSchema)

    class Meta:
        fields = (
            "book_id",
            "available",
            "location",
            "book",
        )


library_book_out_schema = LibraryBookOutSchema()
library_books_out_schema = LibraryBookOutSchema(many=True)


class LibraryBookCompleteOutSchema(Schema):
    book_id = fields.String()
    available = fields.Boolean()
    location = fields.String()
    book_isbn = fields.Integer()
    book = fields.Nested(BookFlatSchema)
    reading_pupils = fields.List(fields.Nested("PupilBookOutSchema"))

    class Meta:
        fields = (
            "book_id",
            "available",
            "location",
            "book_isbn",
        )


library_book_complete_out_schema = LibraryBookCompleteOutSchema()
library_books_complete_out_schema = LibraryBookCompleteOutSchema(many=True)


class NewLibraryBookSchema(Schema):
    book_id = fields.String()
    book_isbn = fields.Integer()
    location = fields.String()

    class Meta:
        fields = (
            "book_id",
            "book_isbn",
            "location",
        )


new_library_book_schema = NewLibraryBookSchema()
new_library_books_schema = NewLibraryBookSchema(many=True)



class LibraryBooksSearchSchema(Schema):
    title = fields.String(load_default=None)
    author = fields.String(load_default=None)
    location = fields.String(load_default=None)
    keywords = fields.String(load_default=None)
    reading_level = fields.String(load_default=None)
    borrow_status = fields.String(load_default=None)

    class Meta:
        unknown = EXCLUDE

library_books_search_schema = LibraryBooksSearchSchema()
