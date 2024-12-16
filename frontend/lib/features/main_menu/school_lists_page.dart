import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:schuldaten_hub/common/theme/colors.dart';
import 'package:schuldaten_hub/common/theme/styles.dart';
import 'package:schuldaten_hub/features/authorizations/presentation/authorizations_list_page/authorizations_list_page.dart';
import 'package:schuldaten_hub/features/main_menu/widgets/main_menu_button.dart';
import 'package:schuldaten_hub/features/school_lists/presentation/school_lists_page/school_lists_page.dart';
import 'package:watch_it/watch_it.dart';

class SchoolListsMenuPage extends WatchingWidget {
  const SchoolListsMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.canvasColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.backgroundColor,
        title: Text(
          locale.checkLists,
          style: AppStyles.appBarTextStyle,
        ),
      ),
      body: Center(
        child: SizedBox(
          width: 380,
          height: 380,
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            padding: const EdgeInsets.all(20),
            physics: const NeverScrollableScrollPhysics(),
            children: [
              MainMenuButton(
                  destinationPage: const SchoolListsPage(),
                  buttonIcon: const Icon(
                    Icons.rule,
                    size: 50,
                    color: AppColors.gridViewColor,
                  ),
                  buttonText: locale.lists),
              MainMenuButton(
                  destinationPage: const AuthorizationsListPage(),
                  buttonIcon: const Icon(
                    Icons.fact_check_rounded,
                    size: 50,
                    color: AppColors.gridViewColor,
                  ),
                  buttonText: locale.authorizations)
            ],
          ),
        ),
      ),
    );
  }
}
