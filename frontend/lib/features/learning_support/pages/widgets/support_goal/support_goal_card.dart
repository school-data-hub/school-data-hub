import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/utils/extensions.dart';
import 'package:schuldaten_hub/common/widgets/dialogues/confirmation_dialog.dart';
import 'package:schuldaten_hub/features/learning_support/pages/widgets/support_catagory_status/widgets/support_category_status_entry/support_category_status_symbol.dart';
import 'package:schuldaten_hub/features/learning_support/pages/widgets/support_goal/support_goal_card_banner.dart';
import 'package:schuldaten_hub/features/learning_support/services/learning_support_manager.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';

class SupportGoalCard extends StatelessWidget {
  final PupilProxy pupil;
  final int goalIndex;
  const SupportGoalCard(
      {required this.pupil, required this.goalIndex, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25.0),
        child: InkWell(
          onLongPress: () async {
            final bool? delete = await confirmationDialog(
                context: context,
                title: 'Förderziel löschen',
                message: 'Förderziel löschen?');
            if (delete == true) {
              await locator<LearningSupportManager>()
                  .deleteGoal(pupil.supportGoals![goalIndex].goalId);
              return;
            }
            return;
          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            color: cardInCardColor,
            child: Column(
              children: [
                const Gap(5),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 8.0, bottom: 8, left: 10, right: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: locator<LearningSupportManager>()
                          .getRootSupportCategoryColor(
                              locator<LearningSupportManager>()
                                  .getRootSupportCategory(pupil
                                      .supportGoals![goalIndex]
                                      .supportCategoryId)),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: SupportCategoryCardBanner(
                        categoryId:
                            pupil.supportGoals![goalIndex].supportCategoryId),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: getLastCategoryStatusSymbol(pupil,
                            pupil.supportGoals![goalIndex].supportCategoryId),
                      ),
                      const Gap(10),
                      Flexible(
                        child: Text(
                          locator<LearningSupportManager>()
                              .getSupportCategory(pupil
                                  .supportGoals![goalIndex].supportCategoryId)
                              .categoryName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(5),
                Row(
                  children: [
                    const Gap(15),
                    Flexible(
                      child: Text(
                        pupil.supportGoals![goalIndex].description!,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: groupColor),
                      ),
                    ),
                    const Gap(10)
                  ],
                ),
                const Gap(5),
                const Row(
                  children: [
                    Gap(15),
                    Text('Strategien:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        )),
                  ],
                ),
                const Gap(5),
                Row(
                  children: [
                    const Gap(15),
                    Flexible(
                      child: Text(
                        pupil.supportGoals![goalIndex].strategies!,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const Gap(10),
                  ],
                ),
                const Gap(5),
                Row(
                  children: [
                    const Gap(15),
                    const Text('Erstellt von:'),
                    const Gap(10),
                    Text(
                      pupil.supportGoals![goalIndex].createdBy,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Gap(15),
                    const Text('am'),
                    const Gap(10),
                    Text(
                      pupil.supportGoals![goalIndex].createdAt.formatForUser(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const Gap(10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
