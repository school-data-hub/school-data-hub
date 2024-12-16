// ignore_for_file: invalid_annotation_target

import 'package:json_annotation/json_annotation.dart';
part 'support_category_status.g.dart';

enum SupportCategoryState {
  white('white'),
  red('red'),
  yellow('yellow'),
  green('green');

  static const stringToValue = {
    'white': SupportCategoryState.white,
    'red': SupportCategoryState.red,
    'yellow': SupportCategoryState.yellow,
    'green': SupportCategoryState.green,
  };

  final String value;
  const SupportCategoryState(this.value);
}

@JsonSerializable()
class SupportCategoryStatus {
  final String comment;
  @JsonKey(name: 'file_id')
  final String? fileId;
  @JsonKey(name: 'support_category_id')
  final int supportCategoryId;
  @JsonKey(name: 'status_id')
  final String statusId;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'created_by')
  final String createdBy;
  final String state;
  SupportCategoryStatus(
      {required this.comment,
      required this.fileId,
      required this.supportCategoryId,
      required this.statusId,
      required this.createdAt,
      required this.createdBy,
      required this.state});

  factory SupportCategoryStatus.fromJson(Map<String, dynamic> json) =>
      _$SupportCategoryStatusFromJson(json);

  Map<String, dynamic> toJson() => _$SupportCategoryStatusToJson(this);
}
