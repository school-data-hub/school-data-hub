import 'package:flutter/material.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/features/competence/models/competence.dart';
import 'package:schuldaten_hub/features/competence/models/competence_check.dart';
import 'package:schuldaten_hub/features/competence/services/competence_manager.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';
import 'package:schuldaten_hub/features/pupil/services/pupil_manager.dart';

class CompetenceHelper {
  static CompetenceCheck? getLastCompetenceCheckOfCompetence(
      PupilProxy pupil, int competenceId) {
    if (pupil.competenceChecks != null && pupil.competenceChecks!.isNotEmpty) {
      final filteredChecks = pupil.competenceChecks!
          .where((element) => element.competenceId == competenceId)
          .toList();
      if (filteredChecks.isNotEmpty) {
        return filteredChecks
            .reduce((a, b) => a.createdAt.isAfter(b.createdAt) ? a : b);
      }
    }
    return null;
  }

  static Color getCompetenceColor(int categoryId) {
    final Competence rootCategory =
        locator<CompetenceManager>().getRootCompetence(categoryId);
    return getRootCompetenceColor(rootCategory);
  }

  static Color getRootCompetenceColor(Competence competence) {
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

  static Widget getLastCompetenceCheckSymbol(
      {required PupilProxy pupil, required int competenceId}) {
    if (pupil.competenceChecks!.isNotEmpty) {
      final CompetenceCheck? competenceCheck =
          getLastCompetenceCheckOfCompetence(pupil, competenceId);

      if (competenceCheck != null) {
        switch (competenceCheck.competenceStatus) {
          case 1:
            return SizedBox(
                width: 50, child: Image.asset('assets/growth_1-4.png'));
          case 2:
            return SizedBox(
                width: 50, child: Image.asset('assets/growth_2-4.png'));
          case 3:
            return SizedBox(
                width: 50, child: Image.asset('assets/growth_3-4.png'));
          // case 'orange':
          //   return Colors.orange;
          case 4:
            return SizedBox(
                width: 50, child: Image.asset('assets/growth_4-4.png'));
        }
      }
      return const SizedBox(
          width: 50, child: Icon(Icons.question_mark_rounded));
    }

    return const SizedBox(width: 40, child: Icon(Icons.question_mark_rounded));
  }

  static Map<int, List<CompetenceCheck>> getCompetenceChecksMapOfPupil(
      int pupilId) {
    final Map<int, List<CompetenceCheck>> competenceChecksMap = {};

    final PupilProxy pupil = locator<PupilManager>().findPupilById(pupilId)!;
    if (pupil.competenceChecks == null || pupil.competenceChecks!.isEmpty) {
      return {};
    }
    for (CompetenceCheck competenceCheck in pupil.competenceChecks!) {
      if (competenceChecksMap[competenceCheck.competenceId] == null) {
        competenceChecksMap[competenceCheck.competenceId] = [];
      }
      // add the competence check to the list of the competence checks of the competence
      competenceChecksMap[competenceCheck.competenceId]!.add(competenceCheck);
    }

    return competenceChecksMap;
  }

  static List<Competence> getAllowedCompetencesForThisPupil(PupilProxy pupil) {
    return locator<CompetenceManager>()
        .competences
        .value
        .where((Competence competence) =>
            competence.competenceLevel!.contains(pupil.schoolyear))
        .toList();
  }
}
