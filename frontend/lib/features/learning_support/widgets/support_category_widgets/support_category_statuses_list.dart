import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/constants/styles.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/utils/logger.dart';
import 'package:schuldaten_hub/common/utils/extensions.dart';
import 'package:schuldaten_hub/features/learning_support/models/support_category/support_category_status.dart';
import 'package:schuldaten_hub/features/learning_support/services/learning_support_manager.dart';
import 'package:schuldaten_hub/features/learning_support/services/learning_support_helper_functions.dart';
import 'package:schuldaten_hub/features/learning_support/pages/new_category_item_page/controller/new_category_item_controller.dart';
import 'package:schuldaten_hub/features/learning_support/widgets/support_category_widgets/category_tree_ancestors_names.dart';
import 'package:schuldaten_hub/features/learning_support/widgets/support_category_widgets/support_category_status_entry.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';

List<Widget> pupilCategoryStatusesList(PupilProxy pupil, BuildContext context) {
  if (pupil.supportCategoryStatuses != null) {
    List<Widget> statusesWidgetList = [];

    Map<int, List<SupportCategoryStatus>> statusesWithDuplicateGoalCategory =
        {};
    for (SupportCategoryStatus status in pupil.supportCategoryStatuses!) {
      if (pupil.supportCategoryStatuses!.any((element) =>
          element.supportCategoryId == status.supportCategoryId &&
          pupil.supportCategoryStatuses!.indexOf(element) !=
              pupil.supportCategoryStatuses!.indexOf(status))) {
        //- This one is duplicate. Adding a key / widget in the map
        if (!statusesWithDuplicateGoalCategory
            .containsKey(status.supportCategoryId)) {
          statusesWithDuplicateGoalCategory[(status.supportCategoryId)] =
              List<SupportCategoryStatus>.empty(growable: true);
          statusesWithDuplicateGoalCategory[(status.supportCategoryId)]!
              .add(status);
        } else {
          statusesWithDuplicateGoalCategory[(status.supportCategoryId)]!
              .add(status);
        }
        logger.i(
            'Adding status vom ${status.createdAt.formatForUser()} erstellt von ${status.createdBy}');
      } else {
        //- GECHECKT
        //- This one is returning a unique status for this category
        statusesWidgetList.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: BorderSide(
                    color: pupil.supportCategoryStatuses!.any((element) =>
                            element.supportCategoryId ==
                            status.supportCategoryId)
                        ? Colors.green
                        : accentColor,
                    width: 2,
                  )),
              child: Column(
                children: [
                  const Gap(10),
                  Row(
                    children: [
                      const Gap(10),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            color: locator<LearningSupportManager>()
                                .getCategoryColor(status.supportCategoryId),
                          ),
                          child: InkWell(
                            onLongPress: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (ctx) => NewCategoryItem(
                                        appBarTitle: 'Neuer Förderbereich',
                                        pupilId: pupil.internalId,
                                        goalCategoryId:
                                            status.supportCategoryId,
                                        elementType: 'status',
                                      )));
                            },
                            child: Column(children: [
                              const Gap(5),
                              ...categoryTreeAncestorsNames(
                                status.supportCategoryId,
                              ),
                            ]),
                          ),
                        ),
                      ),
                      const Gap(10),
                    ],
                  ),
                  Row(
                    children: [
                      const Gap(15),
                      Flexible(
                        child: Text(
                          locator<LearningSupportManager>()
                              .getSupportCategory(status.supportCategoryId)
                              .categoryName,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: locator<LearningSupportManager>()
                                  .getCategoryColor(status.supportCategoryId)),
                        ),
                      ),
                    ],
                  ),
                  const Gap(10),
                  SupportCategoryStatusEntry(
                    pupil: pupil,
                    status: status,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ElevatedButton(
                      style: actionButtonStyle,
                      onPressed: () async {
                        await Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) => NewCategoryItem(
                                  appBarTitle: 'Neues Förderziel',
                                  pupilId: pupil.internalId,
                                  goalCategoryId: status.supportCategoryId,
                                  elementType: 'goal',
                                )));
                      },
                      child: const Text(
                        "NEUES FÖRDERZIEL",
                        style: TextStyle(
                            fontSize: 17.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }
    //- Now let's build the statuses with multiple entries for a category
    if (statusesWithDuplicateGoalCategory.isNotEmpty) {
      for (int key in statusesWithDuplicateGoalCategory.keys) {
        logger.w('Duplicate status, setting a key: $key');
        List<SupportCategoryStatus> mappedStatusesWithSameGoalCategory = [];

        mappedStatusesWithSameGoalCategory =
            statusesWithDuplicateGoalCategory[key]!;

        statusesWidgetList.add(
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: BorderSide(
                  color: pupil.supportCategoryStatuses!
                          .any((element) => element.supportCategoryId == key)
                      ? Colors.green
                      : accentColor,
                  width: 2,
                )),
            child: Column(children: [
              const Gap(10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Gap(10),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: locator<LearningSupportManager>()
                            .getRootSupportCategoryColor(
                          locator<LearningSupportManager>()
                              .getRootSupportCategory(
                            key,
                          ),
                        ),
                      ),
                      child: InkWell(
                        onLongPress: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (ctx) => NewCategoryItem(
                                    appBarTitle: 'Neuer Förderbereich',
                                    pupilId: pupil.internalId,
                                    goalCategoryId: key,
                                    elementType: 'status',
                                  )));
                        },
                        child: Column(
                          children: [
                            ...categoryTreeAncestorsNames(
                              key,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Gap(10),
                ],
              ),
              Row(
                children: [
                  const Gap(10),
                  Flexible(
                    child: Text(
                      locator<LearningSupportManager>()
                          .getSupportCategory(key)
                          .categoryName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: locator<LearningSupportManager>()
                            .getCategoryColor(key),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 20.0,
                        height: 20.0,
                        decoration: const BoxDecoration(
                          color: interactiveColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            LearningSupportHelper.getGoalsForCategory(
                                    pupil, key)
                                .length
                                .toString(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(10),
                ],
              ),
              for (int i = 0;
                  i < mappedStatusesWithSameGoalCategory.length;
                  i++) ...<Widget>[
                SupportCategoryStatusEntry(
                    pupil: pupil,
                    status: mappedStatusesWithSameGoalCategory[i]),
              ],
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ElevatedButton(
                  style: actionButtonStyle,
                  onPressed: () async {
                    await Navigator.of(context).push(MaterialPageRoute(
                        builder: (ctx) => NewCategoryItem(
                              appBarTitle: 'Neues Förderziel',
                              pupilId: pupil.internalId,
                              goalCategoryId: key,
                              elementType: 'goal',
                            )));
                  },
                  child: const Text(
                    "NEUES FÖRDERZIEL",
                    style: TextStyle(
                        fontSize: 17.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ]),
          ),
        );
      }
    }
    return statusesWidgetList;
  }
  return [];
}
