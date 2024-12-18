import 'package:flutter/material.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/features/matrix/domain/matrix_policy_manager.dart';
import 'package:schuldaten_hub/features/matrix/presentation/set_matrix_environment_page/set_matrix_environment_page.dart';

class SetMatrixEnvironment extends StatefulWidget {
  const SetMatrixEnvironment({super.key});

  @override
  State<SetMatrixEnvironment> createState() => SetMatrixEnvironmentViewModel();
}

class SetMatrixEnvironmentViewModel extends State<SetMatrixEnvironment> {
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
    return SetupMatrixEnvironmentPage(this);
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
