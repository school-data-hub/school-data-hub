// import 'package:flutter/material.dart';
// import 'package:flutter_hooks/flutter_hooks.dart';
// import 'package:schuldaten_hub/common/constants/colors.dart';
// import 'package:schuldaten_hub/common/widgets/custom_expansion_tile/custom_expansion_tile.dart';
// import 'package:schuldaten_hub/features/competence/pages/learning_pupil_list_page/widgets/pupil_competence_tree_function.dart';
// import 'package:schuldaten_hub/features/competence/pages/learning_pupil_list_page/widgets/pupil_competence_tree/competence_tree_builder.dart';
// import 'package:schuldaten_hub/features/competence/pages/widgets/dialogues/comptence_check_widgets.dart';
// import 'package:schuldaten_hub/features/competence/services/competence_helper.dart';
// import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';
// import 'competence_card.dart'; // Adjust the import path as needed

// class PupilCompetenceStatusTree extends HookWidget {
//   final PupilProxy pupil;
//   final int? parentId;
//   final double indentation;
//   final Color? passedBackGroundColor;
//   final BuildContext context;

//   const PupilCompetenceStatusTree({
//     super.key,
//     required this.pupil,
//     required this.parentId,
//     required this.indentation,
//     this.passedBackGroundColor,
//     required this.context,
//   });

//   @override
//   Widget build(BuildContext context) {
//     List<Widget> competenceWidgets = [];
//     Color competenceBackgroundColor = backgroundColor;
//     final competences =
//         CompetenceHelper.getAllowedCompetencesForThisPupil(pupil);
//     for (var competence in competences) {
//       if (passedBackGroundColor == null) {
//         competenceBackgroundColor =
//             CompetenceHelper.getCompetenceColor(competence.competenceId);
//       } else {
//         competenceBackgroundColor = passedBackGroundColor!;
//       }

//       if (competence.parentCompetence == parentId) {
//         final children = buildPupilCompetenceTree(
//           pupil: pupil,
//           parentId: competence.competenceId,
//           indentation: indentation + 15,
//           passedBackGroundColor: competenceBackgroundColor,
//           context: context,
//         );

//         competenceWidgets.add(
//           Padding(
//             padding: EdgeInsets.only(top: 10, left: indentation),
//             child: children.isNotEmpty
//                 ? CompetenceCard(
//                     backgroundColor: competenceBackgroundColor,
//                     title: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               Text('test'),
//                               Padding(
//                                 padding: const EdgeInsets.all(5.0),
//                                 child: InkWell(
//                                   onLongPress: () {
//                                     // Navigator.of(context)
//                                     //     .push(MaterialPageRoute(
//                                     //   builder: (ctx) => NewCategoryGoalView(
//                                     //     pupilId: pupil.internalId,
//                                     //     goalCategoryId:
//                                     //         competence.competenceId,
//                                     //   ),
//                                     // ));
//                                   },
//                                   child: getLastCompetenceCheckSymbol(
//                                       pupil, competence.competenceId),
//                                 ),
//                               ),
//                               Flexible(
//                                 child: Text(
//                                   competence.competenceName,
//                                   maxLines: 3,
//                                   style: const TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           if (pupil.competenceChecks != null &&
//                               pupil.competenceChecks!.isNotEmpty)
//                             const CustomExpansionTile(
//                               title: Text('Competence Details'),
//                               children: [
//                                 // Add your custom widgets here
//                                 Text('Details about the competence checks'),
//                               ],
//                             ),
//                         ],
//                       ),
//                     ),
//                     children: children,
//                   )
//                 : Container(),
//           ),
//         );
//       }
//     }

//     return Column(children: competenceWidgets);
//   }
// }
