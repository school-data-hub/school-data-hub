import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/domain/env_manager.dart';
import 'package:schuldaten_hub/common/domain/models/enums.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_service.dart';
import 'package:schuldaten_hub/common/theme/app_colors.dart';
import 'package:schuldaten_hub/common/widgets/bottom_nav_bar_layouts.dart';
import 'package:schuldaten_hub/common/widgets/dialogs/information_dialog.dart';
import 'package:schuldaten_hub/common/widgets/snackbars.dart';
import 'package:schuldaten_hub/features/main_menu/main_menu_pages/learn_resources_menu_page.dart';
import 'package:schuldaten_hub/features/main_menu/main_menu_pages/pupil_lists_menu_page.dart';
import 'package:schuldaten_hub/features/main_menu/main_menu_pages/school_lists_page.dart';
import 'package:schuldaten_hub/features/main_menu/scan_tools_page.dart';
import 'package:schuldaten_hub/features/main_menu/settings_page/settings_page.dart';
import 'package:watch_it/watch_it.dart';

class MainMenuBottomNavManager {
  final _bottomNavState = ValueNotifier<int>(0);
  ValueListenable<int> get bottomNavState => _bottomNavState;

  final _pageViewController = ValueNotifier<PageController>(PageController());
  ValueListenable<PageController> get pageViewController => _pageViewController;

  final _pupilProfileNavState = ValueNotifier<int>(0);
  ValueListenable<int> get pupilProfileNavState => _pupilProfileNavState;

  MainMenuBottomNavManager() {
    _bottomNavState.value = 0;
    _pageViewController.value = PageController();
  }

  setBottomNavPage(int index) {
    _bottomNavState.value = index;
  }

  setPupilProfileNavPage(int index) {
    _pupilProfileNavState.value = index;
  }

  disposePageViewController() {
    _pageViewController.value.dispose();
  }
}

class MainMenuBottomNavigation extends WatchingWidget {
  MainMenuBottomNavigation({super.key});

  final List pages = [
    const PupilListsMenuPage(),
    const SchoolListsMenuPage(),
    const LearnResourcesMenuPage(),
    const ScanToolsPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final manager = locator<MainMenuBottomNavManager>();
    final tab = watchValue((MainMenuBottomNavManager x) => x.bottomNavState);
    final pageViewController =
        watchValue((MainMenuBottomNavManager x) => x.pageViewController);

    // with these handlers we control the overlays of the notification service
    registerHandler(
        select: (NotificationService x) => x.notification,
        handler: (context, value, cancel) {
          value.type == NotificationType.infoDialog
              ? informationDialog(context, 'Info', value.message)
              : snackbar(context, value.type, value.message);
        });

    registerHandler(
        select: (NotificationService x) => x.loadingNewInstance,
        handler: (context, value, cancel) {
          value ? showInstanceLoadingOverlay(context) : hideLoadingOverlay();
        });

    registerHandler(
        select: (NotificationService x) => x.heavyLoading,
        handler: (context, value, cancel) {
          value ? showHeavyLoadingOverlay(context) : hideLoadingOverlay();
        });

    return Scaffold(
      backgroundColor: AppColors.canvasColor,
      body: PageView(
        controller: pageViewController,
        children: const <Widget>[
          PupilListsMenuPage(),
          SchoolListsMenuPage(),
          LearnResourcesMenuPage(),
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
          selectedItemColor: AppColors.accentColor,
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

void showInstanceLoadingOverlay(BuildContext context) {
  final locale = AppLocalizations.of(context)!;
  overlayEntry = OverlayEntry(
    builder: (context) => Stack(
      fit: StackFit.expand,
      children: [
        const ModalBarrier(
          dismissible: false,
          color: AppColors.backgroundColor, // Colors.black.withOpacity(0.3)
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
                if (locator<EnvManager>().env != null)
                  Text(
                    locator<EnvManager>().env!.server,
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
                  color: AppColors.accentColor,
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

void showHeavyLoadingOverlay(BuildContext context) {
  overlayEntry = OverlayEntry(
    builder: (context) => const Stack(
      fit: StackFit.expand,
      children: [
        ModalBarrier(
          dismissible: false,
          color: Color.fromARGB(108, 0, 0, 0), // Colors.black.withOpacity(0.3)
        ), // Background color
        Material(
          color: Colors.transparent,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Bitte warten...', // Your text here
                    style: TextStyle(
                        color: Colors.white, // Text color
                        fontSize: 20, // Text size
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                CircularProgressIndicator(
                  color: AppColors.interactiveColor,
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
