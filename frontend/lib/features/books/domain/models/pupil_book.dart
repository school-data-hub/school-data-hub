// ignore_for_file: invalid_annotation_target

import 'package:json_annotation/json_annotation.dart';

part 'pupil_book.g.dart';

@JsonSerializable()
class PupilBorrowedBook {
  @JsonKey(name: 'book_id')
  final String bookId;
  @JsonKey(name: 'lending_id')
  final String lendingId;
  @JsonKey(name: 'lent_at')
  final DateTime lentAt;
  @JsonKey(name: 'lent_by')
  final String lentBy;
  @JsonKey(name: 'pupil_id')
  final int pupilId;
  @JsonKey(name: 'received_by')
  final String? receivedBy;
  @JsonKey(name: 'returned_at')
  final DateTime? returnedAt;
  final String? state;
  final int? rating;

  PupilBorrowedBook(
      {required this.bookId,
      required this.lendingId,
      required this.lentAt,
      required this.lentBy,
      required this.pupilId,
      this.receivedBy,
      this.returnedAt,
      required this.state,
      required this.rating});

  factory PupilBorrowedBook.fromJson(Map<String, dynamic> json) =>
      _$PupilBookFromJson(json);

  Map<String, dynamic> toJson() => _$PupilBookToJson(this);
}
