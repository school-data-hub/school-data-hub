// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'school_semester.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SchoolSemester _$SchoolSemesterFromJson(Map<String, dynamic> json) =>
    SchoolSemester(
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      classConferenceDate: json['class_conference_date'] == null
          ? null
          : DateTime.parse(json['class_conference_date'] as String),
      reportConferenceDate: json['report_conference_date'] == null
          ? null
          : DateTime.parse(json['report_conference_date'] as String),
      isFirst: json['is_first'] as bool,
    );

Map<String, dynamic> _$SchoolSemesterToJson(SchoolSemester instance) =>
    <String, dynamic>{
      'start_date': instance.startDate.toIso8601String(),
      'end_date': instance.endDate.toIso8601String(),
      'class_conference_date': instance.classConferenceDate?.toIso8601String(),
      'report_conference_date':
          instance.reportConferenceDate?.toIso8601String(),
      'is_first': instance.isFirst,
    };
