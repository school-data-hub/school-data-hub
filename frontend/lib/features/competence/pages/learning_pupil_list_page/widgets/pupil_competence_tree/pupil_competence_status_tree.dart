import 'package:flutter/material.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/features/competence/models/competence.dart';
import 'package:schuldaten_hub/features/competence/models/competence_check.dart';
import 'package:schuldaten_hub/features/competence/pages/learning_pupil_list_page/widgets/pupil_competence_tree/competence_card.dart';
import 'package:schuldaten_hub/features/competence/pages/learning_pupil_list_page/widgets/pupil_competence_tree/competence_check_card.dart';
import 'package:schuldaten_hub/features/competence/services/competence_helper.dart';
import 'package:schuldaten_hub/features/competence/services/competence_manager.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';

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
      CompetenceHelper.getCompetenceChecksMapOfPupil(pupil.internalId);

  Color competenceBackgroundColor = backgroundColor;
  for (Competence competence in competences) {
    if (passedBackGroundColor == null) {
      competenceBackgroundColor =
          CompetenceHelper.getCompetenceColor(competence.competenceId);
    } else {
      competenceBackgroundColor = passedBackGroundColor;
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
                    children: children)),
      );
    }
  }

  return competenceWidgets;
}
