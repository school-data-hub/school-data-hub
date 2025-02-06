import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:schuldaten_hub/common/domain/env_manager.dart';
import 'package:schuldaten_hub/common/domain/models/enums.dart';
import 'package:schuldaten_hub/common/services/api/api_client.dart';
import 'package:schuldaten_hub/common/services/api/api_settings.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_service.dart';
import 'package:schuldaten_hub/common/utils/extensions.dart';
import 'package:schuldaten_hub/features/learning_support/domain/models/support_category/support_category.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_data.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_proxy.dart';

class LearningSupportApiService {
  final ApiClient _client = locator<ApiClient>();

  final _notificationService = locator<NotificationService>();

  String _baseUrl() {
    return locator<EnvManager>().env!.serverUrl;
  }
  //- GOAL CATEGORIES --------------------------------------------------

  //- fetch goal categories
  static const String _fetchGoalCategoriesUrl = '/support_categories/all/flat';

  Future<List<SupportCategory>> fetchSupportCategories() async {
    _notificationService.apiRunning(true);

    final response = await _client.get(
      '${_baseUrl()}$_fetchGoalCategoriesUrl',
      options: _client.hubOptions,
    );

    if (response.statusCode != 200) {
      _notificationService.showSnackBar(
          NotificationType.error, 'Fehler beim Laden der Kategorien');

      _notificationService.apiRunning(false);

      throw ApiException(
          'Failed to fetch goal categories', response.statusCode);
    }

    final List<SupportCategory> goalCategories = (response.data as List)
        .map((e) => SupportCategory.fromJson(e))
        .toList();

    _notificationService.apiRunning(false);

    return goalCategories;
  }

  //- this endpoint is not used in the app
  static const String fetchGoalCategoriesWithChildren =
      '/support_categories/all';

  //- STATUSES ---------------------------------------------------------

  String _postCategoryStatusUrl(int pupilId, int categoryId) {
    return '/support_category/statuses/$pupilId/$categoryId';
  }

  Future<PupilData> postSupportCategoryStatus(
      {required int pupilInternalId,
      required int goalCategoryId,
      required String state,
      required String comment}) async {
    _notificationService.apiRunning(true);

    final data = jsonEncode({
      "state": state,
      // "file_id": null,
      "comment": comment,
    });

    final response = await _client.post(
      '${_baseUrl()}${_postCategoryStatusUrl(pupilInternalId, goalCategoryId)}',
      data: data,
      options: _client.hubOptions,
    );

    if (response.statusCode != 200) {
      _notificationService.showSnackBar(
          NotificationType.error, 'Fehler beim Posten des Status');

      _notificationService.apiRunning(false);

      throw ApiException('Failed to post category status', response.statusCode);
    }
    final PupilData pupil = PupilData.fromJson(response.data);

    _notificationService.showSnackBar(
        NotificationType.success, 'Status erfolgreich gepostet');
    _notificationService.apiRunning(false);

    return pupil;
  }

  //- update category status
  String _patchCategoryStatusUrl(String categoryStatusId) {
    return '/support_category/statuses/$categoryStatusId';
  }

  Future<PupilData> updateCategoryStatusProperty(
      PupilProxy pupil,
      String statusId,
      String? state,
      String? comment,
      String? createdBy,
      String? createdAt) async {
    _notificationService.apiRunning(true);

    final data = jsonEncode({
      if (state != null) "state": state,
      if (comment != null) "comment": comment,
      if (createdBy != null) "created_by": createdBy,
      if (createdAt != null) "created_at": createdAt
    });

    final response = await _client.patch(
      '${_baseUrl()}${_patchCategoryStatusUrl(statusId)}',
      data: data,
      options: _client.hubOptions,
    );

    if (response.statusCode != 200) {
      _notificationService.showSnackBar(
          NotificationType.error, 'Fehler beim Aktualisieren des Status');

      _notificationService.apiRunning(false);

      throw ApiException(
          'Failed to update category status', response.statusCode);
    }

    final PupilData pupil = PupilData.fromJson(response.data);

    _notificationService.apiRunning(false);

    return pupil;
  }

  String postFileForCategoryStatus(String categoryStatusId) {
    return '/support_category/statuses/$categoryStatusId/file';
  }

  String _deleteCategoryStatusUrl(String categoryStatusId) {
    return '/support_category/statuses/$categoryStatusId/delete';
  }

  Future deleteCategoryStatus(String statusId) async {
    _notificationService.apiRunning(true);

    final response = await _client.delete(
      '${_baseUrl()}${_deleteCategoryStatusUrl(statusId)}',
      options: _client.hubOptions,
    );

    if (response.statusCode != 200) {
      _notificationService.showSnackBar(
          NotificationType.error, 'Fehler beim Löschen des Status');

      _notificationService.apiRunning(false);

      throw ApiException(
          'Failed to delete category status', response.statusCode);
    }

    final PupilData pupil = PupilData.fromJson(response.data);

    _notificationService.apiRunning(false);

    return pupil;
  }

  //- GOALS ------------------------------------------------------------

  //- post category goal

  String _postGoalUrl(int pupilId) {
    return '/support_goals/$pupilId/new';
  }

  Future<PupilData> postNewCategoryGoal(
      {required int goalCategoryId,
      required int pupilId,
      required String description,
      required String strategies}) async {
    _notificationService.apiRunning(true);

    final data = jsonEncode({
      "support_category_id": goalCategoryId,
      "created_at": DateTime.now().formatForJson(),
      "achieved": 0,
      "achieved_at": null,
      "description": description,
      "strategies": strategies
    });

    final Response response = await _client.post(
      '${_baseUrl()}${_postGoalUrl(pupilId)}',
      data: data,
      options: _client.hubOptions,
    );

    if (response.statusCode != 200) {
      _notificationService.showSnackBar(
          NotificationType.error, 'Fehler beim Hinzufügen des Ziels');

      _notificationService.apiRunning(false);

      throw ApiException('Failed to post category goal', response.statusCode);
    }

    final PupilData pupil = PupilData.fromJson(response.data);

    _notificationService.apiRunning(false);

    return pupil;
  }

  //- delete category goal

  String _deleteGoalUrl(String goalId) {
    return '/support_goals/$goalId/delete';
  }

  Future deleteGoal(String goalId) async {
    _notificationService.apiRunning(true);

    final Response response = await _client.delete(
      '${_baseUrl()}${_deleteGoalUrl(goalId)}',
      options: _client.hubOptions,
    );

    if (response.statusCode != 200) {
      _notificationService.showSnackBar(
          NotificationType.error, 'Fehler beim Löschen des Ziels');

      _notificationService.apiRunning(false);

      throw ApiException('Failed to delete category goal', response.statusCode);
    }

    final PupilData pupil = PupilData.fromJson(response.data);

    _notificationService.apiRunning(false);

    return pupil;
  }

  //- NOT IMPLEMENTED ------------------------------------------------------

  String patchgoal(String goalId) {
    return '/support_goals/$goalId';
  }

  String _postGoalCheck(int goalId) {
    return '/support_goals/$goalId/check/new';
  }

  Future<PupilData> postGoalCheck(int goalId) async {
    _notificationService.apiRunning(true);

    final data = jsonEncode({
      "created_at": DateTime.now().formatForJson(),
      "checked": false,
      "checked_at": null,
    });

    final Response response = await _client.post(
      '${_baseUrl()}${_postGoalCheck(goalId)}',
      data: data,
      options: _client.hubOptions,
    );

    if (response.statusCode != 200) {
      _notificationService.showSnackBar(
          NotificationType.error, 'Fehler beim Hinzufügen des Checks');

      _notificationService.apiRunning(false);

      throw ApiException('Failed to post goal check', response.statusCode);
    }

    final PupilData pupil = PupilData.fromJson(response.data);

    _notificationService.apiRunning(false);

    return pupil;
  }

  String patchGoalCheck(int goalId, String checkId) {
    return '/support_goals/$goalId/check/$checkId';
  }
}
