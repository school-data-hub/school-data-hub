// ignore_for_file: invalid_annotation_target

import 'package:json_annotation/json_annotation.dart';
part 'support_goal_check.g.dart';

@JsonSerializable()
class SupportGoalCheck {
  final String comment;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'created_by')
  final String createdBy;
  final int achieved;

  SupportGoalCheck(
      {required this.comment,
      required this.createdAt,
      required this.createdBy,
      required this.achieved});

  factory SupportGoalCheck.fromJson(Map<String, dynamic> json) =>
      _$SupportGoalCheckFromJson(json);

  Map<String, dynamic> toJson() => _$SupportGoalCheckToJson(this);
}
