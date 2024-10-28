import 'package:schuldaten_hub/common/constants/enums.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/features/learning_support/services/learning_support_manager.dart';
import 'package:schuldaten_hub/features/pupil/filters/pupils_filter.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';
import 'package:schuldaten_hub/features/pupil/filters/pupil_filter_manager.dart';

List<PupilProxy> learningSupportFilteredPupils(
    List<PupilProxy> filteredPupils) {
  final Map<SupportAreaFilter, bool> activeFilters =
      locator<PupilFilterManager>().supportAreaFilterState.value;

  if (filteredPupils.isNotEmpty) {
    List<PupilProxy> categoryFilteredPupils = [];
    for (PupilProxy pupil in filteredPupils) {
      if (pupil.supportGoals != null) {
        if ((activeFilters[SupportAreaFilter.motorics] == true &&
                pupil.supportGoals!.any((element) =>
                    locator<LearningSupportManager>()
                        .getRootSupportCategory(element.supportCategoryId)
                        .categoryId ==
                    1)) ||
            (activeFilters[SupportAreaFilter.motorics] == false)) {
        } else {
          locator<PupilsFilter>().setFiltersOnValue(true);
          continue;
        }

        if (activeFilters[SupportAreaFilter.emotions] == true &&
            pupil.supportGoals!.any((element) =>
                locator<LearningSupportManager>()
                    .getRootSupportCategory(element.supportCategoryId)
                    .categoryId ==
                2)) {
        } else if (activeFilters[SupportAreaFilter.emotions] == false) {
        } else {
          locator<PupilsFilter>().setFiltersOnValue(true);
          continue;
        }
        if (activeFilters[SupportAreaFilter.math] == true &&
            pupil.supportGoals!.any((element) =>
                locator<LearningSupportManager>()
                    .getRootSupportCategory(element.supportCategoryId)
                    .categoryId ==
                3)) {
        } else if (activeFilters[SupportAreaFilter.math] == false) {
        } else {
          locator<PupilsFilter>().setFiltersOnValue(true);
          continue;
        }
        if (activeFilters[SupportAreaFilter.learning] == true &&
            pupil.supportGoals!.any((element) =>
                locator<LearningSupportManager>()
                    .getRootSupportCategory(element.supportCategoryId)
                    .categoryId ==
                4)) {
        } else if (activeFilters[SupportAreaFilter.learning] == false) {
        } else {
          locator<PupilsFilter>().setFiltersOnValue(true);
          continue;
        }
        if (activeFilters[SupportAreaFilter.german] == true &&
            pupil.supportGoals!.any((element) =>
                locator<LearningSupportManager>()
                    .getRootSupportCategory(element.supportCategoryId)
                    .categoryId ==
                5)) {
        } else if (activeFilters[SupportAreaFilter.german] == false) {
        } else {
          locator<PupilsFilter>().setFiltersOnValue(true);
          continue;
        }
        if (activeFilters[SupportAreaFilter.language] == true &&
            pupil.supportGoals!
                .any((element) => element.supportCategoryId == 6)) {
        } else if (activeFilters[SupportAreaFilter.language] == false) {
        } else {
          locator<PupilsFilter>().setFiltersOnValue(true);
          continue;
        }

        categoryFilteredPupils.add(pupil);
      }
    }
    return categoryFilteredPupils;
  }
  return [];
}
