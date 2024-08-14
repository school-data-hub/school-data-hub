import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/widgets/generic_app_bar.dart';
import 'package:schuldaten_hub/common/widgets/generic_sliver_list.dart';
import 'package:schuldaten_hub/common/widgets/sliver_search_app_bar.dart';
import 'package:schuldaten_hub/features/learning_support/filters/learning_support_filters.dart';
import 'package:schuldaten_hub/features/learning_support/services/learning_support_filters.dart';
import 'package:schuldaten_hub/features/learning_support/pages/learning_support_list_page/widgets/learning_support_list_card.dart';
import 'package:schuldaten_hub/features/learning_support/pages/learning_support_list_page/widgets/learning_support_list_search_bar.dart';
import 'package:schuldaten_hub/features/learning_support/pages/learning_support_list_page/widgets/learning_support_list_page_bottom_navbar.dart';
import 'package:schuldaten_hub/features/pupil/filters/pupils_filter.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';
import 'package:schuldaten_hub/features/pupil/services/pupil_manager.dart';
import 'package:watch_it/watch_it.dart';

class LearningSupportListPage extends WatchingWidget {
  const LearningSupportListPage({super.key});

  @override
  Widget build(BuildContext context) {
    bool filtersOn = watchValue((PupilsFilter x) => x.filtersOn);
    // These come from the PupilFilterManager
    List<PupilProxy> filteredPupilsByClassAndSchoolGrade =
        watchValue((PupilsFilter x) => x.filteredPupils);
    // We want them to go through the learning support filters first
    List<PupilProxy> filteredPupilsByCategoryGoals =
        learningSupportFilteredPupils(filteredPupilsByClassAndSchoolGrade);
    List<PupilProxy> pupils =
        learningSupportFilters(filteredPupilsByCategoryGoals);
    return Scaffold(
      backgroundColor: canvasColor,
      appBar: const GenericAppBar(
          iconData: Icons.support_rounded, title: 'Förderung'),
      body: RefreshIndicator(
        onRefresh: () async => locator<PupilManager>().updatePupilList(pupils),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: CustomScrollView(
              slivers: [
                const SliverGap(5),
                SliverSearchAppBar(
                  height: 110,
                  title: LearningSupportListSearchBar(
                      pupils: pupils, filtersOn: filtersOn),
                ),
                GenericSliverListWithEmptyListCheck(
                    items: pupils,
                    itemBuilder: (_, pupil) => LearningSupportCard(pupil)),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar:
          LearningSupportListPageBottomNavBar(filtersOn: filtersOn),
    );
  }
}