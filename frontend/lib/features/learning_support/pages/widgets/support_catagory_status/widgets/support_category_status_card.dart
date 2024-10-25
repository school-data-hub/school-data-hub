import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/constants/styles.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/features/learning_support/models/support_category/support_category_status.dart';
import 'package:schuldaten_hub/features/learning_support/pages/new_support_category_goal_page/controller/new_support_category_goal_controller.dart';
import 'package:schuldaten_hub/features/learning_support/pages/widgets/support_catagory_status/widgets/support_category_status_entry/support_category_status_entry.dart';
import 'package:schuldaten_hub/features/learning_support/pages/widgets/support_category_parents_names.dart';
import 'package:schuldaten_hub/features/learning_support/services/learning_support_helper_functions.dart';
import 'package:schuldaten_hub/features/learning_support/services/learning_support_manager.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';

class SupportCategoryStatusCard extends StatelessWidget {
  final PupilProxy pupil;
  final List<SupportCategoryStatus> statusesWithSameGoalCategory;

  const SupportCategoryStatusCard({
    required this.pupil,
    required this.statusesWithSameGoalCategory,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final int supportCategoryId =
        statusesWithSameGoalCategory[0].supportCategoryId;
    final Color supportCategoryColor =
        locator<LearningSupportManager>().getCategoryColor(supportCategoryId);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
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
                    locator<LearningSupportManager>().getRootSupportCategory(
                      supportCategoryId,
                    ),
                  ),
                ),
                child: InkWell(
                  onLongPress: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (ctx) => NewSupportCategoryGoal(
                              appBarTitle: 'Neuer Status',
                              pupilId: pupil.internalId,
                              goalCategoryId: supportCategoryId,
                              elementType: 'status',
                            )));
                  },
                  child: Column(
                    children: [
                      ...categoryTreeAncestorsNames(
                        categoryId: supportCategoryId,
                        categoryColor: supportCategoryColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Gap(10),
          ],
        ),
        const Gap(5),
        Row(
          children: [
            const Gap(10),
            Flexible(
              child: Text(
                locator<LearningSupportManager>()
                    .getSupportCategory(supportCategoryId)
                    .categoryName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: supportCategoryColor,
                ),
              ),
            ),
          ],
        ),
        const Gap(10),
        for (int i = 0;
            i < statusesWithSameGoalCategory.length;
            i++) ...<Widget>[
          SupportCategoryStatusEntry(
              pupil: pupil, status: statusesWithSameGoalCategory[i]),
        ],
        if (LearningSupportHelper.getGoalsForCategory(pupil, supportCategoryId)
            .isEmpty)
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.warning,
                color: Colors.red,
              ),
              Gap(5),
              Text(
                'Noch keine Förderziele formuliert!',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Gap(10),
            ],
          ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: ElevatedButton(
            style: actionButtonStyle,
            onPressed: () async {
              await Navigator.of(context).push(MaterialPageRoute(
                  builder: (ctx) => NewSupportCategoryGoal(
                        appBarTitle: 'Neues Förderziel',
                        pupilId: pupil.internalId,
                        goalCategoryId: supportCategoryId,
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
    );
  }
}
