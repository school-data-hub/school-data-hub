// ignore_for_file: invalid_annotation_target
import 'package:json_annotation/json_annotation.dart';

part 'workbook.g.dart';

@JsonSerializable()
class Workbook {
  Workbook(
      {required this.isbn,
      required this.name,
      required this.subject,
      required this.level,
      required this.amount,
      required this.imageUrl});

  final int isbn;
  String name;
  final String? subject;
  final String? level;
  final int amount;
  @JsonKey(name: 'image_url')
  String? imageUrl;

  factory Workbook.fromJson(Map<String, dynamic> json) =>
      _$WorkbookFromJson(json);

  Map<String, dynamic> toJson() => _$WorkbookToJson(this);
}
