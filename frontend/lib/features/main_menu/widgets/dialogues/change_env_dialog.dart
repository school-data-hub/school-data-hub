import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/domain/env_manager.dart';
import 'package:schuldaten_hub/common/domain/models/env.dart';
import 'package:schuldaten_hub/common/domain/session_manager.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/theme/app_colors.dart';
import 'package:schuldaten_hub/common/theme/styles.dart';
import 'package:schuldaten_hub/common/widgets/dialogs/confirmation_dialog.dart';

Future<bool?> changeEnvironmentDialog({
  required BuildContext context,
}) async {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      final List<Env> envs = locator<EnvManager>().envs.values.toList();
      return AlertDialog(
        title: const Text('Instanz auswählen',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          height: 200,
          width: 300,
          child: ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextButton(
                        child: Text(
                          envs[index].server,
                          style: const TextStyle(
                              fontSize: 20, color: AppColors.interactiveColor),
                        ),
                        onPressed: () async {
                          if (envs[index].server ==
                              locator<EnvManager>().env?.server) {
                            return;
                          }

                          final confirmation = await confirmationDialog(
                              context: context,
                              title: 'Instanz wechseln',
                              message:
                                  'Möchten Sie wirklich die Instanz wechseln?');
                          if (confirmation != true) return;
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            locator<EnvManager>()
                                .activateEnv(envName: envs[index].server);
                          }
                        },
                      ),
                      const Gap(10),
                      locator<EnvManager>().env?.server == envs[index].server
                          ? const Icon(
                              Icons.check,
                              color: Colors.green,
                              weight: 20,
                            )
                          : const SizedBox(),
                    ],
                  ),
                );
              },
              itemCount: envs.length),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: ElevatedButton(
              style: AppStyles.successButtonStyle,
              onPressed: () {
                Navigator.of(context).pop();

                locator<SessionManager>().setSessionNotAuthenticated();
                locator<EnvManager>().setEnvNotReady();
              }, // Add onPressed
              child: const Text(
                "NEUE INSTANZ",
                style: AppStyles.buttonTextStyle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: ElevatedButton(
              style: AppStyles.cancelButtonStyle,
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                "ABBRECHEN",
                style: AppStyles.buttonTextStyle,
              ),
            ),
          ),
        ],
      );
    },
  );
}
