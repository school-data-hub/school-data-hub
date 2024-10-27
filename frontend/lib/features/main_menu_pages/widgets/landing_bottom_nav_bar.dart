import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/constants/enums.dart';
import 'package:schuldaten_hub/common/services/env_manager.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_manager.dart';
import 'package:schuldaten_hub/common/widgets/bottom_nav_bar_layouts.dart';
import 'package:schuldaten_hub/common/widgets/dialogues/information_dialog.dart';
import 'package:schuldaten_hub/common/widgets/snackbars.dart';
import 'package:schuldaten_hub/features/main_menu_pages/learn_list_page.dart';
import 'package:schuldaten_hub/features/main_menu_pages/pupil_lists_menu_page.dart';
import 'package:schuldaten_hub/features/main_menu_pages/scan_tools_page.dart';
import 'package:schuldaten_hub/features/main_menu_pages/school_lists_page.dart';
import 'package:schuldaten_hub/features/main_menu_pages/settings_page.dart';
import 'package:watch_it/watch_it.dart';

class BottomNavManager {
  ValueListenable<int> get bottomNavState => _bottomNavState;
  ValueListenable<int> get pupilProfileNavState => _pupilProfileNavState;
  ValueListenable<PageController> get pageViewController => _pageViewController;
  final _bottomNavState = ValueNotifier<int>(0);
  final _pageViewController = ValueNotifier<PageController>(PageController());
  final _pupilProfileNavState = ValueNotifier<int>(0);
  BottomNavManager() {
    _bottomNavState.value = 0;
    _pageViewController.value = PageController();
  }
  setBottomNavPage(index) {
    _bottomNavState.value = index;
  }

  setPupilProfileNavPage(index) {
    _pupilProfileNavState.value = index;
  }

  disposePageViewController() {
    _pageViewController.value.dispose();
  }
}

class BottomNavigation extends WatchingWidget {
  BottomNavigation({super.key});

  final List pages = [
    const PupilListsMenuPage(),
    const SchoolListsMenuPage(),
    const LearnListPage(),
    const ScanToolsPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final manager = locator<BottomNavManager>();
    final tab = watchValue((BottomNavManager x) => x.bottomNavState);
    final pageViewController =
        watchValue((BottomNavManager x) => x.pageViewController);
    registerHandler(
        select: (NotificationManager x) => x.notification,
        handler: (context, value, cancel) {
          value.type == NotificationType.infoDialog
              ? informationDialog(context, 'Info', value.message)
              : snackbar(context, value.type, value.message);
        });

    registerHandler(
        select: (NotificationManager x) => x.heavyLoading,
        handler: (context, value, cancel) {
          value ? showLoadingOverlay(context) : hideLoadingOverlay();
        });

    return Scaffold(
      backgroundColor: canvasColor,
      body: PageView(
        controller: pageViewController,
        children: const <Widget>[
          PupilListsMenuPage(),
          SchoolListsMenuPage(),
          LearnListPage(),
          ScanToolsPage(),
          SettingsPage(),
        ],
        onPageChanged: (index) => manager.setBottomNavPage(index),
      ),
      bottomNavigationBar: BottomNavBarLayout(
        bottomNavBar: BottomNavigationBar(
          iconSize: 28,
          onTap: (index) {
            manager.setBottomNavPage(index);
            pageViewController.animateToPage(index,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeIn);
            //BottomNavManager().setBottomNavPage(index);
          },
          showSelectedLabels: true,
          currentIndex: tab,
          selectedItemColor: accentColor,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: const Icon(Icons.account_box_rounded),
              label: locale.pupilLists,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.list),
              label: locale.schoolLists,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.lightbulb),
              label: locale.learningLists,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.qr_code_scanner),
              label: locale.scanTools,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings),
              label: locale.settings,
            ),
          ],

          //onTap:
        ),
      ),
    );
  }
}

OverlayEntry? overlayEntry;

void showLoadingOverlay(BuildContext context) {
  final locale = AppLocalizations.of(context)!;
  overlayEntry = OverlayEntry(
    builder: (context) => Stack(
      fit: StackFit.expand,
      children: [
        const ModalBarrier(
          dismissible: false,
          color: backgroundColor, // Colors.black.withOpacity(0.3)
        ), // Background color
        Material(
          color: Colors.transparent,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 300,
                  width: 300,
                  child: Image(
                    image: AssetImage('assets/foreground.png'),
                  ),
                ),
                Text(
                  locale.schoolDataHub,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
                const Gap(15),
                if (locator<EnvManager>().env.value.server != null)
                  Text(
                    locator<EnvManager>().env.value.server!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                const Gap(10),
                const Text('Instanzdaten werden geladen!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    )),
                const Gap(5),
                const Text(
                  'Bitte warten...', // Your text here
                  style: TextStyle(
                      color: Colors.white, // Text color
                      fontSize: 20,
                      fontWeight: FontWeight.bold // Text size
                      ),
                ),
                const SizedBox(height: 16),
                const CircularProgressIndicator(
                  color: accentColor,
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Overlay.of(context).insert(overlayEntry!);
}

void hideLoadingOverlay() {
  overlayEntry?.remove();
  overlayEntry = null;
}
