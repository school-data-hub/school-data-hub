import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';
import 'package:schuldaten_hub/features/learning_support/pages/widgets/support_goal/support_goal_card.dart';

class SupportGoalsList extends StatelessWidget {
  final PupilProxy pupil;
  const SupportGoalsList({required this.pupil, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Gap(5),
        const Row(
          children: [
            Text(
              'Förderziele',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const Gap(10),
        pupil.pupilGoals!.isNotEmpty
            ? ListView.builder(
                padding: const EdgeInsets.all(0),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pupil.pupilGoals!.length,
                itemBuilder: (context, int index) {
                  return SupportGoalCard(pupil: pupil, goalIndex: index);
                })
            : const Column(
                children: [
                  Text('Noch keine Förderziele festgelegt!'),
                ],
              ),
        const Gap(10),
      ],
    );
  }
}
