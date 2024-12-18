import 'package:flutter/material.dart';
import 'package:schuldaten_hub/common/theme/colors.dart';
import 'package:schuldaten_hub/common/theme/styles.dart';
import 'package:schuldaten_hub/features/competence/presentation/select_competece_page/controller/select_common_competemce_controller.dart';
import 'package:schuldaten_hub/features/competence/presentation/select_competece_page/select_common_competence_tree.dart';

class SelectCompetencePage extends StatelessWidget {
  final SelectCompetenceController controller;
  const SelectCompetencePage(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
          unselectedWidgetColor: Colors.white,
          radioTheme: RadioThemeData(
            fillColor: WidgetStateProperty.all(Colors.white),
            // overlayColor: MaterialStateProperty.all(Colors.green),
          )),
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.white,
          centerTitle: true,
          backgroundColor: AppColors.backgroundColor,
          title: const Text('Kompetenz', style: AppStyles.appBarTextStyle),
          // automaticallyImplyLeading: false,
        ),
        body: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text('Bitte eine Kompetenz auswählen!',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            )),
                      ],
                    ),
                  ),
                  ...selectCommonCompetenceTree(
                      indentation: 0,
                      controller: controller,
                      elementType: controller.widget.elementType),
                  // ...pupilSupportCategoryTree(
                  //     context: context,
                  //     pupil: controller.widget.pupil,
                  //     parentCategoryId: null,
                  //     indentation: 0,
                  //     backGroundColor: null,
                  //     controller: controller,
                  //     elementType: controller.widget.elementType),
                ]),
              ),
            ),
          ),
        ),
        floatingActionButton: controller.selectedCategoryId != null
            ? FloatingActionButton(
                backgroundColor: AppColors.backgroundColor,
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 35,
                ),
                onPressed: () {
                  Navigator.of(context).pop(controller.selectedCategoryId);
                })
            : const SizedBox.shrink(),
      ),
    );
  }
}
