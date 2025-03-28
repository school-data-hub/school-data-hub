import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/theme/app_colors.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/widgets/bottom_nav_bar_layouts.dart';
import 'package:schuldaten_hub/features/pupil/presentation/credit/credit_list_page/widgets/credit_filter_bottom_sheet.dart';
import 'package:schuldaten_hub/features/users/presentation/new_user_page/new_user_page.dart';

import '../../../../pupil/domain/filters/pupil_filter_manager.dart';

Widget usersListPageBottomNavBar(
  BuildContext context,
) {
  return BottomNavBarLayout(
    bottomNavBar: BottomAppBar(
      padding: const EdgeInsets.all(10),
      shape: null,
      color: AppColors.backgroundColor,
      child: IconTheme(
        data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Row(
            children: [
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
                tooltip: 'neues Konto',
                icon: const Icon(
                  Icons.add,
                  size: 30,
                ),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (ctx) => const NewUserPage(),
                  ));
                },
              ),
              const Gap(30),
              IconButton(
                  tooltip: 'Zur Startseite',
                  onPressed: () =>
                      Navigator.popUntil(context, (route) => route.isFirst),
                  icon: const Icon(
                    Icons.home,
                    size: 35,
                  )),
              const Gap(30),
              InkWell(
                onTap: () => showCreditFilterBottomSheet(context),
                onLongPress: () => locator<PupilFilterManager>().resetFilters(),
                child: const Icon(
                  Icons.filter_list,
                  color: Colors
                      .white, //filtersOn ? Colors.deepOrange : Colors.white,
                  size: 30,
                ),
              ),
              const Gap(15)
            ],
          ),
        ),
      ),
    ),
  );
}
