import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:schuldaten_hub/common/domain/env_manager.dart';
import 'package:schuldaten_hub/common/domain/models/enums.dart';
import 'package:schuldaten_hub/common/services/api/api_client.dart';
import 'package:schuldaten_hub/common/services/api/api_settings.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_service.dart';
import 'package:schuldaten_hub/common/utils/extensions.dart';
import 'package:schuldaten_hub/features/schooldays/domain/models/schoolday.dart';

class SchooldayApiService {
  final ApiClient _client = locator<ApiClient>();

  final _notificationService = locator<NotificationService>();

  String _baseUrl() {
    return locator<EnvManager>().env!.serverUrl;
  }
  //- get schooldays

  static const getSchooldaysWithChildren = '/schooldays/all';

  static const _getSchooldays = '/schooldays/all/flat';
  Future<List<Schoolday>> getSchooldaysFromServer() async {
    _notificationService.apiRunning(true);

    final Response response = await _client.get(
      '${_baseUrl()}$_getSchooldays',
      options: _client.hubOptions,
    );
    _notificationService.apiRunning(false);

    if (response.statusCode != 200) {
      _notificationService.showSnackBar(
          NotificationType.error, 'Die Schultage konnten nicht geladen werden');

      _notificationService.apiRunning(false);

      throw ApiException('Failed to fetch schooldays', response.statusCode);
    }

    final List<Schoolday> schooldays = List<Schoolday>.from(
        (response.data as List).map((e) => Schoolday.fromJson(e)));

    return schooldays;
  }

  String getOneSchoolday(DateTime date) {
    return '/schooldays/${date.formatForJson()}';
  }

  //- POST
  static const _postSchoolday = '/schooldays/new';
  static const _postMultipleSchooldays = '/schooldays/new/list';

  Future<Schoolday> postSchoolday(DateTime date) async {
    _notificationService.apiRunning(true);

    final data = jsonEncode({'schoolday': date.formatForJson()});

    final Response response = await _client.post(
      '${_baseUrl()}$_postSchoolday',
      data: data,
      options: _client.hubOptions,
    );

    if (response.statusCode != 200) {
      _notificationService.showSnackBar(
          NotificationType.error, 'Fehler beim Erstellen des Schultages');

      _notificationService.apiRunning(false);

      throw ApiException('Failed to post schoolday', response.statusCode);
    }

    _notificationService.apiRunning(false);

    return Schoolday.fromJson(response.data);
  }

  Future<List<Schoolday>> postMultipleSchooldays(
      {required List<DateTime> dates}) async {
    _notificationService.apiRunning(true);
    final schooldays = dates.map((e) => e.formatForJson()).toList();
    final data = jsonEncode({'schooldays': schooldays});

    final Response response = await _client.post(
      '${_baseUrl()}$_postMultipleSchooldays',
      data: data,
      options: _client.hubOptions,
    );
    _notificationService.apiRunning(false);
    if (response.statusCode != 200) {
      _notificationService.showSnackBar(
          NotificationType.error, 'Fehler beim Erstellen der Schultage');

      throw ApiException(
          'Failed to post multiple schooldays', response.statusCode);
    }

    return List<Schoolday>.from(
        (response.data as List).map((e) => Schoolday.fromJson(e)));
  }

  //- DELETE
  String _deleteSchoolday(DateTime date) {
    return '/schooldays/${date.formatForJson()}';
  }

  Future<bool> deleteSchoolday(Schoolday schoolday) async {
    _notificationService.apiRunning(true);

    final Response response = await _client.delete(
      '${_baseUrl()}${_deleteSchoolday(schoolday.schoolday)}',
      options: _client.hubOptions,
    );

    if (response.statusCode != 200) {
      _notificationService.showSnackBar(
          NotificationType.error, 'Fehler beim Löschen des Schultages');

      _notificationService.apiRunning(false);

      throw ApiException('Failed to delete schoolday', response.statusCode);
    }

    _notificationService.apiRunning(false);

    return true;
  }

  static const deleteSchooldays = '/schooldays/delete/list';

  //- School semester

  static const _getSchoolSemester = '/school_semesters/all';

  Future<List<SchoolSemester>> getSchoolSemesters() async {
    _notificationService.apiRunning(true);

    final Response response = await _client.get(
      '${_baseUrl()}$_getSchoolSemester',
      options: _client.hubOptions,
    );

    if (response.statusCode != 200) {
      _notificationService.showSnackBar(NotificationType.error,
          'Die Schulsemester konnten nicht geladen werden');

      _notificationService.apiRunning(false);

      throw ApiException(
          'Failed to fetch school semesters', response.statusCode);
    }

    final List<SchoolSemester> schoolSemesters = List<SchoolSemester>.from(
        (response.data as List).map((e) => SchoolSemester.fromJson(e)));

    _notificationService.apiRunning(false);

    return schoolSemesters;
  }

  static const _postSchoolSemester = '/school_semesters/new';

  Future<SchoolSemester> postSchoolSemester(
      {required DateTime startDate,
      required DateTime endDate,
      required bool isFirst}) async {
    _notificationService.apiRunning(true);

    final data = jsonEncode({
      'start_date': startDate.formatForJson(),
      'end_date': endDate.formatForJson(),
      'is_first': isFirst
    });

    final Response response = await _client.post(
      '${_baseUrl()}$_postSchoolSemester',
      data: data,
      options: _client.hubOptions,
    );

    if (response.statusCode != 200) {
      _notificationService.showSnackBar(
          NotificationType.error, 'Fehler beim Erstellen des Schulsemesters');

      _notificationService.apiRunning(false);

      throw ApiException('Failed to post school semester', response.statusCode);
    }

    _notificationService.apiRunning(false);

    return SchoolSemester.fromJson(response.data);
  }
}
