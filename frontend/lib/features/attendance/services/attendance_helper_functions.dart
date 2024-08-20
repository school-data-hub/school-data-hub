import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/features/schooldays/services/schoolday_manager.dart';
import 'package:schuldaten_hub/common/utils/extensions.dart';
import 'package:schuldaten_hub/common/widgets/date_picker.dart';
import 'package:schuldaten_hub/features/attendance/services/attendance_manager.dart';
import 'package:schuldaten_hub/features/pupil/services/pupil_manager.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';

class AttendanceValues {
  final MissedType missedTypeValue;
  final ContactedType contactedTypeValue;
  final String? createdOrModifiedByValue;
  final bool excusedValue;
  final bool returnedValue;
  final String? returnedTimeValue;
  final String? commentValue;

  AttendanceValues({
    required this.missedTypeValue,
    required this.contactedTypeValue,
    required this.createdOrModifiedByValue,
    required this.excusedValue,
    this.returnedValue = false,
    this.returnedTimeValue,
    this.commentValue,
  });
}

//- lookup functions
class AttendanceHelper {
  static int? findMissedClassIndex(PupilProxy pupil, DateTime date) {
    final int? foundMissedClassIndex = pupil.pupilMissedClasses
        ?.indexWhere((datematch) => (datematch.missedDay.isSameDate(date)));
    if (foundMissedClassIndex == null) {
      return null;
    }
    return foundMissedClassIndex;
  }

//- overview numbers functions

//- of all pupils

  static int missedGlobalSum() {
    int missedGlobalSum = 0;
    final List<PupilProxy> allPupils = locator<PupilManager>().allPupils;
    for (PupilProxy pupil in allPupils) {
      if (pupil.pupilMissedClasses!.isNotEmpty) {
        missedGlobalSum += pupil.pupilMissedClasses!
            .where((element) =>
                element.missedType == 'missed' ||
                element.missedType == 'home' ||
                element.backHome == true)
            .length;
      }
    }
    return missedGlobalSum;
  }

  static int unexcusedGlobalSum() {
    int unexcusedGlobalSum = 0;
    final List<PupilProxy> allPupils = locator<PupilManager>().allPupils;
    for (PupilProxy pupil in allPupils) {
      if (pupil.pupilMissedClasses!.isNotEmpty) {
        unexcusedGlobalSum += pupil.pupilMissedClasses!
            .where((element) =>
                element.missedType == 'missed' && element.excused == true)
            .length;
      }
    }
    return unexcusedGlobalSum;
  }

  static int lateGlobalSum() {
    int lateGlobalSum = 0;
    final List<PupilProxy> allPupils = locator<PupilManager>().allPupils;
    for (PupilProxy pupil in allPupils) {
      if (pupil.pupilMissedClasses!.isNotEmpty) {
        lateGlobalSum += pupil.pupilMissedClasses!
            .where((element) => element.missedType == 'late')
            .length;
      }
    }
    return lateGlobalSum;
  }

  static int contactedGlobalSum() {
    int contactedGlobalSum = 0;
    final List<PupilProxy> allPupils = locator<PupilManager>().allPupils;
    for (PupilProxy pupil in allPupils) {
      if (pupil.pupilMissedClasses!.isNotEmpty) {
        contactedGlobalSum += pupil.pupilMissedClasses!
            .where((element) => element.contacted != '0')
            .length;
      }
    }
    return contactedGlobalSum;
  }

  static int pickedUpGlobalSum() {
    int pickedUpGlobalSum = 0;
    final List<PupilProxy> allPupils = locator<PupilManager>().allPupils;
    for (PupilProxy pupil in allPupils) {
      if (pupil.pupilMissedClasses!.isNotEmpty) {
        pickedUpGlobalSum += pupil.pupilMissedClasses!
            .where((element) => element.backHome == true)
            .length;
      }
    }
    return pickedUpGlobalSum;
  }

//- of a list of pupils in a schoolday

  static int missedPupilsSum(
      List<PupilProxy> filteredPupils, DateTime thisDate) {
    List<PupilProxy> missedPupils = [];
    if (filteredPupils.isNotEmpty) {
      for (PupilProxy pupil in filteredPupils) {
        if (pupil.pupilMissedClasses!.any((missedClass) =>
            missedClass.missedDay == thisDate &&
            (missedClass.missedType == 'missed' ||
                missedClass.missedType == 'home' ||
                missedClass.backHome == true))) {
          missedPupils.add(pupil);
        }
      }
      return missedPupils.length;
    }
    return 0;
  }

  static int unexcusedPupilsSum(
      List<PupilProxy> filteredPupils, DateTime thisDate) {
    List<PupilProxy> unexcusedPupils = [];

    for (PupilProxy pupil in filteredPupils) {
      if (pupil.pupilMissedClasses!.any((missedClass) =>
          missedClass.missedDay == thisDate && missedClass.excused == true)) {
        unexcusedPupils.add(pupil);
      }
    }

    return unexcusedPupils.length;
  }

//- of a list of pupils

  static int pupilListMissedclassSum(List<PupilProxy> filteredPupils) {
    int pupilsListmissedclassSum = 0;
    for (PupilProxy pupil in filteredPupils) {
      pupilsListmissedclassSum += missedclassSum(pupil);
    }
    return pupilsListmissedclassSum;
  }

  static int pupilListUnexcusedSum(List<PupilProxy> filteredPupils) {
    int pupilsListUnexcusedSum = 0;
    for (PupilProxy pupil in filteredPupils) {
      pupilsListUnexcusedSum += missedclassUnexcusedSum(pupil);
    }
    return pupilsListUnexcusedSum;
  }

  static int pupilListLateSum(List<PupilProxy> filteredPupils) {
    int pupilsListLateSum = 0;
    for (PupilProxy pupil in filteredPupils) {
      pupilsListLateSum += lateSum(pupil);
    }
    return pupilsListLateSum;
  }

  static int pupilListContactedSum(List<PupilProxy> filteredPupils) {
    int pupilsListContactedSum = 0;
    for (PupilProxy pupil in filteredPupils) {
      pupilsListContactedSum += contactedSum(pupil);
    }
    return pupilsListContactedSum;
  }

  static int pupilListPickedUpSum(List<PupilProxy> filteredPupils) {
    int pupilsListPickedUpSum = 0;
    for (PupilProxy pupil in filteredPupils) {
      pupilsListPickedUpSum += pickedUpSum(pupil);
    }
    return pupilsListPickedUpSum;
  }
//- of a single pupil

  static int missedclassSum(PupilProxy pupil) {
    // count the number of missed classes - avoid null when missedClasses is empty
    int missedclassCount = 0;
    if (pupil.pupilMissedClasses != null) {
      missedclassCount = pupil.pupilMissedClasses!
          .where((element) =>
              element.missedType == 'missed' && element.excused == false)
          .length;
    }
    return missedclassCount;
  }

  static int missedclassUnexcusedSum(PupilProxy pupil) {
    // count the number of unexcused missed classes
    int missedclassCount = 0;
    if (pupil.pupilMissedClasses != null) {
      missedclassCount = pupil.pupilMissedClasses!
          .where((element) =>
              element.missedType == 'missed' && element.excused == true)
          .length;
    }
    return missedclassCount;
  }

  static int lateSum(PupilProxy pupil) {
    int lateCount = 0;
    if (pupil.pupilMissedClasses != null) {
      lateCount = pupil.pupilMissedClasses!
          .where((element) => element.missedType == 'late')
          .length;
    }
    return lateCount;
  }

  static int lateUnexcusedSum(PupilProxy pupil) {
    int missedClassUnexcusedCount = 0;
    if (pupil.pupilMissedClasses != null) {
      missedClassUnexcusedCount = pupil.pupilMissedClasses!
          .where((element) =>
              element.missedType == 'late' && element.excused == true)
          .length;
    }
    return missedClassUnexcusedCount;
  }

  static int contactedSum(PupilProxy pupil) {
    int contactedCount = pupil.pupilMissedClasses!
        .where((element) => element.contacted != '0')
        .length;

    return contactedCount;
  }

  static int pickedUpSum(PupilProxy pupil) {
    int pickedUpCount = pupil.pupilMissedClasses!
        .where((element) => element.backHome == true)
        .length;

    return pickedUpCount;
  }

//- check condition functions

  static bool pupilIsMissedToday(PupilProxy pupil) {
    if (pupil.pupilMissedClasses!.isEmpty) return false;
    if (pupil.pupilMissedClasses!.any((element) =>
        element.missedDay.isSameDate(DateTime.now()) &&
        element.missedType != 'late')) {
      return true;
    }
    return false;
  }

  static bool schooldayIsToday(DateTime schoolday) {
    if (schoolday.isSameDate(DateTime.now())) {
      return true;
    }
    return false;
  }

// use one function instead all the set value functions
// to avoid unnecessary lookups
  static AttendanceValues setAttendanceInfo(int pupilId, DateTime date) {
    MissedType missedType;
    ContactedType contactedType;
    final PupilProxy pupil = locator<PupilManager>().findPupilById(pupilId)!;
    final int? missedClass = findMissedClassIndex(pupil, date);
    if (missedClass == -1 || missedClass == null) {
      return AttendanceValues(
        missedTypeValue: MissedType.notSet,
        contactedTypeValue: ContactedType.notSet,
        createdOrModifiedByValue: null,
        excusedValue: false,
        returnedValue: false,
        returnedTimeValue: null,
        commentValue: null,
      );
    } else {
      final dropdownvalue = pupil.pupilMissedClasses![missedClass].missedType;
      missedType =
          MissedType.values.firstWhere((e) => e.value == dropdownvalue);
    }

    final contactedValue = pupil.pupilMissedClasses![missedClass].contacted;
    contactedType = ContactedType.values
            .firstWhereOrNull((e) => e.value == contactedValue) ??
        ContactedType.notSet;

    String createdOrModifiedBy =
        pupil.pupilMissedClasses![missedClass].modifiedBy ??
            pupil.pupilMissedClasses![missedClass].createdBy;

    final bool excused = pupil.pupilMissedClasses![missedClass].excused!;
    final bool returned = pupil.pupilMissedClasses![missedClass].backHome!;
    final String? returnedTime =
        pupil.pupilMissedClasses![missedClass].backHomeAt;
    final String? comment = pupil.pupilMissedClasses![missedClass].comment;

    return AttendanceValues(
      missedTypeValue: missedType,
      contactedTypeValue: contactedType,
      createdOrModifiedByValue: createdOrModifiedBy,
      excusedValue: excused,
      returnedValue: returned,
      returnedTimeValue: returnedTime,
      commentValue: comment,
    );
  }

// //- set value functions
//   static MissedType setMissedTypeValue(int pupilId, DateTime date) {
//     final PupilProxy pupil = locator<PupilManager>().findPupilById(pupilId)!;
//     final int? missedClass = findMissedClassIndex(pupil, date);
//     if (missedClass == -1 || missedClass == null) {
//       return MissedType.notSet;
//     }
//     final dropdownvalue = pupil.pupilMissedClasses![missedClass].missedType;

//     final MissedType missedType =
//         MissedType.values.firstWhere((e) => e.value == dropdownvalue);
//     return missedType;
//   }

//   static ContactedType setContactedValue(int pupilId, DateTime date) {
//     final PupilProxy pupil = locator<PupilManager>().findPupilById(pupilId)!;
//     final int? missedClass = findMissedClassIndex(pupil, date);
//     if (missedClass == -1) {
//       return ContactedType.notSet;
//     } else {
//       final contactedType = ContactedType.values.firstWhereOrNull(
//           (e) => e.value == pupil.pupilMissedClasses![missedClass!].contacted);

//       return contactedType ?? ContactedType.notSet;
//     }
//   }

//   static String? setCreatedModifiedValue(int pupilId, DateTime date) {
//     final PupilProxy pupil = locator<PupilManager>().findPupilById(pupilId)!;
//     final int? missedClass = findMissedClassIndex(pupil, date);
//     if (missedClass == -1 || missedClass == null) {
//       return null;
//     }
//     final String createdBy = pupil.pupilMissedClasses![missedClass].createdBy;
//     final String? modifiedBy =
//         pupil.pupilMissedClasses![missedClass].modifiedBy;

//     if (modifiedBy != null) {
//       return modifiedBy;
//     }
//     return createdBy;
//   }

//   static bool setExcusedValue(int pupilId, DateTime date) {
//     final PupilProxy pupil = locator<PupilManager>().findPupilById(pupilId)!;
//     final int? missedClass = findMissedClassIndex(pupil, date);
//     if (missedClass == -1) {
//       return false;
//     }
//     final excusedValue = pupil.pupilMissedClasses![missedClass!].excused;
//     return excusedValue!;
//   }

//   static bool? setReturnedValue(int pupilId, DateTime date) {
//     final PupilProxy pupil = locator<PupilManager>().findPupilById(pupilId)!;
//     final int? missedClass = findMissedClassIndex(pupil, date);

//     if (missedClass == -1) {
//       return false;
//     }
//     final returnedindex = pupil.pupilMissedClasses![missedClass!].backHome;
//     return returnedindex;
//   }

//   static String? setReturnedTime(int pupilId, DateTime date) {
//     final PupilProxy pupil = locator<PupilManager>().findPupilById(pupilId)!;
//     final int? missedClass = findMissedClassIndex(pupil, date);
//     if (missedClass == -1) {
//       return null;
//     }
//     final returnedTime = pupil.pupilMissedClasses![missedClass!].backHomeAt;
//     return returnedTime;
//   }

//- Date functions

  static Future<void> setThisDate(
      BuildContext context, DateTime thisDate) async {
    final DateTime? newDate = await selectSchooldayDate(context, thisDate);
    if (newDate != null) {
      locator<SchooldayManager>().setThisDate(newDate);
    }
  }

  static String thisDateAsString(BuildContext context, DateTime thisDate) {
    return '${DateFormat('EEEE', Localizations.localeOf(context).toString()).format(thisDate)}, ${thisDate.formatForUser()}';
  }
}
