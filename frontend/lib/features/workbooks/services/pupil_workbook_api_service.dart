import 'package:dio/dio.dart';
import 'package:schuldaten_hub/common/services/api/api.dart';
import 'package:schuldaten_hub/common/services/api/services/api_client_service.dart';
import 'package:schuldaten_hub/common/constants/enums.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_manager.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_data.dart';

class PupilWorkbookApiService {
  final ApiClientService _client = locator<ApiClientService>();
  final notificationManager = locator<NotificationManager>();

  //- post new pupil workbook
  String _newPupilWorkbookUrl(int pupilId, int isbn) {
    return '/pupil_workbooks/$pupilId/$isbn';
  }

  Future<PupilData> postNewPupilWorkbook(int pupilId, int isbn) async {
    notificationManager.apiRunningValue(true);

    final Response response =
        await _client.post(_newPupilWorkbookUrl(pupilId, isbn));

    notificationManager.apiRunningValue(false);

    if (response.statusCode != 200) {
      notificationManager.showSnackBar(
          NotificationType.error, 'Fehler beim Erstellen des Arbeitshefts');
      notificationManager.apiRunningValue(false);
      throw ApiException(
          'Failed to create a pupil workbook', response.statusCode);
    }
    final PupilData pupil = PupilData.fromJson(response.data);

    return pupil;
  }

  //- delete pupil workbook
  String _deletePupilWorkbookUrl(int pupilId, int isbn) {
    return '/pupil_workbooks/$pupilId/$isbn';
  }

  Future<PupilData> deletePupilWorkbook(int pupilId, int isbn) async {
    notificationManager.apiRunningValue(true);
    final Response response =
        await _client.delete(_deletePupilWorkbookUrl(pupilId, isbn));

    notificationManager.apiRunningValue(false);

    if (response.statusCode != 200) {
      notificationManager.showSnackBar(
          NotificationType.error, 'Fehler beim Löschen des Arbeitshefts');

      throw ApiException(
          'Failed to delete a pupil workbook', response.statusCode);
    }
    final PupilData pupil = PupilData.fromJson(response.data);

    return pupil;
  }

  //- not implemented
  String patchPupilWorkbook(int pupilId, int isbn) {
    return '/pupil_workbooks/$pupilId/$isbn';
  }
}
