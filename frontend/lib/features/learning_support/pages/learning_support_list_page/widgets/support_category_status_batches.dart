import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/features/learning_support/models/support_category/support_category_status.dart';
import 'package:schuldaten_hub/features/learning_support/services/learning_support_manager.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';

class SupportCategoryStatusBatches extends StatelessWidget {
  final PupilProxy pupil;
  const SupportCategoryStatusBatches({
    super.key,
    required this.pupil,
  });

  @override
  Widget build(BuildContext context) {
    List<SupportCategoryStatus> supportCategoryStatuses =
        pupil.supportCategoryStatuses!;
    List<Widget> widgetList = [];
    Map<int, int> categoryCounts = {};
    Set<int> countedCategoryIds = {};

    // Calculate counts
    for (SupportCategoryStatus supportCategoryStatus
        in supportCategoryStatuses) {
      if (countedCategoryIds
          .contains(supportCategoryStatus.supportCategoryId)) {
        continue;
      }
      countedCategoryIds.add(supportCategoryStatus.supportCategoryId);
      int rootCategoryId = locator<LearningSupportManager>()
          .getRootSupportCategory(supportCategoryStatus.supportCategoryId)
          .categoryId;
      if (categoryCounts.containsKey(rootCategoryId)) {
        categoryCounts[rootCategoryId] = categoryCounts[rootCategoryId]! + 1;
      } else {
        categoryCounts[rootCategoryId] = 1;
      }
    }

    categoryCounts.forEach((categoryId, count) {
      widgetList.add(
        Container(
          width: 21.0,
          height: 21.0,
          decoration: BoxDecoration(
            color: locator<LearningSupportManager>()
                .getRootSupportCategoryColor(locator<LearningSupportManager>()
                    .getRootSupportCategory(categoryId)),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              count.toString(),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
      widgetList.add(
        const Gap(5),
      );
    });
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [...widgetList],
    );
  }
}
