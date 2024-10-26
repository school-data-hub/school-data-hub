import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/widgets/avatar.dart';
import 'package:schuldaten_hub/features/competence/pages/learning_pupil_list_page/widgets/competence_checks_badges.dart';
import 'package:schuldaten_hub/features/competence/pages/widgets/pupil_learning_content_expansion_tile_nav_bar.dart';
import 'package:schuldaten_hub/features/competence/services/competence_helper.dart';
import 'package:schuldaten_hub/features/main_menu_pages/widgets/landing_bottom_nav_bar.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';
import 'package:schuldaten_hub/features/pupil/pages/pupil_profile_page/pupil_profile_page.dart';
import 'package:watch_it/watch_it.dart';

class LearningCard extends WatchingWidget {
  final PupilProxy passedPupil;
  const LearningCard(this.passedPupil, {super.key});
  @override
  Widget build(BuildContext context) {
    final PupilProxy pupil = watch(passedPupil);
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
                    const Gap(10),
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
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(5),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text('Items dokumentiert: '),
                        const Gap(5),
                        Text(
                          '$totalCompetencesChecked/$totalCompetencesToReport',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: backgroundColor,
                          ),
                        ),
                      ],
                    ),
                    const Gap(5),
                    if (pupil.competenceChecks!.isNotEmpty)
                      CompetenceChecksBadges(pupil: pupil),
                  ],
                ),
              ),
            ],
          ),
          const Gap(5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: PupilLearningContentExpansionTileNavBar(
              pupil: pupil,
            ),
          ),
        ],
      ),
    );
  }
}
