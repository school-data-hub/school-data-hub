import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/widgets/bottom_nav_bar_layouts.dart';
import 'package:schuldaten_hub/common/widgets/date_picker.dart';
import 'package:schuldaten_hub/common/widgets/generic_filter_bottom_sheet.dart';
import 'package:schuldaten_hub/features/attendance/pages/attendance_page/widgets/attendance_filters.dart';
import 'package:schuldaten_hub/features/attendance/pages/missed_classes_pupil_list_page/widgets/missed_classes_badges_info_dialog.dart';
import 'package:schuldaten_hub/features/pupil/filters/pupils_filter.dart';
import 'package:schuldaten_hub/features/pupil/pages/widgets/common_pupil_filters.dart';
import 'package:schuldaten_hub/features/pupil/services/pupil_identity_manager.dart';
import 'package:schuldaten_hub/features/schooldays/services/schoolday_manager.dart';
import 'package:watch_it/watch_it.dart';

class AttendanceListPageBottomNavBar extends WatchingWidget {
  const AttendanceListPageBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    DateTime thisDate = watchValue((SchooldayManager x) => x.thisDate);
    bool filtersOn = watchValue((PupilsFilter x) => x.filtersOn);
    return BottomNavBarLayout(
      bottomNavBar: BottomAppBar(
        padding: const EdgeInsets.all(10),
        shape: null,
        color: backgroundColor,
        child: IconTheme(
          data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
          child: Row(
            children: <Widget>[
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
                  missedClassesBadgesInformationDialog(
                      context: context, isAttendancePage: true);
                },
              ),
              const Gap(30),
              IconButton(
                tooltip: 'Scan Kinder-IDs',
                icon: const Icon(
                  Icons.qr_code_scanner_rounded,
                  size: 30,
                ),
                onPressed: () {
                  locator<PupilIdentityManager>()
                      .scanNewPupilIdentities(context);
                },
              ),
              const Gap(30),
              InkWell(
                onTap: () async {
                  final DateTime? newDate =
                      await selectSchooldayDate(context, thisDate);
                  if (newDate != null) {
                    locator<SchooldayManager>().setThisDate(newDate);
                  }
                },
                onLongPress: () => locator<SchooldayManager>().getThisDate(),
                child: const Icon(
                  Icons.today_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const Gap(30),
              InkWell(
                onTap: () =>
                    showGenericFilterBottomSheet(context: context, filterList: [
                  const CommonPupilFiltersWidget(),
                  const AttendanceFilters(),
                ]),
                onLongPress: () => locator<PupilsFilter>().resetFilters(),
                child: Icon(
                  Icons.filter_list,
                  color: filtersOn ? Colors.deepOrange : Colors.white,
                  size: 30,
                ),
              ),
              const Gap(15)
            ],
          ),
        ),
      ),
    );
  }
}
