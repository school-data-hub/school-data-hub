import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:schuldaten_hub/common/domain/env_manager.dart';
import 'package:schuldaten_hub/common/domain/session_manager.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/utils/secure_storage.dart';
import 'package:schuldaten_hub/common/widgets/dialogs/confirmation_dialog.dart';
import 'package:schuldaten_hub/common/widgets/qr/qr_utilites.dart';
import 'package:schuldaten_hub/features/books/utils/book_ids_pdf_generator.dart';
import 'package:schuldaten_hub/features/competence/utils/competence_report_pdf.dart';
import 'package:schuldaten_hub/features/matrix/domain/matrix_policy_manager.dart';
import 'package:schuldaten_hub/features/matrix/presentation/pupil_matrix_contacts.dart';
import 'package:schuldaten_hub/features/matrix/presentation/set_matrix_environment_page/set_matrix_environment_view_model.dart';
import 'package:schuldaten_hub/features/schooldays/presentation/schooldays_calendar_page.dart';
import 'package:schuldaten_hub/features/users/domain/user_manager.dart';
import 'package:schuldaten_hub/features/users/presentation/users_list_page/users_list_page.dart';
import 'package:watch_it/watch_it.dart';

class SettingsAdminSection extends AbstractSettingsSection with WatchItMixin {
  const SettingsAdminSection({super.key});

  @override
  Widget build(BuildContext context) {
    final bool matrixPolicyManagerIsRegistered = watchValue(
        (SessionManager x) => x.matrixPolicyManagerRegistrationStatus);
    return SettingsSection(
      title: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          'Admin-Tools',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      tiles: <SettingsTile>[
        SettingsTile.navigation(
            title: const Text('User-Verwaltung'),
            leading: const Icon(Icons.account_circle_rounded),
            onPressed: (context) {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (ctx) => const UsersListPage(),
              ));
            }),
        SettingsTile.navigation(
            title: const Text('Buch IDs generieren'),
            leading: const Icon(Icons.qr_code_rounded),
            onPressed: (context) {
              generateBookIdsPdf();
            }),
        SettingsTile.navigation(
            title: const Text('Zeugnis generieren'),
            leading: const Icon(Icons.qr_code_rounded),
            onPressed: (context) {
              generateCompetenceReportPdf(reportLevel: ReportLevel.E1);
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
            onPressed: (context) {
              final Map<String, dynamic> json =
                  locator<EnvManager>().env.value.toJson();

              final String jsonString = jsonEncode(json);

              showQrCode(jsonString, context);
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
                    builder: (ctx) => const SetMatrixEnvironment(),
                  ));
                }
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
            onPressed: (context) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const SchooldaysCalendar(),
                ),
              );
            }),
      ],
    );
  }
}
