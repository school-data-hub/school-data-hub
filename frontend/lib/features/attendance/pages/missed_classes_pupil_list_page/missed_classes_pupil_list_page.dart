import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/services/base_state.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/widgets/generic_app_bar.dart';
import 'package:schuldaten_hub/common/widgets/generic_sliver_list.dart';
import 'package:schuldaten_hub/common/widgets/sliver_search_app_bar.dart';
import 'package:schuldaten_hub/features/attendance/pages/missed_classes_pupil_list_page/widgets/missed_classes_pupil_list_card.dart';
import 'package:schuldaten_hub/features/attendance/pages/missed_classes_pupil_list_page/widgets/missed_classes_pupil_list_searchbar.dart';
import 'package:schuldaten_hub/features/attendance/pages/missed_classes_pupil_list_page/widgets/missed_classes_pupil_list_page_bottom_navbar.dart';
import 'package:schuldaten_hub/features/attendance/services/attendance_manager.dart';
import 'package:schuldaten_hub/features/pupil/filters/pupils_filter.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';
import 'package:schuldaten_hub/features/pupil/services/pupil_manager.dart';
import 'package:watch_it/watch_it.dart';

import '../../../school_lists/filters/school_list_filter_manager.dart';

class MissedClassesPupilListPage extends WatchingStatefulWidget {
  const MissedClassesPupilListPage({super.key});

  @override
  State<MissedClassesPupilListPage> createState() =>
      _MissedClassesPupilListPageState();
}

class _MissedClassesPupilListPageState
    extends BaseState<MissedClassesPupilListPage> {
  @override
  Future<void> onInitialize() async {
    await locator.isReady<PupilsFilter>();
    await locator.isReady<SchoolListFilterManager>();
    await locator.isReady<AttendanceManager>();
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      return const Scaffold(
        backgroundColor: canvasColor,
        appBar: GenericAppBar(
            iconData: Icons.calendar_month_rounded, title: 'Fehlzeiten'),
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
          iconData: Icons.calendar_month_rounded, title: 'Fehlzeiten'),
      body: RefreshIndicator(
        onRefresh: () async => locator<PupilManager>().fetchAllPupils(),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: CustomScrollView(
              slivers: [
                const SliverGap(5),
                SliverSearchAppBar(
                  height: 110,
                  title: AttendanceRankingListSearchbar(pupils: pupils),
                ),
                GenericSliverListWithEmptyListCheck(
                    items: pupils,
                    itemBuilder: (_, pupil) =>
                        AttendanceRankingListCard(pupil)),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AttendanceRankingListPageBottomNavBar(),
    );
  }
}
