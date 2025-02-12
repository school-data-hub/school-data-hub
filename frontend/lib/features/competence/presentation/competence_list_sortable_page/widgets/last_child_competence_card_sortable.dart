import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/widgets/grades_widget.dart';
import 'package:schuldaten_hub/features/competence/domain/models/competence.dart';

class LastChildCompetenceCardSortable extends StatelessWidget {
  final Competence competence;
  final Function({int? competenceId, Competence? competence})
      navigateToNewOrPatchCompetencePage;
  const LastChildCompetenceCardSortable(
      {required this.competence,
      required this.navigateToNewOrPatchCompetencePage,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  child: InkWell(
                    onTap: () => navigateToNewOrPatchCompetencePage(
                        competence: competence),
                    onLongPress: () => navigateToNewOrPatchCompetencePage(
                        competenceId: competence.competenceId),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          competence.competenceName,
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        competence.competenceLevel != null
                            ? Padding(
                                padding: const EdgeInsets.only(
                                    left: 10.0, bottom: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    GradesWidget(
                                        stringWithGrades:
                                            competence.competenceLevel!),
                                    const Gap(10),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const Gap(10),
          ],
        ),
      ),
    );
  }
}
