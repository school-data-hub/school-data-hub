import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:schuldaten_hub/common/constants/enums.dart';
import 'package:schuldaten_hub/common/services/api/api.dart';
import 'package:schuldaten_hub/common/services/api/services/api_client_service.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_manager.dart';
import 'package:schuldaten_hub/common/utils/extensions.dart';
import 'package:schuldaten_hub/features/competence/models/competence.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_data.dart';

class CompetenceApiService {
  final ApiClientService _client = locator<ApiClientService>();

  final notificationManager = locator<NotificationManager>();

  //- fetch list of competences

  static const String _fetchCompetencesUrl = '/competences/all/flat';

  Future<List<Competence>> fetchCompetences() async {
    notificationManager.apiRunningValue(true);

    final response = await _client.get(_fetchCompetencesUrl);

    if (response.statusCode != 200) {
      notificationManager.showSnackBar(
          NotificationType.error, 'Failed to fetch competences');

      notificationManager.apiRunningValue(false);

      throw ApiException('Failed to fetch competences', response.statusCode);
    }

    final List<Competence> competences =
        (response.data as List).map((e) => Competence.fromJson(e)).toList();

    notificationManager.apiRunningValue(false);

    return competences;
  }

  //- post new competence

  static const String _postNewCompetenceUrl = '/competences/new';

  Future<Competence> postNewCompetence(
      {int? parentCompetence,
      required String competenceName,
      String? competenceLevel,
      String? indicators}) async {
    notificationManager.apiRunningValue(true);

    final data = jsonEncode({
      "parent_competence": parentCompetence,
      "competence_name": competenceName,
      "competence_level": competenceLevel == '' ? null : competenceLevel,
      "indicators": indicators == '' ? null : indicators
    });

    final Response response =
        await _client.post(_postNewCompetenceUrl, data: data);

    if (response.statusCode != 200) {
      notificationManager.showSnackBar(
          NotificationType.error, 'Failed to post a competence');

      notificationManager.apiRunningValue(false);

      throw ApiException('Failed to post a competence', response.statusCode);
    }

    final Competence newCompetence = Competence.fromJson(response.data);

    notificationManager.apiRunningValue(false);

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
    notificationManager.apiRunningValue(true);

    final data = jsonEncode({
      "competence_name": competenceName,
      "competence_level": competenceLevel,
      "indicators": indicators
    });

    final Response response =
        await _client.patch(_patchCompetenceUrl(competenceId), data: data);

    if (response.statusCode != 200) {
      notificationManager.showSnackBar(
          NotificationType.error, 'Failed to patch a competence');

      notificationManager.apiRunningValue(false);

      throw ApiException('Failed to patch a competence', response.statusCode);
    }

    final patchedCompetence = Competence.fromJson(response.data);

    notificationManager.apiRunningValue(false);

    return patchedCompetence;
  }

  //- all endpoints below are not implemented

  String deleteCompetence(int id) {
    return '/competences/$id/delete';
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
