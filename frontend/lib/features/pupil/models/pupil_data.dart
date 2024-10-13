// ignore_for_file: invalid_annotation_target
import 'package:json_annotation/json_annotation.dart';
import 'package:schuldaten_hub/features/schoolday_events/models/schoolday_event.dart';
import 'package:schuldaten_hub/features/attendance/models/missed_class.dart';
import 'package:schuldaten_hub/features/books/models/pupil_book.dart';
import 'package:schuldaten_hub/features/competence/models/competence_check.dart';
import 'package:schuldaten_hub/features/competence/models/competence_goal.dart';
import 'package:schuldaten_hub/features/learning_support/models/support_category/support_category_status.dart';
import 'package:schuldaten_hub/features/learning_support/models/support_goal/support_goal.dart';
import 'package:schuldaten_hub/features/pupil/models/credit_history_log.dart';
import 'package:schuldaten_hub/features/workbooks/models/pupil_workbook.dart';

part 'pupil_data.g.dart';

@JsonSerializable()
class SupportLevel {
  @JsonKey(name: 'support_level_id')
  final String supportLevelId;
  @JsonKey(name: 'level')
  final int level;
  @JsonKey(name: 'comment')
  final String comment;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'created_by')
  final String createdBy;

  factory SupportLevel.fromJson(Map<String, dynamic> json) =>
      _$SupportLevelFromJson(json);

  Map<String, dynamic> toJson() => _$SupportLevelToJson(this);

  SupportLevel({
    required this.supportLevelId,
    required this.level,
    required this.comment,
    required this.createdAt,
    required this.createdBy,
  });
}

@JsonSerializable()
class PupilData {
  @JsonKey(name: 'avatar_id')
  final String? avatarId;
  @JsonKey(name: 'communication_pupil')
  final String? communicationPupil;
  @JsonKey(name: 'communication_tutor1')
  final String? communicationTutor1;
  @JsonKey(name: 'communication_tutor2')
  final String? communicationTutor2;
  @JsonKey(name: 'contact')
  final String? contact;
  @JsonKey(name: 'parents_contact')
  final String? parentsContact;
  final int credit;
  @JsonKey(name: 'credit_earned')
  final int creditEarned;
  @JsonKey(name: 'five_years')
  final String? fiveYears;
  @JsonKey(name: 'latest_support_level')
  final int latestSupportLevel;
  @JsonKey(name: 'internal_id')
  final int internalId;
  final bool ogs;
  @JsonKey(name: 'ogs_info')
  final String? ogsInfo;
  @JsonKey(name: 'pick_up_time')
  final String? pickUpTime;
  @JsonKey(name: 'preschool_revision')
  int? preschoolRevision;
  @JsonKey(name: 'special_information')
  final String? specialInformation;
  @JsonKey(name: 'emergency_care')
  bool? emergencyCare;
  @JsonKey(name: 'competence_checks')
  List<CompetenceCheck> competenceChecks;
  @JsonKey(name: 'support_category_statuses')
  final List<SupportCategoryStatus> supportCategoryStatuses;
  @JsonKey(name: 'pupil_schoolday_events')
  final List<SchooldayEvent> schooldayEvents;
  @JsonKey(name: 'pupil_books')
  final List<PupilBook> pupilBooks;

  @JsonKey(name: 'support_goals')
  final List<SupportGoal> supportGoals;
  @JsonKey(name: 'pupil_missed_classes')
  final List<MissedClass> pupilMissedClasses;
  @JsonKey(name: 'pupil_workbooks')
  final List<PupilWorkbook> pupilWorkbooks;

  @JsonKey(name: "credit_history_logs")
  final List<CreditHistoryLog> creditHistoryLogs;
  @JsonKey(name: "competence_goals")
  final List<CompetenceGoal> competenceGoals;

  @JsonKey(name: 'support_level_history')
  final List<SupportLevel> supportLevelHistory;

  factory PupilData.fromJson(Map<String, dynamic> json) =>
      _$PupilDataFromJson(json);

  Map<String, dynamic> toJson() => _$PupilDataToJson(this);

  PupilData({
    required this.avatarId,
    required this.communicationPupil,
    required this.communicationTutor1,
    required this.communicationTutor2,
    required this.contact,
    required this.parentsContact,
    required this.credit,
    required this.creditEarned,
    required this.fiveYears,
    required this.latestSupportLevel,
    required this.internalId,
    required this.ogs,
    required this.ogsInfo,
    required this.pickUpTime,
    required this.specialInformation,
    required this.preschoolRevision,
    required this.emergencyCare,
    required this.supportCategoryStatuses,
    required this.schooldayEvents,
    required this.pupilBooks,
    required this.supportGoals,
    required this.pupilMissedClasses,
    required this.pupilWorkbooks,
    required this.creditHistoryLogs,
    required this.competenceGoals,
    required this.competenceChecks,
    required this.supportLevelHistory,
  });
}
