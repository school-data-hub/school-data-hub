import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/widgets/bottom_nav_bar_layouts.dart';
import 'package:schuldaten_hub/common/widgets/filter_button.dart';
import 'package:schuldaten_hub/common/widgets/generic_filter_bottom_sheet.dart';
import 'package:schuldaten_hub/features/attendance/pages/missed_classes_pupil_list_page/widgets/missed_classes_badges_info_dialog.dart';
import 'package:schuldaten_hub/features/attendance/pages/missed_classes_pupil_list_page/widgets/missed_classes_filters.dart';
import 'package:schuldaten_hub/features/pupil/filters/pupils_filter.dart';
import 'package:schuldaten_hub/features/pupil/pages/widgets/common_pupil_filters.dart';
import 'package:watch_it/watch_it.dart';

class AttendanceRankingListPageBottomNavBar extends WatchingWidget {
  const AttendanceRankingListPageBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final filtersOn = watchValue((PupilsFilter x) => x.filtersOn);
    return BottomNavBarLayout(
      bottomNavBar: BottomAppBar(
        padding: const EdgeInsets.all(10),
        shape: null,
        color: backgroundColor,
        child: IconTheme(
          data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Row(
              children: [
                const Spacer(),
                IconButton(
                  tooltip: 'zurück',
                  icon: const Icon(
                    Icons.arrow_back,
                    size: 30,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const Gap(30),
                IconButton(
                  tooltip: 'Info',
                  icon: const Icon(Icons.info, size: 30),
                  onPressed: () async {
                    missedClassesBadgesInformationDialog(context: context);
                  },
                ),
                const Gap(30),
                FilterButton(
                    isSearchBar: false,
                    showBottomSheetFunction: () {
                      showGenericFilterBottomSheet(
                        context: context,
                        filterList: [
                          const CommonPupilFiltersWidget(),
                          const MissedClassFilters()
                        ],
                      );
                    }),
                const Gap(15)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
