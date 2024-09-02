import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/services/base_state.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/widgets/generic_app_bar.dart';
import 'package:schuldaten_hub/common/widgets/generic_sliver_list.dart';
import 'package:schuldaten_hub/common/widgets/sliver_search_app_bar.dart';
import 'package:schuldaten_hub/features/pupil/services/pupil_manager.dart';
import 'package:schuldaten_hub/features/pupil/filters/pupils_filter.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';
import 'package:schuldaten_hub/features/schoolday_events/pages/schoolday_event_list_page/widgets/schoolday_event_list_card.dart';
import 'package:schuldaten_hub/features/schoolday_events/pages/schoolday_event_list_page/widgets/schoolday_event_list_page_bottom_navbar.dart';
import 'package:schuldaten_hub/features/schoolday_events/pages/schoolday_event_list_page/widgets/schoolday_event_list_page_search_bar.dart';
import 'package:schuldaten_hub/features/schooldays/services/schoolday_manager.dart';
import 'package:watch_it/watch_it.dart';

import '../../../school_lists/filters/school_list_filter_manager.dart';

class SchooldayEventListPage extends WatchingStatefulWidget {
  const SchooldayEventListPage({super.key});

  @override
  State<SchooldayEventListPage> createState() => _SchooldayEventListPageState();
}

class _SchooldayEventListPageState extends BaseState<SchooldayEventListPage> {
  @override
  Future<void> onInitialize() async {
    await locator.isReady<PupilsFilter>();
    await locator.isReady<SchoolListFilterManager>();
    await locator.isReady<SchooldayManager>();
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      return const Scaffold(
        backgroundColor: canvasColor,
        appBar: GenericAppBar(
            iconData: Icons.warning_amber_rounded, title: 'Ereignisse'),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    //- TODO: check how this works
    // pushScope(
    //     init: (locator) => locator.registerSingleton<PupilsFilter>(
    //         locator<PupilManager>().getPupilFilter()));
    //-TODO: Filterstate in SchooldayEventSearchbar and SchooldayEventListPageBottomNavBar

    List<PupilProxy> pupils = watchValue((PupilsFilter x) => x.filteredPupils);

    return Scaffold(
      backgroundColor: canvasColor,
      appBar: const GenericAppBar(
          iconData: Icons.warning_amber_rounded, title: 'Ereignisse'),
      body: RefreshIndicator(
        onRefresh: () async => locator<PupilManager>().fetchAllPupils(),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: CustomScrollView(
              slivers: [
                const SliverGap(5),
                const SliverSearchAppBar(
                  height: 110,
                  title: SchooldayEventListSearchBar(),
                ),
                GenericSliverListWithEmptyListCheck(
                    items: pupils,
                    itemBuilder: (_, pupil) => SchooldayEventListCard(pupil)),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const SchooldayEventListPageBottomNavBar(),
    );
  }
}
