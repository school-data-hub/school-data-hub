import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/domain/env_manager.dart';
import 'package:schuldaten_hub/common/domain/models/enums.dart';
import 'package:schuldaten_hub/common/domain/models/session.dart';
import 'package:schuldaten_hub/common/domain/session_helper_functions.dart';
import 'package:schuldaten_hub/common/domain/session_manager.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_service.dart';
import 'package:schuldaten_hub/common/widgets/dialogues/confirmation_dialog.dart';
import 'package:schuldaten_hub/common/widgets/dialogues/short_textfield_dialog.dart';
import 'package:schuldaten_hub/features/main_menu/login_page/login_controller.dart';
import 'package:schuldaten_hub/features/main_menu/widgets/dialogues/change_env_dialog.dart';
import 'package:schuldaten_hub/features/pupil/domain/pupil_identity_helper_functions.dart';
import 'package:schuldaten_hub/features/pupil/domain/pupil_manager.dart';
import 'package:schuldaten_hub/features/users/presentation/user_change_password_page/user_change_password_page.dart';
import 'package:watch_it/watch_it.dart';

class SettingsSessionSection extends AbstractSettingsSection with WatchItMixin {
  const SettingsSessionSection({super.key});

  @override
  Widget build(BuildContext context) {
    final SessionManager sessionManager = locator<SessionManager>();
    final EnvManager envManager = locator<EnvManager>();
    final cacheManager = locator<DefaultCacheManager>();
    final locale = AppLocalizations.of(context)!;
    final Session session = watchValue((SessionManager x) => x.credentials);

    final int credit = session.credit!;
    final String username = session.username!;
    return SettingsSection(
      title: Text(
        locale.session,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      tiles: <SettingsTile>[
        SettingsTile.navigation(
          onPressed: (context) => changeEnvironmentDialog(context: context),
          leading: const Icon(Icons.home),
          title: const Text('Instanz:'),
          value: Text(
            locator<EnvManager>().env.value.server!,
          ),
          trailing: null,
        ),
        SettingsTile.navigation(
          onPressed: (context) =>
              locator<PupilManager>().cleanPupilsAvatarIds(),
          leading: const Icon(
            Icons.account_circle_rounded,
          ),
          title: const Text('Angemeldet als'),
          value: Text(
            username,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: null,
        ),
        SettingsTile.navigation(
          onPressed: (context) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (ctx) => const UserChangePasswordPage(),
            ));
          },
          leading: const Icon(
            Icons.text_fields_rounded,
          ),
          title: const Text('Passwort ändern'),
          trailing: null,
        ),
        SettingsTile.navigation(
          leading: const Icon(Icons.attach_money_rounded),
          title: const Text('Guthaben'),
          value: Text(
            credit.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SettingsTile.navigation(
          leading: const Icon(Icons.punch_clock_rounded),
          title: const Text('Token gültig noch:'),
          value: Text(
            SessionHelper.tokenLifetimeLeft(session.jwt!).toString(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SettingsTile.navigation(
          onPressed: (context) async {
            try {
              final String? password = await shortTextfieldDialog(
                  context: context,
                  title: 'Token erneuern',
                  labelText: 'Passwort eingeben',
                  hintText: 'Ihr Passwort hier eingeben',
                  obscureText: true);
              if (password == null) {
                return;
              }
              await sessionManager.refreshToken(password);
            } catch (e) {
              locator<NotificationService>().showSnackBar(
                  NotificationType.error, 'Unbekannter Fehler: $e');
            }
          },
          leading: const Icon(Icons.password_rounded),
          title: const Text('Token erneuern'),
        ),
        SettingsTile.navigation(
          onPressed: (context) async {
            final confirm = await confirmationDialog(
                context: context,
                title: 'Ausloggen',
                message: 'Wirklich ausloggen?');
            if (confirm == true && context.mounted) {
              sessionManager.logout();
              locator<NotificationService>().showSnackBar(
                  NotificationType.success, 'Erfolgreich ausgeloggt!');
            }
          },
          leading: const Icon(Icons.logout),
          title: const Text('Ausloggen'),
          description: const Text('Daten bleiben erhalten'),

          //onPressed:
        ),
        SettingsTile.navigation(
          leading: const Row(
            children: [
              Icon(Icons.perm_contact_cal_rounded),
              Icon(Icons.delete_forever_outlined),
            ],
          ),
          title: const Text('gespeicherte Identitäten löschen'),
          onPressed: (context) async {
            final confirm = await confirmationDialog(
                context: context,
                title: 'Lokale Kinder-Ids löschen',
                message: 'Kinder-Ids für diese Instanz löschen?');
            if (confirm == true && context.mounted) {
              PupilIdentityHelper.deletePupilIdentitiesForEnv(
                  envManager.env.value.server!);
              locator<NotificationService>().showSnackBar(
                  NotificationType.success, 'ID-Schlüssel gelöscht');
            }
            return;
          },
        ),
        SettingsTile.navigation(
          leading: const Row(
            children: [
              Icon(Icons.key),
              Icon(Icons.delete_forever_outlined),
            ],
          ),
          title: const Text('Schul-Schlüssel löschen'),
          onPressed: (context) async {
            final confirm = await confirmationDialog(
                context: context,
                title: 'Instanz-ID-Schlüssel löschen',
                message: 'Instanz-ID-Schlüssel löschen?');
            if (confirm == true && context.mounted) {
              await envManager.deleteEnv();
              locator<NotificationService>().showSnackBar(
                  NotificationType.success, 'Instanz-ID-Schlüssel gelöscht');

              await cacheManager.emptyCache();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (ctx) => const Login(),
                  ),
                  (route) => false,
                );
              }
            }
            return;

            //locator<SessionManager>().logout();
          },
          value: const Text('Nur Instanz-ID löschen'),
          //onPressed:
        ),
        SettingsTile.navigation(
          leading: GestureDetector(
              onTap: () async {
                bool? confirm = await confirmationDialog(
                    context: context,
                    title: 'Bilder-Cache löschen',
                    message: 'Cached Bilder löschen?');
                if (confirm == true && context.mounted) {
                  final cacheManager = locator<DefaultCacheManager>();
                  await cacheManager.emptyCache();
                  locator<NotificationService>().showSnackBar(
                      NotificationType.success,
                      'der Bilder-Cache wurde gelöscht');
                }
                return;
              },
              child: const Row(
                children: [
                  Icon(Icons.logout),
                  Gap(5),
                  Icon(Icons.delete_forever_outlined)
                ],
              )),
          title: const Text('Cache löschen'),
          value: const Text('Lokal gespeicherte Bilder löschen'),
          //onPressed:
        ),
        SettingsTile.navigation(
          leading: GestureDetector(
              onTap: () async {
                bool? confirm = await confirmationDialog(
                    context: context,
                    title: 'Achtung!',
                    message: 'Ausloggen und alle Daten löschen?');
                if (confirm == true && context.mounted) {
                  SessionHelper.logoutAndDeleteAllData(context);
                }
                return;
              },
              child: const Row(
                children: [
                  Icon(Icons.logout),
                  Gap(5),
                  Icon(Icons.delete_forever_outlined)
                ],
              )),
          title: const Text('Ausloggen und Daten löschen'),
          value: const Text('App wird zurückgesetzt!'),
          //onPressed:
        ),
      ],
    );
  }
}
