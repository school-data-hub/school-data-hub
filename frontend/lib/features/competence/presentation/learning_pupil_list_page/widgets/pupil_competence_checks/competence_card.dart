import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/theme/colors.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/widgets/custom_expansion_tile/custom_expansion_tile_content.dart';
import 'package:schuldaten_hub/common/widgets/custom_expansion_tile/custom_expansion_tile_switch.dart';
import 'package:schuldaten_hub/common/widgets/custom_expansion_tile/custom_expasion_tile_hook.dart';
import 'package:schuldaten_hub/features/competence/domain/models/competence.dart';
import 'package:schuldaten_hub/features/competence/presentation/widgets/competence_check_symbols.dart';
import 'package:schuldaten_hub/features/competence/presentation/widgets/dialogues/new_competence_check_dialog.dart';
import 'package:schuldaten_hub/features/competence/domain/competence_manager.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_proxy.dart';

class CompetenceCard extends HookWidget {
  final Color backgroundColor;
  final bool isReport;
  final Competence competence;
  final PupilProxy pupil;

  final List<Widget> children;
  final List<Widget> competenceChecks;
  final double? checksAverageValue;

  const CompetenceCard({
    super.key,
    required this.backgroundColor,
    required this.isReport,
    required this.competence,
    required this.pupil,
    required this.children,
    required this.competenceChecks,
    required this.checksAverageValue,
  });

  @override
  Widget build(BuildContext context) {
    final controller = useCustomExpansionTileController();
    final checksController = useCustomExpansionTileController();
    return Padding(
      padding: isReport
          ? const EdgeInsets.symmetric(vertical: 4, horizontal: 4)
          : EdgeInsets.symmetric(
              vertical: competence.parentCompetence == null ? 3 : 0),
      child: Card(
        color: AppColors.backgroundColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: isReport
              ? const BorderSide(
                  color: Colors.white,
                  width: 2,
                )
              : BorderSide.none,
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
                  if (competenceChecks.isNotEmpty) ...[
                    CustomExpansionTileSwitch(
                        customExpansionTileController: checksController,
                        expansionSwitchWidget: const Icon(
                          Icons.remove_red_eye,
                          color: Colors.white,
                        )),
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
                            pupil: pupil,
                            competenceId: competence.competenceId,
                            isReport: false,
                            parentContext: context);
                      },
                      child: const Icon(Icons.add, color: Colors.white)),
                  const Gap(5),
                ]),
              ]),
            ),
            if (competenceChecks.isNotEmpty || isReport)
              Padding(
                padding: const EdgeInsets.only(left: 15.0, bottom: 5.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
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
                              color: AppColors.backgroundColor,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const Gap(20),
                    const Text(
                      'Ø',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const Gap(10),
                    if (checksAverageValue != null)
                      Text(
                        checksAverageValue!.toStringAsFixed(1),
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 17),
                      ),
                    if (isReport) ...<Widget>[
                      const Spacer(),
                      InkWell(
                        onLongPress: () {
                          newCompetenceCheckDialog(
                              pupil: pupil,
                              competenceId: competence.competenceId,
                              isReport: true,
                              parentContext: context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: getCompetenceReportCheckSymbol(
                              pupil, competence.competenceId),
                        ),
                      ),
                    ],
                  ],
                ),
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
