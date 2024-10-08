import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:schuldaten_hub/common/services/api/api.dart';
import 'package:schuldaten_hub/common/services/api/services/api_client_service.dart';

import 'package:schuldaten_hub/common/constants/enums.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_manager.dart';
import 'package:schuldaten_hub/common/utils/extensions.dart';
import 'package:schuldaten_hub/features/learning_support/models/support_category/support_category.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_data.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';

class LearningSupportApiService {
  final ApiClientService _client = locator<ApiClientService>();

  final notificationManager = locator<NotificationManager>();

  //- GOAL CATEGORIES --------------------------------------------------

  //- fetch goal categories
  static const String _fetchGoalCategoriesUrl = '/support_categories/all/flat';

  Future<List<SupportCategory>> fetchGoalCategories() async {
    notificationManager.apiRunningValue(true);

    final response = await _client.get(_fetchGoalCategoriesUrl);

    if (response.statusCode != 200) {
      notificationManager.showSnackBar(
          NotificationType.error, 'Fehler beim Laden der Kategorien');

      notificationManager.apiRunningValue(false);

      throw ApiException(
          'Failed to fetch goal categories', response.statusCode);
    }

    final List<SupportCategory> goalCategories = (response.data as List)
        .map((e) => SupportCategory.fromJson(e))
        .toList();

    notificationManager.apiRunningValue(false);

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
    notificationManager.apiRunningValue(true);

    final data = jsonEncode({
      "state": state,
      // "file_id": null,
      "comment": comment,
    });

    final response = await _client.post(
        _postCategoryStatusUrl(pupilInternalId, goalCategoryId),
        data: data);

    if (response.statusCode != 200) {
      notificationManager.showSnackBar(
          NotificationType.error, 'Fehler beim Posten des Status');

      notificationManager.apiRunningValue(false);

      throw ApiException('Failed to post category status', response.statusCode);
    }
    final PupilData pupil = PupilData.fromJson(response.data);

    notificationManager.showSnackBar(
        NotificationType.success, 'Status erfolgreich gepostet');
    notificationManager.apiRunningValue(false);

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
    notificationManager.apiRunningValue(true);

    final data = jsonEncode({
      if (state != null) "state": state,
      if (comment != null) "comment": comment,
      if (createdBy != null) "created_by": createdBy,
      if (createdAt != null) "created_at": createdAt
    });

    final response =
        await _client.patch(_patchCategoryStatusUrl(statusId), data: data);

    if (response.statusCode != 200) {
      notificationManager.showSnackBar(
          NotificationType.error, 'Fehler beim Aktualisieren des Status');

      notificationManager.apiRunningValue(false);

      throw ApiException(
          'Failed to update category status', response.statusCode);
    }

    final PupilData pupil = PupilData.fromJson(response.data);

    notificationManager.apiRunningValue(false);

    return pupil;
  }

  String postFileForCategoryStatus(String categoryStatusId) {
    return '/support_category/statuses/$categoryStatusId/file';
  }

  String _deleteCategoryStatusUrl(String categoryStatusId) {
    return '/support_category/statuses/$categoryStatusId/delete';
  }

  Future deleteCategoryStatus(String statusId) async {
    notificationManager.apiRunningValue(true);

    final response = await _client.delete(_deleteCategoryStatusUrl(statusId));

    if (response.statusCode != 200) {
      notificationManager.showSnackBar(
          NotificationType.error, 'Fehler beim Löschen des Status');

      notificationManager.apiRunningValue(false);

      throw ApiException(
          'Failed to delete category status', response.statusCode);
    }

    final PupilData pupil = PupilData.fromJson(response.data);

    notificationManager.apiRunningValue(false);

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
    notificationManager.apiRunningValue(true);

    final data = jsonEncode({
      "support_category_id": goalCategoryId,
      "created_at": DateTime.now().formatForJson(),
      "achieved": 0,
      "achieved_at": null,
      "description": description,
      "strategies": strategies
    });

    final Response response =
        await _client.post(_postGoalUrl(pupilId), data: data);

    if (response.statusCode != 200) {
      notificationManager.showSnackBar(
          NotificationType.error, 'Fehler beim Hinzufügen des Ziels');

      notificationManager.apiRunningValue(false);

      throw ApiException('Failed to post category goal', response.statusCode);
    }

    final PupilData pupil = PupilData.fromJson(response.data);

    notificationManager.apiRunningValue(false);

    return pupil;
  }

  //- delete category goal

  String _deleteGoalUrl(String goalId) {
    return '/support_goals/$goalId/delete';
  }

  Future deleteGoal(String goalId) async {
    notificationManager.apiRunningValue(true);

    final Response response = await _client.delete(_deleteGoalUrl(goalId));

    if (response.statusCode != 200) {
      notificationManager.showSnackBar(
          NotificationType.error, 'Fehler beim Löschen des Ziels');

      notificationManager.apiRunningValue(false);

      throw ApiException('Failed to delete category goal', response.statusCode);
    }

    final PupilData pupil = PupilData.fromJson(response.data);

    notificationManager.apiRunningValue(false);

    return pupil;
  }

  //- NOT IMPLEMENTED ------------------------------------------------------

  String patchgoal(String goalId) {
    return '/support_goals/$goalId';
  }

  String postGoalCheck(int id) {
    return '/support_goals/$id/check/new';
  }

  String patchGoalCheck(int goalId, String checkId) {
    return '/support_goals/$goalId/check/$checkId';
  }
}
