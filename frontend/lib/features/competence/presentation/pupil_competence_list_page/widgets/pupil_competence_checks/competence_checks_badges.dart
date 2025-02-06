import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/theme/app_colors.dart';
import 'package:schuldaten_hub/features/competence/domain/competence_helper.dart';
import 'package:schuldaten_hub/features/competence/domain/competence_manager.dart';
import 'package:schuldaten_hub/features/competence/domain/models/competence_check.dart';
import 'package:schuldaten_hub/features/competence/domain/models/enums.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_proxy.dart';

String getRootCompetenceShortName(int competenceId) {
  final competence =
      locator<CompetenceManager>().findCompetenceById(competenceId);
  final type = RootCompetenceType.stringToValue[competence.competenceName];
  switch (type) {
    case RootCompetenceType.math:
      return 'MA';
    case RootCompetenceType.german:
      return 'DE';
    case RootCompetenceType.science:
      return 'SU';
    case RootCompetenceType.english:
      return 'EN';
    case RootCompetenceType.art:
      return 'KU';
    case RootCompetenceType.music:
      return 'MU';
    case RootCompetenceType.sport:
      return 'SP';
    case RootCompetenceType.religion:
      return 'RE';
    case RootCompetenceType.workBehavior:
      return 'AV';
    case RootCompetenceType.socialBehavior:
      return 'SV';
    case null:
      return competence.competenceName;
  }
}

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
    Map<int, int> rootCompetences =
        locator<CompetenceManager>().rootCompetencesMap;
    for (int competenceId in rootCompetences.keys) {
      if (rootCompetences[competenceId] == competenceId) {
        competenceCounts[competenceId] = 0;
      }
    }
    // Calculate counts
    for (CompetenceCheck competenceCheck in competenceChecks) {
      if (countedCompetenceIds.contains(competenceCheck.competenceId)) {
        continue;
      }
      countedCompetenceIds.add(competenceCheck.competenceId);
      int rootCompetenceId = locator<CompetenceManager>()
          .findRootCompetenceById(competenceCheck.competenceId)
          .competenceId;
      if (competenceCounts.containsKey(rootCompetenceId)) {
        competenceCounts[rootCompetenceId] =
            competenceCounts[rootCompetenceId]! + 1;
      } else {
        competenceCounts[rootCompetenceId] = 1;
      }
    }

    competenceCounts.forEach((competenceId, count) {
      Color competenceColor = CompetenceHelper.getCompetenceColor(competenceId);
      widgetList.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 5.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(getRootCompetenceShortName(competenceId),
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
              const Gap(2),
              Container(
                width: 21.0,
                height: 21.0,
                decoration: BoxDecoration(
                  color: competenceColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                        color: AppColors.bestContrastCompetenceFontColor(
                            competenceColor),
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      widgetList.add(
        const Gap(5),
      );
    });
    return Wrap(
      spacing: 5,
      direction: Axis.horizontal,
      alignment: WrapAlignment.end,
      children: [...widgetList],
    );
  }
}
