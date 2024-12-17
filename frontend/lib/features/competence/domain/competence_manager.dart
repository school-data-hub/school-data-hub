import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:schuldaten_hub/common/domain/models/enums.dart';
import 'package:schuldaten_hub/common/services/api/api_settings.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_service.dart';
import 'package:schuldaten_hub/features/competence/domain/filters/competence_filter_manager.dart';
import 'package:schuldaten_hub/features/competence/domain/models/competence.dart';
import 'package:schuldaten_hub/features/competence/data/competence_check_repository.dart';
import 'package:schuldaten_hub/features/pupil/domain/pupil_manager.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_data.dart';

class CompetenceManager {
  ValueListenable<List<Competence>> get competences => _competences;
  ValueListenable<bool> get isRunning => _isRunning;

  final _competences = ValueNotifier<List<Competence>>([]);
  final _isRunning = ValueNotifier<bool>(false);

  final snackBarManager = locator<NotificationService>();
  CompetenceManager();
  Future<CompetenceManager> init() async {
    await firstFetchCompetences();
    return this;
  }

  final notificationService = locator<NotificationService>();

  final competenceApiService = CompetenceRepository();
  final competenceCheckApiService = CompetenceCheckRepository();

  void clearData() {
    _competences.value = [];
  }

  Future<void> firstFetchCompetences() async {
    final List<Competence> competences =
        await competenceApiService.fetchCompetences();

    _competences.value = competences;

    snackBarManager.showSnackBar(
        NotificationType.success, 'Kompetenzen geladen');

    return;
  }

  Future<void> fetchCompetences() async {
    final List<Competence> competences =
        await competenceApiService.fetchCompetences();

    _competences.value = competences;
    locator<CompetenceFilterManager>().refreshFilteredCompetences(competences);

    notificationService.showSnackBar(
        NotificationType.success, 'Kompetenzen aktualisiert!');

    return;
  }

  Future<void> deleteCompetence(int competenceId) async {
    final bool success =
        await competenceApiService.deleteCompetence(competenceId);

    if (success) {
      final List<Competence> competences = List.from(_competences.value);
      competences
          .removeWhere((element) => element.competenceId == competenceId);

      _competences.value = competences;
      locator<CompetenceFilterManager>()
          .refreshFilteredCompetences(_competences.value);

      notificationService.showSnackBar(
          NotificationType.success, 'Kompetenz gelöscht');
    } else {
      notificationService.showSnackBar(
          NotificationType.error, 'Fehler beim Löschen der Kompetenz');
    }
  }

  Future<void> postNewCompetence({
    int? parentCompetence,
    required String competenceName,
    required competenceLevel,
    required indicators,
  }) async {
    final Competence newCompetence =
        await competenceApiService.postNewCompetence(
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

  Future<void> updateCompetenceProperty({
    required int competenceId,
    required String competenceName,
    required String? competenceLevel,
    required String? indicators,
  }) async {
    final Competence updatedCompetence =
        await competenceApiService.updateCompetenceProperty(
            competenceId, competenceName, competenceLevel, indicators);

    final List<Competence> competences = List.from(_competences.value);
    final index = competences
        .indexWhere((element) => element.competenceId == competenceId);
    competences[index] = updatedCompetence;

    _competences.value = competences;
    locator<CompetenceFilterManager>()
        .refreshFilteredCompetences(_competences.value);

    notificationService.showSnackBar(
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
        await competenceCheckApiService.postCompetenceCheck(
      pupilId: pupilId,
      competenceId: competenceId,
      competenceStatus: competenceStatus,
      comment: competenceComment,
      isReport: isReport,
      reportId: reportId,
    );
    locator<PupilManager>().updatePupilProxyWithPupilData(updatedPupilData);
    notificationService.showSnackBar(
        NotificationType.success, 'Kompetenzcheck erstellt');

    return;
  }

  Future<void> updateCompetenceCheck({
    required String competenceCheckId,
    int? competenceStatus,
    String? competenceComment,
    DateTime? createdAt,
    String? createdBy,
    bool? isReport,
  }) async {
    final PupilData updatedPupilData =
        await competenceCheckApiService.patchCompetenceCheck(
      competenceCheckId: competenceCheckId,
      competenceStatus: competenceStatus,
      createdAt: createdAt,
      createdBy: createdBy,
      comment: competenceComment,
    );
    locator<PupilManager>().updatePupilProxyWithPupilData(updatedPupilData);
    notificationService.showSnackBar(
        NotificationType.success, 'Kompetenzcheck aktualisiert');

    return;
  }

  Future<void> deleteCompetenceCheck(String competenceCheckId) async {
    final PupilData pupilData = await competenceCheckApiService
        .deleteCompetenceCheck(competenceCheckId);
    notificationService.showSnackBar(
        NotificationType.success, 'Kompetenzcheck gelöscht');
    locator<PupilManager>().updatePupilProxyWithPupilData(pupilData);
    return;
  }

  Future<void> postCompetenceCheckFile({
    required String competenceCheckId,
    required File file,
  }) async {
    final PupilData updatedPupilData =
        await competenceCheckApiService.postCompetenceCheckFile(
      competenceCheckId: competenceCheckId,
      file: file,
    );
    locator<PupilManager>().updatePupilProxyWithPupilData(updatedPupilData);
    notificationService.showSnackBar(
        NotificationType.success, 'Datei zum Kompetenzcheck hinzugefügt');

    return;
  }

  Future<void> deleteCompetenceCheckFile(
      {required String competenceCheckId, required String fileId}) async {
    final PupilData updatedPupilData =
        await competenceCheckApiService.deleteCompetenceCheckFile(fileId);
    locator<PupilManager>().updatePupilProxyWithPupilData(updatedPupilData);
    notificationService.showSnackBar(
        NotificationType.success, 'Datei vom Kompetenzcheck gelöscht');

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

  bool isCompetenceWithChildren(Competence competence) {
    return _competences.value
        .any((element) => element.parentCompetence == competence.competenceId);
  }
}
