import 'dart:convert';
import 'dart:developer';

import 'package:schuldaten_hub/common/domain/models/enums.dart';
import 'package:schuldaten_hub/common/domain/session_manager.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_service.dart';
import 'package:schuldaten_hub/common/utils/secure_storage.dart';
import 'package:schuldaten_hub/features/matrix/domain/filters/matrix_policy_filter_manager.dart';
import 'package:schuldaten_hub/features/matrix/domain/matrix_policy_manager.dart';
import 'package:schuldaten_hub/features/matrix/domain/models/matrix_credentials.dart';
import 'package:schuldaten_hub/features/pupil/domain/pupil_manager.dart';

Future<void> registerMatrixPolicyManager(
    {MatrixCredentials? passedCredentials}) async {
  // We are passing the credentials here for convenience
  // when they come from the SetMatrixEnvironmentPage
  // (and they are not stored in secure storage yet)
  // if they are null, we will read them from secure storage

  MatrixCredentials? storedCredentials;
  if (passedCredentials == null) {
    log('No matrix credentials passed, the app is initializing\nreading matrix credentials from secure storage');
    final String? matrixStoredValues =
        await AppSecureStorage.read(SecureStorageKey.matrix.value);

    if (matrixStoredValues == null) {
      throw Exception('Matrix stored values are null');
    }

    storedCredentials =
        MatrixCredentials.fromJson(jsonDecode(matrixStoredValues));
  } else {
    log('Matrix credentials passed, storing them in secure storage');

    await AppSecureStorage.write(
        SecureStorageKey.matrix.value,
        jsonEncode(MatrixCredentials(
            url: passedCredentials.url,
            matrixToken: passedCredentials.matrixToken,
            policyToken: passedCredentials.policyToken)));
  }

  // if the MatrixPolicyManager is already registered, we will return
  // and not register it again
  // instead we will update the credentials in the manager
  // calling a function and fetch the policy again
  if (locator.isRegistered<MatrixPolicyManager>()) {
    return;
  }

  // is the passed credentials are null, we will use the stored ones
  final validCredentials = passedCredentials ?? storedCredentials;

  locator.registerSingletonAsync<MatrixPolicyManager>(() async {
    log('Registering MatrixPolicyManager');

    final policyManager = await MatrixPolicyManager(
            validCredentials!.url,
            validCredentials.policyToken,
            validCredentials.matrixToken,
            validCredentials.compulsoryRooms ?? [])
        .init();

    log('MatrixPolicyManager initialized');

    locator<NotificationService>().showSnackBar(
        NotificationType.success, 'Matrix-Räumeverwaltung initialisiert');
    locator<SessionManager>().changeMatrixPolicyManagerRegistrationStatus(true);
    return policyManager;
  }, dependsOn: [SessionManager, PupilManager]);

  locator.registerSingletonWithDependencies<MatrixPolicyFilterManager>(
    () => MatrixPolicyFilterManager(locator<MatrixPolicyManager>()),
    dependsOn: [MatrixPolicyManager],
  );

  return;
}
