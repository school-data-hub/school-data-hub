import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/features/competence/domain/competence_helper.dart';
import 'package:schuldaten_hub/features/competence/domain/competence_manager.dart';
import 'package:schuldaten_hub/features/competence/domain/models/competence_check.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_proxy.dart';

class CompetenceChecksBadges extends StatelessWidget {
  final PupilProxy pupil;
  const CompetenceChecksBadges({
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
      int rootCompetenceId = locator<CompetenceManager>()
          .findRootCompetence(competenceCheck.competenceId)
          .competenceId;
      if (competenceCounts.containsKey(rootCompetenceId)) {
        competenceCounts[rootCompetenceId] =
            competenceCounts[rootCompetenceId]! + 1;
      } else {
        competenceCounts[rootCompetenceId] = 1;
      }
    }

    competenceCounts.forEach((competenceId, count) {
      widgetList.add(
        Container(
          width: 21.0,
          height: 21.0,
          decoration: BoxDecoration(
            color: CompetenceHelper.getRootCompetenceColor(
                locator<CompetenceManager>().findCompetence(competenceId)),
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
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [const Gap(5), ...widgetList],
    );
  }
}
