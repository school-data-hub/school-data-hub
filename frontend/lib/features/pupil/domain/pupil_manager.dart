import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:schuldaten_hub/common/domain/models/enums.dart';
import 'package:schuldaten_hub/common/domain/session_manager.dart';
import 'package:schuldaten_hub/common/services/api/api_settings.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_service.dart';
import 'package:schuldaten_hub/common/utils/custom_encrypter.dart';
import 'package:schuldaten_hub/common/utils/logger.dart';
import 'package:schuldaten_hub/features/attendance/domain/models/missed_class.dart';
import 'package:schuldaten_hub/features/books/data/pupil_book_api_service.dart';
import 'package:schuldaten_hub/features/pupil/domain/filters/pupils_filter.dart';
import 'package:schuldaten_hub/features/pupil/domain/filters/pupils_filter_impl.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_data.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_proxy.dart';
import 'package:schuldaten_hub/features/pupil/domain/pupil_identity_manager.dart';
import 'package:schuldaten_hub/features/schooldays/domain/schoolday_manager.dart';

class PupilManager extends ChangeNotifier {
  final _pupils = <int, PupilProxy>{};

  List<PupilProxy> get allPupils => _pupils.values.toList();

  PupilManager();

  //- HELPER METHODS

  void clearData() {
    _pupils.clear();
    return;
  }

  PupilProxy? getPupilById(int id) {
    if (!_pupils.containsKey(id)) {
      logger.f('Pupil $id not found', stackTrace: StackTrace.current);
      return null;
    }
    return _pupils[id];
  }

  List<PupilProxy> pupilsFromPupilIds(List<int> pupilIds) {
    List<PupilProxy> pupilsfromPupilIds = [];

    for (int pupilId in pupilIds) {
      pupilsfromPupilIds.add(_pupils[pupilId]!);
    }

    return pupilsfromPupilIds;
  }

  List<int> pupilIdsFromPupils(List<PupilProxy> pupils) {
    return pupils.map((pupil) => pupil.internalId).toList();
  }

  List<PupilProxy> pupilsNotListed(List<int> pupilIds) {
    Map<int, PupilProxy> allPupils = Map<int, PupilProxy>.of(_pupils);
    allPupils.removeWhere((key, value) => pupilIds.contains(key));
    return allPupils.values.toList();
  }

  List<PupilProxy> siblings(PupilProxy pupil) {
    if (pupil.family == null) {
      return [];
    }

    Map<int, PupilProxy> allPupils = Map<int, PupilProxy>.of(_pupils);

    allPupils.removeWhere((key, value) => value.family != pupil.family);

    allPupils.remove(pupil.internalId);
    final pupilSiblings = allPupils.values.toList();
    return pupilSiblings;
  }

  List<PupilProxy> pupilsWithBirthdaySinceDate(DateTime date) {
    Map<int, PupilProxy> allPupils = Map<int, PupilProxy>.of(_pupils);
    final DateTime now = DateTime.now();
    allPupils.removeWhere((key, pupil) {
      final birthdayThisYear =
          DateTime(now.year, pupil.birthday.month, pupil.birthday.day);
      // Ensure the birthday this year is not before the specified date and not after today.
      return !(birthdayThisYear.isAtSameMomentAs(date) ||
          (birthdayThisYear.isAfter(date) && birthdayThisYear.isBefore(now)));
    });
    final pupilsWithBirthdaySinceDate = allPupils.values.toList();
    pupilsWithBirthdaySinceDate.sort((b, a) {
      final birthdayA =
          DateTime(DateTime.now().year, a.birthday.month, a.birthday.day);
      final birthdayB =
          DateTime(DateTime.now().year, b.birthday.month, b.birthday.day);
      return birthdayA.compareTo(birthdayB);
    });
    return pupilsWithBirthdaySinceDate;
  }

  final pupilDataApiService = PupilDataApiService();
  final notificationService = locator<NotificationService>();

  //- Fetch all available pupils from the backend

  Future<void> fetchAllPupils() async {
    final pupilsToFetch = locator.get<PupilIdentityManager>().availablePupilIds;
    if (pupilsToFetch.isEmpty) {
      return;
    }
    await fetchPupilsByInternalId(pupilsToFetch);
  }

  Future<void> cleanPupilsAvatarIds() async {
    final pupilsToFetch = locator.get<PupilIdentityManager>().availablePupilIds;
    if (pupilsToFetch.isEmpty) {
      return;
    }
    for (int pupilId in pupilsToFetch) {
      final PupilProxy? pupil = getPupilById(pupilId);

      if (pupil != null) {
        if (pupil.avatarId != null) {
          final cleanedAvatarId = pupil.avatarId!
              .replaceFirst('./media_upload/avtr/', '')
              .replaceFirst('.jpg', '');
          final PupilData pupilData =
              await pupilDataApiService.updatePupilProperty(
                  id: pupilId, property: 'avatar_id', value: cleanedAvatarId);
          pupil.updatePupil(pupilData);
          _pupils[pupilId]!.updatePupil(pupilData);
        }
      }
    }
  }

  Future<void> init() async {
    await fetchAllPupils();
  }

  Future<void> updatePupilList(List<PupilProxy> pupils) async {
    await fetchPupilsByInternalId(pupils.map((e) => e.internalId).toList());
  }

  //- Fetch pupils with the given ids from the backend

  Future<void> fetchPupilsByInternalId(List<int> internalPupilIds) async {
    notificationService.showSnackBar(
        NotificationType.info, 'Lade Schülerdaten vom Server. Bitte warten...');

    // fetch the pupils from the backend
    final fetchedPupils = await pupilDataApiService.fetchListOfPupils(
        internalPupilIds: internalPupilIds);

    // check if we did not get a pupil response for some ids
    // if so, we will delete the personal data for those ids later
    final List<int> outdatedPupilIdentitiesIds = internalPupilIds
        .where((element) =>
            !fetchedPupils.any((pupil) => pupil.internalId == element))
        .toList();

    // now we match the pupils from the response with their personal data
    final pupilIdentityManager = locator.get<PupilIdentityManager>();
    for (PupilData fetchedPupil in fetchedPupils) {
      final proxyInRepository = _pupils[fetchedPupil.internalId];
      if (proxyInRepository != null) {
        proxyInRepository.updatePupil(fetchedPupil);
      } else {
        // if the pupil is not in the repository, that would be weird
        // since we did not send the id to the backend

        final pupilIdentity =
            pupilIdentityManager.getPupilIdentity(fetchedPupil.internalId);

        _pupils[fetchedPupil.internalId] =
            PupilProxy(pupilData: fetchedPupil, pupilIdentity: pupilIdentity);
      }
    }

    // remove the outdated pupil identities that
    // did not get a response from the backend
    // because this means they are outdated
    // and we do not need them anymore

    if (outdatedPupilIdentitiesIds.isNotEmpty) {
      final deletedPupilIdentities = await pupilIdentityManager
          .deletePupilIdentities(outdatedPupilIdentitiesIds);
      notificationService.showInformationDialog(
          'Diese Schüler_innen existieren nicht mehr in der Datenbank, Ihre Ids wurden aus dem Gerät gelöscht:\n\n$deletedPupilIdentities');
    }
    notificationService.showSnackBar(
        NotificationType.success, 'Schülerdaten geladen!');

    notifyListeners();
  }

  void updatePupilProxyWithPupilData(PupilData pupilData) {
    final proxy = _pupils[pupilData.internalId];
    if (proxy != null) {
      proxy.updatePupil(pupilData);
      //- TODO: Is this true: No need to call notifyListeners here, because the proxy will notify the listeners itself
      notifyListeners();
    }
  }

  void updatePupilProxiesWithPupilData(List<PupilData> pupils) {
    for (PupilData pupil in pupils) {
      updatePupilProxyWithPupilData(pupil);
    }
  }

  void updatePupilsFromMissedClassesOnASchoolday(
      List<MissedClass> allMissedClasses) {
    // Track the IDs of pupils who had missed classes before the update
    // We need this to find out whose missed classes have been deleted
    final Set<int> pupilsWithMissedClassesBeforeUpdate = _pupils.values
        .where((pupil) =>
            pupil.missedClasses!.isNotEmpty &&
            pupil.missedClasses!.any((missedClass) =>
                missedClass.missedDay ==
                locator<SchooldayManager>().thisDate.value))
        .map((pupil) => pupil.internalId)
        .toSet();

    if (allMissedClasses.isEmpty) {
      for (int pupilId in pupilsWithMissedClassesBeforeUpdate) {
        final pupil = _pupils[pupilId];
        if (pupil != null) {
          pupil.updateFromMissedClassesOnASchoolday([]);
        }
      }
      notifyListeners();
      return;
    }

    for (MissedClass missedClass in allMissedClasses) {
      final missedPupil = _pupils[missedClass.missedPupilId];

      if (missedPupil == null) {
        logger.f('Pupil ${missedClass.missedPupilId} not found',
            stackTrace: StackTrace.current);

        continue;
      }

      missedPupil.updateFromMissedClassesOnASchoolday(allMissedClasses);
    }
    // Identify pupils whose missed classes are no longer present
    final Set<int> pupilsWithMissedClassesAfterUpdate = allMissedClasses
        .map((missedClass) => missedClass.missedPupilId)
        .toSet();

    final Set<int> pupilsWithDeletedMissedClasses =
        pupilsWithMissedClassesBeforeUpdate
            .difference(pupilsWithMissedClassesAfterUpdate);

    for (int pupilId in pupilsWithDeletedMissedClasses) {
      final pupil = _pupils[pupilId];
      if (pupil != null) {
        pupil.updateFromMissedClassesOnASchoolday(allMissedClasses);
      }
    }
    notifyListeners();
  }

  Future<void> postAvatarImage(
    File imageFile,
    PupilProxy pupilProxy,
  ) async {
    // first we encrypt the file

    final encryptedFile = await customEncrypter.encryptFile(imageFile);

    // Now we prepare the form data for the request.

    String fileName = encryptedFile.path.split('/').last;
    var formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        encryptedFile.path,
        filename: fileName,
      ),
    });

    // send the Api request

    final PupilData pupilUpdate =
        await pupilDataApiService.updatePupilWithAvatar(
      id: pupilProxy.internalId,
      formData: formData,
    );

    // update the pupil in the repository
    updatePupilProxyWithPupilData(pupilUpdate);
    //  pupilProxy.updatePupil(pupilUpdate);

    // Delete the outdated encrypted file.

    final cacheManager = locator<DefaultCacheManager>();
    final cacheKey = pupilProxy.avatarId;

    cacheManager.removeFile(cacheKey.toString());
  }

  Future<void> postAvatarAuthImage(
    File imageFile,
    PupilProxy pupilProxy,
  ) async {
    // first we encrypt the file

    final encryptedFile = await customEncrypter.encryptFile(imageFile);

    // Now we prepare the form data for the request.

    String fileName = encryptedFile.path.split('/').last;
    var formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        encryptedFile.path,
        filename: fileName,
      ),
    });

    // send the Api request

    final PupilData pupilUpdate =
        await pupilDataApiService.updatePupilWithAvatarAuth(
      id: pupilProxy.internalId,
      formData: formData,
    );

    // update the pupil in the repository
    updatePupilProxyWithPupilData(pupilUpdate);
    //  pupilProxy.updatePupil(pupilUpdate);

    // Delete the outdated encrypted file.

    final cacheManager = locator<DefaultCacheManager>();
    final cacheKey = pupilProxy.avatarId;

    cacheManager.removeFile(cacheKey.toString());
  }

  Future<void> postPublicMediaAuthImage(
    File imageFile,
    PupilProxy pupilProxy,
  ) async {
    // first we encrypt the file

    final encryptedFile = await customEncrypter.encryptFile(imageFile);

    // Now we prepare the form data for the request.

    String fileName = encryptedFile.path.split('/').last;
    var formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        encryptedFile.path,
        filename: fileName,
      ),
    });

    // send the Api request

    final PupilData pupilUpdate =
        await pupilDataApiService.updatePupilWithPublicMediaAuth(
      id: pupilProxy.internalId,
      formData: formData,
    );

    // update the pupil in the repository
    updatePupilProxyWithPupilData(pupilUpdate);
    //  pupilProxy.updatePupil(pupilUpdate);

    // Delete the outdated encrypted file.

    final cacheManager = locator<DefaultCacheManager>();
    final cacheKey = pupilProxy.avatarId;

    cacheManager.removeFile(cacheKey.toString());
  }

  Future<void> deleteAvatarImage(int pupilId, String cacheKey) async {
    // send the Api request
    await pupilDataApiService.deletePupilAvatar(
      internalId: pupilId,
    );

    // Delete the outdated encrypted file in the cache.

    final cacheManager = locator<DefaultCacheManager>();
    await cacheManager.removeFile(cacheKey);

    // and update the repository
    _pupils[pupilId]!.clearAvatar();
  }

  Future<void> deleteAvatarAuthImage(int pupilId, String cacheKey) async {
    // send the Api request
    await pupilDataApiService.deletePupilAvatarAuth(
      internalId: pupilId,
    );

    // Delete the outdated encrypted file in the cache.

    final cacheManager = locator<DefaultCacheManager>();
    await cacheManager.removeFile(cacheKey);

    // and update the repository
    _pupils[pupilId]!.deleteAvatarAuthId();
  }

  Future<void> deletePublicMediaAuthImage(int pupilId, String cacheKey) async {
    // send the Api request
    await pupilDataApiService.deletePupilPublicMediaAuthImage(
      internalId: pupilId,
    );

    // Delete the outdated encrypted file in the cache.

    final cacheManager = locator<DefaultCacheManager>();
    await cacheManager.removeFile(cacheKey);

    // and update the repository
    _pupils[pupilId]!.deletePublicMediaAuthId();
  }

  Future<void> patchOnePupilProperty(
      {required int pupilId,
      required String jsonKey,
      required dynamic value}) async {
    // if the value is relevant to siblings, check for siblings first and handle them if true

    if (jsonKey == 'communication_tutor1' ||
        jsonKey == 'communication_tutor2' ||
        jsonKey == 'parents_contact' ||
        jsonKey == 'emergency_care') {
      final PupilProxy pupil = getPupilById(pupilId)!;
      if (pupil.family != null) {
        // we have a sibling
        // create list with ids of all pupils with the same family value

        final List<int> pupilIdsWithSameFamily = _pupils.values
            .where((p) => p.family == pupil.family)
            .map((p) => p.internalId)
            .toList();

        // call the endpoint to update the siblings

        final List<PupilData> siblingsUpdate =
            await pupilDataApiService.updateSiblingsProperty(
                siblingsPupilIds: pupilIdsWithSameFamily,
                property: jsonKey,
                value: value);

        // now update the siblings with the new data

        for (PupilData sibling in siblingsUpdate) {
          _pupils[sibling.internalId]!.updatePupil(sibling);
        }

        notificationService.showSnackBar(
            NotificationType.success, 'Geschwister erfolgreich gepatcht!');
      }
    }

    // The pupil is no sibling. Make the api call for the single pupil

    final PupilData pupilUpdate = await pupilDataApiService.updatePupilProperty(
        id: pupilId, property: jsonKey, value: value);

    // now update the pupil in the repository

    _pupils[pupilId]!.updatePupil(pupilUpdate);
    notifyListeners();
  }

  Future<void> patchPupilWithNewSupportLevel(
      {required int pupilId,
      required int level,
      required DateTime createdAt,
      required String createdBy,
      required String comment}) async {
    final PupilData updatedPupil = await pupilDataApiService.updateSupportLevel(
      internalId: pupilId,
      newSupportLevel: level,
      createdAt: createdAt,
      createdBy: createdBy,
      comment: comment,
    );

    _pupils[pupilId]!.updatePupil(updatedPupil);
  }

  Future<void> deleteSupportLevelHistoryItem(
      {required int pupilId, required String supportLevelId}) async {
    final PupilData updatedPupil =
        await pupilDataApiService.deleteSupportLevelHistoryItem(
      internalId: pupilId,
      supportLevelId: supportLevelId,
    );

    _pupils[pupilId]!.updatePupil(updatedPupil);
  }

  PupilsFilter getPupilFilter() {
    //return PupilsFilterImplementation(this, sortMode: sortMode);
    return PupilsFilterImplementation(this);
  }

  Future<void> borrowBook(
      {required int pupilId, required String bookId}) async {
    final pupilBookApiService = PupilBookApiService();
    final PupilData updatedPupil = await pupilBookApiService
        .postNewPupilWorkbook(pupilId: pupilId, bookId: bookId);

    _pupils[pupilId]!.updatePupil(updatedPupil);

    return;
  }

  Future<void> deletePupilBook({required String lendingId}) async {
    final pupilBookRepository = PupilBookApiService();
    final pupil = await pupilBookRepository.deletePupilBook(lendingId);

    _pupils[pupil.internalId]!.updatePupil(pupil);

    return;
  }

  Future<void> returnBook({required String lendingId}) async {
    final returnedAt = DateTime.now();
    final receivedBy = locator<SessionManager>().credentials.value.username;
    final pupil = await PupilBookApiService().patchPupilBook(
        returnedAt: returnedAt, receivedBy: receivedBy, lendingId: lendingId);

    _pupils[pupil.internalId]!.updatePupil(pupil);

    return;
  }

  Future<void> patchPupilBook(
      {required String lendingId,
      DateTime? lentAt,
      String? lentBy,
      String? comment,
      int? rating,
      DateTime? returnedAt,
      String? receivedBy}) async {
    final pupil = await PupilBookApiService().patchPupilBook(
        lendingId: lendingId,
        lentAt: lentAt,
        lentBy: lentBy,
        state: comment,
        rating: rating,
        returnedAt: returnedAt,
        receivedBy: receivedBy);

    _pupils[pupil.internalId]!.updatePupil(pupil);

    return;
  }
}
