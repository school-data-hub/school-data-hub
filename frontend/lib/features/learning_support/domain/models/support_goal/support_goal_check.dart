// ignore_for_file: invalid_annotation_target

import 'package:json_annotation/json_annotation.dart';

part 'support_goal_check.g.dart';

@JsonSerializable()
class SupportGoalCheckFile {
  @JsonKey(name: 'file_id')
  final String fileId;
  @JsonKey(name: 'check_id')
  final String checkId;

  SupportGoalCheckFile({
    required this.fileId,
    required this.checkId,
  });

  factory SupportGoalCheckFile.fromJson(Map<String, dynamic> json) =>
      _$SupportGoalCheckFileFromJson(json);

  Map<String, dynamic> toJson() => _$SupportGoalCheckFileToJson(this);
}

@JsonSerializable()
class SupportGoalCheck {
  final String comment;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'created_by')
  final String createdBy;
  final int achieved;
  @JsonKey(name: 'support_goal_check_files')
  final List<SupportGoalCheckFile> supportGoalCheckFiles;

  SupportGoalCheck(
      {required this.comment,
      required this.createdAt,
      required this.createdBy,
      required this.achieved,
      required this.supportGoalCheckFiles});

  factory SupportGoalCheck.fromJson(Map<String, dynamic> json) =>
      _$SupportGoalCheckFromJson(json);

  Map<String, dynamic> toJson() => _$SupportGoalCheckToJson(this);
}
