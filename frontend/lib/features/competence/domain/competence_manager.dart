import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:schuldaten_hub/common/domain/env_manager.dart';
import 'package:schuldaten_hub/common/domain/models/enums.dart';
import 'package:schuldaten_hub/common/services/api/api_settings.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_service.dart';
import 'package:schuldaten_hub/features/competence/data/competence_check_repository.dart';
import 'package:schuldaten_hub/features/competence/domain/competence_helper.dart';
import 'package:schuldaten_hub/features/competence/domain/filters/competence_filter_manager.dart';
import 'package:schuldaten_hub/features/competence/domain/models/competence.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_data.dart';
import 'package:schuldaten_hub/features/pupil/domain/pupil_manager.dart';

class CompetenceManager {
  final _competences = ValueNotifier<List<Competence>>([]);
  ValueListenable<List<Competence>> get competences => _competences;

  final _isRunning = ValueNotifier<bool>(false);
  ValueListenable<bool> get isRunning => _isRunning;

  Map<int, int> _rootCompetencesMap = {};

  CompetenceManager();
  Future<CompetenceManager> init() async {
    await fetchCompetences();

    return this;
  }

  final notificationService = locator<NotificationService>();

  final _competenceRepository = CompetenceRepository();

  final _competenceCheckRepository = CompetenceCheckRepository();

  void clearData() {
    _competences.value = [];
  }

  Future<void> fetchCompetences() async {
    final List<Competence> competences =
        await _competenceRepository.fetchCompetences();

    competences.sort((a, b) => a.competenceId.compareTo(b.competenceId));

    _competences.value = competences;

    _rootCompetencesMap.clear();

    _rootCompetencesMap =
        CompetenceHelper.generateRootCompetencesMap(competences);

    if (locator<EnvManager>().dependentManagersRegistered.value) {
      locator<CompetenceFilterManager>()
          .refreshFilteredCompetences(competences);
    }

    notificationService.showSnackBar(
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
        await _competenceRepository.postNewCompetence(
      parentCompetence: parentCompetence,
      competenceName: competenceName,
      competenceLevel: competenceLevel,
      indicators: indicators,
    );

    _competences.value = [..._competences.value, newCompetence];
    locator<CompetenceFilterManager>()
        .refreshFilteredCompetences(_competences.value);

    notificationService.showSnackBar(
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
        await _competenceRepository.updateCompetenceProperty(
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

  Future<void> deleteCompetence(int competenceId) async {
    final bool success =
        await _competenceRepository.deleteCompetence(competenceId);

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

  Future<void> postCompetenceCheck({
    required int pupilId,
    required int competenceId,
    required int competenceStatus,
    required String competenceComment,
    required bool isReport,
    required String? reportId,
  }) async {
    final PupilData updatedPupilData =
        await _competenceCheckRepository.postCompetenceCheck(
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
        await _competenceCheckRepository.patchCompetenceCheck(
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
    final PupilData pupilData = await _competenceCheckRepository
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
        await _competenceCheckRepository.postCompetenceCheckFile(
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
        await _competenceCheckRepository.deleteCompetenceCheckFile(fileId);

    locator<PupilManager>().updatePupilProxyWithPupilData(updatedPupilData);

    notificationService.showSnackBar(
        NotificationType.success, 'Datei vom Kompetenzcheck gelöscht');

    return;
  }

  Competence findCompetence(int competenceId) {
    final Competence competence = _competences.value
        .firstWhere((element) => element.competenceId == competenceId);

    return competence;
  }

  Competence findRootCompetence(int competenceId) {
    return findCompetence(_rootCompetencesMap[competenceId]!);
  }

  bool isCompetenceWithChildren(Competence competence) {
    return _competences.value
        .any((element) => element.parentCompetence == competence.competenceId);
  }
}
