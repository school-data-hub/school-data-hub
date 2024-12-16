// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'support_goal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SupportGoal _$SupportGoalFromJson(Map<String, dynamic> json) => SupportGoal(
      achieved: (json['achieved'] as num?)?.toInt(),
      achievedAt: json['achieved_at'] == null
          ? null
          : DateTime.parse(json['achieved_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      createdBy: json['created_by'] as String,
      description: json['description'] as String?,
      supportCategoryId: (json['support_category_id'] as num).toInt(),
      goalChecks: (json['goal_checks'] as List<dynamic>?)
          ?.map((e) => SupportGoalCheck.fromJson(e as Map<String, dynamic>))
          .toList(),
      goalId: json['goal_id'] as String,
      strategies: json['strategies'] as String?,
    );

Map<String, dynamic> _$SupportGoalToJson(SupportGoal instance) =>
    <String, dynamic>{
      'achieved': instance.achieved,
      'achieved_at': instance.achievedAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'created_by': instance.createdBy,
      'description': instance.description,
      'support_category_id': instance.supportCategoryId,
      'goal_checks': instance.goalChecks,
      'goal_id': instance.goalId,
      'strategies': instance.strategies,
    };
