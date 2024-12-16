import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:schuldaten_hub/common/domain/env_manager.dart';
import 'package:schuldaten_hub/common/domain/session_manager.dart';
import 'package:schuldaten_hub/common/routes/app_routes.dart';
import 'package:schuldaten_hub/common/services/connection_manager.dart';
import 'package:schuldaten_hub/common/theme/colors.dart';
import 'package:schuldaten_hub/features/main_menu/loading_page.dart';
import 'package:schuldaten_hub/features/main_menu/login_page/login_controller.dart';
import 'package:schuldaten_hub/features/main_menu/no_connection_page.dart';
import 'package:schuldaten_hub/features/main_menu/widgets/landing_bottom_nav_bar.dart';
import 'package:watch_it/watch_it.dart';
import 'package:window_manager/window_manager.dart';

import 'common/services/locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // using package window_manager for windows window size
  if (Platform.isWindows) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(1200, 800),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
  // set status bar color
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle().copyWith(
      statusBarColor: AppColors.backgroundColor,
      statusBarBrightness: Brightness.light,
    ),
  );

  registerBaseManagers();
  await locator.allReady();

  // await locator.isReady<EnvManager>();
  // await locator.isReady<ConnectionManager>();
  // await locator.isReady<SessionManager>();
  // await locator.isReady<PupilIdentityManager>();

  runApp(const MyApp());
  // TODO: INFO - This is a hack to avoid calls to firebase from the mobile_scanner package every 15 minutes
  // like described here: https://github.com/juliansteenbakker/mobile_scanner/issues/553
  if (Platform.isAndroid) {
    final dir = await getApplicationDocumentsDirectory();
    final path = dir.parent.path;
    final file =
        File('$path/databases/com.google.android.datatransport.events');
    await file.writeAsString('Fake');
  }
}

class MyApp extends WatchingWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    bool envIsReady = watchValue((EnvManager x) => x.envReady);
    bool isAuthenticated = watchValue((SessionManager x) => x.isAuthenticated);

    AsyncSnapshot<List<ConnectivityResult>?> connectionStatus =
        watchStream((ConnectionManager x) => x.connectivity.value);

    bool isConnected = connectionStatus.hasData
        ? connectionStatus.data!.last != ConnectivityResult.none
            ? true
            : false
        : false;

    return ProviderScope(
      child: MaterialApp(
        localizationsDelegates: const <LocalizationsDelegate<Object>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('de', 'DE'), // Set the default locale to German
          // Locale('en', 'EN'), // Set the default locale to German
        ],
        debugShowCheckedModeBanner: false,
        title: 'Schuldaten Hub',
        // theme: lightTheme,
        // darkTheme: darkTheme,
        routes: AppRoutes.routes,
        home: !isConnected
            ? const NoConnectionPage()
            : envIsReady && isAuthenticated
                ? FutureBuilder(
                    future: locator.allReady(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return BottomNavigation();
                      } else {
                        return const LoadingPage();
                      }
                    },
                  )
                : const Login(),
      ),
    );
  }
}
