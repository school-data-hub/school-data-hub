import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/theme/colors.dart';
import 'package:schuldaten_hub/common/widgets/bottom_nav_bar_layouts.dart';
import 'package:schuldaten_hub/common/widgets/filter_button.dart';
import 'package:schuldaten_hub/features/ogs/widgets/ogs_filter_bottom_sheet.dart';

class OgsListPageBottomNavBar extends StatelessWidget {
  final bool filtersOn;
  const OgsListPageBottomNavBar({required this.filtersOn, super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavBarLayout(
      bottomNavBar: BottomAppBar(
        height: 60,
        padding: const EdgeInsets.all(10),
        shape: null,
        color: AppColors.backgroundColor,
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
              const FilterButton(
                  isSearchBar: true,
                  showBottomSheetFunction: showOgsFilterBottomSheet),
              const Gap(15)
            ],
          ),
        ),
      ),
    );
  }
}
