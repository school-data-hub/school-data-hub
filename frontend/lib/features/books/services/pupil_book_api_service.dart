import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:schuldaten_hub/common/services/api/api.dart';
import 'package:schuldaten_hub/common/services/api/services/api_client_service.dart';
import 'package:schuldaten_hub/common/constants/enums.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_manager.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_data.dart';

class PupilBookApiService {
  final ApiClientService _client = locator<ApiClientService>();
  final notificationManager = locator<NotificationManager>();

  //- post new pupil book
  String _newPupilBookUrl(int pupilId, String bookId) {
    return '/pupil_books/$pupilId/$bookId';
  }

  Future<PupilData> postNewPupilBook(int pupilId, String bookId) async {
    notificationManager.apiRunningValue(true);

    final Response response =
        await _client.post(_newPupilBookUrl(pupilId, bookId));

    notificationManager.apiRunningValue(false);

    if (response.statusCode != 200) {
      notificationManager.showSnackBar(
          NotificationType.error, 'Fehler beim Erstellen des Arbeitshefts');
      notificationManager.apiRunningValue(false);
      throw ApiException('Failed to create a pupil book', response.statusCode);
    }
    final PupilData pupil = PupilData.fromJson(response.data);

    return pupil;
  }

  //- delete pupil book
  String _deletePupilBookUrl(int pupilId, int isbn) {
    return '/pupil_books/$pupilId/$isbn';
  }

  Future<PupilData> deletePupilBook(int pupilId, int isbn) async {
    notificationManager.apiRunningValue(true);
    final Response response =
        await _client.delete(_deletePupilBookUrl(pupilId, isbn));

    notificationManager.apiRunningValue(false);

    if (response.statusCode != 200) {
      notificationManager.showSnackBar(
          NotificationType.error, 'Fehler beim Löschen des Arbeitshefts');

      throw ApiException('Failed to delete a pupil book', response.statusCode);
    }
    final PupilData pupil = PupilData.fromJson(response.data);

    return pupil;
  }

  String _patchPupilBookUrl(int pupilId, String bookId) {
    return '/pupil_books/$pupilId/$bookId';
  }

  Future<PupilData> patchPupilBook(int pupilId, String bookId) async {
    final data = jsonEncode({
      "book_id": bookId,
      "pupil_id": pupilId,
    });
    notificationManager.apiRunningValue(true);
    final Response response =
        await _client.patch(_patchPupilBookUrl(pupilId, bookId), data: data);

    notificationManager.apiRunningValue(false);

    if (response.statusCode != 200) {
      notificationManager.showSnackBar(
          NotificationType.error, 'Fehler beim Zurücknehmen des Buchs');

      throw ApiException('Failed to return a pupil book', response.statusCode);
    }
    final PupilData pupil = PupilData.fromJson(response.data);

    return pupil;
  }
}
