// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pupil_book.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PupilBorrowedBook _$PupilBookFromJson(Map<String, dynamic> json) =>
    PupilBorrowedBook(
      bookId: json['book_id'] as String,
      lendingId: json['lending_id'] as String,
      lentAt: DateTime.parse(json['lent_at'] as String),
      lentBy: json['lent_by'] as String,
      pupilId: (json['pupil_id'] as num).toInt(),
      receivedBy: json['received_by'] as String?,
      returnedAt: json['returned_at'] == null
          ? null
          : DateTime.parse(json['returned_at'] as String),
      state: json['state'] as String?,
      rating: (json['rating'] as num?)?.toInt(),
    );

Map<String, dynamic> _$PupilBookToJson(PupilBorrowedBook instance) =>
    <String, dynamic>{
      'book_id': instance.bookId,
      'lending_id': instance.lendingId,
      'lent_at': instance.lentAt.toIso8601String(),
      'lent_by': instance.lentBy,
      'pupil_id': instance.pupilId,
      'received_by': instance.receivedBy,
      'returned_at': instance.returnedAt?.toIso8601String(),
      'state': instance.state,
      'rating': instance.rating,
    };
