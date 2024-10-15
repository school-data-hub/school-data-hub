import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/session_manager.dart';
import 'package:schuldaten_hub/features/competence/models/competence.dart';
import 'package:schuldaten_hub/features/competence/pages/widgets/competence_status_dialog.dart';
import 'package:schuldaten_hub/features/competence/pages/widgets/dialogues/comptence_check_widgets.dart';
import 'package:schuldaten_hub/features/competence/services/competence_helper.dart';
import 'package:schuldaten_hub/features/competence/services/competence_manager.dart';
import 'package:schuldaten_hub/features/learning_support/widgets/support_category_widgets/support_category_status_comment.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';

import 'package:schuldaten_hub/features/learning_support/pages/new_support_category_goal_page/controller/new_support_category_goal_controller.dart';

List<Widget> buildPupilCompetenceTree(PupilProxy pupil, int? parentId,
    double indentation, Color? passedBackGroundColor, BuildContext context) {
  List<Widget> competenceWidgets = [];
  final competenceLocator = locator<CompetenceManager>();
  List<Competence> competences = competenceLocator.competences.value
      .where((Competence competence) =>
          competence.competenceLevel!.contains(pupil.schoolyear))
      .toList();
  Color competenceBackgroundColor = backgroundColor;
  for (var competence in competences) {
    if (passedBackGroundColor == null) {
      competenceBackgroundColor =
          CompetenceHelper.getCompetenceColor(competence.competenceId);
    } else {
      competenceBackgroundColor = passedBackGroundColor;
    }

    if (competence.parentCompetence == parentId) {
      final children = buildPupilCompetenceTree(pupil, competence.competenceId,
          indentation + 15, competenceBackgroundColor, context);

      competenceWidgets.add(
        Padding(
          padding: EdgeInsets.only(top: 10, left: indentation),
          child: children.isNotEmpty
              ? Wrap(
                  children: [
                    Card(
                      color: competenceBackgroundColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      clipBehavior: Clip.antiAlias,
                      margin: EdgeInsets.zero,
                      child: ExpansionTile(
                        iconColor: Colors.white,
                        collapsedTextColor: Colors.white,
                        collapsedIconColor: Colors.white,
                        textColor: Colors.white,
                        maintainState: true,
                        backgroundColor: competenceBackgroundColor,
                        title: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: InkWell(
                                      onLongPress: () {
                                        // Navigator.of(context)
                                        //     .push(MaterialPageRoute(
                                        //   builder: (ctx) => NewCategoryGoalView(
                                        //     pupilId: pupil.internalId,
                                        //     goalCategoryId:
                                        //         competence.competenceId,
                                        //   ),
                                        // ));
                                      },
                                      child: getLastCompetenceCheckSymbol(
                                          pupil, competence.competenceId),
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      competence.competenceName,
                                      maxLines: 3,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              // locator<GoalManager>().getCategoryStatusComment(
                              //     pupil, competence.competenceId),
                            ],
                          ),
                        ),
                        collapsedBackgroundColor: competenceBackgroundColor,
                        children: children,
                      ),
                    ),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: InkWell(
                              // onTap: () => competenceStatusDialog(
                              //     pupil, competence.competenceId, context),
                              onLongPress: () {
                                if (locator<SessionManager>().isAdmin.value ==
                                    true) {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (ctx) => NewSupportCategoryGoal(
                                      appBarTitle: 'Neues Förderziel',
                                      pupilId: pupil.internalId,
                                      goalCategoryId: competence.competenceId,
                                      elementType: 'goal',
                                    ),
                                  ));
                                }
                              },
                              child:
                                  CompetenceHelper.getLastCompetenceCheckSymbol(
                                      pupil, competence.competenceId),
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
                ),
        ),
      );
    }
  }

  return competenceWidgets;
}
