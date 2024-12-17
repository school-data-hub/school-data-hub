import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:schuldaten_hub/common/domain/models/enums.dart';
import 'package:schuldaten_hub/common/services/api/api_settings.dart';
import 'package:schuldaten_hub/common/services/api/api_client.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_service.dart';
import 'package:schuldaten_hub/common/utils/custom_encrypter.dart';
import 'package:schuldaten_hub/features/authorizations/domain/models/authorization.dart';

class AuthorizationRepository {
  final ApiClient _client = locator<ApiClient>();
  final notificationService = locator<NotificationService>();

  //- AUTHORIZATIONS -------------------------------------------

  //- getAuthorizations

  static const String _getAuthorizationsUrl = '/authorizations/all';

  Future<List<Authorization>> fetchAuthorizations() async {
    notificationService.apiRunning(true);

    final Response response = await _client.get(_getAuthorizationsUrl);

    if (response.statusCode != 200) {
      notificationService.showSnackBar(NotificationType.error,
          'Einwilligungen konnten nicht geladen werden: ${response.statusCode}');

      notificationService.apiRunning(false);

      throw ApiException('Failed to get authorizations', response.statusCode);
    }

    final authorizations =
        (response.data as List).map((e) => Authorization.fromJson(e)).toList();

    notificationService.apiRunning(false);

    return authorizations;
  }

  //- post authorization with a list of pupils as members

  static const String _postAuthorizationWithPupilsFromListUrl =
      '/authorizations/new/list';

  Future<Authorization> postAuthorizationWithPupils(
      String name, String description, List<int> pupilIds) async {
    notificationService.apiRunning(true);

    final data = jsonEncode({
      "authorization_description": description,
      "authorization_name": name,
      "pupils": pupilIds
    });

    final Response response =
        await _client.post(_postAuthorizationWithPupilsFromListUrl, data: data);
    notificationService.apiRunning(false);
    if (response.statusCode != 200) {
      notificationService.showSnackBar(NotificationType.error,
          'Einwilligungen konnten nicht erstellt werden');

      notificationService.apiRunning(false);

      throw ApiException('Failed to post authorization', response.statusCode);
    }

    final authorization = Authorization.fromJson(response.data);

    return authorization;
  }

  //-PUPIL AUTHORIZATIONS -------------------------------------------

  //- add pupil to authorization

  String _postPupilAuthorizationUrl(int pupilId, String authorizationId) {
    return '/pupil_authorizations/$pupilId/$authorizationId/new';
  }

  Future<Authorization> postPupilAuthorization(
      int pupilId, String authId) async {
    notificationService.apiRunning(true);

    final data = jsonEncode({"comment": null, "file_id": null, "status": null});

    final response = await _client
        .post(_postPupilAuthorizationUrl(pupilId, authId), data: data);

    notificationService.apiRunning(false);

    if (response.statusCode != 200) {
      notificationService.showSnackBar(
          NotificationType.error, 'Error: ${response.data}');

      throw ApiException(
          'Failed to post pupil authorization', response.statusCode);
    }

    return Authorization.fromJson(response.data);
  }

  //- post pupil authorizations for a list of pupils as members of an authorization

  String _postPupilAuthorizationsUrl(String authorizationId) {
    return '/pupil_authorizations/$authorizationId/list';
  }

  Future<Authorization> postPupilAuthorizations(
      List<int> pupilIds, String authId) async {
    notificationService.apiRunning(true);

    final data = jsonEncode({"pupils": pupilIds});

    final response =
        await _client.post(_postPupilAuthorizationsUrl(authId), data: data);
    notificationService.apiRunning(false);
    if (response.statusCode != 200) {
      notificationService.showSnackBar(NotificationType.error,
          'Es konnten keine Einwilligungen erstellt werden');

      notificationService.apiRunning(false);

      throw ApiException(
          'Failed to post pupil authorizations', response.statusCode);
    }
    final Authorization authorization = Authorization.fromJson(response.data);

    return authorization;
  }

  //- delete pupil authorization

  String _deletePupilAuthorizationUrl(int pupilId, String authorizationId) {
    return '/pupil_authorizations/$pupilId/$authorizationId';
  }

  Future<Authorization> deletePupilAuthorization(
      int pupilId, String authId) async {
    notificationService.apiRunning(true);

    final response =
        await _client.delete(_deletePupilAuthorizationUrl(pupilId, authId));
    notificationService.apiRunning(false);

    if (response.statusCode != 200) {
      notificationService.showSnackBar(NotificationType.error,
          'Die Einwilligung konnte nicht gelöscht werden');

      notificationService.apiRunning(false);

      throw ApiException(
          'Failed to delete pupil authorization', response.statusCode);
    }

    final authorization = Authorization.fromJson(response.data);

    return authorization;
  }

  //- patch pupil authorization

  String _patchPupilAuthorizationUrl(int pupilId, String authorizationId) {
    return '/pupil_authorizations/$pupilId/$authorizationId';
  }

  Future<Authorization> updatePupilAuthorizationProperty(
      int pupilId, String listId, bool? value, String? comment) async {
    notificationService.apiRunning(true);

    String data = '';
    if (value == null) {
      data = jsonEncode({"comment": comment});
    } else if (comment == null) {
      data = jsonEncode({"status": value});
    } else {
      data = jsonEncode({"comment": comment, "status": value});
    }

    final response = await _client
        .patch(_patchPupilAuthorizationUrl(pupilId, listId), data: data);

    notificationService.apiRunning(false);

    if (response.statusCode != 200) {
      notificationService.showSnackBar(
          NotificationType.error, 'Einwilligung konnte nicht geändert werden');

      notificationService.apiRunning(false);

      throw ApiException(
          'Failed to patch pupil authorization', response.statusCode);
    }

    final authorization = Authorization.fromJson(response.data);

    return authorization;
  }

  // - patch pupil authorization with file
  String _patchPupilAuthorizationWithFileUrl(
      int pupilId, String authorizationId) {
    return '/pupil_authorizations/$pupilId/$authorizationId/file';
  }

  Future<Authorization> postAuthorizationFile(
    File file,
    int pupilId,
    String authId,
  ) async {
    notificationService.apiRunning(true);

    final encryptedFile = await customEncrypter.encryptFile(file);
    String fileName = encryptedFile.path.split('/').last;

    final Response response = await _client.patch(
      _patchPupilAuthorizationWithFileUrl(pupilId, authId),
      data: FormData.fromMap(
        {
          "file": await MultipartFile.fromFile(encryptedFile.path,
              filename: fileName),
        },
      ),
    );
    notificationService.apiRunning(false);
    if (response.statusCode != 200) {
      notificationService.showSnackBar(
          NotificationType.error, 'Error: ${response.data}');

      notificationService.apiRunning(false);

      throw ApiException(
          'Failed to post pupil authorization file', response.statusCode);
    }

    return Authorization.fromJson(response.data);
  }

//- delete pupil authorization file

  String _deletePupilAuthorizationFileUrl(int pupilId, String authorizationId) {
    return '/pupil_authorizations/$pupilId/$authorizationId/file';
  }

  Future<Authorization> deleteAuthorizationFile(
      int pupilId, String authId, String cacheKey) async {
    notificationService.apiRunning(true);

    final Response response =
        await _client.delete(_deletePupilAuthorizationFileUrl(pupilId, authId));
    notificationService.apiRunning(false);
    if (response.statusCode != 200) {
      notificationService.showSnackBar(
          NotificationType.error, 'Error: ${response.data}');

      notificationService.apiRunning(false);

      throw ApiException(
          'Failed to delete pupil authorization file', response.statusCode);
    }

    // First we delete the cached image
    final cacheManager = locator<DefaultCacheManager>();
    await cacheManager.removeFile(cacheKey);

    return Authorization.fromJson(response.data);
  }

  //-dieser Endpoint wird in widgets benutzt
  String getPupilAuthorizationFile(int pupilId, String authorizationId) {
    return '/pupil_authorizations/$pupilId/$authorizationId/file';
  }

  //- diese Endpoints sind noch nicht implementiert
  String patchAuthorization(int id) {
    return '/authorizations/$id';
  }

  static const String postAuthorizationWithAllPupils =
      '/authorizations/new/all';

  //- diese Endpunkte werden nicht verwendet
  String postAuthorization(int id) {
    return '/pupil/$id/authorization';
  }

  static const String getAuthorizationsFlatUrl = '/authorizations/all/flat';
  String deleteAuthorization(int id) {
    return '/authorizations/$id';
  }
}
