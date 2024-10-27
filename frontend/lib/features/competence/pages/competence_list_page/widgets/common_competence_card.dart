import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/utils/custom_expasion_tile_hook.dart';
import 'package:schuldaten_hub/common/widgets/custom_expansion_tile/custom_expansion_tile_content.dart';
import 'package:schuldaten_hub/common/widgets/custom_expansion_tile/custom_expansion_tile_switch.dart';
import 'package:schuldaten_hub/features/competence/models/competence.dart';
import 'package:schuldaten_hub/features/competence/pages/competence_list_page/widgets/competence_filtered_pupils.dart';

class CommonCompetenceCard extends HookWidget {
  final Color competenceBackgroundColor;
  final Function({int? competenceId, Competence? competence})
      navigateToNewOrPatchCompetencePage;
  final Competence competence;
  final List<Widget> children;
  const CommonCompetenceCard(
      {required this.competence,
      required this.competenceBackgroundColor,
      required this.navigateToNewOrPatchCompetencePage,
      required this.children,
      super.key});

  @override
  Widget build(BuildContext context) {
    final childrenController = useCustomExpansionTileController();
    final pupilListController = useCustomExpansionTileController();
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: competence.parentCompetence == null ? 3 : 0),
      child: Card(
        color: competenceBackgroundColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Gap(10),
                  Expanded(
                    child: InkWell(
                      onTap: () => navigateToNewOrPatchCompetencePage(
                          competence: competence),
                      onLongPress: () => navigateToNewOrPatchCompetencePage(
                          competenceId: competence.competenceId),
                      child: Text(
                        competence.competenceName,
                        maxLines: 4,
                        softWrap: true,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize:
                              competence.parentCompetence == null ? 20 : 16,
                        ),
                      ),
                    ),
                  ),
                  if (children.isNotEmpty) ...<Widget>[
                    CustomExpansionTileSwitch(
                      customExpansionTileController: childrenController,
                    ),
                    const Gap(10),
                  ],
                  CustomExpansionTileSwitch(
                    customExpansionTileController: pupilListController,
                    expansionSwitchWidget: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            CustomExpansionTileContent(
              tileController: childrenController,
              widgetList: children,
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 5.0, right: 5.0, bottom: 2.5, top: 2.5),
              child: CustomExpansionTileContent(
                  tileController: pupilListController,
                  widgetList: competenceFilteredPupils(competence: competence)),
            ),
          ],
        ),
      ),
    );
  }
}
