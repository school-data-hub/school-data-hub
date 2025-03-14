import 'package:flutter/material.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/theme/app_colors.dart';
import 'package:schuldaten_hub/features/competence/domain/competence_helper.dart';
import 'package:schuldaten_hub/features/competence/domain/competence_manager.dart';
import 'package:schuldaten_hub/features/competence/domain/models/competence.dart';
import 'package:schuldaten_hub/features/competence/domain/models/competence_check.dart';
import 'package:schuldaten_hub/features/competence/presentation/pupil_competence_list_page/widgets/pupil_competence_checks/competence_card.dart';
import 'package:schuldaten_hub/features/competence/presentation/pupil_competence_list_page/widgets/pupil_competence_checks/competence_check_card.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_proxy.dart';

List<Widget> buildPupilCompetenceStatusTree(
    {required PupilProxy pupil,
    int? parentId,
    required double indentation,
    required Color? passedBackGroundColor,
    required BuildContext context}) {
  // This is the list of widgets that will be returned
  List<Widget> competenceWidgets = [];
  // Get all competences that are allowed for this pupil
  final competences = CompetenceHelper.getAllowedCompetencesForThisPupil(pupil);
  // Get the competence checks of the pupil as a map
  final Map<int, List<CompetenceCheck>> pupilCompetenceChecksMap =
      CompetenceHelper.getCompetenceChecksMappedToCompetenceIdsForThisPupil(
          pupil.internalId);

  Color competenceBackgroundColor = AppColors.backgroundColor;
  for (Competence competence in competences) {
    if (passedBackGroundColor == null) {
      competenceBackgroundColor =
          CompetenceHelper.getCompetenceColor(competence.competenceId);
    } else {
      competenceBackgroundColor = passedBackGroundColor;
    }
    double? averageCompetenceStatus;
    if (pupilCompetenceChecksMap.containsKey(competence.competenceId)) {
      final filteredChecks = pupilCompetenceChecksMap[competence.competenceId]!
          .where((check) => check.competenceStatus != 0)
          .toList();

      if (filteredChecks.isNotEmpty) {
        final totalStatus = filteredChecks
            .map((check) => check.competenceStatus)
            .reduce((a, b) => a + b);
        averageCompetenceStatus = totalStatus / filteredChecks.length;
      }
    }

    if (competence.parentCompetence == parentId) {
      final isReport =
          !locator<CompetenceManager>().isCompetenceWithChildren(competence);
      final children = buildPupilCompetenceStatusTree(
          pupil: pupil,
          parentId: competence.competenceId,
          indentation: indentation,
          passedBackGroundColor: competenceBackgroundColor,
          context: context);

      competenceWidgets.add(
        Padding(
            padding: EdgeInsets.only(left: indentation),
            child: children.isNotEmpty ||
                    pupilCompetenceChecksMap
                        .containsKey(competence.competenceId)
                ? Wrap(
                    children: [
                      CompetenceCard(
                        backgroundColor: competenceBackgroundColor,
                        competence: competence,
                        pupil: pupil,
                        isReport: isReport,
                        competenceChecks: pupilCompetenceChecksMap
                                .containsKey(competence.competenceId)
                            ? [
                                ...pupilCompetenceChecksMap[
                                        competence.competenceId]!
                                    .map((check) {
                                  return CompetenceCheckCard(
                                      competenceCheck: check);
                                })
                              ]
                            : [],
                        checksAverageValue: averageCompetenceStatus,
                        children: children,
                      ),
                    ],
                  )
                : CompetenceCard(
                    backgroundColor: competenceBackgroundColor,
                    isReport: isReport,
                    competence: competence,
                    pupil: pupil,
                    competenceChecks: const [],
                    checksAverageValue: averageCompetenceStatus,
                    children: children)),
      );
    }
  }

  return competenceWidgets;
}
