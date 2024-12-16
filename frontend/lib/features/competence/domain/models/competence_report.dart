// ignore_for_file: invalid_annotation_target

import 'package:json_annotation/json_annotation.dart';

part 'competence_report.g.dart';

@JsonSerializable()
class CompetenceReport {
  @JsonKey(name: "report_id")
  final String reportId;
  @JsonKey(name: "created_by")
  final String createdBy;
  @JsonKey(name: "created_at")
  final DateTime createdAt;
  @JsonKey(name: "pupil_id")
  final int pupilId;
  @JsonKey(name: "school_semester_id")
  final int schoolSemesterId;

  CompetenceReport(
      {required this.reportId,
      required this.createdBy,
      required this.createdAt,
      required this.pupilId,
      required this.schoolSemesterId});

  factory CompetenceReport.fromJson(Map<String, dynamic> json) =>
      _$CompetenceReportFromJson(json);

  Map<String, dynamic> toJson() => _$CompetenceReportToJson(this);
}
