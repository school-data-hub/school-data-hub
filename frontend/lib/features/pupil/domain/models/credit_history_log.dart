// ignore_for_file: invalid_annotation_target
import 'package:json_annotation/json_annotation.dart';
part 'credit_history_log.g.dart';

@JsonSerializable()
class CreditHistoryLog {
  @JsonKey(name: "created_at")
  final DateTime createdAt;
  @JsonKey(name: "created_by")
  final String createdBy;
  @JsonKey(name: "credit")
  final int credit;
  @JsonKey(name: "operation")
  final int operation;

  factory CreditHistoryLog.fromJson(Map<String, dynamic> json) =>
      _$CreditHistoryLogFromJson(json);

  Map<String, dynamic> toJson() => _$CreditHistoryLogToJson(this);

  CreditHistoryLog(
      {required this.createdAt,
      required this.createdBy,
      required this.credit,
      required this.operation});
}
