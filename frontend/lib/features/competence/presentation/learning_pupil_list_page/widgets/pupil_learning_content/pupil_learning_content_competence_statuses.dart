import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/features/competence/presentation/learning_pupil_list_page/widgets/pupil_competence_checks/pupil_competence_status_tree.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_proxy.dart';

class PupilLearningContentCompetenceStatuses extends StatelessWidget {
  final PupilProxy pupil;
  const PupilLearningContentCompetenceStatuses(
      {required this.pupil, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          children: [
            Text(
              'Status Kompetenzen',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const Gap(10),
        ...buildPupilCompetenceStatusTree(
            pupil: pupil,
            parentId: null,
            indentation: 0,
            passedBackGroundColor: null,
            context: context),
        const Gap(15),
      ],
    );
  }
}
