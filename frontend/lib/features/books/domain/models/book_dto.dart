// ignore_for_file: invalid_annotation_target

import 'package:json_annotation/json_annotation.dart';

part 'book_dto.g.dart';

@JsonSerializable()
class BookTag {
  final String name;

  factory BookTag.fromJson(Map<String, dynamic> json) =>
      _$BookTagFromJson(json);

  Map<String, dynamic> toJson() => _$BookTagToJson(this);

  BookTag({required this.name});
}

@JsonSerializable()
class BookDTO {
  final int isbn;
  final String title;
  final String author;
  final String? description;
  @JsonKey(name: "image_id")
  final String? imageId;
  @JsonKey(name: "reading_level")
  final String readingLevel;
  @JsonKey(name: "book_tags")
  final List<BookTag>? bookTags;

  factory BookDTO.fromJson(Map<String, dynamic> json) => _$BookFromJson(json);

  Map<String, dynamic> toJson() => _$BookToJson(this);

  BookDTO({
    required this.author,
    required this.description,
    required this.imageId,
    required this.isbn,
    required this.readingLevel,
    required this.title,
    required this.bookTags,
  });
}
