import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:gap/gap.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/constants/enums.dart';
import 'package:schuldaten_hub/common/constants/styles.dart';
import 'package:schuldaten_hub/common/models/session.dart';
import 'package:schuldaten_hub/common/services/env_manager.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/session_helper_functions.dart';
import 'package:schuldaten_hub/common/services/session_manager.dart';
import 'package:schuldaten_hub/common/services/notification_manager.dart';
import 'package:schuldaten_hub/features/matrix/pages/pupil_matrix_contacts.dart';
import 'package:schuldaten_hub/features/users/pages/user_change_password_page/user_change_password_page.dart';
import 'package:schuldaten_hub/features/users/services/user_manager.dart';
import 'package:schuldaten_hub/common/utils/secure_storage.dart';
import 'package:schuldaten_hub/common/widgets/dialogues/confirmation_dialog.dart';
import 'package:schuldaten_hub/common/widgets/dialogues/short_textfield_dialog.dart';
import 'package:schuldaten_hub/common/widgets/qr_widgets.dart';
import 'package:schuldaten_hub/features/schooldays/pages/schooldays_calendar_page.dart';
import 'package:schuldaten_hub/features/main_menu_pages/login_page/controller/login_controller.dart';
import 'package:schuldaten_hub/features/main_menu_pages/widgets/dialogues/change_env_dialog.dart';
import 'package:schuldaten_hub/features/matrix/services/matrix_policy_helper_functions.dart';
import 'package:schuldaten_hub/features/matrix/pages/set_matrix_environment_values_page.dart';
import 'package:schuldaten_hub/features/matrix/services/matrix_policy_manager.dart';
import 'package:schuldaten_hub/features/pupil/services/pupil_identity_manager.dart';
import 'package:schuldaten_hub/features/pupil/services/pupil_manager.dart';
import 'package:schuldaten_hub/features/pupil/pages/select_pupils_list_page/select_pupils_list_page.dart';
import 'package:schuldaten_hub/features/pupil/pages/birthdays_page.dart';
import 'package:schuldaten_hub/features/statistics/statistics_page/controller/statistics.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:schuldaten_hub/features/users/pages/users_list_page/users_list_page.dart';
import 'package:watch_it/watch_it.dart';

class SettingsPage extends WatchingWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final SessionManager sessionManager = locator<SessionManager>();
    final locale = AppLocalizations.of(context)!;
    final Session session = watchValue((SessionManager x) => x.credentials);
    final bool matrixPolicyManagerIsRegistered = watchValue(
        (SessionManager x) => x.matrixPolicyManagerRegistrationStatus);
    final int credit = session.credit!;
    final String username = session.username!;
    final bool isAdmin = session.isAdmin!;

    return Scaffold(
      backgroundColor: canvasColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: backgroundColor,
        title: Text(
          locale.settings,
          style: appBarTextStyle,
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SettingsList(
            contentPadding: const EdgeInsets.only(top: 10),
            sections: [
              SettingsSection(
                title: Text(
                  locale.session,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                tiles: <SettingsTile>[
                  SettingsTile.navigation(
                    onPressed: (context) =>
                        changeEnvironmentDialog(context: context),
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
                      tokenLifetimeLeft(session.jwt!).toString(),
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
                        await locator<SessionManager>().refreshToken(password);
                      } catch (e) {
                        locator<NotificationManager>().showSnackBar(
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
                        locator<NotificationManager>().showSnackBar(
                            NotificationType.success,
                            'Erfolgreich ausgeloggt!');
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
                        locator
                            .get<PupilIdentityManager>()
                            .deletePupilIdentitiesForEnv(
                                locator<EnvManager>().env.value.server!);
                        locator<NotificationManager>().showSnackBar(
                            NotificationType.success, 'ID-Schlüssel gelöscht');
                      }
                      return;
                    },

                    //onPressed:
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
                        await locator<EnvManager>().deleteEnv();
                        locator<NotificationManager>().showSnackBar(
                            NotificationType.success,
                            'Instanz-ID-Schlüssel gelöscht');
                        final cacheManager = locator<DefaultCacheManager>();
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
                            locator<NotificationManager>().showSnackBar(
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
                            logoutAndDeleteAllData(context);
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
              ),
              if (isAdmin == true)
                SettingsSection(
                    title: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Admin-Tools',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    tiles: <SettingsTile>[
                      SettingsTile.navigation(
                          title: const Text('User-Verwaltung'),
                          leading: const Icon(Icons.account_circle_rounded),
                          onPressed: (context) async {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (ctx) => const UsersListPage(),
                            ));
                          }),
                      SettingsTile.navigation(
                        leading: const Icon(Icons.attach_money_rounded),
                        title: const Text('Guthaben überweisen'),
                        onPressed: (context) async {
                          final bool? confirmed = await confirmationDialog(
                              context: context,
                              title: 'Guthaben überweisen',
                              message: 'Sind Sie sicher?');
                          if (confirmed != true) {
                            return;
                          }
                          await locator<UserManager>().increaseUsersCredit();
                        },
                      ),
                      SettingsTile.navigation(
                          leading: const Icon(Icons.qr_code_rounded),
                          title: const Text('Schulschlüssel zeigen'),
                          onPressed: (context) async {
                            final Map<String, dynamic> json =
                                locator<EnvManager>().env.value.toJson();
                            final String jsonString = jsonEncode(json);
                            if (context.mounted) {
                              showQrCode(jsonString, context);
                            }
                          }),
                      SettingsTile.navigation(
                          leading: matrixPolicyManagerIsRegistered
                              ? const Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.green,
                                )
                              : const Icon(Icons.chat_rounded),
                          title: matrixPolicyManagerIsRegistered
                              ? const Text('Raumverwaltung initialisiert')
                              : const Text('Raumverwaltung initialisieren'),
                          onPressed: (context) async {
                            if (!matrixPolicyManagerIsRegistered) {
                              bool matrixEnvValuesAvailable =
                                  await secureStorageContainsKey('matrix');
                              if (matrixEnvValuesAvailable) {
                                await registerMatrixPolicyManager();
                                return;
                              }
                              if (context.mounted) {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (ctx) =>
                                      const SetMatrixEnvironmentValuesPage(),
                                ));
                              }
                            }
                          }),
                      SettingsTile.navigation(
                          leading: const Icon(Icons.chat_rounded),
                          title: const Text('Policy generieren'),
                          onPressed: (context) async {
                            final bool confirmed =
                                await generatePolicyJsonFile();
                            if (confirmed) {
                              locator<NotificationManager>().showSnackBar(
                                  NotificationType.error, 'Datei generiert');
                            }
                          }),
                      SettingsTile.navigation(
                          leading: const Icon(Icons.chat_rounded),
                          title: const Text('Raumverwaltung löschen'),
                          onPressed: (context) async {
                            await locator<MatrixPolicyManager>()
                                .deleteAndDeregisterMatrixPolicyManager();
                          }),
                      SettingsTile.navigation(
                          leading: const Icon(
                            Icons.group,
                          ),
                          title: const Text('Kontakte bearbeiten'),
                          onPressed: (context) async {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (ctx) => const PupilsContactList(),
                            ));
                          }),
                      SettingsTile.navigation(
                          leading: const Icon(
                            Icons.calendar_month_rounded,
                          ),
                          title: const Text('Schultage-Kalender'),
                          onPressed: (context) async {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (ctx) => const SchooldaysCalendar(),
                            ));
                          }),
                    ]),
              SettingsSection(
                title: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Tools',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                tiles: <SettingsTile>[
                  SettingsTile.navigation(
                    leading: const Icon(Icons.bar_chart_rounded),
                    title: const Text('Statistik-Zahlen ansehen'),
                    onPressed: (context) {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (ctx) => const Statistics(),
                      ));
                    },
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.cake_rounded),
                    title:
                        const Text('vergangene Geburtstage seit einem Datum'),
                    onPressed: (context) async {
                      final DateTime? selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (selectedDate == null) {
                        return;
                      }
                      if (context.mounted) {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (ctx) => BirthdaysView(
                            selectedDate: selectedDate,
                          ),
                        ));
                      }
                    },
                  ),
                  SettingsTile.navigation(
                      leading: const Icon(Icons.qr_code_rounded),
                      title:
                          const Text('QR-Ids von ausgewählten Kindern zeigen'),
                      onPressed: (context) async {
                        final List<int>? pupilIds =
                            await Navigator.of(context).push(MaterialPageRoute(
                          builder: (ctx) => SelectPupilsListPage(
                              selectablePupils: locator<PupilManager>()
                                  .pupilsFromPupilIds(
                                      locator<PupilIdentityManager>()
                                          .availablePupilIds)),
                        ));
                        if (pupilIds == null || pupilIds.isEmpty) {
                          return;
                        }
                        final String qr = await locator<PupilIdentityManager>()
                            .generatePupilIdentitiesQrData(pupilIds);

                        if (context.mounted) {
                          showQrCode(qr, context);
                        }
                      }),
                  SettingsTile.navigation(
                      leading: const Icon(Icons.qr_code_rounded),
                      title: const Text(
                          'Alle vorhandenen QR-Ids zeigen (autoplay)'),
                      onPressed: (context) async {
                        final List<Map<String, Object>> qrData =
                            await locator<PupilIdentityManager>()
                                .generateAllPupilIdentitiesQrData(
                                    pupilsPerCode: 8);

                        if (context.mounted) {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) => QrCodeSpeedShow(qrMaps: qrData),
                          ));
                        }
                      }),
                  SettingsTile.navigation(
                      leading: const Icon(Icons.qr_code_rounded),
                      title: const Text(
                          'Alle vorhandenen QR-Ids zeigen (manuelle slides)'),
                      onPressed: (context) async {
                        final qrDataMaps = await locator<PupilIdentityManager>()
                            .generateAllPupilIdentitiesQrData(pupilsPerCode: 8);
                        final qrData = qrDataMaps[1] as Map<String, String>;

                        if (context.mounted) {
                          showQrCarousel(qrData, true, context);
                        }
                      }),
                ],
              ),
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
                        'Versionsnummer: ${locator<EnvManager>().packageInfo.value.version}'),
                  ),
                  SettingsTile(
                    leading: const Icon(Icons.build_rounded),
                    title: Text(
                        'Build: ${locator<EnvManager>().packageInfo.value.buildNumber}'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
