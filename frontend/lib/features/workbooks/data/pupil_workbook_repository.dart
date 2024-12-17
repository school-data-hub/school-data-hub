import 'package:dio/dio.dart';
import 'package:schuldaten_hub/common/domain/models/enums.dart';
import 'package:schuldaten_hub/common/services/api/api_settings.dart';
import 'package:schuldaten_hub/common/services/api/api_client.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_service.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_data.dart';

class PupilWorkbookRepository {
  final ApiClient _client = locator<ApiClient>();
  final notificationService = locator<NotificationService>();

  //- post new pupil workbook
  String _newPupilWorkbookUrl(int pupilId, int isbn) {
    return '/pupil_workbooks/$pupilId/$isbn';
  }

  Future<PupilData> postNewPupilWorkbook(int pupilId, int isbn) async {
    notificationService.apiRunning(true);

    final Response response =
        await _client.post(_newPupilWorkbookUrl(pupilId, isbn));

    notificationService.apiRunning(false);

    if (response.statusCode != 200) {
      notificationService.showSnackBar(
          NotificationType.error, 'Fehler beim Erstellen des Arbeitshefts');
      notificationService.apiRunning(false);
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
    notificationService.apiRunning(true);
    final Response response =
        await _client.delete(_deletePupilWorkbookUrl(pupilId, isbn));

    notificationService.apiRunning(false);

    if (response.statusCode != 200) {
      notificationService.showSnackBar(
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
