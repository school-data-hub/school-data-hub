import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:schuldaten_hub/common/theme/colors.dart';
import 'package:schuldaten_hub/common/theme/styles.dart';
import 'package:schuldaten_hub/features/main_menu/widgets/pupil_lists_buttons.dart';

class PupilListsMenuPage extends StatelessWidget {
  const PupilListsMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      primary: true,
      backgroundColor: AppColors.canvasColor,
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: AppColors.backgroundColor,
        ),
        centerTitle: true,
        backgroundColor: AppColors.backgroundColor,
        title: Text(
          locale.pupilLists,
          style: AppStyles.appBarTextStyle,
          textAlign: TextAlign.end,
        ),
      ),
      body: Center(
        child: SizedBox(
          width: Platform.isWindows ? 700 : 600,
          height: Platform.isWindows
              ? 600
              : MediaQuery.of(context).size.height * 0.9,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: const ScrollPhysics(),
            child: PupilListButtons(
              screenWidth: screenWidth,
            ),
          ),
        ),
      ),
    );
  }
}
