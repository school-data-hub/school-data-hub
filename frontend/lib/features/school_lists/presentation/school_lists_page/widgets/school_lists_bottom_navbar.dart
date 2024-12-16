import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/theme/colors.dart';
import 'package:schuldaten_hub/common/widgets/bottom_nav_bar_layouts.dart';
import 'package:schuldaten_hub/features/school_lists/presentation/new_list_page/new_school_list_page.dart';

class SchoolListsBottomNavBar extends StatelessWidget {
  const SchoolListsBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavBarLayout(
      bottomNavBar: BottomAppBar(
        padding: const EdgeInsets.all(9),
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
                  size: 35,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const Gap(15),
              IconButton(
                tooltip: 'Neue Liste',
                icon: const Icon(
                  Icons.add,
                  size: 35,
                ),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (ctx) => const NewSchoolListPage(),
                  ));
                },
              ),
              const Gap(15)
            ],
          ),
        ),
      ),
    );
  }
}
