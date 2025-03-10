import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:schuldaten_hub/common/domain/env_manager.dart';
import 'package:schuldaten_hub/common/domain/models/session.dart';
import 'package:schuldaten_hub/common/domain/session_manager.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/theme/app_colors.dart';
import 'package:schuldaten_hub/common/theme/styles.dart';
import 'package:schuldaten_hub/features/main_menu/settings_page/widgets/settings_admin_section.dart';
import 'package:schuldaten_hub/features/main_menu/settings_page/widgets/settings_session_section.dart';
import 'package:schuldaten_hub/features/main_menu/settings_page/widgets/settings_tools_section.dart';
import 'package:watch_it/watch_it.dart';

class SettingsPage extends WatchingWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final Session session = watchValue((SessionManager x) => x.credentials);

    final bool isAdmin = session.isAdmin!;

    return Scaffold(
      backgroundColor: AppColors.canvasColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.backgroundColor,
        title: Text(
          locale.settings,
          style: AppStyles.appBarTextStyle,
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SettingsList(
            contentPadding: const EdgeInsets.only(top: 10),
            sections: [
              const SettingsSessionSection(),
              if (isAdmin == true) const SettingsAdminSection(),
              const SettingsToolsSection(),
              SettingsSection(
                title: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Über die App',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                tiles: <SettingsTile>[
                  SettingsTile(
                    leading: const Icon(Icons.perm_device_info_rounded),
                    title: Text(
                        'Versionsnummer: ${locator<EnvManager>().packageInfo.version}'),
                  ),
                  SettingsTile(
                    leading: const Icon(Icons.build_rounded),
                    title: Text(
                        'Build: ${locator<EnvManager>().packageInfo.buildNumber}'),
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.info_rounded),
                    title: const Text('App Infos'),
                    onPressed: (context) => showAboutDialog(
                        context: context,
                        applicationIcon: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            'assets/schuldaten_hub_logo.png',
                            scale: 8,
                          ),
                        ),
                        applicationName: 'Schuldaten App',
                        applicationVersion:
                            locator<EnvManager>().packageInfo.version,
                        applicationLegalese: '© 2025 Schuldaten Hub'),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
