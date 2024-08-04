import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:schuldaten_hub/common/constants/enums.dart';
import 'package:schuldaten_hub/common/services/env_manager.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/session_manager.dart';
import 'package:schuldaten_hub/common/services/notification_manager.dart';
import 'package:schuldaten_hub/common/utils/scanner.dart';
import 'package:schuldaten_hub/features/main_menu_pages/loading_page.dart';
import 'package:schuldaten_hub/features/main_menu_pages/login_page/login_page.dart';
import 'package:watch_it/watch_it.dart';

class Login extends WatchingStatefulWidget {
  const Login({super.key});

  @override
  LoginController createState() => LoginController();
}

class LoginController extends State<Login> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  scanCredentials(BuildContext context) async {
    final locale = AppLocalizations.of(context)!;
    final String? scanResponse = await scanner(context, locale.scanAccessCode);
    if (scanResponse != null) {
      final loginData = await json.decode(scanResponse);
      final String username = loginData['username'];
      final String password = loginData['password'];

      attemptLogin(username: username, password: password);
    } else {
      locator<NotificationManager>()
          .showSnackBar(NotificationType.warning, locale.scanAborted);

      return;
    }
  }

  scanEnv(BuildContext context) async {
    final locale = AppLocalizations.of(context)!;
    final String? scanResponse = await scanner(context, locale.scanSchoolId);
    if (scanResponse != null) {
      locator<EnvManager>().setEnv(scanResponse);
      locator<NotificationManager>().showSnackBar(NotificationType.success, '');
      return;
    } else {
      locator<NotificationManager>().showSnackBar(NotificationType.warning, '');
      return;
    }
  }

  loginWithTextCredentials() {
    final String username = usernameController.text;
    final String password = passwordController.text;
    attemptLogin(username: username, password: password);
  }

  attemptLogin({required String username, required String password}) async {
    await locator<SessionManager>().attemptLogin(username, password);
  }

  importEnvFromTxt() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      String rawTextResult = await file.readAsString();
      locator<EnvManager>().setEnv(rawTextResult);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: locator.allReady(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return LoginPage(this);
        } else {
          return const LoadingPage();
        }
      },
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
