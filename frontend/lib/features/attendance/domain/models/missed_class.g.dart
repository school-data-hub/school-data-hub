// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'missed_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MissedClass _$MissedClassFromJson(Map<String, dynamic> json) => MissedClass(
      contacted: json['contacted'] as String?,
      createdBy: json['created_by'] as String,
      minutesLate: (json['minutes_late'] as num?)?.toInt(),
      unexcused: json['unexcused'] as bool,
      missedDay: DateTime.parse(json['missed_day'] as String),
      missedPupilId: (json['missed_pupil_id'] as num).toInt(),
      missedType: json['missed_type'] as String,
      modifiedBy: json['modified_by'] as String?,
      backHome: json['returned'] as bool?,
      backHomeAt: json['returned_at'] as String?,
      writtenExcuse: json['written_excuse'] as bool?,
      comment: json['comment'] as String?,
    );

Map<String, dynamic> _$MissedClassToJson(MissedClass instance) =>
    <String, dynamic>{
      'contacted': instance.contacted,
      'created_by': instance.createdBy,
      'unexcused': instance.unexcused,
      'minutes_late': instance.minutesLate,
      'missed_day': instance.missedDay.toIso8601String(),
      'missed_pupil_id': instance.missedPupilId,
      'missed_type': instance.missedType,
      'modified_by': instance.modifiedBy,
      'returned': instance.backHome,
      'returned_at': instance.backHomeAt,
      'written_excuse': instance.writtenExcuse,
      'comment': instance.comment,
    };
