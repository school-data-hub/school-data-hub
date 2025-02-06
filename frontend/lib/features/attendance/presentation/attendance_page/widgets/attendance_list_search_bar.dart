import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/domain/filters/filters_state_manager.dart';
import 'package:schuldaten_hub/common/domain/models/enums.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/theme/app_colors.dart';
import 'package:schuldaten_hub/common/widgets/list_view_components/generic_filter_bottom_sheet.dart';
import 'package:schuldaten_hub/features/attendance/domain/attendance_helper_functions.dart';
import 'package:schuldaten_hub/features/attendance/presentation/attendance_page/widgets/attendance_filters.dart';
import 'package:schuldaten_hub/features/pupil/domain/filters/pupils_filter.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_proxy.dart';
import 'package:schuldaten_hub/features/pupil/presentation/widgets/common_pupil_filters.dart';
import 'package:schuldaten_hub/features/pupil/presentation/widgets/pupil_search_text_field.dart';
import 'package:schuldaten_hub/features/schooldays/domain/schoolday_manager.dart';
import 'package:watch_it/watch_it.dart';

class AttendanceListSearchBar extends WatchingWidget {
  final List<PupilProxy> pupils;

  const AttendanceListSearchBar({required this.pupils, super.key});

  @override
  Widget build(BuildContext context) {
    DateTime thisDate = watchValue((SchooldayManager x) => x.thisDate);

    bool filtersOn = watchValue((FiltersStateManager x) => x.filtersActive);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.canvasColor,
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Column(
        children: [
          const Gap(5),
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.people_alt_rounded,
                    color: AppColors.backgroundColor,
                  ),
                  const Gap(10),
                  Text(
                    pupils.length.toString(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const Gap(15),
                  const Text(
                    'Anwesend: ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                    ),
                  ),
                  const Gap(5),
                  Text(
                    (pupils.length -
                            AttendanceHelper.missedPupilsSum(pupils, thisDate))
                        .toString(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const Gap(15),
                  const Text(
                    'Unent. ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                    ),
                  ),
                  const Gap(5),
                  Text(
                    AttendanceHelper.missedAndUnexcusedPupilsSum(
                            pupils, thisDate)
                        .toString(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
            child: Row(
              children: [
                Expanded(
                    child: PupilSearchTextField(
                        searchType: SearchType.pupil,
                        hintText: 'Schüler/in suchen',
                        refreshFunction: locator<PupilsFilter>().refreshs)),
                InkWell(
                  onTap: () => showGenericFilterBottomSheet(
                      context: context,
                      filterList: const [
                        CommonPupilFiltersWidget(),
                        AttendanceFilters(),
                      ]),
                  onLongPress: () =>
                      locator<FiltersStateManager>().resetFilters(),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Icon(
                      Icons.filter_list,
                      color: filtersOn ? Colors.deepOrange : Colors.grey,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
