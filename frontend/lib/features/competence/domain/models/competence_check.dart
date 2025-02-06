// ignore_for_file: invalid_annotation_target

import 'package:json_annotation/json_annotation.dart';

part 'competence_check.g.dart';

@JsonSerializable()
class CompetenceCheck {
  @JsonKey(name: 'check_id')
  final String checkId;
  final String comment;
  @JsonKey(name: 'competence_id')
  final int competenceId;
  @JsonKey(name: 'competence_status')
  final int competenceStatus;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'created_by')
  final String createdBy;
  @JsonKey(name: 'pupil_id')
  final int pupilId;

  @JsonKey(name: 'value_factor')
  final double? valueFactor;
  @JsonKey(name: 'group_name')
  final String? groupName;
  @JsonKey(name: 'group_id')
  final String? groupId;
  @JsonKey(name: "competence_check_files")
  final List<CompetenceCheckFile>? competenceCheckFiles;

  CompetenceCheck(
      {required this.checkId,
      required this.comment,
      required this.competenceId,
      required this.competenceStatus,
      required this.createdAt,
      required this.createdBy,
      required this.pupilId,
      required this.valueFactor,
      required this.groupName,
      required this.groupId,
      required this.competenceCheckFiles});

  factory CompetenceCheck.fromJson(Map<String, dynamic> json) =>
      _$CompetenceCheckFromJson(json);

  Map<String, dynamic> toJson() => _$CompetenceCheckToJson(this);
}

@JsonSerializable()
class CompetenceCheckFile {
  @JsonKey(name: "check_id")
  final String checkId;
  @JsonKey(name: "file_id")
  final String fileId;

  CompetenceCheckFile({required this.checkId, required this.fileId});

  factory CompetenceCheckFile.fromJson(Map<String, dynamic> json) =>
      _$CompetenceCheckFileFromJson(json);

  Map<String, dynamic> toJson() => _$CompetenceCheckFileToJson(this);
}
