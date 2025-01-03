// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookTag _$BookTagFromJson(Map<String, dynamic> json) => BookTag(
      name: json['name'] as String,
    );

Map<String, dynamic> _$BookTagToJson(BookTag instance) => <String, dynamic>{
      'name': instance.name,
    };

Book _$BookFromJson(Map<String, dynamic> json) => Book(
      author: json['author'] as String,
      description: json['description'] as String?,
      available: json['available'] as bool,
      bookId: json['book_id'] as String,
      imageId: json['image_id'] as String?,
      isbn: (json['isbn'] as num).toInt(),
      location: json['location'] as String,
      readingLevel: json['reading_level'] as String,
      title: json['title'] as String,
      bookTags: (json['book_tags'] as List<dynamic>?)
          ?.map((e) => BookTag.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BookToJson(Book instance) => <String, dynamic>{
      'author': instance.author,
      'description': instance.description,
      'available': instance.available,
      'book_id': instance.bookId,
      'image_id': instance.imageId,
      'isbn': instance.isbn,
      'location': instance.location,
      'reading_level': instance.readingLevel,
      'title': instance.title,
      'book_tags': instance.bookTags,
    };
