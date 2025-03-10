import 'package:json_annotation/json_annotation.dart';

part 'school_semester.g.dart';

@JsonSerializable()
class SchoolSemester {
  @JsonKey(name: 'start_date')
  final DateTime startDate;
  @JsonKey(name: 'end_date')
  final DateTime endDate;
  @JsonKey(name: 'class_conference_date')
  final DateTime? classConferenceDate;
  @JsonKey(name: 'report_conference_date')
  final DateTime? reportConferenceDate;
  @JsonKey(name: 'is_first')
  final bool isFirst;

  factory SchoolSemester.fromJson(Map<String, dynamic> json) =>
      _$SchoolSemesterFromJson(json);

  Map<String, dynamic> toJson() => _$SchoolSemesterToJson(this);
  SchoolSemester(
      {required this.startDate,
      required this.endDate,
      this.classConferenceDate,
      this.reportConferenceDate,
      required this.isFirst});
}
