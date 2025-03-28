import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/domain/filters/filters_state_manager.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/theme/app_colors.dart';
import 'package:schuldaten_hub/common/widgets/list_view_components/generic_sliver_search_app_bar.dart';
import 'package:schuldaten_hub/common/widgets/list_view_components/generic_app_bar.dart';
import 'package:schuldaten_hub/common/widgets/list_view_components/generic_sliver_list.dart';
import 'package:schuldaten_hub/features/competence/presentation/pupil_competence_list_page/widgets/learning_list_card/learning_list_card.dart';
import 'package:schuldaten_hub/features/competence/presentation/pupil_competence_list_page/widgets/pupil_competence_list_bottom_navbar.dart';
import 'package:schuldaten_hub/features/competence/presentation/pupil_competence_list_page/widgets/pupil_competence_list_search_bar.dart';
import 'package:schuldaten_hub/features/pupil/domain/filters/pupils_filter.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_proxy.dart';
import 'package:schuldaten_hub/features/pupil/domain/pupil_manager.dart';
import 'package:watch_it/watch_it.dart';

class LearningPupilListPage extends WatchingWidget {
  const LearningPupilListPage({super.key});

  @override
  Widget build(BuildContext context) {
    bool filtersOn = watchValue((FiltersStateManager x) => x.filtersActive);
    // These come from the PupilFilterManager
    List<PupilProxy> pupils = watchValue((PupilsFilter x) => x.filteredPupils);

    return Scaffold(
      backgroundColor: AppColors.canvasColor,
      appBar: const GenericAppBar(
          iconData: Icons.lightbulb_rounded, title: 'Lernen'),
      body: RefreshIndicator(
        onRefresh: () async => locator<PupilManager>().updatePupilList(pupils),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: CustomScrollView(
              slivers: [
                const SliverGap(5),
                GenericSliverSearchAppBar(
                  height: 140,
                  title: PupilCompetenceListSearchBar(
                      pupils: pupils, filtersOn: filtersOn),
                ),
                GenericSliverListWithEmptyListCheck(
                    items: pupils,
                    itemBuilder: (_, pupil) => LearningListCard(pupil)),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar:
          PupilCompetenceListBottomNavBar(filtersOn: filtersOn),
    );
  }
}
