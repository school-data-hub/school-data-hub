import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/widgets/bottom_nav_bar_layouts.dart';
import 'package:schuldaten_hub/features/learning_support/pages/learning_support_list_page/widgets/learning_support_list_filter_bottom_sheet.dart';
import 'package:schuldaten_hub/features/pupil/filters/pupils_filter.dart';

class LearningSupportListPageBottomNavBar extends StatelessWidget {
  final bool filtersOn;
  const LearningSupportListPageBottomNavBar(
      {required this.filtersOn, super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavBarLayout(
      bottomNavBar: BottomAppBar(
        padding: const EdgeInsets.all(15),
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
              InkWell(
                onTap: () => showLearningSupportFilterBottomSheet(context),
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
