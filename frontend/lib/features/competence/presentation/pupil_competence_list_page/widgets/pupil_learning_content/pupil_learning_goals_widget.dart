import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/features/competence/domain/models/competence_goal.dart';
import 'package:schuldaten_hub/features/competence/presentation/pupil_competence_list_page/widgets/pupil_competence_goals/competence_goal_card.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_proxy.dart';

class PupilLearningGoals extends StatelessWidget {
  final PupilProxy pupil;
  const PupilLearningGoals({required this.pupil, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        pupil.competenceGoals!.isNotEmpty
            ? const Gap(15)
            : const SizedBox.shrink(),
        pupil.competenceGoals!.isNotEmpty
            ? ListView.builder(
                padding: const EdgeInsets.all(0),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pupil.competenceGoals!.length,
                itemBuilder: (context, int index) {
                  List<CompetenceGoal> pupilGoals = pupil.competenceGoals!;
                  return CompetenceGoalCard(
                    pupil: pupil,
                    pupilGoal: pupilGoals[index],
                  );
                })
            : const SizedBox.shrink(),
      ],
    );
  }
}
