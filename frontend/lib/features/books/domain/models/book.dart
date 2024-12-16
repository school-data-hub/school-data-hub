// ignore_for_file: invalid_annotation_target

import 'package:json_annotation/json_annotation.dart';

part 'book.g.dart';

@JsonSerializable()
class Book {
  final String author;
  final String? description;
  final bool available;
  @JsonKey(name: "book_id")
  final String bookId;
  @JsonKey(name: "image_id")
  final String? imageId;
  final int isbn;
  final String location;
  @JsonKey(name: "reading_level")
  final String readingLevel;
  final String title;

  factory Book.fromJson(Map<String, dynamic> json) => _$BookFromJson(json);

  Map<String, dynamic> toJson() => _$BookToJson(this);

  Book(
      {required this.author,
      required this.description,
      required this.available,
      required this.bookId,
      required this.imageId,
      required this.isbn,
      required this.location,
      required this.readingLevel,
      required this.title});
}
