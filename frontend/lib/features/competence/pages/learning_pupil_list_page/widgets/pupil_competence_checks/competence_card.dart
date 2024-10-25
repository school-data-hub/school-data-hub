import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/utils/custom_expasion_tile_hook.dart';
import 'package:schuldaten_hub/common/widgets/custom_expansion_tile/custom_expansion_tile_content.dart';
import 'package:schuldaten_hub/common/widgets/custom_expansion_tile/custom_expansion_tile_switch.dart';
import 'package:schuldaten_hub/features/competence/models/competence.dart';
import 'package:schuldaten_hub/features/competence/pages/widgets/competence_check_symbols.dart';
import 'package:schuldaten_hub/features/competence/pages/widgets/dialogues/competence_status_dialog.dart';
import 'package:schuldaten_hub/features/competence/services/competence_manager.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';

class CompetenceCard extends HookWidget {
  final Color backgroundColor;
  final bool isReport;
  final Competence competence;
  final PupilProxy pupil;

  final List<Widget> children;
  final List<Widget> competenceChecks;

  const CompetenceCard({
    super.key,
    required this.backgroundColor,
    required this.isReport,
    required this.competence,
    required this.pupil,
    required this.children,
    required this.competenceChecks,
  });

  @override
  Widget build(BuildContext context) {
    final controller = useCustomExpansionTileController();
    final checksController = useCustomExpansionTileController();
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: competence.parentCompetence == null ? 3 : 0),
      child: Card(
        color: backgroundColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(mainAxisSize: MainAxisSize.max, children: [
                const Gap(10),
                Expanded(
                  child: isReport
                      ? Text(
                          competence.competenceName,
                          maxLines: 4,
                          softWrap: true,
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                            color: Colors.white,
                            //fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        )
                      : Text(
                          competence.competenceName,
                          maxLines: 3,
                          softWrap: true,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize:
                                competence.parentCompetence == null ? 20 : 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
                Row(children: [
                  const Gap(20),
                  if (isReport) ...<Widget>[
                    // const Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: InkWell(
                        onLongPress: () {},
                        child: getCompetenceReportCheckSymbol(
                            pupil, competence.competenceId),
                      ),
                    ),
                    const Gap(10),
                  ],
                  if (competenceChecks.isNotEmpty) ...[
                    CustomExpansionTileSwitch(
                      customExpansionTileController: checksController,
                      expansionSwitchWidget: Container(
                        width: 23.0,
                        height: 23.0,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            competenceChecks.length.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: backgroundColor,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    const Gap(10)
                  ],
                  if (competenceChecks.isEmpty && !isReport) const Gap(35),
                  if (locator<CompetenceManager>()
                      .isCompetenceWithChildren(competence))
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: CustomExpansionTileSwitch(
                        customExpansionTileController: controller,
                      ),
                    ),
                  const Gap(10),
                  InkWell(
                      onTap: () {
                        newCompetenceCheckDialog(
                            pupil, competence.competenceId, context);
                      },
                      child: const Icon(Icons.add, color: Colors.white)),
                  const Gap(5),
                ]),
              ]),
            ),
            CustomExpansionTileContent(
              tileController: checksController,
              widgetList: competenceChecks,
            ),
            CustomExpansionTileContent(
              tileController: controller,
              widgetList: children,
            ),
          ],
        ),
      ),
    );
  }
}
