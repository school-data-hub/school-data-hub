// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'competence_check.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompetenceCheck _$CompetenceCheckFromJson(Map<String, dynamic> json) =>
    CompetenceCheck(
      checkId: json['check_id'] as String,
      comment: json['comment'] as String,
      competenceId: (json['competence_id'] as num).toInt(),
      competenceStatus: (json['competence_status'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      createdBy: json['created_by'] as String,
      pupilId: (json['pupil_id'] as num).toInt(),
      valueFactor: (json['value_factor'] as num?)?.toDouble(),
      groupName: json['group_name'] as String?,
      groupId: json['group_id'] as String?,
      competenceCheckFiles: (json['competence_check_files'] as List<dynamic>?)
          ?.map((e) => CompetenceCheckFile.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CompetenceCheckToJson(CompetenceCheck instance) =>
    <String, dynamic>{
      'check_id': instance.checkId,
      'comment': instance.comment,
      'competence_id': instance.competenceId,
      'competence_status': instance.competenceStatus,
      'created_at': instance.createdAt.toIso8601String(),
      'created_by': instance.createdBy,
      'pupil_id': instance.pupilId,
      'value_factor': instance.valueFactor,
      'group_name': instance.groupName,
      'group_id': instance.groupId,
      'competence_check_files': instance.competenceCheckFiles,
    };

CompetenceCheckFile _$CompetenceCheckFileFromJson(Map<String, dynamic> json) =>
    CompetenceCheckFile(
      checkId: json['check_id'] as String,
      fileId: json['file_id'] as String,
    );

Map<String, dynamic> _$CompetenceCheckFileToJson(
        CompetenceCheckFile instance) =>
    <String, dynamic>{
      'check_id': instance.checkId,
      'file_id': instance.fileId,
    };
