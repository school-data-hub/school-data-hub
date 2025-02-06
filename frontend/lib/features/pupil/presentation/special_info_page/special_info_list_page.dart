import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/domain/filters/filters_state_manager.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/theme/app_colors.dart';
import 'package:schuldaten_hub/common/theme/styles.dart';
import 'package:schuldaten_hub/common/widgets/list_view_components/generic_sliver_list.dart';
import 'package:schuldaten_hub/common/widgets/list_view_components/generic_sliver_search_app_bar.dart';
import 'package:schuldaten_hub/features/pupil/domain/filters/pupils_filter.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_proxy.dart';
import 'package:schuldaten_hub/features/pupil/domain/pupil_manager.dart';
import 'package:schuldaten_hub/features/pupil/presentation/special_info_page/widgets/special_info_card.dart';
import 'package:schuldaten_hub/features/pupil/presentation/special_info_page/widgets/special_info_list_page_bottom_navbar.dart';
import 'package:schuldaten_hub/features/pupil/presentation/special_info_page/widgets/special_info_list_search_bar.dart';
import 'package:watch_it/watch_it.dart';

List<PupilProxy> specialInfoFilter(List<PupilProxy> pupils) {
  List<PupilProxy> filteredPupils = [];
  bool filtersOn = false;
  for (PupilProxy pupil in pupils) {
    if (pupil.specialInformation == null || pupil.specialInformation!.isEmpty) {
      filtersOn = true;
      continue;
    }

    filteredPupils.add(pupil);
  }
  if (filtersOn) {
    locator<FiltersStateManager>()
        .setFilterState(filterState: FilterState.pupil, value: true);
  }
  return filteredPupils;
}

void _onPop(bool didPop, dynamic result) {
  locator<FiltersStateManager>()
      .setFilterState(filterState: FilterState.pupil, value: false);
  locator<PupilsFilter>().resetFilters();
  // You can add more logic here if needed
}

class SpecialInfoListPage extends WatchingWidget {
  const SpecialInfoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    List<PupilProxy> filteredPupils =
        watchValue((PupilsFilter x) => x.filteredPupils);
    List<PupilProxy> pupils = specialInfoFilter(filteredPupils);
    return PopScope(
      onPopInvokedWithResult: (didPop, result) => _onPop(didPop, result),
      child: Scaffold(
        backgroundColor: AppColors.canvasColor,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: AppColors.backgroundColor,
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emergency_rounded,
                size: 25,
                color: Colors.white,
              ),
              Gap(10),
              Text(
                'Besondere Infos',
                style: AppStyles.appBarTextStyle,
              ),
            ],
          ),
          automaticallyImplyLeading: false,
        ),
        body: RefreshIndicator(
          onRefresh: () async =>
              locator<PupilManager>().updatePupilList(pupils),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: CustomScrollView(
                slivers: [
                  const SliverGap(5),
                  GenericSliverSearchAppBar(
                    height: 110,
                    title: SpecialInfoListSearchBar(
                      pupils: pupils,
                    ),
                  ),
                  GenericSliverListWithEmptyListCheck(
                      items: pupils,
                      itemBuilder: (_, pupil) => SpecialInfoCard(pupil)),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: SpecialInfoListPageBottomNavBar(),
      ),
    );
  }
}
