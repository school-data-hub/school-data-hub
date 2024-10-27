import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/session_manager.dart';
import 'package:schuldaten_hub/common/widgets/dialogues/confirmation_dialog.dart';
import 'package:schuldaten_hub/features/learning_support/models/support_category/support_category.dart';
import 'package:schuldaten_hub/features/learning_support/models/support_category/support_category_status.dart';
import 'package:schuldaten_hub/features/learning_support/pages/select_support_category_page/controller/select_support_category_controller.dart';
import 'package:schuldaten_hub/features/learning_support/services/learning_support_manager.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';

List<Widget> pupilSupportCategoryTree({
  required BuildContext context,
  required PupilProxy pupil,
  int? parentCategoryId,
  required double indentation,
  Color? backGroundColor,
  required SelectCategoryPageController controller,
  required String elementType,
}) {
  List<Widget> supportCategoryWidgets = [];
  final supportCategoryLocator = locator<LearningSupportManager>();
  List<SupportCategory> supportCategories =
      supportCategoryLocator.goalCategories.value;
  Color categoryBackgroundColor;

  for (SupportCategory supportCategory in supportCategories) {
    if (backGroundColor == null) {
      categoryBackgroundColor = locator<LearningSupportManager>()
          .getRootSupportCategoryColor(supportCategory);
    } else {
      categoryBackgroundColor = backGroundColor;
    }

    if (supportCategory.parentCategory == parentCategoryId) {
      final children = pupilSupportCategoryTree(
          context: context,
          pupil: pupil,
          parentCategoryId: supportCategory.categoryId,
          indentation: indentation + 15,
          backGroundColor: categoryBackgroundColor,
          controller: controller,
          elementType: elementType);

      supportCategoryWidgets.add(
        Padding(
          padding: EdgeInsets.only(top: 10, left: indentation),
          child: children.isNotEmpty
              ? Wrap(
                  children: [
                    Card(
                      color: categoryBackgroundColor,
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
                        backgroundColor: categoryBackgroundColor,
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
                                      supportCategory.categoryName,
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
                        collapsedBackgroundColor: categoryBackgroundColor,
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
                              value: supportCategory.categoryId,
                              groupValue: controller.selectedCategoryId,
                              onChanged: (value) {
                                controller.selectCategory(value!);
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
                                  .selectCategory(supportCategory.categoryId),
                              onLongPress: locator<SessionManager>()
                                      .isAdmin
                                      .value
                                  ? () async {
                                      if (pupil
                                          .supportCategoryStatuses!.isEmpty) {
                                        return;
                                      }
                                      final bool? delete =
                                          await confirmationDialog(
                                              context: context,
                                              title: 'Kategoriestatus löschen',
                                              message:
                                                  'Kategoriestatus löschen?');
                                      if (delete == true) {
                                        final SupportCategoryStatus?
                                            supportCategoryStatus = pupil
                                                .supportCategoryStatuses!
                                                .lastWhereOrNull((element) =>
                                                    element.supportCategoryId ==
                                                    supportCategory.categoryId);
                                        await locator<LearningSupportManager>()
                                            .deleteSupportCategoryStatus(
                                                supportCategoryStatus!
                                                    .statusId);
                                      }
                                      return;
                                    }
                                  : () {},
                              child: Text(
                                supportCategory.categoryName,
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

  return supportCategoryWidgets;
}
