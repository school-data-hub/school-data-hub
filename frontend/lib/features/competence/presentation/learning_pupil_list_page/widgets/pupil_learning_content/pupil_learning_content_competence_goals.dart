import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/theme/styles.dart';
import 'package:schuldaten_hub/features/competence/presentation/learning_pupil_list_page/widgets/pupil_learning_content/pupil_learning_goals_widget.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_proxy.dart';

class PupilLearningContentCompetenceGoals extends StatelessWidget {
  final PupilProxy pupil;
  const PupilLearningContentCompetenceGoals({required this.pupil, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          children: [
            Text(
              'Lernziele',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const Gap(10),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ElevatedButton(
                style: AppStyles.actionButtonStyle,
                onPressed: () async {},
                child: const Text(
                  "NEUES LERNZIEL",
                  style: AppStyles.buttonTextStyle,
                ),
              ),
            ),
          ],
        ),
        const Gap(5),
        PupilLearningGoals(pupil: pupil),
      ],
    );
  }
}
