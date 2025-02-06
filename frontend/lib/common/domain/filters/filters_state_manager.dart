import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/features/attendance/domain/filters/attendance_pupil_filter.dart';
import 'package:schuldaten_hub/features/authorizations/domain/filters/authorization_filter_manager.dart';
import 'package:schuldaten_hub/features/authorizations/domain/filters/pupil_authorization_filter_manager.dart';
import 'package:schuldaten_hub/features/learning_support/domain/filters/learning_support_filter_manager.dart';
import 'package:schuldaten_hub/features/pupil/domain/filters/pupil_filter_manager.dart';
import 'package:schuldaten_hub/features/pupil/domain/filters/pupils_filter.dart';
import 'package:schuldaten_hub/features/school_lists/domain/filters/school_list_filter_manager.dart';
import 'package:schuldaten_hub/features/schoolday_events/domain/filters/schoolday_event_filter_manager.dart';

enum FilterState {
  pupil,
  pupilLegacy,
  attendance,
  schooldayEvent,
  schoolList,
  authorization,
  matrixUser,
  matrixRoom,
}

const Map<FilterState, bool> _initialFilterGlobalValues = {
  FilterState.pupil: false,
  FilterState.pupilLegacy: false,
  FilterState.attendance: false,
  FilterState.schooldayEvent: false,
  FilterState.schoolList: false,
  FilterState.authorization: false,
  FilterState.matrixUser: false,
  FilterState.matrixRoom: false,
};

abstract class FiltersStateManager {
  bool getFilterState(FilterState filterState);

  ValueListenable<bool> get filtersActive;

  ValueListenable<Map<FilterState, bool>> get filterStates;

  void setFilterState({required FilterState filterState, required bool value});

  void markFiltersActive(bool filtersOn);

  void resetFilters();
}

class FiltersStateManagerImplementation implements FiltersStateManager {
  final _filterStates =
      ValueNotifier<Map<FilterState, bool>>(_initialFilterGlobalValues);

  @override
  ValueListenable<Map<FilterState, bool>> get filterStates => _filterStates;

  final _filtersActive = ValueNotifier<bool>(false);

  @override
  ValueListenable<bool> get filtersActive => _filtersActive;

  @override
  bool getFilterState(FilterState filterState) {
    return _filterStates.value[filterState]!;
  }

  @override
  void setFilterState({required FilterState filterState, required bool value}) {
    final newFilterState = Map<FilterState, bool>.from(_filterStates.value);
    newFilterState[filterState] = value;
    _filterStates.value = newFilterState;

    final filterStatesAreEqualInitialValues = const MapEquality()
        .equals(_filterStates.value, _initialFilterGlobalValues);
    if (filterStatesAreEqualInitialValues) {
      _filtersActive.value = false;
    } else {
      _filtersActive.value = true;
    }
  }

  @override
  void markFiltersActive(bool filtersOn) {
    _filtersActive.value = filtersOn;
  }

  @override
  void resetFilters() {
    locator<AttendancePupilFilterManager>().resetFilters();
    locator<PupilsFilter>().resetFilters();
    locator<PupilFilterManager>().resetFilters();
    locator<SchooldayEventFilterManager>().resetFilters();
    locator<SchoolListFilterManager>().resetFilters();
    locator<AuthorizationFilterManager>().resetFilters();
    locator<PupilAuthorizationFilterManager>().resetFilters();
    locator<LearningSupportFilterManager>().resetFilters();

    _filterStates.value = {..._initialFilterGlobalValues};
    _filtersActive.value = false;
  }
}
