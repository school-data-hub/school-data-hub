// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'support_category_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SupportCategoryStatus _$SupportCategoryStatusFromJson(
        Map<String, dynamic> json) =>
    SupportCategoryStatus(
      comment: json['comment'] as String,
      fileId: json['file_id'] as String?,
      supportCategoryId: (json['support_category_id'] as num).toInt(),
      statusId: json['status_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      createdBy: json['created_by'] as String,
      state: json['state'] as String,
    );

Map<String, dynamic> _$SupportCategoryStatusToJson(
        SupportCategoryStatus instance) =>
    <String, dynamic>{
      'comment': instance.comment,
      'file_id': instance.fileId,
      'support_category_id': instance.supportCategoryId,
      'status_id': instance.statusId,
      'created_at': instance.createdAt.toIso8601String(),
      'created_by': instance.createdBy,
      'state': instance.state,
    };
