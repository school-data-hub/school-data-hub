import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:schuldaten_hub/common/services/api/api.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/constants/enums.dart';
import 'package:schuldaten_hub/common/services/notification_manager.dart';
import 'package:schuldaten_hub/features/competence/models/competence.dart';
import 'package:schuldaten_hub/features/competence/filters/competence_filter_manager.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/features/competence/models/competence_check.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';

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

  Color getCompetenceColor(int categoryId) {
    final Competence rootCategory = getRootCompetence(categoryId);
    return getRootCompetenceColor(rootCategory);
  }

  Color getRootCompetenceColor(Competence competence) {
    if (competence.competenceName == 'Sachunterricht') {
      return scienceColor;
    } else if (competence.competenceName == 'Englisch') {
      return englishColor;
    } else if (competence.competenceName == 'Mathematik') {
      return mathColor;
    } else if (competence.competenceName == 'Musik') {
      return musicColor;
    } else if (competence.competenceName == 'Deutsch') {
      return germanColor;
    } else if (competence.competenceName == 'Kunst') {
      return artColor;
    } else if (competence.competenceName == 'Religion') {
      return religionColor;
    } else if (competence.competenceName == 'Sport') {
      return sportColor;
    } else if (competence.competenceName == 'Arbeitsverhalten') {
      return workBehaviourColor;
    } else if (competence.competenceName == 'Sozialverhalten') {
      return socialColor;
    }
    return const Color.fromARGB(255, 157, 36, 36);
  }

  Widget getLastCompetenceCheckSymbol(PupilProxy pupil, int competenceId) {
    if (pupil.competenceChecks!.isNotEmpty) {
      final CompetenceCheck? competenceCheck = pupil.competenceChecks!
          .lastWhereOrNull((element) => element.competenceId == competenceId);

      if (competenceCheck != null) {
        switch (competenceCheck.competenceStatus) {
          case 0:
            return SizedBox(
                width: 50, child: Image.asset('assets/growth_1-4.png'));
          case 1:
            return SizedBox(
                width: 50, child: Image.asset('assets/growth_2-4.png'));
          case 2:
            return SizedBox(
                width: 50, child: Image.asset('assets/growth_3-4.png'));
          // case 'orange':
          //   return Colors.orange;
          case 3:
            return SizedBox(
                width: 50, child: Image.asset('assets/growth_4-4.png'));
        }
      }
      return SizedBox(width: 50, child: Image.asset('assets/growth_1-4.png'));
    }

    return SizedBox(width: 40, child: Image.asset('assets/growth_1-4.png'));
  }
}
