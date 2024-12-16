// ignore_for_file: invalid_annotation_target

import 'package:json_annotation/json_annotation.dart';
import 'package:schuldaten_hub/features/learning_support/domain/models/support_goal/support_goal_check.dart';
part 'support_goal.g.dart';

@JsonSerializable()
class SupportGoal {
  final int? achieved;
  @JsonKey(name: 'achieved_at')
  final DateTime? achievedAt;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'created_by')
  final String createdBy;
  final String? description;
  @JsonKey(name: 'support_category_id')
  final int supportCategoryId;
  @JsonKey(name: 'goal_checks')
  final List<SupportGoalCheck>? goalChecks;
  @JsonKey(name: 'goal_id')
  final String goalId;
  final String? strategies;

  SupportGoal(
      {required this.achieved,
      required this.achievedAt,
      required this.createdAt,
      required this.createdBy,
      required this.description,
      required this.supportCategoryId,
      required this.goalChecks,
      required this.goalId,
      required this.strategies});

  factory SupportGoal.fromJson(Map<String, dynamic> json) =>
      _$SupportGoalFromJson(json);

  Map<String, dynamic> toJson() => _$SupportGoalToJson(this);
}
