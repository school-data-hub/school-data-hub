import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/features/schooldays/services/schoolday_manager.dart';
import 'package:schuldaten_hub/common/widgets/generic_sliver_list.dart';
import 'package:schuldaten_hub/common/widgets/sliver_search_app_bar.dart';
import 'package:schuldaten_hub/features/attendance/services/attendance_helper_functions.dart';
import 'package:schuldaten_hub/features/attendance/services/attendance_manager.dart';
import 'package:schuldaten_hub/features/attendance/pages/attendance_page/widgets/atendance_list_card.dart';
import 'package:schuldaten_hub/features/attendance/pages/attendance_page/widgets/attendance_list_search_bar.dart';
import 'package:schuldaten_hub/features/attendance/pages/attendance_page/widgets/attendance_view_bottom_navbar.dart';
import 'package:schuldaten_hub/features/pupil/services/pupil_manager.dart';
import 'package:schuldaten_hub/features/pupil/filters/pupils_filter.dart';
import 'package:watch_it/watch_it.dart';

class AttendanceListPage extends WatchingStatefulWidget {
  const AttendanceListPage({super.key});
  @override
  State<AttendanceListPage> createState() => _AttendanceListPageState();
}

class _AttendanceListPageState extends State<AttendanceListPage> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    locator<PupilsFilter>().switchAttendanceFilters(true);

    locator<AttendanceManager>().fetchMissedClassesOnASchoolday(
        locator<SchooldayManager>().thisDate.value);

    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      locator<AttendanceManager>().fetchMissedClassesOnASchoolday(
          locator<SchooldayManager>().thisDate.value);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    locator<PupilsFilter>().switchAttendanceFilters(false);
    super.dispose();
  }

  final pupilManager = locator<PupilManager>();
  @override
  Widget build(BuildContext context) {
    DateTime thisDate = watchValue((SchooldayManager x) => x.thisDate);
    List<int> pupilIds = watchValue((PupilsFilter x) => x.filteredPupilIds);

    return Scaffold(
      backgroundColor: canvasColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: backgroundColor,
        title: InkWell(
          onTap: () async => AttendanceHelper.setThisDate(context, thisDate),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(
                Icons.today_rounded,
                color: AttendanceHelper.schooldayIsToday(thisDate)
                    ? const Color.fromARGB(255, 83, 196, 55)
                    : Colors.white,
                size: 30,
              ),
              const Gap(10),
              Text(
                AttendanceHelper.thisDateAsString(context, thisDate),
                style: const TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async => locator<AttendanceManager>()
            .fetchMissedClassesOnASchoolday(thisDate),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: CustomScrollView(
              slivers: [
                const SliverGap(5),
                SliverSearchAppBar(
                    height: 110,
                    title: AttendanceListSearchBar(
                      pupils: pupilManager.pupilsFromPupilIds(pupilIds),
                      thisDate: thisDate,
                    )),
                GenericSliverListWithEmptyListCheck(
                    items: pupilIds,
                    itemBuilder: (_, pupilId) =>
                        AttendanceCard(pupilId, thisDate)),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AttendanceListPageBottomNavBar(),
    );
  }
}
