import 'dart:io';

import 'package:schuldaten_hub/common/domain/models/enums.dart';
import 'package:schuldaten_hub/common/services/api/api_settings.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_service.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_data.dart';
import 'package:schuldaten_hub/features/pupil/domain/pupil_manager.dart';
import 'package:schuldaten_hub/features/schooldays/domain/schoolday_manager.dart';

class SchooldayEventManager {
  final pupilManager = locator<PupilManager>();
  final schooldayManager = locator<SchooldayManager>();

  final apiSchooldayEventService = SchooldayEventApiService();
  final notificationService = locator<NotificationService>();

  SchooldayEventManager();

  //- post schoolday event

  Future<void> postSchooldayEvent(
    int pupilId,
    DateTime date,
    String type,
    String reason,
  ) async {
    final PupilData responsePupil = await apiSchooldayEventService
        .postSchooldayEvent(pupilId, date, type, reason);

    pupilManager.updatePupilProxyWithPupilData(responsePupil);

    notificationService.showSnackBar(
        NotificationType.success, 'Eintrag erfolgreich!');

    return;
  }

  //- patch admonition

  Future<void> patchSchooldayEvent(
      {required String schooldayEventId,
      String? createdBy,
      String? reason,
      bool? processed,
      String? processedBy,
      DateTime? processedAt,
      DateTime? schoolEventDay,
      String? schoolEventType}) async {
    final PupilData responsePupil =
        await apiSchooldayEventService.patchSchooldayEvent(
            id: schooldayEventId,
            creator: createdBy,
            reason: reason,
            processed: processed,
            processedBy: processedBy,
            processedAt: processedAt,
            day: schoolEventDay,
            type: schoolEventType);

    pupilManager.updatePupilProxyWithPupilData(responsePupil);

    notificationService.showSnackBar(
        NotificationType.success, 'Eintrag erfolgreich geändert!');

    return;
  }

  // Future<void> patchSchooldayEventAsProcessed(
  //     String schooldayEventId, bool processed) async {
  //   locator<NotificationService>().isRunningValue(true);

  //   String data;
  //   if (processed) {
  //     data = jsonEncode({
  //       "processed": processed,
  //       "processed_at": DateTime.now().formatForJson(),
  //       "processed_by": locator<SessionManager>().credentials.value.username
  //     });
  //   } else {
  //     data = jsonEncode(
  //         {"processed": processed, "processed_at": null, "processed_by": null});
  //   }
  //   // send request
  //   final Response response = await client.patch(
  //       ApiSchooldayEventService()._patchSchooldayEventUrl(schooldayEventId),
  //       data: data);
  //   // Handle errors.
  //   if (response.statusCode != 200) {
  //     locator<NotificationService>().showSnackBar(
  //         NotificationType.warning, 'Fehler beim Patchen der Fehlzeit!');
  //     locator<NotificationService>().isRunningValue(false);
  //     return;
  //   }
  //   // Success! We have a pupil response - let's patch the pupil with the data
  //   locator<NotificationService>()
  //       .showSnackBar(NotificationType.success, 'Ereignis geändert!');
  //   final Map<String, dynamic> pupilResponse = response.data;

  //   pupilManager
  //       .updatePupilProxyWithPupilData(PupilData.fromJson(pupilResponse));
  //   locator<NotificationService>().isRunningValue(false);
  // }

  Future<void> patchSchooldayEventWithFile(
      File imageFile, String schooldayEventId, bool isProcessed) async {
    final PupilData responsePupil = await apiSchooldayEventService
        .patchSchooldayEventWithFile(imageFile, schooldayEventId, isProcessed);

    pupilManager.updatePupilProxyWithPupilData(responsePupil);

    locator<NotificationService>().showSnackBar(
        NotificationType.success, 'Datei erfolgreich hochgeladen!');

    return;
  }

  Future<void> deleteSchooldayEventFile(
      String schooldayEventId, String cacheKey, bool isProcessed) async {
    final PupilData responsePupil = await apiSchooldayEventService
        .deleteSchooldayEventFile(schooldayEventId, cacheKey, isProcessed);

    pupilManager.updatePupilProxyWithPupilData(responsePupil);

    locator<NotificationService>()
        .showSnackBar(NotificationType.success, 'Datei erfolgreich gelöscht!');

    return;
  }

  Future<void> deleteSchooldayEvent(String schooldayEventId) async {
    final PupilData responsePupil =
        await apiSchooldayEventService.deleteSchooldayEvent(schooldayEventId);

    pupilManager.updatePupilProxyWithPupilData(responsePupil);

    notificationService.showSnackBar(
        NotificationType.success, 'Ereignis gelöscht!');

    return;
  }
}
