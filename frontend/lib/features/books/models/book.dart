// ignore_for_file: invalid_annotation_target

import 'package:json_annotation/json_annotation.dart';

part 'book.g.dart';

@JsonSerializable()
class Book {
  final String? author;
  @JsonKey(name: "book_id")
  final String bookId;
  @JsonKey(name: "image_url")
  final String? imageUrl;
  final int isbn;
  final String location;
  @JsonKey(name: "reading_level")
  final String readingLevel;
  final String? title;

  @JsonKey(name: "qr_code_url")
  final String? qrCodeUrl;

  factory Book.fromJson(Map<String, dynamic> json) => _$BookFromJson(json);

  Map<String, dynamic> toJson() => _$BookToJson(this);

  Book(
      {this.author,
      required this.bookId,
      this.imageUrl,
      required this.isbn,
      required this.location,
      required this.readingLevel,
      this.title, this.qrCodeUrl});
}
