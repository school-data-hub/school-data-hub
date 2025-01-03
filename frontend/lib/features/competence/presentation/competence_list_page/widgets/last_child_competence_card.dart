import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/widgets/custom_expansion_tile/custom_expansion_tile_content.dart';
import 'package:schuldaten_hub/common/widgets/custom_expansion_tile/custom_expansion_tile_switch.dart';
import 'package:schuldaten_hub/common/widgets/custom_expansion_tile/custom_expasion_tile_hook.dart';
import 'package:schuldaten_hub/features/competence/domain/models/competence.dart';
import 'package:schuldaten_hub/features/competence/presentation/competence_list_page/widgets/competence_filtered_pupils.dart';

class LastChildCompetenceCard extends HookWidget {
  final Competence competence;
  final Function({int? competenceId, Competence? competence})
      navigateToNewOrPatchCompetencePage;
  const LastChildCompetenceCard(
      {required this.competence,
      required this.navigateToNewOrPatchCompetencePage,
      super.key});

  @override
  Widget build(BuildContext context) {
    final pupilListController = useCustomExpansionTileController();
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
                    // onTap: () => navigateToNewOrPatchCompetencePage(
                    //     competence: competence),
                    onLongPress: () => navigateToNewOrPatchCompetencePage(
                        competenceId: competence.competenceId),
                    child: Text(
                      competence.competenceName,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Gap(10),
            if (competence.indicators != null) ...[
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Indikatoren:',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic),
                  ),
                ],
              ),
              const Gap(5),
              Text(
                competence.indicators!,
                textAlign: TextAlign.start,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                ),
              ),
            ],
            competence.competenceLevel != null
                ? Padding(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (competence.competenceLevel!
                                  .contains('E1')) ...[
                                Image.asset(
                                  'assets/grade_1.png',
                                  width: 22,
                                ),
                                const Gap(5)
                              ],
                              if (competence.competenceLevel!
                                  .contains('E2')) ...[
                                Image.asset(
                                  'assets/grade_2.png',
                                  width: 22,
                                ),
                                const Gap(5)
                              ],
                              if (competence.competenceLevel!
                                  .contains('S3')) ...[
                                Image.asset(
                                  'assets/grade_3.png',
                                  width: 22,
                                ),
                                const Gap(5)
                              ],
                              if (competence.competenceLevel!
                                  .contains('S4')) ...[
                                Image.asset(
                                  'assets/grade_4.png',
                                  width: 22,
                                ),
                                const Gap(5)
                              ],
                            ],
                          ),
                        ),
                        const Gap(10),
                        CustomExpansionTileSwitch(
                          customExpansionTileController: pupilListController,
                          expansionSwitchWidget: const Icon(
                            Icons.add,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
            CustomExpansionTileContent(
              tileController: pupilListController,
              widgetList: competenceFilteredPupils(competence: competence),
            ),
          ],
        ),
      ),
    );
  }
}
