import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/domain/models/enums.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/theme/app_colors.dart';
import 'package:schuldaten_hub/common/widgets/filter_button.dart';
import 'package:schuldaten_hub/features/pupil/presentation/widgets/pupil_search_text_field.dart';
import 'package:schuldaten_hub/features/ogs/widgets/ogs_filter_bottom_sheet.dart';
import 'package:schuldaten_hub/features/pupil/domain/filters/pupils_filter.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_proxy.dart';

class OgsListSearchBar extends StatelessWidget {
  final List<PupilProxy> pupils;
  final bool filtersOn;
  const OgsListSearchBar(
      {required this.pupils, required this.filtersOn, super.key});

  @override
  Widget build(BuildContext context) {
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.people_alt_rounded,
                  color: AppColors.backgroundColor,
                ),
                const Gap(5),
                Text(
                  pupils.length.toString(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
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
                const Gap(5),
                const FilterButton(
                    isSearchBar: true,
                    showBottomSheetFunction: showOgsFilterBottomSheet),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
