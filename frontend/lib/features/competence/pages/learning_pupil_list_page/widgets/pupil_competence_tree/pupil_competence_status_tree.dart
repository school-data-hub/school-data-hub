import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/features/competence/models/competence.dart';
import 'package:schuldaten_hub/features/competence/models/competence_check.dart';
import 'package:schuldaten_hub/features/competence/pages/learning_pupil_list_page/widgets/pupil_competence_tree/competence_card.dart';
import 'package:schuldaten_hub/features/competence/pages/learning_pupil_list_page/widgets/pupil_competence_tree/competence_check_card.dart';
import 'package:schuldaten_hub/features/competence/pages/widgets/dialogues/competence_status_dialog.dart';
import 'package:schuldaten_hub/features/competence/services/competence_helper.dart';
import 'package:schuldaten_hub/features/competence/services/competence_manager.dart';
import 'package:schuldaten_hub/features/learning_support/widgets/support_category_widgets/support_category_status_comment.dart';
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
                  pupilCompetenceChecksMap.containsKey(competence.competenceId)
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
              : !pupilCompetenceChecksMap.containsKey(pupil.internalId)
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Wrap(
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: InkWell(
                                  onTap: () => newCompetenceCheckDialog(
                                      pupil, competence.competenceId, context),
                                  onLongPress: () {},
                                  child: CompetenceHelper
                                      .getLastCompetenceCheckSymbol(
                                          pupil: pupil,
                                          competenceId:
                                              competence.competenceId),
                                ),
                              ),
                              const Gap(5),
                              Flexible(
                                child: Text(
                                  competence.competenceName,
                                  maxLines: 4,
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          getSupportCategoryStatusComment(
                              pupil, competence.competenceId),
                        ],
                      ),
                    )
                  : ExpansionTile(
                      title: Wrap(
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: InkWell(
                                  onTap: () => newCompetenceCheckDialog(
                                      pupil, competence.competenceId, context),
                                  onLongPress: () {
                                    // if (locator<SessionManager>().isAdmin.value ==
                                    //     true) {
                                    //   Navigator.of(context).push(MaterialPageRoute(
                                    //     builder: (ctx) => NewSupportCategoryGoal(
                                    //       appBarTitle: 'Neues Förderziel',
                                    //       pupilId: pupil.internalId,
                                    //       goalCategoryId: competence.competenceId,
                                    //       elementType: 'goal',
                                    //     ),
                                    //   ));
                                    // }
                                  },
                                  child: CompetenceHelper
                                      .getLastCompetenceCheckSymbol(
                                          pupil: pupil,
                                          competenceId:
                                              competence.competenceId),
                                ),
                              ),
                              const Gap(5),
                              Flexible(
                                child: Text(
                                  competence.competenceName,
                                  maxLines: 4,
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      children: [
                        for (var check
                            in pupilCompetenceChecksMap[pupil.internalId]!)
                          CompetenceCheckCard(competenceCheck: check),
                      ],
                    ),
        ),
      );
    }
  }

  return competenceWidgets;
}
