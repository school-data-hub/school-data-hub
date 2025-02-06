import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/theme/app_colors.dart';
import 'package:schuldaten_hub/common/widgets/avatar.dart';
import 'package:schuldaten_hub/common/widgets/custom_expansion_tile/custom_expansion_tile.dart';
import 'package:schuldaten_hub/common/widgets/custom_expansion_tile/custom_expansion_tile_content.dart';
import 'package:schuldaten_hub/common/widgets/custom_expansion_tile/custom_expansion_tile_switch.dart';
import 'package:schuldaten_hub/features/competence/domain/competence_helper.dart';
import 'package:schuldaten_hub/features/competence/presentation/pupil_competence_list_page/widgets/learning_list_card/workbooks_info_switch.dart';
import 'package:schuldaten_hub/features/competence/presentation/pupil_competence_list_page/widgets/pupil_competence_checks/competence_checks_badges.dart';
import 'package:schuldaten_hub/features/competence/presentation/pupil_competence_list_page/widgets/pupil_learning_content/pupil_learning_content_books.dart';
import 'package:schuldaten_hub/features/competence/presentation/pupil_competence_list_page/widgets/pupil_learning_content/pupil_learning_content_competence_goals.dart';
import 'package:schuldaten_hub/features/competence/presentation/pupil_competence_list_page/widgets/pupil_learning_content/pupil_learning_content_competence_statuses.dart';
import 'package:schuldaten_hub/features/competence/presentation/pupil_competence_list_page/widgets/pupil_learning_content/pupil_learning_content_workbooks.dart';
import 'package:schuldaten_hub/features/competence/presentation/widgets/pupil_learning_content_expansion_tile_nav_bar.dart';
import 'package:schuldaten_hub/features/main_menu/widgets/landing_bottom_nav_bar.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_proxy.dart';
import 'package:schuldaten_hub/features/pupil/presentation/pupil_profile_page/pupil_profile_page.dart';
import 'package:schuldaten_hub/features/pupil/presentation/pupil_profile_page/widgets/pupil_profile_navigation.dart';
import 'package:watch_it/watch_it.dart';

class LearningListCard extends WatchingWidget {
  final PupilProxy pupil;
  const LearningListCard(this.pupil, {super.key});
  @override
  Widget build(BuildContext context) {
    watch(pupil);
    final expansionTileController = createOnce<CustomExpansionTileController>(
        () => CustomExpansionTileController());
    final selectedContentNotifier = SelectedLearningContentNotifier();
    final selectedContent = watchPropertyValue((m) => m.selectedContent,
        target: selectedContentNotifier);
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
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Gap(5),
                    Row(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: InkWell(
                              onTap: () {
                                locator<MainMenuBottomNavManager>()
                                    .setPupilProfileNavPage(
                                        ProfileNavigation.learning.value);
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
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(5),
                    if (selectedContent ==
                        SelectedContent.competenceStatuses) ...[
                      CustomExpansionTileSwitch(
                        includeSwitch: true,
                        switchColor: AppColors.interactiveColor,
                        customExpansionTileController: expansionTileController,
                        expansionSwitchWidget:
                            CompetenceChecksBadges(pupil: pupil),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text('Items dokumentiert: '),
                          const Gap(5),
                          Text(
                            '$totalCompetencesChecked/$totalCompetencesToReport',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.backgroundColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (selectedContent == SelectedContent.competenceGoals) ...[
                      CustomExpansionTileSwitch(
                        customExpansionTileController: expansionTileController,
                        expansionSwitchWidget: const Text(
                            'Lernziele sind noch nicht implementiert'),
                      ),
                    ],
                    if (selectedContent == SelectedContent.workbooks) ...[
                      CustomExpansionTileSwitch(
                        customExpansionTileController: expansionTileController,
                        expansionSwitchWidget:
                            WorkbooksInfoSwitch(pupil: pupil),
                        includeSwitch: true,
                        switchColor: AppColors.interactiveColor,
                      ),
                    ],
                    if (selectedContent == SelectedContent.books) ...[
                      CustomExpansionTileSwitch(
                        customExpansionTileController: expansionTileController,
                        expansionSwitchWidget: const Text('Bücher'),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const Gap(5),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 5.0),
          //   child: PupilLearningContentExpansionTileNavBar(
          //     pupil: pupil,
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 5, right: 5),
            child: CustomExpansionTileContent(
                title: null,
                tileController: expansionTileController,
                widgetList: [
                  if (selectedContent == SelectedContent.competenceStatuses)
                    PupilLearningContentCompetenceStatuses(pupil: pupil),
                  if (selectedContent == SelectedContent.competenceGoals)
                    PupilLearningContentCompetenceGoals(pupil: pupil),
                  if (selectedContent == SelectedContent.workbooks)
                    PupilLearningContentWorkbooks(pupil: pupil),
                  if (selectedContent == SelectedContent.books)
                    PupilLearningContentBooks(pupil: pupil)
                ]),
          )
        ],
      ),
    );
  }
}
