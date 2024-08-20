// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schoolday_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SchooldayEvent _$SchooldayEventFromJson(Map<String, dynamic> json) =>
    SchooldayEvent(
      schooldayEventId: json['schoolday_event_id'] as String,
      schooldayEventType: json['schoolday_event_type'] as String,
      schooldayEventReason: json['schoolday_event_reason'] as String,
      admonishingUser: json['created_by'] as String,
      processed: json['processed'] as bool,
      processedBy: json['processed_by'] as String?,
      processedAt: json['processed_at'] == null
          ? null
          : DateTime.parse(json['processed_at'] as String),
      fileId: json['file_id'] as String?,
      processedFileId: json['processed_file_id'] as String?,
      schooldayEventDate: DateTime.parse(json['schoolday_event_day'] as String),
      admonishedPupilId: (json['schoolday_event_pupil_id'] as num).toInt(),
    );

Map<String, dynamic> _$SchooldayEventToJson(SchooldayEvent instance) =>
    <String, dynamic>{
      'schoolday_event_id': instance.schooldayEventId,
      'schoolday_event_type': instance.schooldayEventType,
      'schoolday_event_reason': instance.schooldayEventReason,
      'created_by': instance.admonishingUser,
      'processed': instance.processed,
      'processed_by': instance.processedBy,
      'processed_at': instance.processedAt?.toIso8601String(),
      'file_id': instance.fileId,
      'processed_file_id': instance.processedFileId,
      'schoolday_event_day': instance.schooldayEventDate.toIso8601String(),
      'schoolday_event_pupil_id': instance.admonishedPupilId,
    };
