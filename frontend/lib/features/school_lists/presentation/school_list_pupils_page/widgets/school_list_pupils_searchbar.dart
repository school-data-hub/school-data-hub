import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/domain/models/enums.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/theme/colors.dart';
import 'package:schuldaten_hub/common/widgets/filter_button.dart';
import 'package:schuldaten_hub/common/widgets/generic_filter_bottom_sheet.dart';
import 'package:schuldaten_hub/common/widgets/search_text_field.dart';
import 'package:schuldaten_hub/features/pupil/domain/filters/pupils_filter.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_proxy.dart';
import 'package:schuldaten_hub/features/pupil/presentation/widgets/common_pupil_filters.dart';
import 'package:schuldaten_hub/features/school_lists/domain/models/school_list.dart';
import 'package:schuldaten_hub/features/school_lists/domain/school_list_helper_functions.dart';
import 'package:schuldaten_hub/features/school_lists/presentation/school_list_pupils_page/widgets/school_list_pupil_filters_widget.dart';
import 'package:schuldaten_hub/features/school_lists/presentation/school_list_pupils_page/widgets/school_list_stats_row.dart';
import 'package:watch_it/watch_it.dart';

class SchoolListPupilsPageSearchBar extends WatchingWidget {
  final SchoolList schoolList;
  final List<PupilProxy> pupilsInList;

  const SchoolListPupilsPageSearchBar(
      {required this.pupilsInList, required this.schoolList, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.canvasColor,
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.00),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          schoolList.listDescription,
                          style: const TextStyle(
                              fontSize: 15, color: Colors.black),
                        ),
                      ],
                    ),
                    const Gap(10),
                    Row(
                      children: [
                        schoolListStatsRow(schoolList, pupilsInList),
                        const Gap(10),
                        schoolList.visibility != 'public'
                            ? Text(
                                schoolList.createdBy,
                                style: const TextStyle(
                                    color: AppColors.backgroundColor,
                                    fontWeight: FontWeight.bold),
                              )
                            : const Icon(
                                Icons.school_rounded,
                                color: AppColors.backgroundColor,
                              ),
                        Text(
                          SchoolListHelper.listOwners(schoolList),
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const Gap(10),
                      ],
                    ),
                  ],
                ),
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
                const Gap(5),
                FilterButton(
                    isSearchBar: false,
                    showBottomSheetFunction: () => showGenericFilterBottomSheet(
                          context: context,
                          filterList: [
                            const CommonPupilFiltersWidget(),
                            const SchoolListPupilFiltersWidget(),
                          ],
                        )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
