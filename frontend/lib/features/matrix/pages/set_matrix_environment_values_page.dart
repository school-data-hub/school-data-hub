import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/constants/styles.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/utils/import_string_from_txt_file.dart';
import 'package:schuldaten_hub/common/utils/scanner.dart';
import 'package:schuldaten_hub/features/matrix/services/matrix_policy_manager.dart';

class SetMatrixEnvironmentValuesPage extends StatefulWidget {
  const SetMatrixEnvironmentValuesPage({super.key});

  @override
  SetMatrixEnvironmentValuesPageState createState() =>
      SetMatrixEnvironmentValuesPageState();
}

class SetMatrixEnvironmentValuesPageState
    extends State<SetMatrixEnvironmentValuesPage> {
  final TextEditingController urlTextFieldController = TextEditingController();
  final TextEditingController matrixTokenTextFieldController =
      TextEditingController();
  final TextEditingController policyTokenTextFieldController =
      TextEditingController();
  Set<String> roomIds = {};
  //Set<int> pupilIds = {};
  void setMatrixEnvironment() async {
    if (!locator.isRegistered<MatrixPolicyManager>()) {
      registerMatrixPolicyManager();
    }

    String url = 'https://${urlTextFieldController.text}';
    String matrixToken = matrixTokenTextFieldController.text;
    String policyToken = policyTokenTextFieldController.text;
    await locator.allReady();

    locator<MatrixPolicyManager>().setMatrixEnvironmentValues(
        url: url,
        matrixToken: matrixToken,
        policyToken: policyToken,
        compulsoryRooms: []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: backgroundColor,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.settings,
              size: 25,
              color: Colors.white,
            ),
            Gap(10),
            Text(
              'Matrix-Umgebung einrichten',
              style: appBarTextStyle,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center, // Add this
                  children: <Widget>[
                    const Text(
                      'Matrix-URL:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(5),
                    const Text('https://', style: TextStyle(fontSize: 16)),
                    const Gap(5),
                    SizedBox(
                      width: 300,
                      child: TextField(
                        minLines: 1,
                        maxLines: 3,
                        controller: urlTextFieldController,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(10),
                          border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: backgroundColor, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: backgroundColor, width: 2),
                          ),
                          labelStyle: TextStyle(color: backgroundColor),
                          labelText: 'Matrix-URL',
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(20),
                TextField(
                  minLines: 1,
                  maxLines: 2,
                  controller: matrixTokenTextFieldController,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: backgroundColor, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: backgroundColor, width: 2),
                    ),
                    labelStyle: TextStyle(color: backgroundColor),
                    labelText: 'Matrix-Admin Token',
                  ),
                ),
                const Gap(20),
                TextField(
                  minLines: 1,
                  maxLines: 2,
                  controller: policyTokenTextFieldController,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: backgroundColor, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: backgroundColor, width: 2),
                    ),
                    labelStyle: TextStyle(color: backgroundColor),
                    labelText: 'Matrix-Corporal Token',
                  ),
                ),
                const Spacer(),
                const Gap(15),
                ElevatedButton(
                  style: successButtonStyle,
                  onPressed: () async {
                    setMatrixEnvironment();
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'SENDEN',
                    style: buttonTextStyle,
                  ),
                ),
                const Gap(15),
                ElevatedButton(
                  style: successButtonStyle,
                  onPressed: () async {
                    String? scanResult;
                    if (Platform.isAndroid || Platform.isIOS) {
                      scanResult =
                          await scanner(context, 'Matrix Zugangsdaten scannen');
                    }
                    if (Platform.isWindows ||
                        Platform.isLinux ||
                        Platform.isMacOS) {
                      scanResult = await importStringtromTxtFile();
                    }
                    if (scanResult != null) {
                      final matrixCredentialsMap = jsonDecode(scanResult);

                      // final MatrixCredentials matrixCredentials =
                      //     MatrixCredentials.fromJson(matrixCredentialsMap);
                      urlTextFieldController.text = matrixCredentialsMap['url'];

                      matrixTokenTextFieldController.text =
                          matrixCredentialsMap['matrixToken'];

                      policyTokenTextFieldController.text =
                          matrixCredentialsMap['policyToken'];

                      setMatrixEnvironment();

                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    }
                  },
                  child: Text(
                    (Platform.isAndroid || Platform.isIOS)
                        ? 'SCANNEN'
                        : 'IMPORT AUS DATEI',
                    style: buttonTextStyle,
                  ),
                ),
                const Gap(15),
                ElevatedButton(
                  style: cancelButtonStyle,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'ABBRECHEN',
                    style: buttonTextStyle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the tree
    urlTextFieldController.dispose();
    matrixTokenTextFieldController.dispose();
    policyTokenTextFieldController.dispose();
    super.dispose();
  }
}
