import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:schuldaten_hub/common/domain/filters/filters_state_manager.dart';
import 'package:schuldaten_hub/common/domain/models/enums.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/features/learning_support/domain/learning_support_manager.dart';
import 'package:schuldaten_hub/features/pupil/domain/filters/pupil_filter_enums.dart';
import 'package:schuldaten_hub/features/pupil/domain/filters/pupil_filter_manager.dart';
import 'package:schuldaten_hub/features/pupil/domain/filters/pupils_filter.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_proxy.dart';
import 'package:schuldaten_hub/features/pupil/domain/pupil_helper_functions.dart';

typedef SupportLevelFilterRecord = ({SupportLevel filter, bool value});
typedef SupportAreaFilterRecord = ({SupportArea filter, bool value});

class LearningSupportFilterManager {
  final _supportLevelFilterState =
      ValueNotifier<Map<SupportLevel, bool>>(initialSupportLevelFilterValues);
  ValueListenable<Map<SupportLevel, bool>> get supportLevelFilterState =>
      _supportLevelFilterState;

  final _supportAreaFiltersState =
      ValueNotifier<Map<SupportArea, bool>>(initialSupportAreaFilterValues);
  ValueListenable<Map<SupportArea, bool>> get supportAreaFilterState =>
      _supportAreaFiltersState;
  bool get supportLevelFiltersActive =>
      _supportLevelFilterState.value.containsValue(true);

  bool get supportAreaFiltersActive =>
      _supportAreaFiltersState.value.containsValue(true);
  LearningSupportFilterManager();

  void setSupportLevelFilter(
      {required List<SupportLevelFilterRecord> supportLevelFilterRecords}) {
    for (final record in supportLevelFilterRecords) {
      _supportLevelFilterState.value = {
        ..._supportLevelFilterState.value,
        record.filter: record.value,
      };
    }
    final bool supportLevelFilterStateEqualsInitialState = const MapEquality()
        .equals(supportLevelFilterState.value, initialSupportLevelFilterValues);

    if (supportLevelFilterStateEqualsInitialState) {
      locator<FiltersStateManager>()
          .setFilterState(filterState: FilterState.pupilLegacy, value: false);
    } else {
      locator<FiltersStateManager>()
          .setFilterState(filterState: FilterState.pupilLegacy, value: true);
    }
    locator<PupilsFilter>().refreshs();
  }

  // We pass a list of [SupportAreaFilterRecord] to this function
  // because we want to be able to set multiple filters at once
  // in the case of filters that are mutually exclusive
  void setSupportAreaFilter(
      {required List<SupportAreaFilterRecord> supportAreaFilterRecords}) {
    for (final record in supportAreaFilterRecords) {
      _supportAreaFiltersState.value = {
        ..._supportAreaFiltersState.value,
        record.filter: record.value,
      };
    }
    final bool pupilFilterStateEqualsInitialState = const MapEquality().equals(
        locator<PupilFilterManager>().pupilFilterState.value,
        initialPupilFilterValues);

    if (pupilFilterStateEqualsInitialState) {
      locator<FiltersStateManager>()
          .setFilterState(filterState: FilterState.pupilLegacy, value: false);
    } else {
      locator<FiltersStateManager>()
          .setFilterState(filterState: FilterState.pupilLegacy, value: true);
    }

    locator<PupilsFilter>().refreshs();
  }

  void resetFilters() {
    _supportLevelFilterState.value = {...initialSupportLevelFilterValues};
    _supportAreaFiltersState.value = {...initialSupportAreaFilterValues};
  }

  bool supportLevelFilters(PupilProxy pupil) {
    final activeFilters = _supportLevelFilterState.value;

    bool isMatched = true;
    bool complementaryFilter = false;

    //- these are complementary filters
    //- they should persist if one of them is active

    // Filter support level 1

    if (activeFilters[SupportLevel.supportLevel1]! && pupil.supportLevel != 1) {
      isMatched = false;
    } else if (activeFilters[SupportLevel.supportLevel1]! &&
        pupil.supportLevel == 1) {
      complementaryFilter = true;
    }

    // Filter support level 2

    if (!complementaryFilter &&
        activeFilters[SupportLevel.supportLevel2]! &&
        pupil.supportLevel != 2) {
      isMatched = false;
    } else if (!complementaryFilter &&
        activeFilters[SupportLevel.supportLevel2]! &&
        pupil.supportLevel == 2) {
      isMatched = true;
      complementaryFilter = true;
    }

    // Filter support level 3

    if (!complementaryFilter &&
        activeFilters[SupportLevel.supportLevel3]! &&
        pupil.supportLevel != 3) {
      isMatched = false;
    } else if (!complementaryFilter &&
        activeFilters[SupportLevel.supportLevel3]! &&
        pupil.supportLevel == 3) {
      isMatched = true;
      complementaryFilter = true;
    }
    // Filter support level 4
    if (!complementaryFilter &&
        activeFilters[SupportLevel.supportLevel4]! &&
        pupil.supportLevel != 4) {
      isMatched = false;
    } else if (!complementaryFilter &&
        activeFilters[SupportLevel.supportLevel4]! &&
        pupil.supportLevel == 4) {
      isMatched = true;
      complementaryFilter = true;
    }

    //- Theses filters exclude pupil that not match
    //- regardless of the other filters

    if (isMatched == true) {
      if (activeFilters[SupportLevel.specialNeeds]! &&
          pupil.specialNeeds == null) {
        isMatched = false;
      } else if (activeFilters[SupportLevel.specialNeeds]! &&
          pupil.specialNeeds != null) {
        isMatched = true;
      }

      if (activeFilters[SupportLevel.migrationSupport]! &&
          hasLanguageSupport(pupil.migrationSupportEnds) != true) {
        isMatched = false;
      } else if (activeFilters[SupportLevel.migrationSupport]! &&
          hasLanguageSupport(pupil.migrationSupportEnds) == true) {
        isMatched = true;
        complementaryFilter = true;
      }
    }
    return isMatched;
  }

  bool supportAreaFilters(PupilProxy pupil) {
    final Map<SupportArea, bool> activeFilters = _supportAreaFiltersState.value;

    // motorics filter

    if (pupil.supportCategoryStatuses != null) {
      if (activeFilters[SupportArea.motorics]! &&
          pupil.supportCategoryStatuses!.any((element) =>
              locator<LearningSupportManager>()
                  .getRootSupportCategory(element.supportCategoryId)
                  .categoryId ==
              SupportArea.motorics.value)) {
        return true;
      }

      // emotions filter

      if (activeFilters[SupportArea.emotions]! &&
          pupil.supportCategoryStatuses!.any((element) =>
              locator<LearningSupportManager>()
                  .getRootSupportCategory(element.supportCategoryId)
                  .categoryId ==
              SupportArea.emotions.value)) {
        return true;
      }

      // math filter

      if (activeFilters[SupportArea.math] == true &&
          pupil.supportCategoryStatuses!.any((element) =>
              locator<LearningSupportManager>()
                  .getRootSupportCategory(element.supportCategoryId)
                  .categoryId ==
              SupportArea.math.value)) {
        return true;
      }

      // learning filter

      if (activeFilters[SupportArea.learning] == true &&
          pupil.supportCategoryStatuses!.any((element) =>
              locator<LearningSupportManager>()
                  .getRootSupportCategory(element.supportCategoryId)
                  .categoryId ==
              SupportArea.learning.value)) {
        return true;
      }

      // German language filter

      if (activeFilters[SupportArea.german] == true &&
          pupil.supportCategoryStatuses!.any((element) =>
              locator<LearningSupportManager>()
                  .getRootSupportCategory(element.supportCategoryId)
                  .categoryId ==
              SupportArea.german.value)) {
        return true;
      }

      // Language filter

      if (activeFilters[SupportArea.language] == true &&
          pupil.supportCategoryStatuses!.any((element) =>
              locator<LearningSupportManager>()
                  .getRootSupportCategory(element.supportCategoryId)
                  .categoryId ==
              SupportArea.language.value)) {
        return true;
      }
    }
    return false;
  }
}
