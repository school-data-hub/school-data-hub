import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:schuldaten_hub/common/domain/models/enums.dart';
import 'package:schuldaten_hub/common/services/api/api_settings.dart';
import 'package:schuldaten_hub/common/services/api/api_client.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_service.dart';
import 'package:schuldaten_hub/common/utils/extensions.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_data.dart';

class PupilDataApiService {
  final ApiClient _client = locator<ApiClient>();

  final notificationService = locator<NotificationService>();

  //- This one is in PupilPersonalDataManager, have to review that one

  static const _updateBackendPupilsDatabaseUrl = '/import/pupils/txt';

  Future<List<PupilData>> updateBackendPupilsDatabase(
      {required File file}) async {
    notificationService.apiRunning(true);

    String fileName = file.path.split('/').last;
    FormData formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      ),
    });

    final response = await _client.post(
      _updateBackendPupilsDatabaseUrl,
      data: formData,
    );

    if (response.statusCode != 200) {
      notificationService.showSnackBar(NotificationType.error,
          'Die Liste konnte nicht aktualisiert werden: ${response.statusCode}');

      notificationService.apiRunning(false);

      throw ApiException('Failed to export pupils to txt', response.statusCode);
    }

    final List<PupilData> pupils =
        (response.data as List).map((e) => PupilData.fromJson(e)).toList();

    notificationService.apiRunning(false);

    return pupils;
  }

  //- THIS ENDPOINTS ARE NOT USED IN THE APP
  static const getAllPupils = '/pupils/all';
  static const getPupilsFlat = '/pupils/all/flat';
  static const postPupil = '/pupils/new';
  String deletePupil(int pupilId) {
    return '/pupils/$pupilId';
  }

  //- fetch list of pupils

  static const _fetchPupilsUrl = '/pupils/list';

  Future<List<PupilData>> fetchListOfPupils({
    required List<int> internalPupilIds,
  }) async {
    notificationService.apiRunning(true);

    final pupilIdsListToJson = jsonEncode({"pupils": internalPupilIds});

    final response =
        await _client.post(_fetchPupilsUrl, data: pupilIdsListToJson);

    if (response.statusCode != 200) {
      notificationService.showSnackBar(NotificationType.error,
          'Die Schüler konnten nicht geladen werden: ${response.statusCode}');

      notificationService.apiRunning(false);

      throw ApiException('Failed to fetch pupils', response.statusCode);
    }

    final List<PupilData> responsePupils =
        (response.data as List).map((e) => PupilData.fromJson(e)).toList();

    notificationService.apiRunning(false);

    return responsePupils;
  }

  //- NOT USED - instead the url is used in downloadOrCachedAndDecryptImage
  static String getPupilAvatar(int id) {
    return '/pupils/$id/avatar';
  }

  /// mach das hier für alle endpoints
  /// Functionen mit aussagekraäfigen Namen
  /// die die richtigen Typen zurückgeben
  /// die verwendung in der App kommt dann im nöchsten Schritt
  /// diese funktionen lassen sich dann auch testen

  //- update pupil property

  String _updatePupilPropertyUrl(int id) {
    return '/pupils/$id';
  }

  Future<PupilData> updatePupilProperty({
    required int id,
    required String property,
    required dynamic value,
  }) async {
    notificationService.apiRunning(true);

    final Map<String, dynamic> data = {property: value};
    final response =
        await _client.patch(_updatePupilPropertyUrl(id), data: data);

    if (response.statusCode != 200) {
      notificationService.showSnackBar(NotificationType.error,
          'Die Schüler konnten nicht aktualisiert werden: ${response.statusCode}');

      notificationService.apiRunning(false);

      throw ApiException(
          'Failed to update pupil property', response.statusCode);
    }

    final PupilData responsePupil = PupilData.fromJson(response.data);

    notificationService.apiRunning(false);

    return responsePupil;
  }

  //- patch siblings

  static const String _patchSiblingsUrl = '/pupils/patch_siblings';
  Future<List<PupilData>> updateSiblingsProperty({
    required List<int> siblingsPupilIds,
    required String property,
    required dynamic value,
  }) async {
    notificationService.apiRunning(true);

    final data = jsonEncode({
      'pupils': siblingsPupilIds,
      property: value,
    });

    final response = await _client.patch(_patchSiblingsUrl, data: data);

    if (response.statusCode != 200) {
      notificationService.showSnackBar(NotificationType.error,
          'Die Geschwister konnten nicht aktualisiert werden: ${response.statusCode}');

      notificationService.apiRunning(false);

      throw ApiException('Failed to patch siblings', response.statusCode);
    }
    final List<PupilData> responsePupils =
        (response.data as List).map((e) => PupilData.fromJson(e)).toList();

    notificationService.apiRunning(false);

    return responsePupils;
  }

  //- post / patch pupil avatar

  String _updatePupilhWithAvatarUrl(int id) {
    return '/pupils/$id/avatar';
  }

  Future<PupilData> updatePupilWithAvatar({
    required int id,
    required FormData formData,
  }) async {
    notificationService.apiRunning(true);

    final Response response =
        await _client.patch(_updatePupilhWithAvatarUrl(id), data: formData);

    if (response.statusCode != 200) {
      notificationService.showSnackBar(NotificationType.error,
          'Das Profilbild konnte nicht aktualisiert werden: ${response.statusCode}');

      notificationService.apiRunning(false);

      throw ApiException('Failed to upload pupil avatar', response.statusCode);
    }

    notificationService.apiRunning(false);

    return PupilData.fromJson(response.data);
  }

  //- delete pupil avatar

  String _deletePupilAvatarUrl(int internalId) {
    return '/pupils/$internalId/avatar';
  }

  Future<void> deletePupilAvatar({required int internalId}) async {
    notificationService.apiRunning(true);

    final Response response =
        await _client.delete(_deletePupilAvatarUrl(internalId));

    if (response.statusCode != 200) {
      notificationService.showSnackBar(NotificationType.error,
          'Das Profilbild konnte nicht gelöscht werden: ${response.statusCode}');

      notificationService.apiRunning(false);

      throw ApiException(
          'Something went wrong deleting the avatar', response.statusCode);
    }
    // TODO: This is an empty response, should we return something?
    return;
  }

  //- update support level

  String _updateSupportLevel(int internalId) {
    return '/pupils/$internalId/support_level';
  }

  Future<PupilData> updateSupportLevel({
    required int internalId,
    required int newSupportLevel,
    required DateTime createdAt,
    required String createdBy,
    required String comment,
  }) async {
    notificationService.apiRunning(true);

    final data = jsonEncode({
      'level': newSupportLevel,
      'created_at': createdAt.formatForJson(),
      'created_by': createdBy,
      'comment': comment,
    });

    final response =
        await _client.patch(_updateSupportLevel(internalId), data: data);

    if (response.statusCode != 200) {
      notificationService.showSnackBar(NotificationType.error,
          'Die Förderstufe konnte nicht aktualisiert werden: ${response.statusCode}');

      notificationService.apiRunning(false);

      throw ApiException(
          'Failed to patch individual development plan', response.statusCode);
    }

    final PupilData responsePupil = PupilData.fromJson(response.data);

    notificationService.apiRunning(false);

    return responsePupil;
  }

  String _deleteSupportLevelHistoryItem(int internalId, String supportLevelId) {
    return '/pupils/$internalId/support_level/$supportLevelId';
  }

  Future<PupilData> deleteSupportLevelHistoryItem({
    required int internalId,
    required String supportLevelId,
  }) async {
    notificationService.apiRunning(true);

    final response = await _client
        .delete(_deleteSupportLevelHistoryItem(internalId, supportLevelId));

    if (response.statusCode != 200) {
      notificationService.showSnackBar(NotificationType.error,
          'Die Förderstufe konnte nicht gelöscht werden: ${response.statusCode}');

      notificationService.apiRunning(false);

      throw ApiException(
          'Failed to delete individual development plan', response.statusCode);
    }

    final PupilData responsePupil = PupilData.fromJson(response.data);

    notificationService.apiRunning(false);

    return responsePupil;
  }
}
