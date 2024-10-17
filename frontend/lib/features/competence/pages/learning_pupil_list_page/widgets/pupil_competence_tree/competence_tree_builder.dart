// import 'package:flutter/material.dart';
// import 'package:schuldaten_hub/common/constants/colors.dart';
// import 'package:schuldaten_hub/common/widgets/custom_expansion_tile.dart';
// import 'package:schuldaten_hub/features/competence/pages/widgets/dialogues/comptence_check_widgets.dart';
// import 'package:schuldaten_hub/features/competence/services/competence_helper.dart';
// import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';
// import 'competence_card.dart'; // Adjust the import path as needed

// List<Widget> buildPupilCompetenceTree(
//   PupilProxy pupil,
//   int parentId,
//   double indentation,
//   Color? passedBackGroundColor,
//   BuildContext context,
// ) {
//   List<Widget> competenceWidgets = [];
//   Color competenceBackgroundColor = backgroundColor;
//   final competences = CompetenceHelper.getAllowedCompetencesForThisPupil(pupil);
//   final competenceMap =
//       CompetenceHelper.getCompetenceChecksMapOfPupil(pupil.internalId);
//   for (var competence in competences) {
//     if (passedBackGroundColor == null) {
//       competenceBackgroundColor =
//           CompetenceHelper.getCompetenceColor(competence.competenceId);
//     } else {
//       competenceBackgroundColor = passedBackGroundColor;
//     }

//     if (competence.parentCompetence == parentId) {
//       final children = buildPupilCompetenceTree(
//         pupil,
//         competence.competenceId,
//         indentation + 15,
//         competenceBackgroundColor,
//         context,
//       );

//       competenceWidgets.add(
//         Padding(
//           padding: EdgeInsets.only(top: 10, left: indentation),
//           child: children.isNotEmpty
//               ? CompetenceCard(
//                   backgroundColor: competenceBackgroundColor,
//                   title: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.all(5.0),
//                               child: InkWell(
//                                 onLongPress: () {
//                                   // Navigator.of(context)
//                                   //     .push(MaterialPageRoute(
//                                   //   builder: (ctx) => NewCategoryGoalView(
//                                   //     pupilId: pupil.internalId,
//                                   //     goalCategoryId:
//                                   //         competence.competenceId,
//                                   //   ),
//                                   // ));
//                                 },
//                                 child: getLastCompetenceCheckSymbol(
//                                     pupil, competence.competenceId),
//                               ),
//                             ),
//                             Flexible(
//                               child: Text(
//                                 competence.competenceName,
//                                 maxLines: 3,
//                                 style: const TextStyle(
//                                     fontSize: 16, fontWeight: FontWeight.bold),
//                               ),
//                             ),
//                           ],
//                         ),
//                         if (competenceMap.containsKey(competence.competenceId))
//                           CustomExpansionTile(
//                             title: const Text('Competence Details'),
//                             children: [
//                               // Add your custom widgets here
//                               Text(competenceMap[competence.competenceId]!
//                                   .competenceStatus
//                                   .toString()),
//                             ],
//                           ),
//                       ],
//                     ),
//                   ),
//                   children: children,
//                 )
//               : Container(),
//         ),
//       );
//     }
//   }

//   return competenceWidgets;
// }
