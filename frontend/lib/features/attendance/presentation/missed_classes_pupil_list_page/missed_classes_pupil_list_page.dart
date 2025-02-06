import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/theme/app_colors.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/widgets/list_view_components/generic_app_bar.dart';
import 'package:schuldaten_hub/common/widgets/list_view_components/generic_sliver_list.dart';
import 'package:schuldaten_hub/common/widgets/list_view_components/generic_sliver_search_app_bar.dart';
import 'package:schuldaten_hub/features/attendance/presentation/missed_classes_pupil_list_page/widgets/missed_classes_pupil_list_card.dart';
import 'package:schuldaten_hub/features/attendance/presentation/missed_classes_pupil_list_page/widgets/missed_classes_pupil_list_page_bottom_navbar.dart';
import 'package:schuldaten_hub/features/attendance/presentation/missed_classes_pupil_list_page/widgets/missed_classes_pupil_list_searchbar.dart';
import 'package:schuldaten_hub/features/pupil/domain/filters/pupils_filter.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_proxy.dart';
import 'package:schuldaten_hub/features/pupil/domain/pupil_manager.dart';
import 'package:watch_it/watch_it.dart';

class MissedClassesPupilListPage extends WatchingWidget {
  const MissedClassesPupilListPage({super.key});

  @override
  Widget build(BuildContext context) {
    List<PupilProxy> pupils = watchValue((PupilsFilter x) => x.filteredPupils);

    return Scaffold(
      backgroundColor: AppColors.canvasColor,
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
                GenericSliverSearchAppBar(
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
