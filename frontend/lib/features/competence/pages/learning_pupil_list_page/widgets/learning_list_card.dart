import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/widgets/avatar.dart';
import 'package:schuldaten_hub/common/widgets/custom_expansion_tile/custom_expansion_tile.dart';
import 'package:schuldaten_hub/common/widgets/custom_expansion_tile/custom_expansion_tile_content.dart';
import 'package:schuldaten_hub/features/competence/pages/learning_pupil_list_page/widgets/competence_checks_batches.dart';
import 'package:schuldaten_hub/features/competence/pages/learning_pupil_list_page/widgets/pupil_learning_content/pupil_learning_content_list.dart';
import 'package:schuldaten_hub/features/main_menu_pages/widgets/landing_bottom_nav_bar.dart';
import 'package:schuldaten_hub/features/learning_support/services/learning_support_helper_functions.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';
import 'package:schuldaten_hub/features/pupil/pages/pupil_profile_page/pupil_profile_page.dart';

import 'package:watch_it/watch_it.dart';

class LearningCard extends WatchingStatefulWidget {
  final PupilProxy pupil;
  const LearningCard(this.pupil, {super.key});

  @override
  State<LearningCard> createState() => _LearningSupportCardState();
}

class _LearningSupportCardState extends State<LearningCard> {
  final CustomExpansionTileController _tileController =
      CustomExpansionTileController();
  @override
  Widget build(BuildContext context) {
    final PupilProxy pupil = watch(widget.pupil);

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
              AvatarWithBadges(pupil: pupil, size: 80),
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
                                locator<BottomNavManager>()
                                    .setPupilProfileNavPage(9);
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (ctx) => PupilProfilePage(
                                    pupil: pupil,
                                  ),
                                ));
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
                        const Text('ärztl. U.:'),
                        const Gap(10),
                        Text(
                          LearningSupportHelper.preschoolRevision(
                              pupil.preschoolRevision!),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const Gap(15),
                    if (pupil.competenceChecks!.isNotEmpty)
                      InkWell(
                        onTap: () {
                          _tileController.isExpanded
                              ? _tileController.collapse()
                              : _tileController.expand();
                        },
                        child: CompetenceChecksBatches(pupil: pupil),
                      ),
                  ],
                ),
              ),
              const Gap(8),
              InkWell(
                onTap: () {
                  _tileController.isExpanded
                      ? _tileController.collapse()
                      : _tileController.expand();
                },
                child: Column(
                  children: [
                    const Gap(20),
                    //const Text('Ebene'),
                    SizedBox(
                      width: 40.0,
                      child: Center(
                        child: Text(
                          pupil.pupilWorkbooks!.length.toString(),
                          style: const TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                            color: backgroundColor,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      pupil.specialNeeds != null
                          ? pupil.specialNeeds!.length == 4
                              ? '${pupil.specialNeeds!.substring(0, 2)} ${pupil.specialNeeds!.substring(2, 4)}'
                              : pupil.specialNeeds!.substring(0, 2)
                          : '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: groupColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(15),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(5),
            child: CustomExpansionTileContent(
                title: null,
                tileController: _tileController,
                widgetList: [PupilLearningContentList(pupil: pupil)]),
          )
        ],
      ),
    );
  }
}
