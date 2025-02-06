import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:schuldaten_hub/common/domain/env_manager.dart';
import 'package:schuldaten_hub/common/domain/models/enums.dart';
import 'package:schuldaten_hub/common/services/api/api_client.dart';
import 'package:schuldaten_hub/common/services/api/api_settings.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_service.dart';
import 'package:schuldaten_hub/common/utils/extensions.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_data.dart';

class PupilDataApiService {
  final ApiClient _client = locator<ApiClient>();

  final _notificationService = locator<NotificationService>();

  String _baseUrl() {
    return locator<EnvManager>().env!.serverUrl;
  }

  static const _updateBackendPupilsDatabaseUrl = '/import/pupils/txt';

  Future<List<PupilData>> updateBackendPupilsDatabase(
      {required File file}) async {
    _notificationService.apiRunning(true);

    String fileName = file.path.split('/').last;
    FormData formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      ),
    });

    final response = await _client.post(
      '${_baseUrl()}$_updateBackendPupilsDatabaseUrl',
      data: formData,
      options: _client.hubOptions,
    );

    if (response.statusCode != 200) {
      _notificationService.showSnackBar(NotificationType.error,
          'Die Liste konnte nicht aktualisiert werden: ${response.statusCode}');

      _notificationService.apiRunning(false);

      throw ApiException('Failed to export pupils to txt', response.statusCode);
    }

    final List<PupilData> pupils =
        (response.data as List).map((e) => PupilData.fromJson(e)).toList();

    _notificationService.apiRunning(false);

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
    _notificationService.apiRunning(true);

    final pupilIdsListToJson = jsonEncode({"pupils": internalPupilIds});

    final response = await _client.post(
      '${_baseUrl()}$_fetchPupilsUrl',
      data: pupilIdsListToJson,
      options: _client.hubOptions,
    );

    if (response.statusCode != 200) {
      _notificationService.showSnackBar(NotificationType.error,
          'Die Schüler konnten nicht geladen werden: ${response.statusCode}');

      _notificationService.apiRunning(false);

      throw ApiException('Failed to fetch pupils', response.statusCode);
    }

    final List<PupilData> responsePupils =
        (response.data as List).map((e) => PupilData.fromJson(e)).toList();

    _notificationService.apiRunning(false);

    return responsePupils;
  }

  //- NOT USED - instead the url is used in downloadOrCachedAndDecryptImage
  static String getPupilAvatar(int id) {
    return '${locator<EnvManager>().env!.serverUrl}/pupils/$id/avatar';
  }

  //- update pupil property

  String _updatePupilPropertyUrl(int id) {
    return '/pupils/$id';
  }

  Future<PupilData> updatePupilProperty({
    required int id,
    required String property,
    required dynamic value,
  }) async {
    _notificationService.apiRunning(true);

    final Map<String, dynamic> data = {property: value};
    final response = await _client.patch(
      '${_baseUrl()}${_updatePupilPropertyUrl(id)}',
      data: data,
      options: _client.hubOptions,
    );

    if (response.statusCode != 200) {
      _notificationService.showSnackBar(NotificationType.error,
          'Die Schüler konnten nicht aktualisiert werden: ${response.statusCode}');

      _notificationService.apiRunning(false);

      throw ApiException(
          'Failed to update pupil property', response.statusCode);
    }

    final PupilData responsePupil = PupilData.fromJson(response.data);

    _notificationService.apiRunning(false);

    return responsePupil;
  }

  //- patch siblings

  static const String _patchSiblingsUrl = '/pupils/patch_siblings';
  Future<List<PupilData>> updateSiblingsProperty({
    required List<int> siblingsPupilIds,
    required String property,
    required dynamic value,
  }) async {
    _notificationService.apiRunning(true);

    final data = jsonEncode({
      'pupils': siblingsPupilIds,
      property: value,
    });

    final response = await _client.patch(
      '${_baseUrl()}$_patchSiblingsUrl',
      data: data,
      options: _client.hubOptions,
    );

    if (response.statusCode != 200) {
      _notificationService.showSnackBar(NotificationType.error,
          'Die Geschwister konnten nicht aktualisiert werden: ${response.statusCode}');

      _notificationService.apiRunning(false);

      throw ApiException('Failed to patch siblings', response.statusCode);
    }
    final List<PupilData> responsePupils =
        (response.data as List).map((e) => PupilData.fromJson(e)).toList();

    _notificationService.apiRunning(false);

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
    _notificationService.apiRunning(true);

    final Response response = await _client.patch(
      '${_baseUrl()}${_updatePupilhWithAvatarUrl(id)}',
      data: formData,
      options: _client.hubOptions,
    );

    if (response.statusCode != 200) {
      _notificationService.showSnackBar(NotificationType.error,
          'Das Profilbild konnte nicht aktualisiert werden: ${response.statusCode}');

      _notificationService.apiRunning(false);

      throw ApiException('Failed to upload pupil avatar', response.statusCode);
    }

    _notificationService.apiRunning(false);

    return PupilData.fromJson(response.data);
  }

  //- post / patch pupil avatar auth image

  String _updatePupilhWithAvatarAuthUrl(int id) {
    return '/pupils/$id/avatar_auth';
  }

  Future<PupilData> updatePupilWithAvatarAuth({
    required int id,
    required FormData formData,
  }) async {
    _notificationService.apiRunning(true);

    final Response response = await _client.patch(
      '${_baseUrl()}${_updatePupilhWithAvatarAuthUrl(id)}',
      data: formData,
      options: _client.hubOptions,
    );

    if (response.statusCode != 200) {
      _notificationService.showSnackBar(NotificationType.error,
          'Die avatar Einwilligung konnte nicht aktualisiert werden: ${response.statusCode}');

      _notificationService.apiRunning(false);

      throw ApiException(
          'Failed to upload pupil avatar auth', response.statusCode);
    }
    locator<NotificationService>().showSnackBar(NotificationType.success,
        'Der Einwilligung wurde ein Dokument hinzugefügt!');
    _notificationService.apiRunning(false);

    return PupilData.fromJson(response.data);
  }

  //- post / patch pupil public media auth image

  String _updatePupilhWithPublicMediaAuthUrl(int id) {
    return '/pupils/$id/public_media_auth';
  }

  Future<PupilData> updatePupilWithPublicMediaAuth({
    required int id,
    required FormData formData,
  }) async {
    _notificationService.apiRunning(true);

    final Response response = await _client.patch(
      '${_baseUrl()}${_updatePupilhWithPublicMediaAuthUrl(id)}',
      data: formData,
      options: _client.hubOptions,
    );

    if (response.statusCode != 200) {
      _notificationService.showSnackBar(NotificationType.error,
          'Die Einwilligung für öffentliche Medien konnte nicht aktualisiert werden: ${response.statusCode}');

      _notificationService.apiRunning(false);

      throw ApiException(
          'Failed to upload pupil public media auth', response.statusCode);
    }

    _notificationService.apiRunning(false);

    return PupilData.fromJson(response.data);
  }

  //- delete pupil avatar

  String _deletePupilAvatarUrl(int internalId) {
    return '/pupils/$internalId/avatar';
  }

  Future<void> deletePupilAvatar({required int internalId}) async {
    _notificationService.apiRunning(true);

    final Response response = await _client.delete(
      '${_baseUrl()}${_deletePupilAvatarUrl(internalId)}',
      options: _client.hubOptions,
    );

    if (response.statusCode != 200) {
      _notificationService.showSnackBar(NotificationType.error,
          'Das Profilbild konnte nicht gelöscht werden: ${response.statusCode}');

      _notificationService.apiRunning(false);

      throw ApiException(
          'Something went wrong deleting the avatar', response.statusCode);
    }
    // TODO: This is an empty response, should we return something?
    return;
  }

  //- delete pupil avatar auth

  String _deletePupilAvatarAuthUrl(int internalId) {
    return '/pupils/$internalId/avatar_auth';
  }

  Future<void> deletePupilAvatarAuth({required int internalId}) async {
    _notificationService.apiRunning(true);

    final Response response = await _client.delete(
      '${_baseUrl()}${_deletePupilAvatarAuthUrl(internalId)}',
      options: _client.hubOptions,
    );

    if (response.statusCode != 200) {
      _notificationService.showSnackBar(NotificationType.error,
          'Die avatar Einwilligung konnte nicht gelöscht werden: ${response.statusCode}');

      _notificationService.apiRunning(false);

      throw ApiException(
          'Something went wrong deleting the avatar auth', response.statusCode);
    }

    return;
  }

  //- delete pupil public media auth

  String _deletePupilPublicMediaAuthUrl(int internalId) {
    return '/pupils/$internalId/public_media_auth';
  }

  Future<void> deletePupilPublicMediaAuthImage(
      {required int internalId}) async {
    _notificationService.apiRunning(true);

    final Response response = await _client.delete(
      '${_baseUrl()}${_deletePupilPublicMediaAuthUrl(internalId)}',
      options: _client.hubOptions,
    );

    if (response.statusCode != 200) {
      _notificationService.showSnackBar(NotificationType.error,
          'Die Einwilligung für öffentliche Medien konnte nicht gelöscht werden: ${response.statusCode}');

      _notificationService.apiRunning(false);

      throw ApiException(
          'Failed to delete pupil public media auth', response.statusCode);
    }

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
    _notificationService.apiRunning(true);

    final data = jsonEncode({
      'level': newSupportLevel,
      'created_at': createdAt.formatForJson(),
      'created_by': createdBy,
      'comment': comment,
    });

    final response = await _client.patch(
      '${_baseUrl()}${_updateSupportLevel(internalId)}',
      data: data,
      options: _client.hubOptions,
    );

    if (response.statusCode != 200) {
      _notificationService.showSnackBar(NotificationType.error,
          'Die Förderstufe konnte nicht aktualisiert werden: ${response.statusCode}');

      _notificationService.apiRunning(false);

      throw ApiException(
          'Failed to patch individual development plan', response.statusCode);
    }

    final PupilData responsePupil = PupilData.fromJson(response.data);

    _notificationService.apiRunning(false);

    return responsePupil;
  }

  String _deleteSupportLevelHistoryItem(int internalId, String supportLevelId) {
    return '/pupils/$internalId/support_level/$supportLevelId';
  }

  Future<PupilData> deleteSupportLevelHistoryItem({
    required int internalId,
    required String supportLevelId,
  }) async {
    _notificationService.apiRunning(true);

    final response = await _client.delete(
      '${_baseUrl()}${_deleteSupportLevelHistoryItem(internalId, supportLevelId)}',
      options: _client.hubOptions,
    );

    if (response.statusCode != 200) {
      _notificationService.showSnackBar(NotificationType.error,
          'Die Förderstufe konnte nicht gelöscht werden: ${response.statusCode}');

      _notificationService.apiRunning(false);

      throw ApiException(
          'Failed to delete individual development plan', response.statusCode);
    }

    final PupilData responsePupil = PupilData.fromJson(response.data);

    _notificationService.apiRunning(false);

    return responsePupil;
  }
}
