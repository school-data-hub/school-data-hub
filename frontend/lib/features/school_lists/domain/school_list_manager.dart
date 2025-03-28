import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:schuldaten_hub/common/domain/models/enums.dart';
import 'package:schuldaten_hub/common/services/api/api_settings.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_service.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_proxy.dart';
import 'package:schuldaten_hub/features/pupil/domain/pupil_manager.dart';
import 'package:schuldaten_hub/features/school_lists/domain/filters/school_list_filter_manager.dart';
import 'package:schuldaten_hub/features/school_lists/domain/models/pupil_list.dart';
import 'package:schuldaten_hub/features/school_lists/domain/models/school_list.dart';

class SchoolListManager {
  ValueListenable<List<SchoolList>> get schoolLists => _schoolLists;

  ValueListenable<List<PupilList>> get pupilSchoolLists => _pupilSchoolLists;

  final _pupilSchoolLists = ValueNotifier<List<PupilList>>([]);

  final _schoolLists = ValueNotifier<List<SchoolList>>([]);

  // Let's define maps to make lookups faster
  // for schoolLists with the key being the listId
  final Map<String, SchoolList> _schoolListMap = {};
  // for pupilLists with the key being the pupilId
  final _pupilListMap = ValueNotifier<Map<int, List<PupilList>>>({});

  ValueListenable<Map<int, List<PupilList>>> get pupilListMap => _pupilListMap;

  SchoolListManager();

  void clearData() {
    _schoolLists.value = [];
    _pupilSchoolLists.value = [];
    _pupilListMap.value = {};
    _schoolListMap.clear();
  }

  Future<SchoolListManager> init() async {
    await fetchSchoolLists();
    return this;
  }

  final notificationService = locator<NotificationService>();
  final SchoolListApiService apiSchoolListService = SchoolListApiService();
  final SchoolListFilterManager schoolListFilterManager =
      locator<SchoolListFilterManager>();
  //- Helper functions

  SchoolList getSchoolListById(String listId) {
    return _schoolListMap[listId]!;
  }

  // SchoolList getSchoolList(String listId) {
  //   final SchoolList schoolList =
  //       _schoolLists.value.where((element) => element.listId == listId).first;
  //   return schoolList;
  // }

  //- Helper functions

  List<PupilList> getPupilListsFromPupilByPupilId(int pupilId) {
    return _pupilListMap.value[pupilId]!;
  }

  PupilList? getPupilSchoolListEntry(
      {required int pupilId, required String listId}) {
    return _pupilListMap.value[pupilId]!
        .where((element) => element.originList == listId)
        .first;
  }

  List<PupilProxy> getPupilsinSchoolList(String listId) {
    final List<PupilProxy> pupils = locator<PupilManager>().allPupils;
    List<PupilProxy> listedPupils = [];
    for (PupilList pupilList in _schoolListMap[listId]!.pupilLists) {
      final PupilProxy? pupil = pupils.firstWhereOrNull(
          (element) => element.internalId == pupilList.listedPupilId);
      if (pupil != null) {
        listedPupils.add(pupil);
      }
    }

    return listedPupils;
  }

  List<PupilProxy> pupilsInSchoolList(String listId, List<PupilProxy> pupils) {
    List<PupilProxy> pupilsInList = getPupilsinSchoolList(listId);
    return pupils
        .where((pupil) => pupilsInList
            .any((element) => element.internalId == pupil.internalId))
        .toList();
  }

  //- Repository functions

  void _updatePupilListsFromSchoolList(SchoolList schoolList) {
    final List<PupilList> pupilLists = schoolList.pupilLists;
    for (final pupilList in pupilLists) {
      if (!_pupilListMap.value.containsKey(pupilList.listedPupilId)) {
        _pupilListMap.value[pupilList.listedPupilId] = [];
      }
      List<PupilList> pupilListEntries =
          List.from(_pupilListMap.value[pupilList.listedPupilId]!);
      // find the pupil list entry and update it
      final index = pupilListEntries
          .indexWhere((element) => element.originList == pupilList.originList);
      if (index != -1) {
        pupilListEntries[index] = pupilList;
      } else {
        pupilListEntries.add(pupilList);
      }

      _pupilListMap.value[pupilList.listedPupilId] = pupilListEntries;
    }
    _pupilSchoolLists.value =
        _pupilListMap.value.values.expand((list) => list).toList();

    return;
  }

  Future<void> fetchSchoolLists() async {
    final List<SchoolList> responseSchoolLists =
        await apiSchoolListService.fetchSchoolLists();

    notificationService.showSnackBar(NotificationType.success,
        '${responseSchoolLists.length} Schullisten geladen!');

    for (final schoolList in responseSchoolLists) {
      _schoolListMap[schoolList.listId] = schoolList;
      // go through the pupil lists and add them to the map
      // with the key being the pupilId
      _updatePupilListsFromSchoolList(schoolList);
    }
    _updateRepositories();

    return;
  }

  Future updateSchoolListProperty(String listId, String? name,
      String? description, String? visibility) async {
    final schoolListToUpdate = getSchoolListById(listId);
    final SchoolList updatedSchoolList =
        await apiSchoolListService.updateSchoolListProperty(
            schoolListToUpdate: schoolListToUpdate,
            name: name,
            description: description,
            visibility: visibility);

    _schoolListMap[updatedSchoolList.listId] = updatedSchoolList;
    _updateRepositories();
    _updatePupilListsFromSchoolList(updatedSchoolList);

    notificationService.showSnackBar(
        NotificationType.success, 'Schulliste erfolgreich aktualisiert');

    return;
  }

  Future<void> deleteSchoolList(String listId) async {
    final List<SchoolList> updatedSchoolLists =
        await apiSchoolListService.deleteSchoolList(listId);

    // first delete the pupil lists from the map
    for (final pupilList in _schoolListMap[listId]!.pupilLists) {
      _pupilListMap.value[pupilList.listedPupilId]!.remove(pupilList);
      _pupilSchoolLists.value =
          _pupilListMap.value.values.expand((list) => list).toList();
    }
    _schoolListMap.clear();
    for (final schoolList in updatedSchoolLists) {
      _schoolListMap[schoolList.listId] = schoolList;
      _schoolLists.value = _schoolListMap.values.toList();
      // go through the pupil lists and add them to the map
      // with the key being the pupilId
      _updatePupilListsFromSchoolList(schoolList);
    }

    _updateRepositories();

    notificationService.showSnackBar(
        NotificationType.success, 'Schulliste erfolgreich gelöscht');

    return;
  }

  Future<void> postSchoolListWithGroup(
      {required String name,
      required String description,
      required List<int> pupilIds,
      required String visibility}) async {
    final SchoolList newList =
        await apiSchoolListService.postSchoolListWithGroup(
            name: name,
            description: description,
            pupilIds: pupilIds,
            visibility: visibility);

    _schoolListMap[newList.listId] = newList;
    _updateRepositories();

    notificationService.showSnackBar(
        NotificationType.success, 'Schulliste erfolgreich erstellt');

    return;
  }

  Future<void> addPupilsToSchoolList(String listId, List<int> pupilIds) async {
    final SchoolList updatedSchoolList = await apiSchoolListService
        .addPupilsToSchoolList(listId: listId, pupilIds: pupilIds);

    _schoolListMap[updatedSchoolList.listId] = updatedSchoolList;
    _updateRepositories();
    _updatePupilListsFromSchoolList(updatedSchoolList);

    notificationService.showSnackBar(
        NotificationType.success, 'Schüler erfolgreich hinzugefügt');

    return;
  }

  Future<void> deletePupilsFromSchoolList(
    List<int> pupilIds,
    String listId,
  ) async {
    // The response are the updated pupils whose pupil list was deleted

    final SchoolList updatedSchoolList =
        await apiSchoolListService.deletePupilsFromSchoolList(
      pupilIds: pupilIds,
      listId: listId,
    );
    _schoolListMap[updatedSchoolList.listId] = updatedSchoolList;
    _updateRepositories();
    _updatePupilListsFromSchoolList(updatedSchoolList);

    notificationService.showSnackBar(
        NotificationType.success, 'Schülereinträge erfolgreich gelöscht');

    return;
  }

  Future<void> patchPupilList(
      int pupilId, String listId, bool? value, String? comment) async {
    final SchoolList updatedSchoolList =
        await apiSchoolListService.patchSchoolListPupil(
            pupilId: pupilId, listId: listId, value: value, comment: comment);
    _schoolListMap[updatedSchoolList.listId] = updatedSchoolList;
    _updateRepositories();
    _updatePupilListsFromSchoolList(updatedSchoolList);

    notificationService.showSnackBar(
        NotificationType.success, 'Eintrag erfolgreich aktualisiert');

    return;
  }

  void _updateRepositories() {
    _schoolLists.value = _schoolListMap.values.toList();
    schoolListFilterManager.updateFilteredSchoolLists(_schoolLists.value);
  }
}
