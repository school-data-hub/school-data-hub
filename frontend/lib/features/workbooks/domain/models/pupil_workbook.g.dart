// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pupil_workbook.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PupilWorkbook _$PupilWorkbookFromJson(Map<String, dynamic> json) =>
    PupilWorkbook(
      createdAt: DateTime.parse(json['created_at'] as String),
      createdBy: json['created_by'] as String,
      comment: json['comment'] as String?,
      status: (json['status'] as num?)?.toInt(),
      workbookIsbn: (json['workbook_isbn'] as num).toInt(),
      finishedAt: json['finished_at'] == null
          ? null
          : DateTime.parse(json['finished_at'] as String),
    );

Map<String, dynamic> _$PupilWorkbookToJson(PupilWorkbook instance) =>
    <String, dynamic>{
      'created_at': instance.createdAt.toIso8601String(),
      'created_by': instance.createdBy,
      'comment': instance.comment,
      'status': instance.status,
      'workbook_isbn': instance.workbookIsbn,
      'finished_at': instance.finishedAt?.toIso8601String(),
    };
