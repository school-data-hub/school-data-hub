import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:schuldaten_hub/common/domain/env_manager.dart';
import 'package:schuldaten_hub/common/domain/models/enums.dart';
import 'package:schuldaten_hub/common/domain/session_manager.dart';
import 'package:schuldaten_hub/common/services/api/api_client.dart';
import 'package:schuldaten_hub/common/services/api/api_settings.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_service.dart';
import 'package:schuldaten_hub/features/school_lists/domain/models/school_list.dart';

class SchoolListApiService {
  final ApiClient _client = locator<ApiClient>();
  final _notificationService = locator<NotificationService>();
  String _baseUrl() {
    return locator<EnvManager>().env!.serverUrl;
  }
  //- get school lists

  static const _getSchoolListsUrl = '/school_lists/all';

  Future<List<SchoolList>> fetchSchoolLists() async {
    _notificationService.apiRunning(true);

    final response = await _client.get(
      '${_baseUrl()}$_getSchoolListsUrl',
      options: _client.hubOptions,
    );

    if (response.statusCode != 200) {
      _notificationService.showSnackBar(
          NotificationType.error, 'Fehler beim Laden der Schullisten');

      _notificationService.apiRunning(false);

      throw ApiException('Failed to fetch school lists', response.statusCode);
    }

    final List<SchoolList> schoolLists =
        (response.data as List).map((e) => SchoolList.fromJson(e)).toList();

    _notificationService.apiRunning(false);

    return schoolLists;
  }

  //- post school list

  static const _postSchoolListWithGroupUrl = '/school_lists/new';

  Future<SchoolList> postSchoolListWithGroup(
      {required String name,
      required String description,
      required List<int> pupilIds,
      required String visibility}) async {
    _notificationService.apiRunning(true);

    final String data = jsonEncode({
      "list_name": name,
      "list_description": description,
      "pupils": pupilIds,
      "visibility": visibility
    });

    final response = await _client.post(
      '${_baseUrl()}$_postSchoolListWithGroupUrl',
      data: data,
      options: _client.hubOptions,
    );

    _notificationService.apiRunning(false);

    if (response.statusCode != 200) {
      _notificationService.showSnackBar(
          NotificationType.error, 'Fehler beim Erstellen der Schulliste');

      throw ApiException('Failed to create school list', response.statusCode);
    }

    final newList = SchoolList.fromJson(response.data);

    return newList;
  }

  static const postSchoolList = '/school_lists/all';

  //- patch school list

  String _patchSchoolListUrl(String listId) {
    return '/school_lists/$listId/patch';
  }

  Future<SchoolList> updateSchoolListProperty(
      {required SchoolList schoolListToUpdate,
      String? name,
      String? description,
      String? visibility}) async {
    assert(name != null || description != null || visibility != null);
    _notificationService.apiRunning(true);
    Map<String, String> jsonMap = {};

    if (name != null) {
      jsonMap["list_name"] = name;
    }
    if (description != null) {
      jsonMap["list_description"] = description;
    }
    if (visibility != null) {
      jsonMap["visibility"] = '${schoolListToUpdate.visibility}*$visibility';
    }

    final String data = jsonEncode(jsonMap);

    final Response response = await _client.patch(
      '${_baseUrl()}${_patchSchoolListUrl(schoolListToUpdate.listId)}',
      data: data,
      options: _client.hubOptions,
    );

    _notificationService.apiRunning(false);

    if (response.statusCode != 200) {
      _notificationService.showSnackBar(
          NotificationType.error, 'Fehler beim Aktualisieren der Schulliste');
      throw ApiException('Failed to update school list', response.statusCode);
    }
    return SchoolList.fromJson(response.data);
  }

  //- delete school list

  String _deleteSchoolListUrl(String listId) {
    return '/school_lists/$listId';
  }

  Future<List<SchoolList>> deleteSchoolList(String listId) async {
    _notificationService.apiRunning(true);

    final Response response = await _client.delete(
      '${_baseUrl()}${_deleteSchoolListUrl(listId)}',
      options: _client.hubOptions,
    );
    _notificationService.apiRunning(false);

    if (response.statusCode != 200) {
      _notificationService.showSnackBar(
          NotificationType.error, 'Fehler beim Löschen der Schulliste');

      throw ApiException('Failed to delete school list', response.statusCode);
    }
    final List<SchoolList> schoolLists =
        (response.data as List).map((e) => SchoolList.fromJson(e)).toList();

    return schoolLists;
  }

  //- PUPIL LISTS -//

  //- POST

  String _addPupilsToSchoolList(String listId) {
    return '/school_lists/$listId/pupils';
  }

  Future<SchoolList> addPupilsToSchoolList(
      {required String listId, required List<int> pupilIds}) async {
    final data = jsonEncode({"pupils": pupilIds});

    _notificationService.apiRunning(true);

    final response = await _client.post(
      '${_baseUrl()}${_addPupilsToSchoolList(listId)}',
      data: data,
      options: _client.hubOptions,
    );

    _notificationService.apiRunning(false);

    if (response.statusCode != 200) {
      _notificationService.showSnackBar(
          NotificationType.error, 'Fehler beim Hinzufügen zur Schulliste');

      throw ApiException('Failed to delete school list', response.statusCode);
    }
    final SchoolList updatedSchoolList = SchoolList.fromJson(response.data);

    return updatedSchoolList;
  }

  //- update pupil list property

  String _patchPupilSchoolList(int pupilId, String listId) {
    return '/pupil_lists/$pupilId/$listId';
  }

  Future<SchoolList> patchSchoolListPupil({
    required int pupilId,
    required String listId,
    bool? value,
    String? comment,
  }) async {
    String data;

    if (value != null) {
      data = jsonEncode({
        "pupil_list_status": value,
        "pupil_list_entry_by":
            locator<SessionManager>().credentials.value.username
      });
    } else {
      data = jsonEncode({
        "pupil_list_comment": comment,
        "pupil_list_entry_by":
            locator<SessionManager>().credentials.value.username
      });
    }
    _notificationService.apiRunning(true);
    final response = await _client.patch(
      '${_baseUrl()}${_patchPupilSchoolList(pupilId, listId)}',
      data: data,
      options: _client.hubOptions,
    );

    _notificationService.apiRunning(false);

    if (response.statusCode != 200) {
      _notificationService.showSnackBar(
          NotificationType.error, 'Fehler beim Aktualisieren der Schulliste');

      throw ApiException('Failed to patch school list', response.statusCode);
    }

    final SchoolList updatedSchoolList = SchoolList.fromJson(response.data);

    return updatedSchoolList;
  }

  //-DELETE
  String _deletePupilsFromSchoolList(String listId) {
    return '/pupil_lists/$listId/delete_pupils';
  }

  Future<SchoolList> deletePupilsFromSchoolList({
    required List<int> pupilIds,
    required String listId,
  }) async {
    final data = jsonEncode({"pupils": pupilIds});

    _notificationService.apiRunning(true);

    final response = await _client.post(
      '${_baseUrl()}${_deletePupilsFromSchoolList(listId)}',
      data: data,
      options: _client.hubOptions,
    );

    _notificationService.apiRunning(false);

    if (response.statusCode != 200) {
      _notificationService.showSnackBar(
          NotificationType.error, 'Fehler beim Löschen von der Schulliste');

      throw ApiException(
          'Failed to delete pupils from school list', response.statusCode);
    }

    final SchoolList updatedSchoolList = SchoolList.fromJson(response.data);

    return updatedSchoolList;
  }

  //- this endpoint is not used in the app
  static const getSchoolListWithPupils = '/school_lists/all';
}
