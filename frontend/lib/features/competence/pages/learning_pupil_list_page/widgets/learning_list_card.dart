import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/widgets/avatar.dart';
import 'package:schuldaten_hub/common/widgets/custom_expansion_tile/custom_expansion_tile.dart';
import 'package:schuldaten_hub/common/widgets/custom_expansion_tile/custom_expansion_tile_content.dart';
import 'package:schuldaten_hub/features/competence/pages/learning_pupil_list_page/widgets/competence_checks_batches.dart';
import 'package:schuldaten_hub/features/competence/pages/learning_pupil_list_page/widgets/pupil_learning_content/pupil_learning_content_competence_goals.dart';
import 'package:schuldaten_hub/features/competence/pages/learning_pupil_list_page/widgets/pupil_learning_content/pupil_learning_content_competence_statuses.dart';
import 'package:schuldaten_hub/features/competence/pages/learning_pupil_list_page/widgets/pupil_learning_content/pupil_learning_content_workbooks.dart';
import 'package:schuldaten_hub/features/competence/services/competence_helper.dart';
import 'package:schuldaten_hub/features/main_menu_pages/widgets/landing_bottom_nav_bar.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';
import 'package:schuldaten_hub/features/pupil/pages/pupil_profile_page/pupil_profile_page.dart';
import 'package:watch_it/watch_it.dart';

enum SelectedContent {
  competenceStatuses,
  competenceGoals,
  workbooks,
  books,
  none,
}

class LearningCard extends WatchingStatefulWidget {
  final PupilProxy pupil;
  const LearningCard(this.pupil, {super.key});

  @override
  State<LearningCard> createState() => _LearningSupportCardState();
}

class _LearningSupportCardState extends State<LearningCard> {
  late SelectedContent selectedContent;

  @override
  initState() {
    selectedContent = SelectedContent.none;
    super.initState();
  }

  final CustomExpansionTileController _tileController =
      CustomExpansionTileController();
  @override
  Widget build(BuildContext context) {
    final PupilProxy pupil = watch(widget.pupil);
    final competenceCheckstats = CompetenceHelper.competenceChecksStats(pupil);
    final totalCompetencesToReport = competenceCheckstats.total;
    final totalCompetencesChecked = competenceCheckstats.checked;
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
                // onTap: () {
                //   _tileController.isExpanded
                //       ? _tileController.collapse()
                //       : _tileController.expand();
                // },
                child: Column(
                  children: [
                    const Gap(20),
                    //const Text('Ebene'),
                    SizedBox(
                      width: 50.0,
                      child: Center(
                        child: Text(
                          '$totalCompetencesChecked/$totalCompetencesToReport',
                          style: const TextStyle(
                            fontSize: 15,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                isSelected:
                    selectedContent == SelectedContent.competenceStatuses,
                icon: const Icon(
                  Icons.lightbulb,
                  color: backgroundColor,
                ),
                selectedIcon: const Icon(
                  Icons.lightbulb,
                  color: accentColor,
                ),
                onPressed: () {
                  setState(
                    () {
                      if (selectedContent !=
                          SelectedContent.competenceStatuses) {
                        if (_tileController.isExpanded) {
                          _tileController.collapse();
                          setState(() {
                            selectedContent =
                                SelectedContent.competenceStatuses;
                          });
                          _tileController.expand();
                          return;
                        }
                        setState(() {
                          selectedContent = SelectedContent.competenceStatuses;
                        });
                        _tileController.expand();
                        return;
                      }
                      _tileController.isExpanded
                          ? _tileController.collapse()
                          : _tileController.expand();
                    },
                  );
                },
              ),
              IconButton(
                isSelected: selectedContent == SelectedContent.competenceGoals,
                icon: const Icon(
                  Icons.emoji_nature_rounded,
                  color: backgroundColor,
                ),
                selectedIcon: const Icon(
                  Icons.emoji_nature_rounded,
                  color: accentColor,
                ),
                onPressed: () {
                  setState(
                    () {
                      if (selectedContent != SelectedContent.competenceGoals) {
                        setState(() {
                          selectedContent = SelectedContent.competenceGoals;
                        });
                        if (_tileController.isExpanded) {
                          return;
                        }
                        setState(() {
                          selectedContent = SelectedContent.competenceGoals;
                        });
                        _tileController.expand();
                        return;
                      }
                      _tileController.isExpanded
                          ? _tileController.collapse()
                          : _tileController.expand();
                    },
                  );
                },
              ),
              IconButton(
                isSelected: selectedContent == SelectedContent.workbooks,
                icon: const Icon(
                  Icons.note_alt,
                  color: backgroundColor,
                ),
                selectedIcon: const Icon(
                  Icons.note_alt,
                  color: accentColor,
                ),
                onPressed: () {
                  setState(
                    () {
                      if (selectedContent != SelectedContent.workbooks) {
                        if (_tileController.isExpanded) {
                          _tileController.collapse();
                          setState(() {
                            selectedContent = SelectedContent.workbooks;
                          });
                          _tileController.expand();
                          return;
                        }
                        setState(() {
                          selectedContent = SelectedContent.workbooks;
                        });
                        _tileController.expand();
                        return;
                      }
                      _tileController.isExpanded
                          ? _tileController.collapse()
                          : _tileController.expand();
                    },
                  );
                },
              ),
              IconButton(
                isSelected: selectedContent == SelectedContent.books,
                icon: const Icon(
                  Icons.book,
                  color: backgroundColor,
                ),
                selectedIcon: const Icon(
                  Icons.book,
                  color: accentColor,
                ),
                onPressed: () {},
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(5),
            child: CustomExpansionTileContent(
                title: null,
                tileController: _tileController,
                widgetList: [
                  if (selectedContent == SelectedContent.competenceStatuses)
                    PupilLearningContentCompetenceStatuses(pupil: pupil),
                  if (selectedContent == SelectedContent.competenceGoals)
                    PupilLearningContentCompetenceGoals(pupil: pupil),
                  if (selectedContent == SelectedContent.workbooks)
                    PupilLearningContentWorkbooks(pupil: pupil)
                ]),
          )
        ],
      ),
    );
  }
}
