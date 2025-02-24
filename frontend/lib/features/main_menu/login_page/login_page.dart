import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/domain/env_manager.dart';
import 'package:schuldaten_hub/common/domain/session_manager.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_service.dart';
import 'package:schuldaten_hub/common/theme/app_colors.dart';
import 'package:schuldaten_hub/common/theme/styles.dart';
import 'package:schuldaten_hub/common/utils/logger.dart';
import 'package:schuldaten_hub/common/widgets/dialogs/confirmation_dialog.dart';
import 'package:schuldaten_hub/common/widgets/snackbars.dart';
import 'package:schuldaten_hub/features/main_menu/login_page/login_controller.dart';
import 'package:schuldaten_hub/features/main_menu/login_page/widgets/environments_dropdown.dart';
import 'package:schuldaten_hub/features/main_menu/widgets/landing_bottom_nav_bar.dart';
import 'package:watch_it/watch_it.dart';

class LoginPage extends WatchingWidget {
  final LoginController controller;
  const LoginPage(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    registerHandler(
      select: (NotificationService x) => x.notification,
      handler: (context, value, cancel) =>
          snackbar(context, value.type, value.message),
    );
    bool isAuthenticated = watchValue((SessionManager x) => x.isAuthenticated);
    bool envReady = watchValue((EnvManager x) => x.envReady);
    final locale = AppLocalizations.of(context)!;
    logger.w('# LoginPage | isAuthenticated: ${isAuthenticated.toString()}');
    final bool keyboardOn = MediaQuery.of(context).viewInsets.vertical > 0.0;
    //FocusScopeNode currentFocus = FocusScope.of(context);

    return (envReady && isAuthenticated)
        ? MainMenuBottomNavigation()
        : Scaffold(
            resizeToAvoidBottomInset: true,
            body: Container(
              color: AppColors.backgroundColor,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                          padding: keyboardOn
                              ? const EdgeInsets.only(top: 70)
                              : Platform.isWindows
                                  ? const EdgeInsets.only(top: 0)
                                  : const EdgeInsets.only(top: 0)),
                      keyboardOn
                          ? const SizedBox.shrink()
                          : const SizedBox(
                              height: 250,
                              width: 250,
                              child: Image(
                                image:
                                    AssetImage('assets/foreground_windows.png'),
                              ),
                            ),
                      const Gap(20),
                      Text(
                        locale.schoolDataHub,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                      ),
                      const Gap(10),
                      if (controller.envs.isNotEmpty)
                        controller.envs.length > 1
                            ? EnvironmentsDropdown(
                                selectedEnv: controller.selectedEnv,
                                changeEnv: controller.changeEnv,
                              )
                            : Text(
                                controller.envs.keys.first,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                      keyboardOn
                          ? const SizedBox(
                              height: 15,
                            )
                          : const SizedBox(
                              height: 15,
                            ),
                      if (envReady) ...<Widget>[
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 380),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 25.0, vertical: 8),
                            child: TextField(
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                              controller: controller.usernameController,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 5),
                                filled: true,
                                fillColor: Colors.white,
                                labelText: locale.userName,
                                labelStyle: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: Color.fromRGBO(74, 76, 161, 1),
                                ),
                              ),
                            ),
                          ),
                        ),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 380),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 25.0, vertical: 8),
                            child: TextField(
                              textDirection: null,
                              controller: controller.passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 5),
                                filled: true,
                                fillColor: Colors.white,
                                labelText: locale.password,
                                labelStyle: const TextStyle(
                                  color: AppColors.backgroundColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            //margin: const EdgeInsets.only(bottom: 16),
                            width: double.infinity,
                            child: ElevatedButton(
                              style: AppStyles.actionButtonStyle,
                              onPressed: () async {
                                // locator<EnvManager>().deleteEnv();
                                await controller.loginWithTextCredentials();
                              },
                              child: Text(
                                locale.logInButtonText,
                                style: const TextStyle(
                                    fontSize: 17.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            //margin: const EdgeInsets.only(bottom: 16),
                            width: double.infinity,
                            child: ElevatedButton(
                              style: AppStyles.actionButtonStyle,
                              onPressed: () async {
                                await confirmationDialog(
                                    context: context,
                                    title: locale.deleteKeyPrompt,
                                    message: locale
                                        .areYouSureYouWantToDeleteSchoolKey);
                                locator<EnvManager>().deleteEnv();
                              },
                              child: Text(
                                locale.deleteKeyButtonText,
                                style: const TextStyle(
                                    fontSize: 17.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                      if (envReady == false) ...<Widget>[
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Center(
                            child: Platform.isWindows
                                ? Text(
                                    locale.importSchoolDataToContinue,
                                    softWrap: true,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  )
                                : Text(
                                    locale.scanSchoolIdToContinue,
                                    softWrap: true,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                      const Gap(5),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          //margin: const EdgeInsets.only(bottom: 16),
                          child: ElevatedButton(
                              style: AppStyles.actionButtonStyle,
                              onPressed: () async {
                                envReady
                                    ? controller.scanCredentials(context)
                                    : Platform.isWindows
                                        ? controller.importEnvFromTxt()
                                        : controller.scanEnv(context);
                              },
                              child: Platform.isWindows
                                  ? Text(locale.chooseFileButton,
                                      style: AppStyles.buttonTextStyle)
                                  : Text(
                                      locale.scanButton,
                                      style: AppStyles.buttonTextStyle,
                                    )),
                        ),
                      ),
                      const Gap(10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          //margin: const EdgeInsets.only(bottom: 16),
                          child: ElevatedButton(
                              style: AppStyles.actionButtonStyle,
                              onPressed: () async {
                                controller.generateSchoolKeys(context);
                              },
                              child: const Text('SCHULSCHLÜSSEL ERSTELLEN',
                                  style: AppStyles.buttonTextStyle)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
