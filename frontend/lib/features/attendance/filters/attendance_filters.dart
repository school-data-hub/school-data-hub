import 'package:collection/collection.dart';
import 'package:schuldaten_hub/common/constants/enums.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/utils/extensions.dart';
import 'package:schuldaten_hub/features/attendance/models/missed_class.dart';
import 'package:schuldaten_hub/features/pupil/filters/pupil_filter_manager.dart';
import 'package:schuldaten_hub/features/pupil/filters/pupils_filter.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';
import 'package:schuldaten_hub/features/schooldays/services/schoolday_manager.dart';

List<PupilProxy> attendanceFilters(List<PupilProxy> pupils) {
  final thisDate = locator<SchooldayManager>().thisDate.value;
  final activeFilters = locator<PupilFilterManager>().pupilFilterState.value;
  List<PupilProxy> filteredPupils = [];

  for (final PupilProxy pupil in pupils) {
    //find out if the pupil has a missed class on this day
    // if so, define it for the coming filters
    final MissedClass? missedClass = pupil.missedClasses!.firstWhereOrNull(
        (missedClass) => missedClass.missedDay.isSameDate(thisDate));
    // if missed class is null, hop to the next pupil
    if (missedClass == null) {
      continue;
    }
    // Filter pupils present
    if (activeFilters[PupilFilter.present]! &&
        (missedClass.missedType == 'late')) {
      locator<PupilsFilter>().setFiltersOnValue(true);
      continue;
    }

    // Filter pupils not present
    if (activeFilters[PupilFilter.notPresent]! &&
        (missedClass.missedType != 'missed' &&
            missedClass.missedType != 'home' &&
            missedClass.backHome != true)) {
      locator<PupilsFilter>().setFiltersOnValue(true);
      continue;
    }

    // Filter unexcused pupils
    if (activeFilters[PupilFilter.unexcused]! &&
        missedClass.missedType == 'missed' &&
        missedClass.excused != true) {
      locator<PupilsFilter>().setFiltersOnValue(true);
      continue;
    }

    // Filter OGS pupils
    if (activeFilters[PupilFilter.ogs]! && pupil.ogs != true) {
      locator<PupilsFilter>().setFiltersOnValue(true);
      continue;
    }

    if (activeFilters[PupilFilter.notOgs]! && pupil.ogs != false) {
      locator<PupilsFilter>().setFiltersOnValue(true);
      continue;
    }
    filteredPupils.add(pupil);
  }
  return filteredPupils;
}
