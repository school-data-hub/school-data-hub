import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/widgets/generic_app_bar.dart';
import 'package:schuldaten_hub/common/widgets/generic_sliver_list.dart';
import 'package:schuldaten_hub/common/widgets/sliver_search_app_bar.dart';
import 'package:schuldaten_hub/features/ogs/widgets/ogs_list_card.dart';
import 'package:schuldaten_hub/features/ogs/widgets/ogs_list_search_bar.dart';
import 'package:schuldaten_hub/features/ogs/widgets/ogs_view_bottom_navbar.dart';
import 'package:schuldaten_hub/features/pupil/filters/pupils_filter.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';
import 'package:schuldaten_hub/features/pupil/filters/pupil_filter_manager.dart';
import 'package:schuldaten_hub/features/pupil/services/pupil_manager.dart';
import 'package:schuldaten_hub/features/school_lists/filters/school_list_filter_manager.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/services/base_state.dart';

List<PupilProxy> ogsFilter(List<PupilProxy> pupils) {
  List<PupilProxy> filteredPupils = [];
  for (PupilProxy pupil in pupils) {
    if (!pupil.ogs == true) {
      locator<PupilsFilter>().setFiltersOnValue(true);
      continue;
    }
    filteredPupils.add(pupil);
  }
  return filteredPupils;
}

class OgsListPage extends WatchingStatefulWidget {
  const OgsListPage({super.key});

  @override
  State<OgsListPage> createState() => _OgsListPageState();
}

class _OgsListPageState extends BaseState<OgsListPage> {
  @override
  Future<void> onInitialize() async {
    await locator.isReady<PupilsFilter>();
    await locator.isReady<SchoolListFilterManager>();
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      return const Scaffold(
        backgroundColor: canvasColor,
        appBar: GenericAppBar(
            iconData: Icons.restaurant_menu_rounded, title: 'OGS Infos'),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    bool filtersOn = watchValue((PupilFilterManager x) => x.filtersOn);

    List<PupilProxy> pupils = watchValue((PupilsFilter x) => x.filteredPupils);

    List<PupilProxy> ogsPupils = ogsFilter(pupils);

    return Scaffold(
      backgroundColor: canvasColor,
      appBar: const GenericAppBar(
          iconData: Icons.restaurant_menu_rounded, title: 'OGS Infos'),
      body: RefreshIndicator(
        onRefresh: () async =>
            locator<PupilManager>().updatePupilList(ogsPupils),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: CustomScrollView(
              slivers: [
                const SliverGap(5),
                SliverSearchAppBar(
                  height: 110,
                  title:
                      OgsListSearchBar(pupils: ogsPupils, filtersOn: filtersOn),
                ),
                GenericSliverListWithEmptyListCheck(
                    items: ogsPupils,
                    itemBuilder: (_, pupil) => OgsCard(pupil)),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: OgsListPageBottomNavBar(filtersOn: filtersOn),
    );
  }
}
