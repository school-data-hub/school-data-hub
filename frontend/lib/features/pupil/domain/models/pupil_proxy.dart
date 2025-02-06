// ignore_for_file: constant_identifier_names

import 'package:flutter/foundation.dart';
import 'package:schuldaten_hub/common/domain/filters/filters.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/features/attendance/domain/models/missed_class.dart';
import 'package:schuldaten_hub/features/books/domain/models/pupil_book.dart';
import 'package:schuldaten_hub/features/competence/domain/models/competence_check.dart';
import 'package:schuldaten_hub/features/competence/domain/models/competence_goal.dart';
import 'package:schuldaten_hub/features/learning_support/domain/models/support_category/support_category_status.dart';
import 'package:schuldaten_hub/features/learning_support/domain/models/support_goal/support_goal.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/credit_history_log.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_data.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_identity.dart';
import 'package:schuldaten_hub/features/schoolday_events/domain/models/schoolday_event.dart';
import 'package:schuldaten_hub/features/schooldays/domain/schoolday_manager.dart';
import 'package:schuldaten_hub/features/workbooks/domain/models/pupil_workbook.dart';

enum SchoolGrade {
  E1('E1'),
  E2('E2'),
  E3('E3'),
  S3('S3'),
  S4('S4');

  static const stringToValue = {
    'E1': SchoolGrade.E1,
    'E2': SchoolGrade.E2,
    'E3': SchoolGrade.E3,
    'S3': SchoolGrade.S3,
    'S4': SchoolGrade.S4,
  };

  final String value;
  const SchoolGrade(this.value);
}

enum Gender {
  male('m'),
  female('w');

  static const stringToValue = {
    'm': Gender.male,
    'w': Gender.female,
  };

  final String value;
  const Gender(this.value);
}

enum GroupId {
  A1('A1'),
  A2('A2'),
  A3('A3'),
  B1('B1'),
  B2('B2'),
  B3('B3'),
  B4('B4'),
  C1('C1'),
  C2('C2'),
  C3('C3');

  static const stringToValue = {
    'A1': GroupId.A1,
    'A2': GroupId.A2,
    'A3': GroupId.A3,
    'B1': GroupId.B1,
    'B2': GroupId.B2,
    'B3': GroupId.B3,
    'B4': GroupId.B4,
    'C1': GroupId.C1,
    'C2': GroupId.C2,
    'C3': GroupId.C3,
  };

  final String value;
  const GroupId(this.value);
}

class SchoolGradeFilter extends SelectorFilter<PupilProxy, SchoolGrade> {
  SchoolGradeFilter(SchoolGrade schoolGrade)
      : super(name: schoolGrade.value, selector: (proxy) => proxy.schoolGrade);

  @override
  bool matches(PupilProxy item) {
    return selector(item).value == name;
  }
}

class GroupFilter extends SelectorFilter<PupilProxy, GroupId> {
  GroupFilter(GroupId group)
      : super(name: group.value, selector: (proxy) => proxy.groupId);

  @override
  bool matches(PupilProxy item) {
    //debugger();
    return selector(item).value == name;
  }
}

class GenderFilter extends SelectorFilter<PupilProxy, Gender> {
  GenderFilter(Gender gender)
      : super(
            name: gender.value == 'm' ? '♂️' : '♀️',
            selector: (proxy) => Gender.stringToValue[proxy.gender]!);

  @override
  bool matches(PupilProxy item) {
    return selector(item).value == (name == '♂️' ? 'm' : 'w');
  }
}

class PupilProxy with ChangeNotifier {
  PupilProxy(
      {required PupilData pupilData, required PupilIdentity pupilIdentity})
      : _pupilIdentity = pupilIdentity {
    updatePupil(pupilData);
  }

  static List<GroupFilter> groupFilters = [
    GroupFilter(GroupId.A1),
    GroupFilter(GroupId.A2),
    GroupFilter(GroupId.A3),
    GroupFilter(GroupId.B1),
    GroupFilter(GroupId.B2),
    GroupFilter(GroupId.B3),
    GroupFilter(GroupId.B4),
    GroupFilter(GroupId.C1),
    GroupFilter(GroupId.C2),
    GroupFilter(GroupId.C3),
  ];

  static List<SchoolGradeFilter> schoolGradeFilters = [
    SchoolGradeFilter(SchoolGrade.E1),
    SchoolGradeFilter(SchoolGrade.E2),
    SchoolGradeFilter(SchoolGrade.E3),
    SchoolGradeFilter(SchoolGrade.S3),
    SchoolGradeFilter(SchoolGrade.S4),
  ];

  static List<GenderFilter> genderFilters = [
    GenderFilter(Gender.male),
    GenderFilter(Gender.female),
  ];

  late PupilData _pupilData;
  PupilIdentity _pupilIdentity;

  bool pupilIsDirty = false;

  void updatePupil(PupilData pupilData) {
    //if (pupilData == _pupilData) return;
    _pupilData = pupilData;
    // ignore: prefer_for_elements_to_map_fromiterable
    _missedClasses = Map.fromIterable(pupilData.pupilMissedClasses,
        key: (e) => e.missedDay, value: (e) => e);

    pupilIsDirty = true;
    notifyListeners();
  }

  //- TODO - remove this method

  void updatePupilIdentity(PupilIdentity pupilIdentity) {
    if (_pupilIdentity != pupilIdentity) {
      _pupilIdentity = pupilIdentity;
      pupilIsDirty = true;
      notifyListeners();
    }
  }

  void deleteAvatarAuthId() {
    final updatedPupil = _pupilData.copyWith(avatarAuthId: (value: null));
    _pupilData = updatedPupil;
    pupilIsDirty = true;
    notifyListeners();
  }

  void deletePublicMediaAuthId() {
    final updatedPupil = _pupilData.copyWith(publicMediaAuthId: (value: null));
    _pupilData = updatedPupil;
    pupilIsDirty = true;
    notifyListeners();
  }

  void updatePupilIdentityFromMoreRecentSource(PupilIdentity pupilIdentity) {
    if (_pupilIdentity != pupilIdentity) {
      _pupilIdentity = pupilIdentity;
      pupilIsDirty = true;
      notifyListeners();
    }
  }

  void clearAvatar() {
    _avatarIdOverride = null;
    _avatarUpdated = true;
    pupilIsDirty = true;
    notifyListeners();
  }

  void updateFromMissedClassesOnASchoolday(
      List<MissedClass> allMissedClassesThisDay) {
    pupilIsDirty = false;

    if (allMissedClassesThisDay.any(
        (missedClass) => missedClass.missedPupilId == _pupilData.internalId)) {
      final missedClass = allMissedClassesThisDay.firstWhere(
          (missedClass) => missedClass.missedPupilId == _pupilData.internalId);
      // if the missed class is not already in the missed classes
      // or if the missed class is different from the one in the missed classes
      // write it
      if (!_missedClasses.containsKey(missedClass.missedDay) ||
          !(_missedClasses[missedClass.missedDay] == missedClass)) {
        _missedClasses[missedClass.missedDay] = missedClass;
        pupilIsDirty = true;
      }
    } else {
      // there is no missed class for this pupil on this date
      // if there is a missed class for this date in the pupil's missed classes in memory
      // remove it
      if (_missedClasses
          .containsKey(locator<SchooldayManager>().thisDate.value)) {
        _missedClasses.remove(locator<SchooldayManager>().thisDate.value);
        pupilIsDirty = true;
      }
    }

    if (pupilIsDirty) {
      notifyListeners();
    }
  }

  String get firstName => _pupilIdentity.firstName;
  String get lastName => _pupilIdentity.lastName;

  String get group => _pupilIdentity.group;
  GroupId get groupId => GroupId.stringToValue[_pupilIdentity.group]!;

  SchoolGrade get schoolGrade =>
      SchoolGrade.stringToValue[_pupilIdentity.schoolGrade]!;

  String get schoolyear => _pupilIdentity.schoolGrade;
  String? get specialNeeds => _pupilIdentity.specialNeeds;
  String get gender => _pupilIdentity.gender;
  String get language => _pupilIdentity.language;
  String? get family => _pupilIdentity.family;
  DateTime get birthday => _pupilIdentity.birthday;
  int get age {
    final today = DateTime.now();
    int age = today.year - _pupilIdentity.birthday.year;
    if (today.month < _pupilIdentity.birthday.month ||
        (today.month == _pupilIdentity.birthday.month &&
            today.day < _pupilIdentity.birthday.day)) {
      age--;
    }
    return age;
  }

  DateTime? get migrationSupportEnds => _pupilIdentity.migrationSupportEnds;
  DateTime get pupilSince => _pupilIdentity.pupilSince;

  String? _avatarIdOverride;
  bool _avatarUpdated = false;
  String? get avatarId =>
      _avatarUpdated ? _avatarIdOverride : _pupilData.avatarId;
  bool get avatarAuth => _pupilData.avatarAuth;
  String? get avatarAuthId => _pupilData.avatarAuthId;
  int get publicMediaAuth => _pupilData.publicMediaAuth;
  String? get publicMediaAuthId => _pupilData.publicMediaAuthId;
  String? get communicationPupil => _pupilData.communicationPupil;
  String? get communicationTutor1 => _pupilData.communicationTutor1;
  String? get communicationTutor2 => _pupilData.communicationTutor2;
  String? get contact => _pupilData.contact;
  String? get parentsContact => _pupilData.parentsContact;
  int get credit => _pupilData.credit;
  int get creditEarned => _pupilData.creditEarned;
  DateTime? get fiveYears => _pupilData.fiveYears;
  int get supportLevel => _pupilData.latestSupportLevel;
  List<SupportLevel> get supportLevelHistory => _pupilData.supportLevelHistory;
  int get internalId => _pupilData.internalId;
  bool get ogs => _pupilData.ogs;
  String? get ogsInfo => _pupilData.ogsInfo;
  String? get pickUpTime => _pupilData.pickUpTime;
  int? get preschoolRevision => _pupilData.preschoolRevision;
  String? get specialInformation => _pupilData.specialInformation;
  bool? get emergencyCare => _pupilData.emergencyCare;
  List<CompetenceCheck>? get competenceChecks => _pupilData.competenceChecks;
  List<SupportCategoryStatus>? get supportCategoryStatuses =>
      _pupilData.supportCategoryStatuses;
  List<SchooldayEvent>? get schooldayEvents => _pupilData.schooldayEvents;
  List<PupilBook>? get pupilBooks => _pupilData.pupilBooks;
  List<SupportGoal>? get supportGoals => _pupilData.supportGoals;

  List<MissedClass>? get missedClasses => _missedClasses.values.toList();
  Map<DateTime, MissedClass> _missedClasses = {};

  List<PupilWorkbook>? get pupilWorkbooks => _pupilData.pupilWorkbooks;
  List<CreditHistoryLog>? get creditHistoryLogs => _pupilData.creditHistoryLogs;
  List<CompetenceGoal>? get competenceGoals => _pupilData.competenceGoals;
}
