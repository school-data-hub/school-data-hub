import 'package:schuldaten_hub/features/attendance/presentation/attendance_page/attendance_list_page.dart';
import 'package:schuldaten_hub/features/main_menu/main_menu_pages/learn_resources_menu_page.dart';
import 'package:schuldaten_hub/features/main_menu/login_page/login_controller.dart';
import 'package:schuldaten_hub/features/main_menu/scan_tools_page.dart';
import 'package:schuldaten_hub/features/main_menu/settings_page/settings_page.dart';
import 'package:schuldaten_hub/features/main_menu/widgets/landing_bottom_nav_bar.dart';
import 'package:schuldaten_hub/main.dart';

import 'routes.dart';

//- TODO: The routing is not yet implemented

class AppRoutes {
  static final routes = {
    Routes.start: (context) => const MyApp(),
    Routes.login: (context) => const Login(),
    Routes.home: (context) => MainMenuBottomNavigation(),
    Routes.attendanceList: (context) => const AttendanceListPage(),
    Routes.learnList: (context) => const LearnResourcesMenuPage(),
    Routes.qrTools: (context) => const ScanToolsPage(),
    Routes.settings: (context) => const SettingsPage()
  };
}
