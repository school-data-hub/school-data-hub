import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/utils/custom_expasion_tile_hook.dart';
import 'package:schuldaten_hub/common/widgets/avatar.dart';
import 'package:schuldaten_hub/common/widgets/custom_expansion_tile/custom_expansion_tile_content.dart';
import 'package:schuldaten_hub/common/widgets/custom_expansion_tile/custom_expansion_tile_switch.dart';
import 'package:schuldaten_hub/features/competence/models/competence.dart';
import 'package:schuldaten_hub/features/competence/services/competence_helper.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';

List<Widget> competenceFilteredPupils({required Competence competence}) {
  List<Widget> finalPupils = [];
  final competenceFilteredPupils =
      CompetenceHelper.getFilteredPupilsByCompetence(competence: competence);
  for (final pupil in competenceFilteredPupils) {
    finalPupils.add(PupilCompetenceCheckCard(pupil: pupil));
  }
  return finalPupils;
}

class PupilCompetenceCheckCard extends HookWidget {
  final PupilProxy pupil;
  const PupilCompetenceCheckCard({required this.pupil, super.key});

  @override
  Widget build(BuildContext context) {
    final tileController = useCustomExpansionTileController();
    final radioButtonValue = useState(0);
    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 1.0,
      margin:
          const EdgeInsets.only(left: 4.0, right: 4.0, top: 4.0, bottom: 4.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              AvatarWithBadges(pupil: pupil, size: 70),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Gap(15),
                    Row(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: InkWell(
                              onTap: () {
                                // locator<BottomNavManager>()
                                //     .setPupilProfileNavPage(2);
                                // Navigator.of(context).push(MaterialPageRoute(
                                //   builder: (ctx) => PupilProfilePage(
                                //     pupil: pupil,
                                //   ),
                                // ));
                              },
                              child: Row(
                                children: [
                                  Text(
                                    pupil.firstName,
                                    overflow: TextOverflow.fade,
                                    softWrap: false,
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const Gap(5),
                                  Text(
                                    pupil.lastName,
                                    overflow: TextOverflow.fade,
                                    softWrap: false,
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const Gap(5),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(5),
                    Row(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset('assets/growth_1-4.png',
                                    width: 40, height: 40),
                                Radio<int>(
                                  value: 1,
                                  groupValue: radioButtonValue.value,
                                  onChanged: (value) {
                                    radioButtonValue.value = value!;
                                  },
                                ),
                                Image.asset('assets/growth_2-4.png',
                                    width: 40, height: 40),
                                Radio<int>(
                                  value: 2,
                                  groupValue: radioButtonValue.value,
                                  onChanged: (value) {
                                    radioButtonValue.value = value!;
                                  },
                                ),
                                Image.asset('assets/growth_3-4.png',
                                    width: 40, height: 40),
                                Radio<int>(
                                  value: 3,
                                  groupValue: radioButtonValue.value,
                                  onChanged: (value) {
                                    radioButtonValue.value = value!;
                                  },
                                ),
                                Image.asset('assets/growth_4-4.png',
                                    width: 40, height: 40),
                                Radio<int>(
                                  value: 4,
                                  groupValue: radioButtonValue.value,
                                  onChanged: (value) {
                                    radioButtonValue.value = value!;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Gap(20),
              if (radioButtonValue.value != 0)
                InkWell(
                  onTap: () {
                    tileController.isExpanded
                        ? tileController.collapse()
                        : tileController.expand();
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Gap(40),
                      Center(
                        child: CustomExpansionTileSwitch(
                            expansionSwitchWidget: Icon(
                              tileController.isExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: interactiveColor,
                            ),
                            customExpansionTileController: tileController),
                      )
                    ],
                  ),
                ),
              const Gap(20),
            ],
          ),
          CustomExpansionTileContent(
            title: null,
            tileController: tileController,
            widgetList: const [],
          ),
        ],
      ),
    );
  }
}
