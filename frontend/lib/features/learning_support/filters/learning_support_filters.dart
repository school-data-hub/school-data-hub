import 'package:schuldaten_hub/common/constants/enums.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/features/pupil/filters/pupils_filter.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';
import 'package:schuldaten_hub/features/pupil/filters/pupil_filter_manager.dart';
import 'package:schuldaten_hub/features/pupil/services/pupil_helper_functions.dart';

List<PupilProxy> learningSupportFilters(List<PupilProxy> pupils) {
  final activeFilters =
      locator<PupilFilterManager>().supportLevelFilterState.value;

  List<PupilProxy> filteredPupils = [];
  for (PupilProxy pupil in pupils) {
    if (!activeFilters[SupportLevel.supportLevel1]! &&
        pupil.individualDevelopmentPlan != 1) {
      locator<PupilsFilter>().setFiltersOnValue(true);
      continue;
    }
    // Filter support level 2
    if (activeFilters[SupportLevel.supportLevel2]! &&
        pupil.individualDevelopmentPlan != 2) {
      locator<PupilsFilter>().setFiltersOnValue(true);
      continue;
    }
    // Filter support level 3
    if (activeFilters[SupportLevel.supportLevel3]! &&
        pupil.individualDevelopmentPlan != 3) {
      locator<PupilsFilter>().setFiltersOnValue(true);
      continue;
    }
    // Filter support level 4
    if (activeFilters[SupportLevel.supportLevel4]! &&
        pupil.individualDevelopmentPlan != 4) {
      locator<PupilsFilter>().setFiltersOnValue(true);
      continue;
    }
    // Filter special needs
    if (activeFilters[SupportLevel.specialNeeds]! &&
        pupil.specialNeeds == null) {
      locator<PupilsFilter>().setFiltersOnValue(true);
      continue;
    }
    // Filter pupils with a development goal

    //- Learning filters -//

    // Filter migrationSupport
    if (activeFilters[SupportLevel.migrationSupport]! &&
        hasLanguageSupport(pupil.migrationSupportEnds) != true) {
      locator<PupilsFilter>().setFiltersOnValue(true);
      continue;
    }
    filteredPupils.add(pupil);
  }
  return filteredPupils;
}
