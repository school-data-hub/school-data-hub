// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'competence_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompetenceReport _$CompetenceReportFromJson(Map<String, dynamic> json) =>
    CompetenceReport(
      reportId: json['report_id'] as String,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      pupilId: (json['pupil_id'] as num).toInt(),
      schoolSemesterId: (json['school_semester_id'] as num).toInt(),
    );

Map<String, dynamic> _$CompetenceReportToJson(CompetenceReport instance) =>
    <String, dynamic>{
      'report_id': instance.reportId,
      'created_by': instance.createdBy,
      'created_at': instance.createdAt.toIso8601String(),
      'pupil_id': instance.pupilId,
      'school_semester_id': instance.schoolSemesterId,
    };
