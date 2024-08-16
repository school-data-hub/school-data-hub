import 'package:flutter/material.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/models/session_models/env.dart';
import 'package:schuldaten_hub/common/services/env_manager.dart';
import 'package:schuldaten_hub/common/services/locator.dart';

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
                return Text(envs[index].serverUrl!);
              },
              itemCount: envs.length),
        ),
        actions: <Widget>[
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
