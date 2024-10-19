import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:schuldaten_hub/features/competence/models/competence_check.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';

Widget getCompetenceCheckSymbol(
    {required PupilProxy pupil,
    required int competenceId,
    required String checkId}) {
  if (pupil.supportCategoryStatuses!.isNotEmpty) {
    final CompetenceCheck competenceCheck = pupil.competenceChecks!.firstWhere(
        (element) =>
            element.competenceId == competenceId && element.checkId == checkId);

    switch (competenceCheck.competenceStatus) {
      case 1:
        return SizedBox(width: 50, child: Image.asset('assets/growth_1-4.png'));
      case 4:
        return SizedBox(width: 50, child: Image.asset('assets/growth_4-4.png'));
      case 3:
        return SizedBox(width: 50, child: Image.asset('assets/growth_3-4.png'));
      case 2:
        return SizedBox(width: 50, child: Image.asset('assets/growth_2-4.png'));
    }
    return SizedBox(width: 50, child: Image.asset('assets/growth_1-4.png'));
  }

  return SizedBox(width: 50, child: Image.asset('assets/growth_1-4.png'));
}

Widget getLastCompetenceCheckSymbol(PupilProxy pupil, int competenceId) {
  if (pupil.competenceChecks!.isNotEmpty) {
    final CompetenceCheck? competenceCheck = pupil.competenceChecks!
        .lastWhereOrNull((element) => element.competenceId == competenceId);

    switch (competenceCheck?.competenceStatus) {
      case 1:
        return SizedBox(width: 50, child: Image.asset('assets/growth_1-4.png'));
      case 4:
        return SizedBox(width: 50, child: Image.asset('assets/growth_4-4.png'));
      case 3:
        return SizedBox(width: 50, child: Image.asset('assets/growth_3-4.png'));
      case 2:
        return SizedBox(width: 50, child: Image.asset('assets/growth_2-4.png'));
    }
    return const SizedBox(width: 50, child: Icon(Icons.question_mark_rounded));
  }

  return const SizedBox(
      width: 50,
      child: Icon(Icons.question_mark_rounded, color: Colors.purple));
}

Widget getCompetenceReportCheckSymbol(PupilProxy pupil, int competenceId) {
  if (pupil.competenceChecks!.isNotEmpty) {
    final CompetenceCheck? competenceCheck = pupil.competenceChecks!
        .lastWhereOrNull((element) =>
            element.competenceId == competenceId && element.isReport);

    switch (competenceCheck?.competenceStatus) {
      case 1:
        return SizedBox(width: 50, child: Image.asset('assets/growth_1-4.png'));
      case 4:
        return SizedBox(width: 50, child: Image.asset('assets/growth_4-4.png'));
      case 3:
        return SizedBox(width: 50, child: Image.asset('assets/growth_3-4.png'));
      case 2:
        return SizedBox(width: 50, child: Image.asset('assets/growth_2-4.png'));
    }
    return const SizedBox(
        width: 50,
        child: Icon(Icons.question_mark_rounded, color: Colors.white));
  }

  return const SizedBox(
      width: 50, child: Icon(Icons.question_mark_rounded, color: Colors.white));
}
