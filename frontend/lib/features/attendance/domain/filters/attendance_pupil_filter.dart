import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:schuldaten_hub/common/domain/filters/filters_state_manager.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/utils/extensions.dart';
import 'package:schuldaten_hub/features/attendance/domain/attendance_manager.dart';
import 'package:schuldaten_hub/features/attendance/domain/models/missed_class.dart';
import 'package:schuldaten_hub/features/pupil/domain/filters/pupils_filter.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_proxy.dart';
import 'package:schuldaten_hub/features/schooldays/domain/schoolday_manager.dart';

enum AttendancePupilFilter {
  late,
  missed,
  home,
  unexcused,
  contacted,
  goneHome,
  present,
  notPresent,
}

final Map<AttendancePupilFilter, bool> initialAttendancePupilFilterValues = {
  AttendancePupilFilter.late: false,
  AttendancePupilFilter.missed: false,
  AttendancePupilFilter.home: false,
  AttendancePupilFilter.unexcused: false,
  AttendancePupilFilter.contacted: false,
  AttendancePupilFilter.goneHome: false,
  AttendancePupilFilter.present: false,
  AttendancePupilFilter.notPresent: false,
};

typedef AttendancePupilFilterRecord = ({
  AttendancePupilFilter attendancePupilFilter,
  bool value
});

class AttendancePupilFilterManager {
  final _attendancePupilFilterState =
      ValueNotifier<Map<AttendancePupilFilter, bool>>(
          initialAttendancePupilFilterValues);

  ValueListenable<Map<AttendancePupilFilter, bool>>
      get attendancePupilFilterState => _attendancePupilFilterState;

  AttendancePupilFilterManager();

  void setAttendancePupilFilter(
      {required List<AttendancePupilFilterRecord>
          attendancePupilFilterRecords}) {
    for (final record in attendancePupilFilterRecords) {
      _attendancePupilFilterState.value = {
        ..._attendancePupilFilterState.value,
        record.attendancePupilFilter: record.value,
      };
    }

    final bool attendanceFilterStateEqualsInitialState = const MapEquality()
        .equals(_attendancePupilFilterState.value,
            initialAttendancePupilFilterValues);

    locator<FiltersStateManager>().setFilterState(
        filterState: FilterState.attendance,
        value: !attendanceFilterStateEqualsInitialState);
    locator<PupilsFilter>().refreshs();
  }

  void resetFilters() {
    _attendancePupilFilterState.value = {...initialAttendancePupilFilterValues};
    locator<FiltersStateManager>()
        .setFilterState(filterState: FilterState.attendance, value: false);
  }

  bool isMatchedByAttendanceFilters(PupilProxy pupil) {
    final thisDate = locator<SchooldayManager>().thisDate.value;

    final Map<AttendancePupilFilter, bool> attendanceActiveFilters =
        _attendancePupilFilterState.value;

    final MissedClass? attendanceEventThisDate = pupil.missedClasses!
        .firstWhereOrNull(
            (missedClass) => missedClass.missedDay.isSameDate(thisDate));

    bool isMatched = true;
    //- Filter pupils present

    if ((attendanceActiveFilters[AttendancePupilFilter.present]! &&
        !(attendanceEventThisDate == null ||
            attendanceEventThisDate.missedType == 'late'))) {
      isMatched = false;
    }

    //- Filter pupils not present

    if (attendanceActiveFilters[AttendancePupilFilter.notPresent]! &&
        !(attendanceEventThisDate != null &&
            attendanceEventThisDate.missedType != 'late')) {
      isMatched = false;
    }

    //- Filter pupils not present AND unexcused

    if (attendanceActiveFilters[AttendancePupilFilter.unexcused]! &&
        !(attendanceEventThisDate != null &&
            attendanceEventThisDate.unexcused == true &&
            attendanceEventThisDate.missedType == MissedType.isMissed.value)) {
      isMatched = false;
    }

    if (isMatched) {
      return true;
    }
    // locator<FiltersStateManager>()
    //     .setFilterState(filterState: FilterState.attendance, value: true);
    return false;
  }
}
