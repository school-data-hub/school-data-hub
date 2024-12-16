import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:schuldaten_hub/common/domain/env_manager.dart';
import 'package:schuldaten_hub/common/domain/session_manager.dart';
import 'package:schuldaten_hub/common/domain/models/enums.dart';
import 'package:schuldaten_hub/common/domain/models/env.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_service.dart';
import 'package:schuldaten_hub/common/utils/scanner.dart';
import 'package:schuldaten_hub/features/main_menu/loading_page.dart';
import 'package:schuldaten_hub/features/main_menu/login_page/login_page.dart';
import 'package:watch_it/watch_it.dart';

class Login extends WatchingStatefulWidget {
  const Login({super.key});

  @override
  LoginController createState() => LoginController();
}

class LoginController extends State<Login> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  late Map<String, Env> envs;
  late Env activeEnv;
  String selectedEnv = '';

  @override
  initState() {
    super.initState();
    envs = locator<EnvManager>().envs.value;
    activeEnv = locator<EnvManager>().env.value;
    selectedEnv = activeEnv.server!;
  }

  void changeEnv(String? envName) {
    setState(() {
      selectedEnv = envName!;
      locator<EnvManager>().activateEnv(envName: envName);
    });
  }

  scanCredentials(BuildContext context) async {
    final locale = AppLocalizations.of(context)!;
    final String? scanResponse = await scanner(context, locale.scanAccessCode);
    if (scanResponse != null) {
      final loginData = await json.decode(scanResponse);
      final String username = loginData['username'];
      final String password = loginData['password'];

      attemptLogin(username: username, password: password);
    } else {
      locator<NotificationService>()
          .showSnackBar(NotificationType.warning, locale.scanAborted);

      return;
    }
  }

  scanEnv(BuildContext context) async {
    final locale = AppLocalizations.of(context)!;
    final String? scanResponse = await scanner(context, locale.scanSchoolId);
    if (scanResponse != null) {
      locator<EnvManager>().importNewEnv(scanResponse);

      return;
    } else {
      locator<NotificationService>()
          .showSnackBar(NotificationType.warning, 'Keine Daten gescannt');
      return;
    }
  }

  List<DropdownMenuItem<String>> get envDropdownItems {
    return envs.keys
        .map((String key) => DropdownMenuItem<String>(
              value: key,
              child: Text(key),
            ))
        .toList();
  }

  Future<void> loginWithTextCredentials() async {
    final String username = usernameController.text;
    final String password = passwordController.text;
    await attemptLogin(username: username, password: password);
  }

  Future<void> attemptLogin(
      {required String username, required String password}) async {
    await locator<SessionManager>()
        .attemptLogin(username: username, password: password);
  }

  Future<void> importEnvFromTxt() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      String rawTextResult = await file.readAsString();
      locator<EnvManager>().importNewEnv(rawTextResult);
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