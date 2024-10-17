import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:schuldaten_hub/common/services/api/api.dart';
import 'package:schuldaten_hub/common/constants/enums.dart';
import 'package:schuldaten_hub/common/services/notification_manager.dart';
import 'package:schuldaten_hub/features/competence/models/competence.dart';
import 'package:schuldaten_hub/features/competence/filters/competence_filter_manager.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_data.dart';
import 'package:schuldaten_hub/features/pupil/services/pupil_manager.dart';

class CompetenceManager {
  ValueListenable<List<Competence>> get competences => _competences;
  ValueListenable<bool> get isRunning => _isRunning;

  final _competences = ValueNotifier<List<Competence>>([]);
  final _isRunning = ValueNotifier<bool>(false);

  final snackBarManager = locator<NotificationManager>();
  CompetenceManager();
  Future<CompetenceManager> init() async {
    await firstFetchCompetences();
    return this;
  }

  final notificationManager = locator<NotificationManager>();
  final apiCompetenceService = CompetenceApiService();

  void clearData() {
    _competences.value = [];
  }

  Future<void> firstFetchCompetences() async {
    final List<Competence> competences =
        await apiCompetenceService.fetchCompetences();

    _competences.value = competences;

    snackBarManager.showSnackBar(
        NotificationType.success, 'Kompetenzen geladen');

    return;
  }

  Future<void> fetchCompetences() async {
    final List<Competence> competences =
        await apiCompetenceService.fetchCompetences();

    _competences.value = competences;
    locator<CompetenceFilterManager>().refreshFilteredCompetences(competences);

    notificationManager.showSnackBar(
        NotificationType.success, 'Kompetenzen aktualisiert!');

    return;
  }

  Future<void> postNewCompetence({
    int? parentCompetence,
    required String competenceName,
    required competenceLevel,
    required indicators,
  }) async {
    final Competence newCompetence =
        await apiCompetenceService.postNewCompetence(
      parentCompetence: parentCompetence,
      competenceName: competenceName,
      competenceLevel: competenceLevel,
      indicators: indicators,
    );

    _competences.value = [..._competences.value, newCompetence];
    locator<CompetenceFilterManager>()
        .refreshFilteredCompetences(_competences.value);

    snackBarManager.showSnackBar(
        NotificationType.success, 'Kompetenz erstellt');

    return;
  }

  Future<void> updateCompetenceProperty(
    int competenceId,
    String competenceName,
    String? competenceLevel,
    String? indicators,
  ) async {
    final Competence updatedCompetence =
        await apiCompetenceService.updateCompetenceProperty(
            competenceId, competenceName, competenceLevel, indicators);

    final List<Competence> competences = List.from(_competences.value);
    final index = competences
        .indexWhere((element) => element.competenceId == competenceId);
    competences[index] = updatedCompetence;

    _competences.value = competences;
    locator<CompetenceFilterManager>()
        .refreshFilteredCompetences(_competences.value);

    notificationManager.showSnackBar(
        NotificationType.success, 'Kompetenz aktualisiert');

    return;
  }

  Future<void> postCompetenceCheck({
    required int pupilId,
    required int competenceId,
    required int competenceStatus,
    required String competenceComment,
    required bool isReport,
    required String? reportId,
  }) async {
    final PupilData updatedPupilData =
        await apiCompetenceService.postCompetenceCheck(
      pupilId: pupilId,
      competenceId: competenceId,
      competenceStatus: competenceStatus,
      comment: competenceComment,
      isReport: isReport,
      reportId: reportId,
    );
    locator<PupilManager>().updatePupilProxyWithPupilData(updatedPupilData);
    notificationManager.showSnackBar(
        NotificationType.success, 'Kompetenzcheck erstellt');

    return;
  }
  //- hier werden keine API Calls gemacht, nur die Kompetenz aus der Liste geholt

  Competence getCompetence(int competenceId) {
    final Competence competence = _competences.value
        .firstWhere((element) => element.competenceId == competenceId);
    return competence;
  }

  Competence getRootCompetence(int competenceId) {
    Competence competence = _competences.value
        .firstWhere((element) => element.competenceId == competenceId);
    if (competence.parentCompetence == null) {
      return competence;
    } else {
      return getRootCompetence(competence.parentCompetence!);
    }
  }
}
