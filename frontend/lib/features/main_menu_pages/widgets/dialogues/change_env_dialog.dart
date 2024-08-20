import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/models/env.dart';
import 'package:schuldaten_hub/common/services/env_manager.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/session_manager.dart';

Future<bool?> changeEnvironmentDialog({
  required BuildContext context,
}) async {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      final List<Env> envs = locator<EnvManager>().envs.value.values.toList();
      return AlertDialog(
        title: const Text('Instanz auswählen'),
        content: SizedBox(
          height: 300,
          width: 300,
          child: ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextButton(
                      child: Text(
                        envs[index].server!,
                        style: const TextStyle(
                            fontSize: 18, color: interactiveColor),
                      ),
                      onPressed: () {
                        locator<EnvManager>()
                            .switchEnv(envName: envs[index].server!);

                        Navigator.of(context)
                            .pop(); // Return false to indicate cancellation
                      },
                    ),
                    const Gap(10),
                    locator<EnvManager>().env.value.server == envs[index].server
                        ? const Icon(Icons.check, color: Colors.green)
                        : const SizedBox(),
                  ],
                );
              },
              itemCount: envs.length),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text(
              'Neue Instanz',
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () {
              locator<EnvManager>().setEnvNotReady();
              locator<SessionManager>().setSessionNotAuthenticated();

              Navigator.of(context)
                  .pop(); // Return false to indicate cancellation
            },
          ),
          TextButton(
            child: const Text(
              'Abbrechen',
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () {
              Navigator.of(context)
                  .pop(false); // Return false to indicate cancellation
            },
          ),
          TextButton(
            child: const Text(
              'Okay',
              style: TextStyle(color: backgroundColor),
            ),
            onPressed: () {
              Navigator.of(context)
                  .pop(true); // Return true to indicate confirmation
            },
          ),
        ],
      );
    },
  );
}
