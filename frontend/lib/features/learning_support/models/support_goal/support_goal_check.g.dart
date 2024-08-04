// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'support_goal_check.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SupportGoalCheck _$SupportGoalCheckFromJson(Map<String, dynamic> json) =>
    SupportGoalCheck(
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      createdBy: json['created_by'] as String,
      achieved: (json['achieved'] as num).toInt(),
    );

Map<String, dynamic> _$SupportGoalCheckToJson(SupportGoalCheck instance) =>
    <String, dynamic>{
      'comment': instance.comment,
      'created_at': instance.createdAt.toIso8601String(),
      'created_by': instance.createdBy,
      'achieved': instance.achieved,
    };
