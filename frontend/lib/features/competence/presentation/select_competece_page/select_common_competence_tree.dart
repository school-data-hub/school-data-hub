import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/features/competence/domain/competence_helper.dart';
import 'package:schuldaten_hub/features/competence/domain/competence_manager.dart';
import 'package:schuldaten_hub/features/competence/domain/models/competence.dart';
import 'package:schuldaten_hub/features/competence/presentation/select_competece_page/controller/select_common_competemce_controller.dart';

List<Widget> selectCommonCompetenceTree({
  //required BuildContext context,
  int? parentCompetenceId,
  required double indentation,
  Color? backGroundColor,
  required SelectCompetenceController controller,
  required String elementType,
}) {
  List<Widget> competenceWidgets = [];
  final competenceLocator = locator<CompetenceManager>();
  List<Competence> competences = competenceLocator.competences.value;
  Color competenceBackgroundColor;

  for (Competence competence in competences) {
    if (backGroundColor == null) {
      competenceBackgroundColor =
          CompetenceHelper.getCompetenceColor(competence.competenceId);
    } else {
      competenceBackgroundColor = backGroundColor;
    }

    if (competence.parentCompetence == parentCompetenceId) {
      final children = selectCommonCompetenceTree(
          //  context: context,
          parentCompetenceId: competence.competenceId,
          indentation: indentation + 15,
          backGroundColor: competenceBackgroundColor,
          controller: controller,
          elementType: elementType);

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
                      clipBehavior: Clip.hardEdge,
                      margin: EdgeInsets.zero,
                      child: ExpansionTile(
                        iconColor: Colors.white,
                        collapsedTextColor: Colors.white,
                        collapsedIconColor: Colors.white,
                        textColor: Colors.white,
                        maintainState: false,
                        backgroundColor: competenceBackgroundColor,
                        title: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Flexible(
                                    fit: FlexFit.loose,
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
                            child:
                                // getCategoryStatus(
                                //             pupil, goalCategory.categoryId) ==
                                //         null
                                //     ?
                                Radio(
                              value: competence.competenceId,
                              groupValue: controller.selectedCategoryId,
                              onChanged: (value) {
                                controller.selectCcompetence(value!);
                              },
                            ),
                            // : const Row(children: [
                            //     Gap(7),
                            //     Icon(
                            //       Icons.support,
                            //       color: Colors.white,
                            //     )
                            //   ]),
                          ),
                          const Gap(5),
                          Flexible(
                            child: InkWell(
                              onTap: () => controller
                                  .selectCcompetence(competence.competenceId),
                              // onLongPress: locator<SessionManager>()
                              //         .isAdmin
                              //         .value
                              //     ? () async {
                              //         if (pupil
                              //             .supportCategoryStatuses!.isEmpty) {
                              //           return;
                              //         }
                              //         final bool? delete =
                              //             await confirmationDialog(
                              //                 context: context,
                              //                 title: 'Kategoriestatus löschen',
                              //                 message:
                              //                     'Kategoriestatus löschen?');
                              //         if (delete == true) {
                              //           final SupportCategoryStatus?
                              //               supportCategoryStatus = pupil
                              //                   .supportCategoryStatuses!
                              //                   .lastWhereOrNull((element) =>
                              //                       element.supportCategoryId ==
                              //                       supportCategory.categoryId);
                              //           await locator<LearningSupportManager>()
                              //               .deleteSupportCategoryStatus(
                              //                   supportCategoryStatus!
                              //                       .statusId);
                              //         }
                              //         return;
                              //       }
                              //     : () {},
                              child: Text(
                                competence.competenceName,
                                maxLines: 4,
                                textAlign: TextAlign.start,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        ),
      );
    }
  }

  return competenceWidgets;
}
