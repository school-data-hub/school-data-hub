import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/constants/styles.dart';
import 'package:schuldaten_hub/features/competence/pages/learning_pupil_list_page/widgets/pupil_learning_content/pupil_learning_goals_widget.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';

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
                style: actionButtonStyle,
                onPressed: () async {},
                child: const Text(
                  "NEUES LERNZIEL",
                  style: buttonTextStyle,
                ),
              ),
            ),
          ],
        ),
        PupilLearningGoals(pupil: pupil),
      ],
    );
  }
}
