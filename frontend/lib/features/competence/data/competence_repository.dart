import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:schuldaten_hub/common/domain/models/enums.dart';
import 'package:schuldaten_hub/common/services/api/api_client.dart';
import 'package:schuldaten_hub/common/services/api/api_settings.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_service.dart';
import 'package:schuldaten_hub/features/competence/domain/models/competence.dart';

class CompetenceRepository {
  final ApiClient _client = locator<ApiClient>();

  final notificationService = locator<NotificationService>();

  //- fetch list of competences

  static const String _fetchCompetencesUrl = '/competences/all/flat';

  Future<List<Competence>> fetchCompetences() async {
    notificationService.apiRunning(true);

    final response = await _client.get(_fetchCompetencesUrl);

    if (response.statusCode != 200) {
      notificationService.showSnackBar(
          NotificationType.error, 'Failed to fetch competences');

      notificationService.apiRunning(false);

      throw ApiException('Failed to fetch competences', response.statusCode);
    }

    final List<Competence> competences =
        (response.data as List).map((e) => Competence.fromJson(e)).toList();

    notificationService.apiRunning(false);

    return competences;
  }

  //- post new competence

  static const String _postNewCompetenceUrl = '/competences/new';

  Future<Competence> postNewCompetence(
      {int? parentCompetence,
      required String competenceName,
      String? competenceLevel,
      String? indicators}) async {
    notificationService.apiRunning(true);

    final data = jsonEncode({
      "parent_competence": parentCompetence,
      "competence_name": competenceName,
      "competence_level": competenceLevel == '' ? null : competenceLevel,
      "indicators": indicators == '' ? null : indicators
    });

    final Response response =
        await _client.post(_postNewCompetenceUrl, data: data);

    if (response.statusCode != 200) {
      notificationService.showSnackBar(
          NotificationType.error, 'Failed to post a competence');

      notificationService.apiRunning(false);

      throw ApiException('Failed to post a competence', response.statusCode);
    }

    final Competence newCompetence = Competence.fromJson(response.data);

    notificationService.apiRunning(false);

    return newCompetence;
  }

  //- update competence property

  String _patchCompetenceUrl(int competenceId) {
    return '/competences/$competenceId/patch';
  }

  Future<Competence> updateCompetenceProperty(
      int competenceId,
      String competenceName,
      String? competenceLevel,
      String? indicators) async {
    notificationService.apiRunning(true);

    final data = jsonEncode({
      "competence_name": competenceName,
      "competence_level": competenceLevel,
      "indicators": indicators
    });

    final Response response =
        await _client.patch(_patchCompetenceUrl(competenceId), data: data);

    if (response.statusCode != 200) {
      notificationService.showSnackBar(
          NotificationType.error, 'Failed to patch a competence');

      notificationService.apiRunning(false);

      throw ApiException('Failed to patch a competence', response.statusCode);
    }

    final patchedCompetence = Competence.fromJson(response.data);

    notificationService.apiRunning(false);

    return patchedCompetence;
  }

  //- all endpoints below are not implemented

  String _deleteCompetence(int id) {
    return '/competences/$id/delete';
  }

  Future<bool> deleteCompetence(int id) async {
    notificationService.apiRunning(true);

    final Response response = await _client.delete(_deleteCompetence(id));

    notificationService.apiRunning(false);

    if (response.statusCode != 200) {
      notificationService.showSnackBar(
          NotificationType.error, 'Failed to delete a competence');

      throw ApiException('Failed to delete a competence', response.statusCode);
    }

    return true;
  }

  //- COMPETENCE GOALS -------------------------------------------------

  //- POST
  String postCompetenceGoal(int pupilId) {
    return '/competence_goals/new/$pupilId';
  }

  //- PATCH
  String patchCompetenceGoal(String competenceGoalId) {
    return '/competence_goals/$competenceGoalId';
  }

  //- DELETE
  String deleteCompetenceGoal(String competenceGoalId) {
    return '/competence_goals/$competenceGoalId/delete';
  }
}
