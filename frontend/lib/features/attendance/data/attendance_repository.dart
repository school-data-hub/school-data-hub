import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:schuldaten_hub/common/domain/models/enums.dart';
import 'package:schuldaten_hub/common/services/api/api_client.dart';
import 'package:schuldaten_hub/common/services/api/api_settings.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_service.dart';
import 'package:schuldaten_hub/common/utils/extensions.dart';
import 'package:schuldaten_hub/features/attendance/domain/attendance_manager.dart';
import 'package:schuldaten_hub/features/attendance/domain/models/missed_class.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_data.dart';
import 'package:schuldaten_hub/features/pupil/domain/pupil_manager.dart';

class AttendanceRepository {
  final ApiClient _client = locator<ApiClient>();

  final pupilManager = locator<PupilManager>();

  final notificationService = locator<NotificationService>();

  //- not implemented

  String getMissedClasses = '/missed_classes/all';

  String getOneMissedClass(int id) {
    return '/missed_classes/$id';
  }

  //- fetch missed classes for a date -//

  String _getMissedClassesOnDate(DateTime date) {
    final missedDate = date.formatForJson();

    return '/missed_classes/schoolday/$missedDate';
  }

  Future<List<MissedClass>> fetchMissedClassesOnASchoolday(
      DateTime schoolday) async {
    // This one is called every 10 seconds, isRunning would be annoying

    final Response response =
        await _client.get(_getMissedClassesOnDate(schoolday));

    if (response.statusCode == 404) {
      locator<NotificationService>().showSnackBar(
          NotificationType.warning, 'Keine Einträge für diesen Tag gefunden!');

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

  static const _postMissedClass = '/missed_classes/new';

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
    notificationService.apiRunning(true);
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
    final Response response = await _client.post(_postMissedClass, data: data);
    notificationService.apiRunning(false);

    if (response.statusCode != 200) {
      notificationService.showSnackBar(
          NotificationType.error, 'Fehler beim Hinzufügen des Eintrags!');

      throw ApiException('Failed to add missed class', response.statusCode);
    }

    final pupil = PupilData.fromJson(response.data);

    return pupil;
  }

  //- post a list of missed classes -//

  static const _postMissedClassList = '/missed_classes/list';

  Future<PupilData> postMissedClassList(
      {required List<MissedClass> missedClasses}) async {
    final data = jsonEncode(
      missedClasses.map((missedClass) => missedClass.toJson()).toList(),
    );

    notificationService.apiRunning(true);

    final Response response =
        await _client.post(_postMissedClassList, data: data);

    notificationService.apiRunning(false);

    if (response.statusCode != 200) {
      notificationService.showSnackBar(
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
    return '/missed_classes/$pupilId/$missedDate';
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
    notificationService.apiRunning(true);

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

    final Response response =
        await _client.patch(_patchMissedClass(pupilId, date), data: data);

    notificationService.apiRunning(false);

    if (response.statusCode != 200) {
      notificationService.showSnackBar(
          NotificationType.error, 'Fehler beim Hinzufügen des Eintrags!');

      throw ApiException('Failed to add missed class', response.statusCode);
    }

    final pupil = PupilData.fromJson(response.data);

    return pupil;
  }

  //- delete missed class -//

  String _deleteMissedClassUrl(int id, DateTime date) {
    final missedDate = date.formatForJson();
    return '/missed_classes/$id/$missedDate';
  }

  Future<PupilData> deleteMissedClass(int pupilId, DateTime date) async {
    notificationService.apiRunning(true);

    final response = await _client.delete(_deleteMissedClassUrl(pupilId, date));

    notificationService.apiRunning(false);

    if (response.statusCode != 200) {
      notificationService.showSnackBar(
          NotificationType.error, 'Fehler: status code ${response.statusCode}');

      throw ApiException('Failed to delete missed class', response.statusCode);
    }

    final pupil = PupilData.fromJson(response.data);

    return pupil;
  }
}
