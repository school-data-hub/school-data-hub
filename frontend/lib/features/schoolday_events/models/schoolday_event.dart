// ignore_for_file: invalid_annotation_target

import 'package:json_annotation/json_annotation.dart';

part 'schoolday_event.g.dart';

@JsonSerializable()
class SchooldayEvent {
  @JsonKey(name: 'schoolday_event_id')
  final String schooldayEventId;
  @JsonKey(name: 'schoolday_event_type')
  final String schooldayEventType;
  @JsonKey(name: 'schoolday_event_reason')
  final String schooldayEventReason;
  @JsonKey(name: 'created_by')
  final String createdBy;
  @JsonKey(name: 'processed')
  final bool processed;
  @JsonKey(name: 'processed_by')
  final String? processedBy;
  @JsonKey(name: 'processed_at')
  final DateTime? processedAt;
  @JsonKey(name: 'file_id')
  final String? fileId;
  @JsonKey(name: 'processed_file_id')
  final String? processedFileId;
  @JsonKey(name: 'schoolday_event_day')
  final DateTime schooldayEventDate;
  @JsonKey(name: 'schoolday_event_pupil_id')
  final int admonishedPupilId;

  SchooldayEvent(
      {required this.schooldayEventId,
      required this.schooldayEventType,
      required this.schooldayEventReason,
      required this.createdBy,
      required this.processed,
      required this.processedBy,
      required this.processedAt,
      required this.fileId,
      required this.processedFileId,
      required this.schooldayEventDate,
      required this.admonishedPupilId});

  factory SchooldayEvent.fromJson(Map<String, dynamic> json) =>
      _$SchooldayEventFromJson(json);

  Map<String, dynamic> toJson() => _$SchooldayEventToJson(this);
}
