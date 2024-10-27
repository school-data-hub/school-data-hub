// import 'package:flutter/material.dart';
// import 'package:schuldaten_hub/common/constants/colors.dart';
// import 'package:schuldaten_hub/common/constants/styles.dart';
// import 'package:schuldaten_hub/features/competence/pages/select_goal_competence_page/controller/select_goal_competence_controller.dart';
// import 'package:schuldaten_hub/features/learning_support/pages/widgets/support_category_widgets/pupil_support_category_tree.dart';

// class SelectGoalCompetencePage extends StatelessWidget {
//   final SelectGoalCompetenceController controller;
//   const SelectGoalCompetencePage(this.controller, {super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Theme(
//       data: ThemeData(
//           unselectedWidgetColor: Colors.white,
//           radioTheme: RadioThemeData(
//             fillColor: WidgetStateProperty.all(Colors.white),
//             // overlayColor: MaterialStateProperty.all(Colors.green),
//           )),
//       child: Scaffold(
//         appBar: AppBar(
//           foregroundColor: Colors.white,
//           centerTitle: true,
//           backgroundColor: backgroundColor,
//           title: const Text('Förderung', style: appBarTextStyle),
//           // automaticallyImplyLeading: false,
//         ),
//         body: Center(
//           heightFactor: 1,
//           child: ConstrainedBox(
//             constraints: const BoxConstraints(maxWidth: 800),
//             child: SingleChildScrollView(
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Column(children: [
//                   const Padding(
//                     padding: EdgeInsets.all(8.0),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: [
//                         Text('Bitte eine Kategorie auswählen!',
//                             style: TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                             )),
//                       ],
//                     ),
//                   ),
//                   ...pupilSupportCategoryTree(context, controller.widget.pupil,
//                       null, 0, null, controller, controller.widget.elementType),
//                 ]),
//               ),
//             ),
//           ),
//         ),
//         floatingActionButton: controller.selectedCategoryId != null
//             ? FloatingActionButton(
//                 backgroundColor: backgroundColor,
//                 child: const Icon(
//                   Icons.check,
//                   color: Colors.white,
//                   size: 35,
//                 ),
//                 onPressed: () {
//                   Navigator.of(context).pop(controller.selectedCategoryId);
//                 })
//             : const SizedBox.shrink(),
//       ),
//     );
//   }
// }
