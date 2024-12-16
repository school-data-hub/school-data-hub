import 'dart:convert';

import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/utils/secure_storage.dart';
import 'package:schuldaten_hub/features/pupil/domain/filters/pupils_filter.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_identity.dart';
import 'package:schuldaten_hub/features/pupil/domain/pupil_identity_manager.dart';
import 'package:schuldaten_hub/features/pupil/domain/pupil_manager.dart';

class PupilIdentityHelper {
  //- LOCAL STORAGE HELPERS
  static Future<Map<int, PupilIdentity>> readPupilIdentitiesFromStorage(
      {required String envKey}) async {
    final pupilsJson = await secureStorageRead(
        '${SecureStorageKey.pupilIdentities.value}_$envKey');
    if (pupilsJson == null) return {};

    final Map<String, dynamic> decoded = jsonDecode(pupilsJson);
    return decoded.map((key, value) =>
        MapEntry(int.parse(key), PupilIdentity.fromJson(value)));
  }

  static Future<void> deletePupilIdentitiesForEnv(String envKey) async {
    await secureStorageDelete(
        '${SecureStorageKey.pupilIdentities.value}_$envKey');
    locator<PupilIdentityManager>().clearPupilIdentities();

    locator<PupilsFilter>().clearFilteredPupils();

    locator<PupilManager>().clearData();
  }

  //- OBJECT HELPERS
  static PupilIdentity pupilIdentityFromString(
      List<String> pupilIdentityStringItems) {
    //-TODO implement enum for the schoolyear
    final schoolyear = pupilIdentityStringItems[4] == '03'
        ? 'S3'
        : pupilIdentityStringItems[4] == '04'
            ? 'S4'
            : pupilIdentityStringItems[4];
    final newPupilIdentity = PupilIdentity(
      id: int.parse(pupilIdentityStringItems[0]),
      firstName: pupilIdentityStringItems[1],
      lastName: pupilIdentityStringItems[2],
      group: pupilIdentityStringItems[3],
      schoolGrade: schoolyear,
      specialNeeds: pupilIdentityStringItems[5] == ''
          ? null
          : '${pupilIdentityStringItems[5]}${pupilIdentityStringItems[6]}',
      gender: pupilIdentityStringItems[7],
      language: pupilIdentityStringItems[8],
      family: pupilIdentityStringItems[9] == ''
          ? null
          : pupilIdentityStringItems[9],
      birthday: DateTime.tryParse(pupilIdentityStringItems[10])!,
      migrationSupportEnds: pupilIdentityStringItems[11] == ''
          ? null
          : DateTime.tryParse(pupilIdentityStringItems[11])!,
      pupilSince: DateTime.tryParse(pupilIdentityStringItems[12])!,
    );
    return newPupilIdentity;
  }
}
