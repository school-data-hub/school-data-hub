import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/features/competence/domain/competence_manager.dart';
import 'package:schuldaten_hub/features/competence/domain/models/competence.dart';

List<Widget> competenceTreeAncestorsNames(
    {required int competenceId, required Color categoryColor}) {
  // Create an empty list to store ancestors
  List<Widget> ancestors = [];

  // Use a recursive helper function to collect ancestors
  void collectAncestors(int currentCompetenceId) {
    final Competence currentCompetence =
        locator<CompetenceManager>().findCompetenceById(currentCompetenceId);

    // Check if parent category exists before recursion
    if (currentCompetence.parentCompetence != null) {
      collectAncestors(currentCompetence.parentCompetence!);
    }

    if (currentCompetence.competenceId ==
        locator<CompetenceManager>()
            .findRootCompetenceById(competenceId)
            .competenceId) {
      ancestors.add(
        Row(
          children: [
            const Gap(10),
            Flexible(
              child: Text(
                  locator<CompetenceManager>()
                      .findRootCompetenceById(competenceId)
                      .competenceName,
                  style: const TextStyle(
                    overflow: TextOverflow.fade,
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  )),
            ),
            const Gap(10),
          ],
        ),
      );
    }
    // Add current category name to the list after recursion
    if (currentCompetence.competenceId !=
        locator<CompetenceManager>()
            .findRootCompetenceById(competenceId)
            .competenceId) {
      if (currentCompetence.competenceId != competenceId) {
        ancestors.add(
          Row(
            children: [
              const Gap(10),
              Flexible(
                child: Text(
                  currentCompetence.competenceName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const Gap(10),
            ],
          ),
        );
      }
    }
  }

  // Start the recursion from the input category
  collectAncestors(competenceId);

  // Add the current category at the end
  final Competence currentCompetence =
      locator<CompetenceManager>().findCompetenceById(competenceId);
  ancestors.add(
    Row(
      children: [
        const Gap(10),
        Flexible(
          child: Text(
            currentCompetence.competenceName,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
        ),
        const Gap(10),
      ],
    ),
  );

  ancestors.add(const Gap(5));
  return ancestors;
}
