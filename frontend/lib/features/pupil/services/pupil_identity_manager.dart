import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:collection/collection.dart';

import 'package:flutter/material.dart';
import 'package:schuldaten_hub/common/services/api/api.dart';
import 'package:schuldaten_hub/common/constants/enums.dart';
import 'package:schuldaten_hub/common/services/env_manager.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_manager.dart';
import 'package:schuldaten_hub/common/utils/custom_encrypter.dart';
import 'package:schuldaten_hub/common/utils/logger.dart';
import 'package:schuldaten_hub/common/utils/extensions.dart';
import 'package:schuldaten_hub/common/utils/scanner.dart';
import 'package:schuldaten_hub/common/utils/secure_storage.dart';
import 'package:schuldaten_hub/features/main_menu_pages/widgets/landing_bottom_nav_bar.dart';
import 'package:schuldaten_hub/features/pupil/filters/pupils_filter.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';
import 'package:schuldaten_hub/features/pupil/services/pupil_identity_helper_functions.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_data.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_identity.dart';
import 'package:schuldaten_hub/features/pupil/services/pupil_manager.dart';

class PupilIdentityManager {
  Map<int, PupilIdentity> _pupilIdentities = {};
  List<int> get availablePupilIds => _pupilIdentities.keys.toList();
  Set<String> get availableGroups =>
      _pupilIdentities.values.map((e) => e.group).toSet();

  PupilIdentity getPupilIdentity(int pupilId) {
    if (_pupilIdentities.containsKey(pupilId) == false) {
      throw StateError('Pupil with id $pupilId not found in pupil identities!');
    }
    return _pupilIdentities[pupilId]!;
  }

  Future<PupilIdentityManager> init() async {
    await getPupilIdentitiesForEnv();
    return this;
  }

  Future<void> deleteAllPupilIdentities() async {
    await secureStorageDelete('pupilIdentities');
    _pupilIdentities.clear();
    locator<PupilsFilter>().clearFilteredPupils();
    locator<PupilManager>().clearData();
  }

  void clearPupilIdentities() {
    _pupilIdentities.clear();
    return;
  }

  Future<void> deletePupilIdentitiesForEnv(String envKey) async {
    await secureStorageDelete(
        '${SecureStorageKey.pupilIdentities.value}_$envKey');
    _pupilIdentities.clear();
    locator<PupilsFilter>().clearFilteredPupils();

    locator<PupilManager>().clearData();
  }

  Future<void> getPupilIdentitiesForEnv() async {
    final defaultEnv = locator<EnvManager>().defaultEnv.value;
    final Map<int, PupilIdentity> pupilIdentities =
        await readPupilIdentitiesFromStorage(envKey: defaultEnv);
    if (pupilIdentities.isEmpty) {
      logger.w(
          'No stored pupil identities found for ${SecureStorageKey.pupilIdentities.value}_$defaultEnv');
    } else {
      logger.i('Pupil identities loaded from secure storage');
    }
    _pupilIdentities = pupilIdentities;
    return;
  }

  Future<void> scanNewPupilIdentities(BuildContext context) async {
    final String? scanResult =
        await scanner(context, 'Personenbezogene Informationen scannen');
    if (scanResult != null) {
      decryptCodesAndAddIdentities([scanResult]);
    } else {
      locator<NotificationManager>()
          .showSnackBar(NotificationType.warning, 'Scan abgebrochen');
      return;
    }
  }

  Future<void> decryptCodesAndAddIdentities(List<String> codes) async {
    String decryptedString = '';
    for (String code in codes) {
      decryptedString += '${customEncrypter.decrypt(code)}\n';
    }

    addNewPupilIdentities(identitiesInStringLines: decryptedString);
  }

  Future<void> addNewPupilIdentities(
      {required String identitiesInStringLines}) async {
    late final String? decryptedIdentitiesAsString;

    // If the string is imported in windows, it comes from a .txt file and it's not encrypted
    decryptedIdentitiesAsString = identitiesInStringLines;

    // The pupils in the string are separated by a '\n' - let's split them apart
    List<String> splittedPupilIdentities =
        decryptedIdentitiesAsString.split('\n');
    // The properties are separated by commas, let's build the PupilIdentity objects with them

    for (String data in splittedPupilIdentities) {
      if (data != '') {
        final newPupilIdentity =
            PupilIdentityHelper.pupilIdentityFromString(data);
        if (!PupilProxy.groupFilters.any((GroupFilter filter) =>
                filter.name == newPupilIdentity.group) ==
            false) {
          //- add the new pupil to the pupilIdentities map
        }
        _pupilIdentities[newPupilIdentity.id] = newPupilIdentity;
      }
    }

    writePupilIdentitiesToStorage(
        envKey: locator<EnvManager>().defaultEnv.value);

    await locator<PupilManager>().fetchAllPupils();
    locator<BottomNavManager>().setBottomNavPage(0);
    locator<BottomNavManager>().pageViewController.value.jumpToPage(0);
  }

  Future<Map<int, PupilIdentity>> readPupilIdentitiesFromStorage(
      {required String envKey}) async {
    final pupilsJson = await secureStorageRead(
        '${SecureStorageKey.pupilIdentities.value}_$envKey');
    if (pupilsJson == null) return {};

    final Map<String, dynamic> decoded = jsonDecode(pupilsJson);
    return decoded.map((key, value) =>
        MapEntry(int.parse(key), PupilIdentity.fromJson(value)));
  }

  Future<void> writePupilIdentitiesToStorage({required String envKey}) async {
    final Map<String, Map<String, dynamic>> jsonMap = _pupilIdentities.map(
      (key, value) => MapEntry(key.toString(), value.toJson()),
    );

    final jsonPupilIdentities = json.encode(jsonMap);
    await secureStorageWrite(
        '${SecureStorageKey.pupilIdentities.value}_$envKey',
        jsonPupilIdentities);
    log('Pupil identities written to secure storage for ${SecureStorageKey.pupilIdentities.value}_$envKey');
  }

  Future<void> updateBackendPupilsFromSchoolPupilIdentitySource(
      String textFileContent) async {
    // The pupils in the string are separated by a line break - let's split them out
    List<String> splittedPupilIdentities = textFileContent.split('\n');
    // Wer prepare a string with the pupils that are going to be updated later in the server
    String pupilListTxtFileContentForBackendUpdate = '';
    // The properties are separated by commas, let's build the pupilbase objects with them
    List<PupilIdentity> importedPupilIdentityList = [];
    for (String data in splittedPupilIdentities) {
      if (data != '') {
        PupilIdentity pupilIdentity =
            PupilIdentityHelper.pupilIdentityFromString(data);

        List pupilIdentityValues = data.split(',');

        importedPupilIdentityList.add(pupilIdentity);

        final bool ogsStatus =
            pupilIdentityValues[13] == 'OFFGANZ' ? true : false;
        final idAndOgsStatus =
            '${int.parse(pupilIdentityValues[0])},$ogsStatus';
        pupilListTxtFileContentForBackendUpdate += '$idAndOgsStatus\n';
      }
    }
    // We have the latest dataset from the school database.
    // Now let's update the pupils in the server with a txt file
    // First we generate a txt file with updatedPupils
    // The server will automatically archive pupils that are not in the list,
    // update the ones that are in the list,
    // and create the ones that are not in the server.

    final textFile = File('temp.txt')
      ..writeAsStringSync(pupilListTxtFileContentForBackendUpdate);
    final List<PupilData> updatedRepository =
        await PupilDataApiService().updateBackendPupilsDatabase(file: textFile);
    for (PupilData pupil in updatedRepository) {
      locator<PupilManager>().updatePupilProxyWithPupilData(pupil);
    }
    // We don't need the temp file any more, let's delete it
    textFile.delete();

    for (PupilIdentity element in importedPupilIdentityList) {
      _pupilIdentities[element.id] = element;
    }

    await secureStorageWrite(
        '${SecureStorageKey.sessions.value}_${locator<EnvManager>().defaultEnv.value}',
        jsonEncode(_pupilIdentities.values.toList()));

    await locator<PupilManager>().fetchAllPupils();

    locator<NotificationManager>().showSnackBar(NotificationType.success,
        '${_pupilIdentities.length} Schülerdaten wurden aktualisiert!');

    locator<BottomNavManager>().setBottomNavPage(0);
    locator<BottomNavManager>().pageViewController.value.jumpToPage(0);
    return;
  }

  Future<String> generatePupilIdentitiesQrData(List<int> pupilIds) async {
    String qrString = '';
    for (int pupilId in pupilIds) {
      PupilIdentity pupilIdentity = _pupilIdentities.values
          .where((element) => element.id == pupilId)
          .single;
      final migrationSupportEnds = pupilIdentity.migrationSupportEnds != null
          ? pupilIdentity.migrationSupportEnds!.formatForJson()
          : '';
      final specialNeeds = pupilIdentity.specialNeeds ?? '';
      final family = pupilIdentity.family ?? '';
      final String pupilbaseString =
          '${pupilIdentity.id},${pupilIdentity.firstName},${pupilIdentity.lastName},${pupilIdentity.group},${pupilIdentity.schoolGrade},$specialNeeds,,${pupilIdentity.gender},${pupilIdentity.language},$family,${pupilIdentity.birthday.formatForJson()},$migrationSupportEnds,${pupilIdentity.pupilSince.formatForJson()},\n';
      qrString = qrString + pupilbaseString;
    }
    final encryptedString = customEncrypter.encrypt(qrString);
    return encryptedString;
  }

  Future<List<Map<String, Object>>> generateAllPupilIdentitiesQrData(
      {required int pupilsPerCode}) async {
    final List<PupilIdentity> pupilIdentity = _pupilIdentities.values.toList();
    // First we group the pupils by their group in a map
    Map<String, List<PupilIdentity>> groupedPupils =
        pupilIdentity.groupListsBy((element) => element.group);
    Map<String, int> groupLengths = {};
    final Map<String, String> finalGroupedList = {};

    // Now we iterate over the groupedPupils and generate maps with smaller lists
    // with no more than [pupilsPerCode] items and add to the group name the subgroup number
    for (String groupName in groupedPupils.keys) {
      final List<PupilIdentity> group = groupedPupils[groupName]!;
      groupLengths[groupName] = group.length;
      int numSubgroups = (group.length / pupilsPerCode).ceil();

      for (int i = 0; i < numSubgroups; i++) {
        List<PupilIdentity> smallerGroup = [];
        int start = i * pupilsPerCode;
        int end = (i + 1) * pupilsPerCode;
        if (end > group.length) {
          end = group.length;
        }
        smallerGroup.addAll(group.sublist(start, end));
        String qrString = '';
        for (PupilIdentity pupilIdentity in smallerGroup) {
          final migrationSupportEnds =
              pupilIdentity.migrationSupportEnds != null
                  ? pupilIdentity.migrationSupportEnds!.formatForJson()
                  : '';
          final specialNeeds = pupilIdentity.specialNeeds ?? '';
          final family = pupilIdentity.family ?? '';
          final String pupilIdentityString =
              '${pupilIdentity.id},${pupilIdentity.firstName},${pupilIdentity.lastName},${pupilIdentity.group},${pupilIdentity.schoolGrade},$specialNeeds,,${pupilIdentity.gender},${pupilIdentity.language},$family,${pupilIdentity.birthday.formatForJson()},$migrationSupportEnds,${pupilIdentity.pupilSince.formatForJson()},\n';
          qrString = qrString + pupilIdentityString;
        }
        final encryptedString = customEncrypter.encrypt(qrString);
        String subgroupName = "$groupName - ${i + 1}/$numSubgroups";
        finalGroupedList[subgroupName] = encryptedString;
      }
    }
    // Extracting entries from the map and sorting them based on keys
    List<MapEntry<String, String>> sortedEntries = finalGroupedList.entries
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    groupLengths = Map.fromEntries(
        groupLengths.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
    // Creating a new map with sorted entries
    Map<String, String> sortedQrGroupLists = Map.fromEntries(sortedEntries);
    return [groupLengths, sortedQrGroupLists];
  }

  Future<String> deletePupilIdentities(List<int> toBeDeletedPupilIds) async {
    List<String> toBeDeletedPupilIdentities = [];

    for (int id in toBeDeletedPupilIds) {
      toBeDeletedPupilIdentities.add(
          '${_pupilIdentities[id]!.firstName} ${_pupilIdentities[id]!.lastName}, ${_pupilIdentities[id]!.group}');

      _pupilIdentities.remove(id);
    }

    writePupilIdentitiesToStorage(
        envKey: locator<EnvManager>().defaultEnv.value);

    log(' ${toBeDeletedPupilIds.length} SuS sind nicht mehr in der Datenbank und wurden gelöscht!');

    return toBeDeletedPupilIdentities.join('\n');
  }
}
