import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/constants/enums.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/widgets/generic_filter_bottom_sheet.dart';
import 'package:schuldaten_hub/common/widgets/search_text_field.dart';
import 'package:schuldaten_hub/features/attendance/pages/attendance_page/widgets/attendance_filters.dart';
import 'package:schuldaten_hub/features/attendance/services/attendance_helper_functions.dart';
import 'package:schuldaten_hub/features/pupil/filters/pupils_filter.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';
import 'package:schuldaten_hub/features/pupil/pages/widgets/common_pupil_filters.dart';
import 'package:watch_it/watch_it.dart';

class AttendanceListSearchBar extends WatchingWidget {
  final List<PupilProxy> pupils;

  final DateTime thisDate;
  const AttendanceListSearchBar(
      {required this.pupils, required this.thisDate, super.key});

  @override
  Widget build(BuildContext context) {
    bool filtersOn = watchValue((PupilsFilter x) => x.filtersOn);
    return Container(
      decoration: BoxDecoration(
        color: canvasColor,
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
                    color: backgroundColor,
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
                    AttendanceHelper.unexcusedPupilsSum(pupils, thisDate)
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
                    child: SearchTextField(
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
                  onLongPress: () => locator<PupilsFilter>().resetFilters(),
                  // onPressed: () => showBottomSheetFilters(context),
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
