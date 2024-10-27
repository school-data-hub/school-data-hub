// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pupil_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SupportLevel _$SupportLevelFromJson(Map<String, dynamic> json) => SupportLevel(
      supportLevelId: json['support_level_id'] as String,
      level: (json['level'] as num).toInt(),
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      createdBy: json['created_by'] as String,
    );

Map<String, dynamic> _$SupportLevelToJson(SupportLevel instance) =>
    <String, dynamic>{
      'support_level_id': instance.supportLevelId,
      'level': instance.level,
      'comment': instance.comment,
      'created_at': instance.createdAt.toIso8601String(),
      'created_by': instance.createdBy,
    };

PupilData _$PupilDataFromJson(Map<String, dynamic> json) => PupilData(
      avatarId: json['avatar_id'] as String?,
      communicationPupil: json['communication_pupil'] as String?,
      communicationTutor1: json['communication_tutor1'] as String?,
      communicationTutor2: json['communication_tutor2'] as String?,
      contact: json['contact'] as String?,
      parentsContact: json['parents_contact'] as String?,
      credit: (json['credit'] as num).toInt(),
      creditEarned: (json['credit_earned'] as num).toInt(),
      fiveYears: json['five_years'] == null
          ? null
          : DateTime.parse(json['five_years'] as String),
      latestSupportLevel: (json['latest_support_level'] as num).toInt(),
      internalId: (json['internal_id'] as num).toInt(),
      ogs: json['ogs'] as bool,
      ogsInfo: json['ogs_info'] as String?,
      pickUpTime: json['pick_up_time'] as String?,
      specialInformation: json['special_information'] as String?,
      preschoolRevision: (json['preschool_revision'] as num?)?.toInt(),
      emergencyCare: json['emergency_care'] as bool?,
      supportCategoryStatuses: (json['support_category_statuses']
              as List<dynamic>)
          .map((e) => SupportCategoryStatus.fromJson(e as Map<String, dynamic>))
          .toList(),
      schooldayEvents: (json['pupil_schoolday_events'] as List<dynamic>)
          .map((e) => SchooldayEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      pupilBooks: (json['pupil_books'] as List<dynamic>)
          .map((e) => PupilBook.fromJson(e as Map<String, dynamic>))
          .toList(),
      supportGoals: (json['support_goals'] as List<dynamic>)
          .map((e) => SupportGoal.fromJson(e as Map<String, dynamic>))
          .toList(),
      pupilMissedClasses: (json['pupil_missed_classes'] as List<dynamic>)
          .map((e) => MissedClass.fromJson(e as Map<String, dynamic>))
          .toList(),
      pupilWorkbooks: (json['pupil_workbooks'] as List<dynamic>)
          .map((e) => PupilWorkbook.fromJson(e as Map<String, dynamic>))
          .toList(),
      creditHistoryLogs: (json['credit_history_logs'] as List<dynamic>)
          .map((e) => CreditHistoryLog.fromJson(e as Map<String, dynamic>))
          .toList(),
      competenceGoals: (json['competence_goals'] as List<dynamic>)
          .map((e) => CompetenceGoal.fromJson(e as Map<String, dynamic>))
          .toList(),
      competenceChecks: (json['competence_checks'] as List<dynamic>)
          .map((e) => CompetenceCheck.fromJson(e as Map<String, dynamic>))
          .toList(),
      supportLevelHistory: (json['support_level_history'] as List<dynamic>)
          .map((e) => SupportLevel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PupilDataToJson(PupilData instance) => <String, dynamic>{
      'avatar_id': instance.avatarId,
      'communication_pupil': instance.communicationPupil,
      'communication_tutor1': instance.communicationTutor1,
      'communication_tutor2': instance.communicationTutor2,
      'contact': instance.contact,
      'parents_contact': instance.parentsContact,
      'credit': instance.credit,
      'credit_earned': instance.creditEarned,
      'five_years': instance.fiveYears?.toIso8601String(),
      'latest_support_level': instance.latestSupportLevel,
      'internal_id': instance.internalId,
      'ogs': instance.ogs,
      'ogs_info': instance.ogsInfo,
      'pick_up_time': instance.pickUpTime,
      'preschool_revision': instance.preschoolRevision,
      'special_information': instance.specialInformation,
      'emergency_care': instance.emergencyCare,
      'competence_checks': instance.competenceChecks,
      'support_category_statuses': instance.supportCategoryStatuses,
      'pupil_schoolday_events': instance.schooldayEvents,
      'pupil_books': instance.pupilBooks,
      'support_goals': instance.supportGoals,
      'pupil_missed_classes': instance.pupilMissedClasses,
      'pupil_workbooks': instance.pupilWorkbooks,
      'credit_history_logs': instance.creditHistoryLogs,
      'competence_goals': instance.competenceGoals,
      'support_level_history': instance.supportLevelHistory,
    };
