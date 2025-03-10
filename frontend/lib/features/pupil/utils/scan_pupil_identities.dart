import 'package:flutter/material.dart';
import 'package:schuldaten_hub/common/domain/models/enums.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_service.dart';
import 'package:schuldaten_hub/common/utils/scanner.dart';
import 'package:schuldaten_hub/features/pupil/domain/pupil_identity_manager.dart';

Future<void> scanNewPupilIdentities(BuildContext context) async {
  final String? scanResult =
      await scanner(context, 'Personenbezogene Informationen scannen');

  if (scanResult != null) {
    locator<PupilIdentityManager>().decryptCodesAndAddIdentities([scanResult]);
  } else {
    locator<NotificationService>()
        .showSnackBar(NotificationType.warning, 'Scan abgebrochen');

    return;
  }
  return;
}
