import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/features/competence/models/competence_check.dart';
import 'package:schuldaten_hub/features/learning_support/services/learning_support_manager.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';

class CompetenceChecksBatches extends StatelessWidget {
  final PupilProxy pupil;
  const CompetenceChecksBatches({
    super.key,
    required this.pupil,
  });

  @override
  Widget build(BuildContext context) {
    List<CompetenceCheck> competenceChecks = pupil.competenceChecks!;
    List<Widget> widgetList = [];
    Map<int, int> competenceCounts = {};
    Set<int> countedCompetenceIds = {};

    // Calculate counts
    for (CompetenceCheck competenceCheck in competenceChecks) {
      if (countedCompetenceIds.contains(competenceCheck.competenceId)) {
        continue;
      }
      countedCompetenceIds.add(competenceCheck.competenceId);
      int rootCategoryId = locator<LearningSupportManager>()
          .getRootSupportCategory(competenceCheck.competenceId)
          .categoryId;
      if (competenceCounts.containsKey(rootCategoryId)) {
        competenceCounts[rootCategoryId] =
            competenceCounts[rootCategoryId]! + 1;
      } else {
        competenceCounts[rootCategoryId] = 1;
      }
    }
    // TODO: implement colors in CompetenceManger analog to this
    competenceCounts.forEach((categoryId, count) {
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
