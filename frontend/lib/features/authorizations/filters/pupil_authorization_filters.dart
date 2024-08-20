import 'package:schuldaten_hub/common/constants/enums.dart';

import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/features/authorizations/models/pupil_authorization.dart';
import 'package:schuldaten_hub/features/pupil/filters/pupil_filter_manager.dart';

// class AuthorizationFilter extends Filter<PupilProxy> {
//   AuthorizationFilter({
//     required super.name,
//   });

//   Authorization? _authorization;
//   Authorization? get authorization => _authorization;

//   void setAuthorization(Authorization authorization) {
//     _authorization = authorization;
//     toggle(true);
//     notifyListeners();
//   }

//   @override
//   void reset() {
//     _authorization = null;
//     super.reset();
//   }

//   @override
//   bool matches(PupilProxy item) {
//     return addAuthorizationFiltersToPupil(item, authorization!);
//   }
// }

final activeFilters = locator<PupilFilterManager>();

// bool addAuthorizationFiltersToPupil(
//   PupilProxy pupil,
//   Authorization authorization,
// ) {
//   // Check first if the filtered pupil is in the authorization. If not, continue with next one.

//   final PupilAuthorization? pupilAuthorization = pupil.authorizations!
//       .firstWhereOrNull((pupilAuthorization) =>
//           pupilAuthorization.originAuthorization ==
//           authorization.authorizationId);

//   if (pupilAuthorization == null) {
//     return false;
//   }
//   // This one is - let's apply the authorization filters

//   if (activeFilters.filterState.value[PupilFilter.authorizationYesResponse]! &&
//       pupilAuthorization.status == false) {
//     return false;
//   }
//   if (activeFilters.filterState.value[PupilFilter.authorizationNoResponse]! &&
//       pupilAuthorization.status == true) {
//     return false;
//   }
//   if (activeFilters.filterState.value[PupilFilter.authorizationNullResponse]! &&
//       pupilAuthorization.status != null) {
//     return false;
//   }
//   if (activeFilters
//           .filterState.value[PupilFilter.authorizationCommentResponse]! &&
//       pupilAuthorization.comment == null) {
//     return false;
//   }

//   return true;
// }

// List<PupilProxy> addAuthorizationFiltersToFilteredPupils(
//   List<PupilProxy> pupils,
//   Authorization authorization,
// ) {
//   List<PupilProxy> filteredPupils = [];

//   for (PupilProxy pupil in pupils) {
//     // Check first if the filtered pupil is in the authorization. If not, continue with next one.

//     final PupilAuthorization? pupilAuthorization = pupil.authorizations!
//         .firstWhereOrNull((pupilAuthorization) =>
//             pupilAuthorization.originAuthorization ==
//             authorization.authorizationId);

//     if (pupilAuthorization == null) {
//       continue;
//     }
//     // This one is - let's apply the authorization filters

//     if (activeFilters
//             .filterState.value[PupilFilter.authorizationYesResponse]! &&
//         pupilAuthorization.status == false) {
//       continue;
//     }
//     if (activeFilters.filterState.value[PupilFilter.authorizationNoResponse]! &&
//         pupilAuthorization.status == true) {
//       continue;
//     }
//     if (activeFilters
//             .filterState.value[PupilFilter.authorizationNullResponse]! &&
//         pupilAuthorization.status != null) {
//       continue;
//     }
//     if (activeFilters
//             .filterState.value[PupilFilter.authorizationCommentResponse]! &&
//         pupilAuthorization.comment == null) {
//       continue;
//     }

//     filteredPupils.add(pupil);
//   }
//   return filteredPupils;
// }

List<PupilAuthorization> addAuthorizationFiltersToPupilAuthorizations(
  List<PupilAuthorization> pupilAuthorizations,
) {
  List<PupilAuthorization> filteredPupilAuthorizations = [];
  bool filterIsOn = false;
  for (PupilAuthorization pupilAuthorization in pupilAuthorizations) {
    if (activeFilters
            .filterState.value[PupilFilter.authorizationYesResponse]! &&
        pupilAuthorization.status != true) {
      filterIsOn = true;
      continue;
    }
    if (activeFilters.filterState.value[PupilFilter.authorizationNoResponse]! &&
        pupilAuthorization.status != false) {
      filterIsOn = true;
      continue;
    }
    if (activeFilters
            .filterState.value[PupilFilter.authorizationNullResponse]! &&
        pupilAuthorization.status != null) {
      filterIsOn = true;
      continue;
    }
    if (activeFilters
            .filterState.value[PupilFilter.authorizationCommentResponse]! &&
        pupilAuthorization.comment == null) {
      filterIsOn = true;
      continue;
    }
    if (activeFilters
            .filterState.value[PupilFilter.authorizationFileResponse]! &&
        pupilAuthorization.fileId == null) {
      filterIsOn = true;
      continue;
    }

    filteredPupilAuthorizations.add(pupilAuthorization);
  }
  if (filterIsOn) {
    locator<PupilFilterManager>().filtersOnSwitch(true);
  }

  return filteredPupilAuthorizations;
}
