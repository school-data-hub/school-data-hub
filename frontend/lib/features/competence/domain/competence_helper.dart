import 'package:flutter/material.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/theme/colors.dart';
import 'package:schuldaten_hub/features/competence/domain/competence_manager.dart';
import 'package:schuldaten_hub/features/competence/domain/models/competence.dart';
import 'package:schuldaten_hub/features/competence/domain/models/competence_check.dart';
import 'package:schuldaten_hub/features/pupil/domain/filters/pupil_filter_manager.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_proxy.dart';
import 'package:schuldaten_hub/features/pupil/domain/pupil_manager.dart';

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

  static Map<int, int> generateRootCompetencesMap(
      List<Competence> competences) {
    final Map<int, Competence> rootCompetencesMap = {
      for (Competence competence in competences)
        competence.competenceId: competence
    };
    Map<int, int> rootCompetencesCache = {};

    int findRootCompetence(int competenceId) {
      if (rootCompetencesCache.containsKey(competenceId)) {
        return rootCompetencesCache[competenceId]!;
      }
      final Competence competence = rootCompetencesMap[competenceId]!;
      if (competence.parentCompetence == null) {
        rootCompetencesCache[competenceId] = competenceId;
        return competenceId;
      }
      final int rootCompetenceId =
          findRootCompetence(competence.parentCompetence!);
      rootCompetencesCache[competenceId] = rootCompetenceId;
      return rootCompetenceId;
    }

    final Map<int, int> result = {};
    for (var competence in competences) {
      result[competence.competenceId] =
          findRootCompetence(competence.competenceId);
    }
    return result;
  }

  static Color getCompetenceColor(int competenceId) {
    final Competence rootCcompetence =
        locator<CompetenceManager>().findRootCompetence(competenceId);
    return getRootCompetenceColor(rootCompetence: rootCcompetence);
  }

  static Color getRootCompetenceColor({required Competence rootCompetence}) {
    if (rootCompetence.competenceName == 'Sachunterricht') {
      return AppColors.scienceColor;
    } else if (rootCompetence.competenceName == 'Englisch') {
      return AppColors.englishColor;
    } else if (rootCompetence.competenceName == 'Mathematik') {
      return AppColors.mathColor;
    } else if (rootCompetence.competenceName == 'Musik') {
      return AppColors.musicColor;
    } else if (rootCompetence.competenceName == 'Deutsch') {
      return AppColors.germanColor;
    } else if (rootCompetence.competenceName == 'Kunst') {
      return AppColors.artColor;
    } else if (rootCompetence.competenceName == 'Religion') {
      return AppColors.religionColor;
    } else if (rootCompetence.competenceName == 'Sport') {
      return AppColors.sportColor;
    } else if (rootCompetence.competenceName == 'Arbeitsverhalten') {
      return AppColors.workBehaviourColor;
    } else if (rootCompetence.competenceName == 'Sozialverhalten') {
      return AppColors.socialColor;
    }
    return const Color.fromARGB(255, 157, 36, 36);
  }

  static Widget getCompetenceCheckSymbol(
      {required int status, required double size}) {
    switch (status) {
      case 1:
        return SizedBox(
            width: size, child: Image.asset('assets/growth_1-4.png'));
      case 2:
        return SizedBox(
            width: size, child: Image.asset('assets/growth_2-4.png'));
      case 3:
        return SizedBox(
            width: size, child: Image.asset('assets/growth_3-4.png'));
      // case 'orange':
      //   return Colors.orange;
      case 4:
        return SizedBox(
            width: size, child: Image.asset('assets/growth_4-4.png'));
    }
    return SizedBox(
        width: size,
        child: const Icon(Icons.question_mark_rounded, color: Colors.white));
  }

  static Widget getLastCompetenceCheckSymbol(
      {required PupilProxy pupil,
      required int competenceId,
      required double size}) {
    if (pupil.competenceChecks!.isNotEmpty) {
      final CompetenceCheck? competenceCheck =
          getLastCompetenceCheckOfCompetence(pupil, competenceId);

      if (competenceCheck != null) {
        getCompetenceCheckSymbol(
            status: competenceCheck.competenceStatus, size: size);
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
      // order the competence checks by the date of creation latest first
      competenceChecksMap[competenceCheck.competenceId]!
          .sort((a, b) => b.createdAt.isAfter(a.createdAt) ? 1 : -1);
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
