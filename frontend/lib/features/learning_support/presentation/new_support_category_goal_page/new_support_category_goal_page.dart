import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/theme/colors.dart';
import 'package:schuldaten_hub/common/theme/styles.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/features/learning_support/presentation/new_support_category_goal_page/controller/new_support_category_goal_controller.dart';
import 'package:schuldaten_hub/features/learning_support/presentation/select_support_category_page/controller/select_support_category_controller.dart';
import 'package:schuldaten_hub/features/learning_support/presentation/widgets/dialogs/goal_examples_dialog.dart';
import 'package:schuldaten_hub/features/learning_support/presentation/widgets/support_category_parents_names.dart';
import 'package:schuldaten_hub/features/learning_support/presentation/widgets/support_category_widgets/support_category_status_dropdown.dart';
import 'package:schuldaten_hub/features/learning_support/domain/learning_support_manager.dart';
import 'package:schuldaten_hub/features/pupil/domain/pupil_manager.dart';

class NewSupportCategoryStatusPage extends StatelessWidget {
  final NewSupportCategoryStatusController controller;
  const NewSupportCategoryStatusPage(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        unselectedWidgetColor: Colors.white,
        focusColor: AppColors.backgroundColor,
      ),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          backgroundColor: AppColors.backgroundColor,
          title: Text(
            controller.widget.appBarTitle,
            style: AppStyles.appBarTextStyle,
          ),
        ),
        body: Center(
          heightFactor: 1,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        const Row(
                          children: [
                            Text('Förderkategorie',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                )),
                          ],
                        ),
                        const Gap(10),
                        controller.goalCategoryId == null ||
                                controller.goalCategoryId == 0
                            ? ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    backgroundColor: AppColors.backgroundColor,
                                    minimumSize: const Size.fromHeight(60)),
                                onPressed: () async {
                                  final int? categoryId = await Navigator.of(
                                          context)
                                      .push(MaterialPageRoute(
                                          builder: (ctx) =>
                                              SelectSupportCategory(
                                                  pupil: locator<PupilManager>()
                                                      .findPupilById(controller
                                                          .widget.pupilId)!,
                                                  elementType: controller
                                                      .widget.elementType)));
                                  if (categoryId == null) {
                                    return;
                                  }
                                  controller.setGoalCategoryId(categoryId);
                                },
                                child: const Text(
                                  'KATEGORIE AUSWÄHLEN',
                                  style: AppStyles.buttonTextStyle,
                                ),
                              )
                            : InkWell(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.0),
                                    color: locator<LearningSupportManager>()
                                        .getCategoryColor(
                                      controller.goalCategoryId!,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 5.0, bottom: 8),
                                    child: Wrap(
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        ...categoryTreeAncestorsNames(
                                          categoryId:
                                              controller.goalCategoryId!,
                                          categoryColor: Colors
                                              .white, //locator<LearningSupportManager>().getCategoryColor(controller.goalCategoryId!),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                        const Gap(10),
                        controller.goalCategoryId == null
                            ? const SizedBox.shrink()
                            : controller.goalCategoryId == 0
                                ? const SizedBox.shrink()
                                : Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          locator<LearningSupportManager>()
                                              .getSupportCategory(
                                                  controller.goalCategoryId!)
                                              .categoryName,
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: locator<
                                                    LearningSupportManager>()
                                                .getCategoryColor(
                                                    controller.goalCategoryId!),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                        const Gap(15),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                (controller.widget.appBarTitle ==
                                        'Neues Förderziel')
                                    ? 'Förderziel'
                                    : 'Status',
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                )),
                          ],
                        ),
                        const Gap(10),
                        if (controller.widget.appBarTitle ==
                            'Neues Förderziel') ...[
                          TextField(
                            minLines: 1,
                            maxLines: 3,
                            controller:
                                controller.descriptionTextFieldController,
                            decoration: AppStyles.textFieldDecoration(
                                labelText: 'Beschreibung des Zieles'),
                          ),
                          const Gap(20),
                          const Row(
                            children: [
                              Text('Strategien',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  )),
                            ],
                          ),
                          const Gap(10),
                        ],
                        TextField(
                          minLines: 4,
                          maxLines: 4,
                          controller: controller.strategiesTextField2Controller,
                          decoration: AppStyles.textFieldDecoration(
                            labelText: (controller.widget.appBarTitle ==
                                    'Neues Förderziel')
                                ? 'Hilfen für das Erreichen des Zieles'
                                : 'Beschreibung des Status',
                          ),
                        ),
                        const Gap(20),
                        if (controller.widget.appBarTitle != 'Neues Förderziel')
                          Row(
                            children: [
                              const Text(
                                'Aktueller Zustand',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const Gap(10),
                              Padding(
                                padding: const EdgeInsets.only(right: 5.0),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    itemHeight: 70,
                                    icon: const Visibility(
                                        visible: false,
                                        child: Icon(Icons.arrow_downward)),
                                    onTap: () {
                                      FocusManager.instance.primaryFocus!
                                          .unfocus();
                                    },
                                    value: controller.categoryStatusValue,
                                    items: supportCategoryStatusDropdownItems,
                                    onChanged: (newValue) {
                                      controller
                                          .setCategoryStatusValue(newValue!);
                                    },
                                  ),
                                ),
                              )
                            ],
                          ),
                        const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40)),
                        if (controller.goalCategoryId != null)
                          if (locator<LearningSupportManager>()
                              .getGoalsForSupportCategory(
                                  controller.goalCategoryId!)
                              .isNotEmpty) ...<Widget>[
                            ElevatedButton(
                              style: AppStyles.actionButtonStyle,
                              onPressed: () {
                                goalExamplesDialog(
                                    context,
                                    'Beispiele',
                                    locator<LearningSupportManager>()
                                        .getGoalsForSupportCategory(
                                            controller.goalCategoryId!));
                              },
                              child: const Text(
                                'BEISPIELE',
                                style: AppStyles.buttonTextStyle,
                              ),
                            ),
                          ],
                      ],
                    ),
                  ),
                ),
                const Gap(15),
                ElevatedButton(
                  style: AppStyles.successButtonStyle,
                  onPressed: () {
                    if (controller.widget.appBarTitle == 'Neues Förderziel') {
                      controller.postCategoryGoal();
                    } else {
                      locator<LearningSupportManager>()
                          .postSupportCategoryStatus(
                              locator<PupilManager>()
                                  .findPupilById(controller.widget.pupilId)!,
                              controller.goalCategoryId!,
                              controller.categoryStatusValue,
                              controller.strategiesTextField2Controller.text);
                    }
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'SENDEN',
                    style: AppStyles.buttonTextStyle,
                  ),
                ),
                const Gap(15),
                ElevatedButton(
                  style: AppStyles.cancelButtonStyle,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'ABBRECHEN',
                    style: AppStyles.buttonTextStyle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
