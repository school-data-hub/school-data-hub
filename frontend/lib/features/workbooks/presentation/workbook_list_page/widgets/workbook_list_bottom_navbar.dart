import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/theme/app_colors.dart';
import 'package:schuldaten_hub/common/widgets/bottom_nav_bar_layouts.dart';
import 'package:schuldaten_hub/features/workbooks/presentation/new_workbook_page/new_workbook_controller.dart';

Widget workbookListBottomNavBar(BuildContext context) {
  return BottomNavBarLayout(
    bottomNavBar: BottomAppBar(
      height: 60,
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
              tooltip: 'Neues Arbeitsheft',
              icon: const Icon(
                Icons.add,
                size: 35,
              ),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (ctx) => const NewWorkbook(isEdit: false),
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
