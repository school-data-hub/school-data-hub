import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/features/competence/models/competence.dart';
import 'package:schuldaten_hub/features/competence/models/competence_check.dart';
import 'package:schuldaten_hub/features/competence/services/competence_manager.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';

class CompetenceHelper {
  static CompetenceCheck? getCompetenceCheck(
      PupilProxy pupil, int competenceId) {
    if (pupil.competenceChecks!.isNotEmpty) {
      return pupil.competenceChecks!
          .firstWhereOrNull((element) => element.competenceId == competenceId);
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
      PupilProxy pupil, int competenceId) {
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
      return const SizedBox(
          width: 50, child: Icon(Icons.question_mark_rounded));
    }

    return const SizedBox(width: 40, child: Icon(Icons.question_mark_rounded));
  }
}
