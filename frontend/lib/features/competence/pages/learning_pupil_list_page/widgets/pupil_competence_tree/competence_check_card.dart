import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/utils/extensions.dart';
import 'package:schuldaten_hub/features/competence/models/competence_check.dart';

class CompetenceCheckCard extends StatelessWidget {
  final CompetenceCheck competenceCheck;
  const CompetenceCheckCard({required this.competenceCheck, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, right: 5),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // display the competenceCheck properties in text widgets
                  const Icon(
                    Icons.lightbulb,
                    color: Colors.black,
                    size: 24,
                  ),
                  const SizedBox(width: 5),
                  Text(competenceCheck.createdAt.formatForUser()),

                  const Gap(5),
                  Text(competenceCheck.competenceStatus.toString()),
                  const Gap(5),
                  Text(competenceCheck.comment),
                ],
              ),
              const SizedBox(height: 15),
              // PupilLearningContentList(pupil: pupil)
            ],
          ),
        ),
      ),
    );
  }
}
