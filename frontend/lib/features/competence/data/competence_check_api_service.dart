import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:schuldaten_hub/common/domain/env_manager.dart';
import 'package:schuldaten_hub/common/domain/models/enums.dart';
import 'package:schuldaten_hub/common/services/api/api_client.dart';
import 'package:schuldaten_hub/common/services/api/api_settings.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_service.dart';
import 'package:schuldaten_hub/common/utils/custom_encrypter.dart';
import 'package:schuldaten_hub/common/utils/extensions.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_data.dart';

class CompetenceCheckApiService {
  final ApiClient _client = locator<ApiClient>();

  final _notificationService = locator<NotificationService>();

  String _baseUrl() {
    return locator<EnvManager>().env!.serverUrl;
  }

  //- COMPETENCE CHECKS ------------------------------------------------

  //- GET

  String getCompetenceCheckFileUrl(String fileId) {
    return '/competence_checks/$fileId';
  }

  Future<void> getCompetenceCheckFile(String fileId) async {
    _notificationService.apiRunning(true);
    final Response response = await _client.get(
      '${_baseUrl()}${getCompetenceCheckFileUrl(fileId)}',
      options: _client.hubOptions,
    );
    _notificationService.apiRunning(false);
    if (response.statusCode != 200) {
      _notificationService.showSnackBar(
          NotificationType.error, 'Failed to get competence check file');

      throw ApiException(
          'Failed to get competence check file', response.statusCode);
    }

    return response.data;
  }
  //- POST

  String _postCompetenceCheck(int pupilId) {
    return '/competence_checks/$pupilId/new';
  }

  Future<PupilData> postCompetenceCheck({
    required int pupilId,
    required int competenceId,
    required int competenceStatus,
    required String comment,
    required String? groupId,
  }) async {
    final data = jsonEncode({
      "competence_id": competenceId,
      "competence_status": competenceStatus,
      "comment": comment,
      if (groupId != null) "group_id": groupId,
    });
    _notificationService.apiRunning(true);
    final Response response = await _client.post(
      '${_baseUrl()}${_postCompetenceCheck(pupilId)}',
      data: data,
      options: _client.hubOptions,
    );
    _notificationService.apiRunning(false);
    if (response.statusCode != 200) {
      _notificationService.showSnackBar(
          NotificationType.error, 'Failed to post a competence check');

      throw ApiException(
          'Failed to post a competence check', response.statusCode);
    }

    final pupilData = PupilData.fromJson(response.data);

    return pupilData;
  }

  String _postCompetenceCheckFile(String competenceCheckId) {
    return '/competence_checks/$competenceCheckId/file';
  }

  Future<PupilData> postCompetenceCheckFile({
    required String competenceCheckId,
    required File file,
  }) async {
    final encryptedFile = await customEncrypter.encryptFile(file);

    String fileName = encryptedFile.path.split('/').last;

    var data = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        encryptedFile.path,
        filename: fileName,
      ),
    });

    _notificationService.apiRunning(true);

    final Response response = await _client.post(
      '${_baseUrl()}${_postCompetenceCheckFile(competenceCheckId)}',
      data: data,
      options: _client.hubOptions,
    );

    _notificationService.apiRunning(false);

    if (response.statusCode != 200) {
      _notificationService.showSnackBar(
          NotificationType.error, 'Failed to post a competence check file');

      throw ApiException(
          'Failed to post a competence check file', response.statusCode);
    }

    final pupilData = PupilData.fromJson(response.data);

    return pupilData;
  }

  String _postCompetenceCheckWithFile(
      {required int pupilId,
      required int competenceId,
      required String? groupId}) {
    return '/competence_checks/$pupilId/$competenceId/$groupId/new';
  }

  Future<PupilData> postCompetenceCheckWithFile({
    required int pupilId,
    required int competenceId,
    required String? groupId,
    required File file,
  }) async {
    final encryptedFile = await customEncrypter.encryptFile(file);

    String fileName = encryptedFile.path.split('/').last;

    var data = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        encryptedFile.path,
        filename: fileName,
      ),
    });

    _notificationService.apiRunning(true);

    final Response response = await _client.post(
      '${_baseUrl()}${_postCompetenceCheckWithFile(
        pupilId: pupilId,
        groupId: groupId,
        competenceId: competenceId,
      )}',
      data: data,
      options: _client.hubOptions,
    );

    _notificationService.apiRunning(false);

    if (response.statusCode != 200) {
      _notificationService.showSnackBar(NotificationType.error,
          'Failed to post a competence check with file');

      throw ApiException(
          'Failed to post a competence check with file', response.statusCode);
    }

    final pupilData = PupilData.fromJson(response.data);

    return pupilData;
  }
  //- PATCH

  String _patchCompetenceCheck(String competenceCheckId) {
    return '/competence_checks/$competenceCheckId';
  }

  Future<PupilData> patchCompetenceCheck({
    required String competenceCheckId,
    int? competenceStatus,
    String? comment,
    DateTime? createdAt,
    String? createdBy,
  }) async {
    final data = jsonEncode({
      if (competenceStatus != null) "competence_status": competenceStatus,
      if (comment != null) "comment": comment,
      if (createdAt != null) "created_at": createdAt.formatForJson(),
      if (createdBy != null) "created_by": createdBy,
    });
    _notificationService.apiRunning(true);
    final Response response = await _client.patch(
      '${_baseUrl()}${_patchCompetenceCheck(competenceCheckId)}',
      data: data,
      options: _client.hubOptions,
    );
    _notificationService.apiRunning(false);
    if (response.statusCode != 200) {
      _notificationService.showSnackBar(
          NotificationType.error, 'Failed to patch a competence check');

      throw ApiException(
          'Failed to patch a competence check', response.statusCode);
    }

    final pupilData = PupilData.fromJson(response.data);

    return pupilData;
  }
  // String patchCompetenceCheckWithFile(String competenceCheckId) {
  //   return '/competence/check/$competenceCheckId';
  // }

  //- DELETE

  String _deleteCompetenceCheck(String competenceCheckId) {
    return '/competence_checks/$competenceCheckId';
  }

  Future<PupilData> deleteCompetenceCheck(String competenceCheckId) async {
    _notificationService.apiRunning(true);
    final Response response = await _client.delete(
      '${_baseUrl()}${_deleteCompetenceCheck(competenceCheckId)}',
      options: _client.hubOptions,
    );
    _notificationService.apiRunning(false);
    if (response.statusCode != 200) {
      _notificationService.showSnackBar(
          NotificationType.error, 'Failed to delete a competence check');

      throw ApiException(
          'Failed to delete a competence check', response.statusCode);
    }

    final pupilData = PupilData.fromJson(response.data);

    return pupilData;
  }

  String _deleteCompetenceCheckFile(String fileId) {
    return '/competence_checks/file/$fileId';
  }

  Future<PupilData> deleteCompetenceCheckFile(String fileId) async {
    _notificationService.apiRunning(true);

    final Response response = await _client.delete(
      '${_baseUrl()}${_deleteCompetenceCheckFile(fileId)}',
      options: _client.hubOptions,
    );

    _notificationService.apiRunning(false);

    if (response.statusCode != 200) {
      _notificationService.showSnackBar(
          NotificationType.error, 'Failed to delete a competence check file');

      throw ApiException(
          'Failed to delete a competence check file', response.statusCode);
    }

    final pupilData = PupilData.fromJson(response.data);

    return pupilData;
  }
}
