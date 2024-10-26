import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/utils/extensions.dart';
import 'package:schuldaten_hub/features/competence/models/competence_goal.dart';
import 'package:schuldaten_hub/features/competence/services/competence_helper.dart';
import 'package:schuldaten_hub/features/competence/services/competence_manager.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';

class CompetenceGoalCard extends StatelessWidget {
  final CompetenceGoal pupilGoal;
  final PupilProxy pupil;
  const CompetenceGoalCard(
      {required this.pupilGoal, required this.pupil, super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  color: CompetenceHelper.getCompetenceColor(
                      pupilGoal.competenceId),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        locator<CompetenceManager>()
                            .getRootCompetence(pupilGoal.competenceId)
                            .competenceName,
                        style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(5),
              Row(
                children: [
                  CompetenceHelper.getCompetenceCheckSymbol(
                      pupilGoal.achieved ?? 0),
                  const Gap(10),
                  Flexible(
                    child: Text(
                      locator<CompetenceManager>()
                          .getCompetence(pupilGoal.competenceId)
                          .competenceName,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const Gap(5),
              Row(
                children: [
                  const Text('Ziel:'),
                  const Gap(10),
                  Flexible(
                    child: Text(
                      pupilGoal.description,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
              const Gap(5),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      pupilGoal.strategies,
                    ),
                  ),
                ],
              ),
              const Gap(10),
              Row(
                children: [
                  const Text('Erstellt von:'),
                  const Gap(10),
                  Text(
                    pupilGoal.createdBy,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Gap(15),
                  const Text('am'),
                  const Gap(10),
                  Text(
                    pupilGoal.createdAt.formatForUser(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
