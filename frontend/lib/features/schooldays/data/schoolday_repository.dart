import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:schuldaten_hub/common/domain/models/enums.dart';
import 'package:schuldaten_hub/common/services/api/api_settings.dart';
import 'package:schuldaten_hub/common/services/api/api_client.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_service.dart';
import 'package:schuldaten_hub/common/utils/extensions.dart';
import 'package:schuldaten_hub/features/schooldays/domain/models/schoolday.dart';

class SchooldayRepository {
  final ApiClient _client = locator<ApiClient>();

  final notificationService = locator<NotificationService>();

  //- get schooldays

  static const getSchooldaysWithChildren = '/schooldays/all';

  static const _getSchooldays = '/schooldays/all/flat';
  Future<List<Schoolday>> getSchooldaysFromServer() async {
    notificationService.apiRunning(true);

    final Response response = await _client.get(_getSchooldays);

    if (response.statusCode != 200) {
      notificationService.showSnackBar(
          NotificationType.error, 'Die Schultage konnten nicht geladen werden');

      notificationService.apiRunning(false);

      throw ApiException('Failed to fetch schooldays', response.statusCode);
    }

    final List<Schoolday> schooldays = List<Schoolday>.from(
        (response.data as List).map((e) => Schoolday.fromJson(e)));

    notificationService.apiRunning(false);

    return schooldays;
  }

  String getOneSchoolday(DateTime date) {
    return '/schooldays/${date.formatForJson()}';
  }

  //- POST
  static const _postSchoolday = '/schooldays/new';
  static const _postMultipleSchooldays = '/schooldays/new/list';

  Future<Schoolday> postSchoolday(DateTime date) async {
    notificationService.apiRunning(true);

    final data = jsonEncode({'schoolday': date.formatForJson()});

    final Response response = await _client.post(_postSchoolday, data: data);

    if (response.statusCode != 200) {
      notificationService.showSnackBar(
          NotificationType.error, 'Fehler beim Erstellen des Schultages');

      notificationService.apiRunning(false);

      throw ApiException('Failed to post schoolday', response.statusCode);
    }

    notificationService.apiRunning(false);

    return Schoolday.fromJson(response.data);
  }

  Future<List<Schoolday>> postMultipleSchooldays(
      {required List<DateTime> dates}) async {
    notificationService.apiRunning(true);
    final schooldays = dates.map((e) => e.formatForJson()).toList();
    final data = jsonEncode({'schooldays': schooldays});

    final Response response =
        await _client.post(_postMultipleSchooldays, data: data);
    notificationService.apiRunning(false);
    if (response.statusCode != 200) {
      notificationService.showSnackBar(
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
    notificationService.apiRunning(true);

    final Response response =
        await _client.delete(_deleteSchoolday(schoolday.schoolday));

    if (response.statusCode != 200) {
      notificationService.showSnackBar(
          NotificationType.error, 'Fehler beim Löschen des Schultages');

      notificationService.apiRunning(false);

      throw ApiException('Failed to delete schoolday', response.statusCode);
    }

    notificationService.apiRunning(false);

    return true;
  }

  static const deleteSchooldays = '/schooldays/delete/list';

  //- School semester

  static const _getSchoolSemester = '/school_semesters/all';

  Future<List<SchoolSemester>> getSchoolSemesters() async {
    notificationService.apiRunning(true);

    final Response response = await _client.get(_getSchoolSemester);

    if (response.statusCode != 200) {
      notificationService.showSnackBar(NotificationType.error,
          'Die Schulsemester konnten nicht geladen werden');

      notificationService.apiRunning(false);

      throw ApiException(
          'Failed to fetch school semesters', response.statusCode);
    }

    final List<SchoolSemester> schoolSemesters = List<SchoolSemester>.from(
        (response.data as List).map((e) => SchoolSemester.fromJson(e)));

    notificationService.apiRunning(false);

    return schoolSemesters;
  }

  static const _postSchoolSemester = '/school_semesters/new';

  Future<SchoolSemester> postSchoolSemester(
      {required DateTime startDate,
      required DateTime endDate,
      required bool isFirst}) async {
    notificationService.apiRunning(true);

    final data = jsonEncode({
      'start_date': startDate.formatForJson(),
      'end_date': endDate.formatForJson(),
      'is_first': isFirst
    });

    final Response response =
        await _client.post(_postSchoolSemester, data: data);

    if (response.statusCode != 200) {
      notificationService.showSnackBar(
          NotificationType.error, 'Fehler beim Erstellen des Schulsemesters');

      notificationService.apiRunning(false);

      throw ApiException('Failed to post school semester', response.statusCode);
    }

    notificationService.apiRunning(false);

    return SchoolSemester.fromJson(response.data);
  }
}
