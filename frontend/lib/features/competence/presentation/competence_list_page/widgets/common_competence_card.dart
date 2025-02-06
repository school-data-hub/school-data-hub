import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/widgets/custom_expansion_tile/custom_expansion_tile.dart';
import 'package:schuldaten_hub/common/widgets/custom_expansion_tile/custom_expansion_tile_content.dart';
import 'package:schuldaten_hub/common/widgets/custom_expansion_tile/custom_expansion_tile_switch.dart';
import 'package:schuldaten_hub/features/competence/domain/models/competence.dart';
import 'package:watch_it/watch_it.dart';

class CommonCompetenceCard extends WatchingWidget {
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
    final childrenController = createOnce<CustomExpansionTileController>(
        () => CustomExpansionTileController());
    // final childrenController = useCustomExpansionTileController();

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
                  // CustomExpansionTileSwitch(
                  //   customExpansionTileController: pupilListController,
                  //   expansionSwitchWidget: const Icon(
                  //     Icons.add,
                  //     color: Colors.white,
                  //   ),
                  // ),
                ],
              ),
            ),
            CustomExpansionTileContent(
              tileController: childrenController,
              widgetList: children,
            ),
            // Padding(
            //   padding: const EdgeInsets.only(
            //       left: 5.0, right: 5.0, bottom: 2.5, top: 2.5),
            //   child: CustomExpansionTileContent(
            //       tileController: pupilListController,
            //       widgetList: [
            //         ListView.builder(
            //           shrinkWrap: true,
            //           physics: const NeverScrollableScrollPhysics(),
            //           itemCount: competenceFilteredPupils.length,
            //           itemBuilder: (context, index) {
            //             final pupil = competenceFilteredPupils[index];
            //             return MultiPupilCompetenceCheckCard(pupil: pupil);
            //           },
            //         ),
            //       ]),
            // ),
          ],
        ),
      ),
    );
  }
}
