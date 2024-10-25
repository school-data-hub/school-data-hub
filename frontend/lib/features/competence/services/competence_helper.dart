import 'package:flutter/material.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/features/competence/models/competence.dart';
import 'package:schuldaten_hub/features/competence/models/competence_check.dart';
import 'package:schuldaten_hub/features/competence/services/competence_manager.dart';
import 'package:schuldaten_hub/features/pupil/filters/pupil_filter_manager.dart';
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

  static Widget getCompetenceCheckSymbol(int status) {
    switch (status) {
      case 1:
        return SizedBox(width: 50, child: Image.asset('assets/growth_1-4.png'));
      case 2:
        return SizedBox(width: 50, child: Image.asset('assets/growth_2-4.png'));
      case 3:
        return SizedBox(width: 50, child: Image.asset('assets/growth_3-4.png'));
      // case 'orange':
      //   return Colors.orange;
      case 4:
        return SizedBox(width: 50, child: Image.asset('assets/growth_4-4.png'));
    }
    return const SizedBox(
        width: 50,
        child: Icon(Icons.question_mark_rounded, color: Colors.white));
  }

  static Widget getLastCompetenceCheckSymbol(
      {required PupilProxy pupil, required int competenceId}) {
    if (pupil.competenceChecks!.isNotEmpty) {
      final CompetenceCheck? competenceCheck =
          getLastCompetenceCheckOfCompetence(pupil, competenceId);

      if (competenceCheck != null) {
        getCompetenceCheckSymbol(competenceCheck.competenceStatus);
      }
      return const SizedBox(
          width: 50,
          child: Icon(
            Icons.question_mark_rounded,
            color: Colors.white,
          ));
    }

    return const SizedBox(
        width: 40, child: Icon(Icons.error, color: Colors.white));
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
    SchoolGrade schoolGrade = pupil.schoolGrade;
    if (pupil.specialNeeds != null && pupil.specialNeeds!.contains('LE')) {
      return locator<CompetenceManager>().competences.value;
    }
    if ((pupil.fiveYears != null) || pupil.schoolGrade.value == 'E3') {
      switch (pupil.schoolGrade.value) {
        case 'E1':
          schoolGrade = SchoolGrade.E1;
          break;
        case 'E2':
          schoolGrade = SchoolGrade.E1;
          break;
        case 'E3':
          schoolGrade = SchoolGrade.E2;
          break;
      }
    }
    return locator<CompetenceManager>()
        .competences
        .value
        .where((Competence competence) =>
            competence.competenceLevel!.contains(schoolGrade.value))
        .toList();
  }

  static ({int total, int checked}) competenceChecksStats(PupilProxy pupil) {
    final competences = getAllowedCompetencesForThisPupil(pupil);
    final Map<int, List<CompetenceCheck>> pupilCompetenceChecksMap =
        getCompetenceChecksMapOfPupil(pupil.internalId);
    int count = 0;
    int competencesWithCheck = 0;
    for (Competence competence in competences) {
      if (!locator<CompetenceManager>().isCompetenceWithChildren(competence)) {
        count++;
      }
      if (pupilCompetenceChecksMap.containsKey(competence.competenceId)) {
        competencesWithCheck++;
      }
    }
    return (total: count, checked: competencesWithCheck);
  }

  static List<PupilProxy> getFilteredPupilsByCompetence(
      {required Competence competence}) {
    List<PupilProxy> pupils = [];
    final filteredPupils = locator<PupilFilterManager>().filteredPupils;
    for (PupilProxy pupil in filteredPupils.value) {
      if (pupil.specialNeeds != null && pupil.specialNeeds!.contains('LE')) {
        pupils.add(pupil);
        continue;
      } else {
        final allowedCompetences = getAllowedCompetencesForThisPupil(pupil);
        if (allowedCompetences.contains(competence)) {
          pupils.add(pupil);
          continue;
        }
      }
    }
    return pupils;
  }
}
