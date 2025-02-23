import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:schuldaten_hub/common/domain/env_manager.dart';
import 'package:schuldaten_hub/common/domain/models/enums.dart';
import 'package:schuldaten_hub/common/services/api/api_client.dart';
import 'package:schuldaten_hub/common/services/api/api_settings.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_service.dart';
import 'package:schuldaten_hub/common/utils/extensions.dart';
import 'package:schuldaten_hub/features/attendance/domain/attendance_manager.dart';
import 'package:schuldaten_hub/features/attendance/domain/models/missed_class.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_data.dart';

class AttendanceApiService {
  final ApiClient _client = locator<ApiClient>();

  String _baseUrl() {
    return locator<EnvManager>().env!.serverUrl;
  }

  final _notificationService = locator<NotificationService>();

  //- not implemented

  // String _getMissedClasses(String baseUrl) {
  //   return '$baseUrl/missed_classes/all';
  // }

  // String _fetchOneMissedClass(int id) {
  //   return '${_baseUrl()}/missed_classes/$id';
  // }

  //- fetch missed classes for a date -//

  String _fetchMissedClassesOnDate(DateTime date) {
    final missedDate = date.formatForJson();

    return '${_baseUrl()}/missed_classes/schoolday/$missedDate';
  }

  Future<List<MissedClass>> fetchMissedClassesOnASchoolday(
      DateTime schoolday) async {
    // This one is called every 10 seconds, isRunning would be annoying

    final Response response = await _client.get(
      _fetchMissedClassesOnDate(schoolday),
      options: _client.hubOptions,
    );

    if (response.statusCode == 404) {
      locator<NotificationService>().showSnackBar(
          NotificationType.success, 'Keine Fehlzeiten für diesen Tag!');

      return [];
    }
    if (response.statusCode != 200) {
      locator<NotificationService>().showSnackBar(
          NotificationType.error, 'Fehler: status code ${response.statusCode}');

      throw ApiException('Failed to fetch missed classes', response.statusCode);
    }

    final List<MissedClass> missedClasses = response.data
        .map<MissedClass>((missedClass) => MissedClass.fromJson(missedClass))
        .toList();

    return missedClasses;
  }

  //- post new class -//

  String _postMissedClass(String baseUrl) {
    return '$baseUrl/missed_classes/new';
  }

  Future<PupilData> postMissedClass({
    required int pupilId,
    required MissedType missedType,
    required DateTime date,
    int? minutesLate,
    bool? writtenExcuse,
    bool? excused,
    bool? returned,
    String? returnedAt,
    ContactedType? contactedType,
  }) async {
    _notificationService.apiRunning(true);
    final data = jsonEncode({
      "missed_pupil_id": pupilId,
      "missed_day": date.formatForJson(),
      "missed_type": missedType.value,
      "unexcused": excused ?? false,
      "contacted": contactedType?.value ?? '0',
      "returned": returned ?? false,
      "returned_at": returnedAt,
      "minutes_late": minutesLate,
      "written_excuse": writtenExcuse ?? false,
    });
    final Response response = await _client.post(
      _postMissedClass(_baseUrl()),
      data: data,
      options: _client.hubOptions,
    );
    _notificationService.apiRunning(false);

    if (response.statusCode != 200) {
      _notificationService.showSnackBar(
          NotificationType.error, 'Fehler beim Hinzufügen des Eintrags!');

      throw ApiException('Failed to add missed class', response.statusCode);
    }

    final pupil = PupilData.fromJson(response.data);

    return pupil;
  }

  //- post a list of missed classes -//

  String _postMissedClassList(String baseUrl) {
    return '$baseUrl/missed_classes/list';
  }

  Future<PupilData> postMissedClassList(
      {required List<MissedClass> missedClasses}) async {
    final data = jsonEncode(
      missedClasses.map((missedClass) => missedClass.toJson()).toList(),
    );

    _notificationService.apiRunning(true);

    final Response response = await _client.post(
      _postMissedClassList(_baseUrl()),
      data: data,
      options: _client.hubOptions,
    );

    _notificationService.apiRunning(false);

    if (response.statusCode != 200) {
      _notificationService.showSnackBar(
          NotificationType.error, 'Fehler beim Hinzufügen des Eintrags!');

      throw ApiException(
          'Failed to add many missed classes', response.statusCode);
    }

    final pupil = PupilData.fromJson(response.data);

    return pupil;
  }

  //- patch a missed class -//

  String _patchMissedClass(int pupilId, DateTime date) {
    final missedDate = date.formatForJson();
    return '${_baseUrl()}/missed_classes/$pupilId/$missedDate';
  }

  Future<PupilData> patchMissedClass({
    required int pupilId,
    required DateTime date,
    MissedType? missedType,
    int? minutesLate,
    bool? writtenExcuse,
    bool? excused,
    bool? returned,
    String? returnedAt,
    ContactedType? contactedType,
    String? comment,
  }) async {
    _notificationService.apiRunning(true);

    final data = jsonEncode({
      "missed_pupil_id": pupilId,
      "missed_day": date.formatForJson(),
      if (missedType != null) "missed_type": missedType.value,
      if (excused != null) "unexcused": excused,
      if (contactedType != null) "contacted": contactedType.value,
      if (returned != null) "returned": returned,
      if (returnedAt != null) "returned_at": returnedAt,
      if (minutesLate != null) "minutes_late": minutesLate,
      if (writtenExcuse != null) "written_excuse": writtenExcuse,
      if (comment != null) "comment": comment,
    });

    final Response response = await _client.patch(
      _patchMissedClass(pupilId, date),
      data: data,
      options: _client.hubOptions,
    );

    _notificationService.apiRunning(false);

    if (response.statusCode != 200) {
      _notificationService.showSnackBar(
          NotificationType.error, 'Fehler beim Hinzufügen des Eintrags!');

      throw ApiException('Failed to add missed class', response.statusCode);
    }

    final pupil = PupilData.fromJson(response.data);

    return pupil;
  }

  //- delete missed class -//

  String _deleteMissedClassUrl(int id, DateTime date) {
    final missedDate = date.formatForJson();
    return '${_baseUrl()}/missed_classes/$id/$missedDate';
  }

  Future<PupilData> deleteMissedClass(int pupilId, DateTime date) async {
    _notificationService.apiRunning(true);

    final response = await _client.delete(
      _deleteMissedClassUrl(pupilId, date),
      options: _client.hubOptions,
    );

    _notificationService.apiRunning(false);

    if (response.statusCode != 200) {
      _notificationService.showSnackBar(
          NotificationType.error, 'Fehler: status code ${response.statusCode}');

      throw ApiException('Failed to delete missed class', response.statusCode);
    }

    final pupil = PupilData.fromJson(response.data);

    return pupil;
  }
}
