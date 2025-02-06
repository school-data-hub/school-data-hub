import 'package:dio/dio.dart';
import 'package:schuldaten_hub/common/domain/env_manager.dart';
import 'package:schuldaten_hub/common/domain/models/enums.dart';
import 'package:schuldaten_hub/common/services/api/api_client.dart';
import 'package:schuldaten_hub/common/services/api/api_settings.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_service.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_data.dart';
import 'package:schuldaten_hub/features/workbooks/domain/models/pupil_workbook.dart';

class PupilWorkbookApiService {
  final ApiClient _client = locator<ApiClient>();
  final _notificationService = locator<NotificationService>();

  String _baseUrl() {
    return locator<EnvManager>().env!.serverUrl;
  }
  //- get pupil workbooks

  static const String _getAllWorkbooksUrl = '/pupil_workbooks/all';

  String _getAllPupilWorkbooksFromPupilUrl(int pupilId) {
    return '/pupil_workbooks/$pupilId';
  }

  Future<List<PupilWorkbook>> getAllPupilWorkbooks() async {
    _notificationService.apiRunning(true);

    final Response response = await _client.get(
      '${_baseUrl()}$_getAllWorkbooksUrl',
      options: _client.hubOptions,
    );

    _notificationService.apiRunning(false);

    if (response.statusCode != 200) {
      _notificationService.showSnackBar(
          NotificationType.error, 'Fehler beim Laden der Arbeitshefte');
      throw ApiException('Failed to load pupil workbooks', response.statusCode);
    }

    final List<PupilWorkbook> pupilWorkbooks = (response.data as List)
        .map((dynamic e) => PupilWorkbook.fromJson(e))
        .toList();

    return pupilWorkbooks;
  }

  Future<List<PupilWorkbook>> getAllPupilWorkbooksFromPupil(
      {required int pupilId}) async {
    _notificationService.apiRunning(true);

    final Response response = await _client.get(
      '${_baseUrl()}${_getAllPupilWorkbooksFromPupilUrl(pupilId)}',
      options: _client.hubOptions,
    );

    _notificationService.apiRunning(false);

    if (response.statusCode != 200) {
      _notificationService.showSnackBar(
          NotificationType.error, 'Fehler beim Laden der Arbeitshefte');
      throw ApiException('Failed to load pupil workbooks', response.statusCode);
    }

    final List<PupilWorkbook> pupilWorkbooks = (response.data as List)
        .map((dynamic e) => PupilWorkbook.fromJson(e))
        .toList();

    return pupilWorkbooks;
  }

  //- post new pupil workbook
  String _newPupilWorkbookUrl(int pupilId, int isbn) {
    return '/pupil_workbooks/$pupilId/$isbn';
  }

  Future<PupilData> postNewPupilWorkbook(int pupilId, int isbn) async {
    _notificationService.apiRunning(true);

    final Response response = await _client.post(
      '${_baseUrl()}${_newPupilWorkbookUrl(pupilId, isbn)}',
      options: _client.hubOptions,
    );

    _notificationService.apiRunning(false);

    if (response.statusCode != 200) {
      _notificationService.showSnackBar(
          NotificationType.error, 'Fehler beim Erstellen des Arbeitshefts');
      _notificationService.apiRunning(false);
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
    _notificationService.apiRunning(true);
    final Response response = await _client.delete(
      '${_baseUrl()}${_deletePupilWorkbookUrl(pupilId, isbn)}',
      options: _client.hubOptions,
    );

    _notificationService.apiRunning(false);

    if (response.statusCode != 200) {
      _notificationService.showSnackBar(
          NotificationType.error, 'Fehler beim Löschen des Arbeitshefts');

      throw ApiException(
          'Failed to delete a pupil workbook', response.statusCode);
    }
    final PupilData pupil = PupilData.fromJson(response.data);

    return pupil;
  }

  //- not implemented
  String _patchPupilWorkbook(int pupilId, int isbn) {
    return '/pupil_workbooks/$pupilId/$isbn';
  }

  Future<PupilData> patchPupilWorkbook({
    required int pupilId,
    required int isbn,
    String? comment,
    int? status,
    String? createdBy,
    DateTime? createdAt,
    DateTime? finishedAt,
  }) async {
    final Map<String, dynamic> data = {
      if (comment != null) 'comment': comment,
      if (status != null) 'status': status,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (finishedAt != null) 'finished_at': finishedAt,
    };
    _notificationService.apiRunning(true);
    final Response response = await _client.patch(
      '${_baseUrl()}${_patchPupilWorkbook(pupilId, isbn)}',
      data: data,
      options: _client.hubOptions,
    );

    _notificationService.apiRunning(false);

    if (response.statusCode != 200) {
      _notificationService.showSnackBar(
          NotificationType.error, 'Fehler beim Aktualisieren des Arbeitshefts');

      throw ApiException(
          'Failed to update a pupil workbook', response.statusCode);
    }
    final PupilData pupil = PupilData.fromJson(response.data);

    return pupil;
  }
}
