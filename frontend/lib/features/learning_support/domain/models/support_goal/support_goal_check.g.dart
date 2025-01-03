// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'support_goal_check.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SupportGoalCheckFile _$SupportGoalCheckFileFromJson(
        Map<String, dynamic> json) =>
    SupportGoalCheckFile(
      fileId: json['file_id'] as String,
      checkId: json['check_id'] as String,
    );

Map<String, dynamic> _$SupportGoalCheckFileToJson(
        SupportGoalCheckFile instance) =>
    <String, dynamic>{
      'file_id': instance.fileId,
      'check_id': instance.checkId,
    };

SupportGoalCheck _$SupportGoalCheckFromJson(Map<String, dynamic> json) =>
    SupportGoalCheck(
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      createdBy: json['created_by'] as String,
      achieved: (json['achieved'] as num).toInt(),
      supportGoalCheckFiles: (json['support_goal_check_files'] as List<dynamic>)
          .map((e) => SupportGoalCheckFile.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SupportGoalCheckToJson(SupportGoalCheck instance) =>
    <String, dynamic>{
      'comment': instance.comment,
      'created_at': instance.createdAt.toIso8601String(),
      'created_by': instance.createdBy,
      'achieved': instance.achieved,
      'support_goal_check_files': instance.supportGoalCheckFiles,
    };
