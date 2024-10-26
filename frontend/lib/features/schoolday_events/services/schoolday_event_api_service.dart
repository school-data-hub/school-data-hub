import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:schuldaten_hub/common/services/api/api.dart';
import 'package:schuldaten_hub/common/services/api/services/api_client_service.dart';

import 'package:schuldaten_hub/common/constants/enums.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_manager.dart';
import 'package:schuldaten_hub/features/schooldays/services/schoolday_manager.dart';
import 'package:schuldaten_hub/common/services/session_manager.dart';
import 'package:schuldaten_hub/common/utils/custom_encrypter.dart';
import 'package:schuldaten_hub/common/utils/extensions.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_data.dart';
import 'package:schuldaten_hub/features/pupil/services/pupil_manager.dart';

class SchooldayEventApiService {
  final pupilManager = locator<PupilManager>();
  final schooldayManager = locator<SchooldayManager>();
  final ApiClientService _client = locator<ApiClientService>();
  final notificationManager = locator<NotificationManager>();

  //- post schooldayEvent

  static const _postSchooldayEventUrl = '/schoolday_events/new';

  Future<PupilData> postSchooldayEvent(
      int pupilId, DateTime date, String type, String reason) async {
    locator<NotificationManager>().apiRunningValue(true);

    final data = jsonEncode({
      "schoolday_event_day": date.formatForJson(),
      "schoolday_event_pupil_id": pupilId,
      "schoolday_event_reason": reason,
      "schoolday_event_type": type,
      "file_id": null,
      "processed": false,
      "processed_at": null,
      "processed_by": null
    });

    final Response response =
        await _client.post(_postSchooldayEventUrl, data: data);

    if (response.statusCode != 200) {
      notificationManager.showSnackBar(
          NotificationType.warning, 'Fehler beim Posten des Ereignisses!');

      notificationManager.apiRunningValue(false);

      throw ApiException(
          'Failed to post an schooldayEvent', response.statusCode);
    }

    final PupilData responsePupil = PupilData.fromJson(response.data);

    locator<NotificationManager>().apiRunningValue(false);
    return responsePupil;
  }

  //- GET
  static const fetchSchooldayEventsUrl = '/schoolday_events/all';

  String getSchooldayEventUrl(String id) {
    return '/schoolday_events/$id';
  }

  String getSchooldayEventFileUrl(String id) {
    return '/schoolday_events/$id/file';
  }

  String getSchooldayEventProcessedFileUrl(String id) {
    return '/schoolday_events/$id/processed_file';
  }

  //- patch schooldayEvent
  String _patchSchooldayEventUrl(String id) {
    return '/schoolday_events/$id/patch';
  }

  Future<PupilData> patchSchooldayEvent(
      {required String id,
      String? creator,
      String? type,
      String? reason,
      bool? processed,
      //String? file,
      String? processedBy,
      DateTime? processedAt,
      DateTime? day}) async {
    notificationManager.apiRunningValue(true);

    // if the schooldayEvent is patched as processed,
    // processing user and processed date are automatically added

    if (processed == true && processedBy == null && processedAt == null) {
      processedBy = locator<SessionManager>().credentials.value.username;
      processedAt = DateTime.now();
    }

    // if the schooldayEvent is patched as not processed,
    // processing user and processed date are set to null

    if (processed == false) {
      processedBy = null;
      processedAt = null;
    }

    final data = jsonEncode({
      if (creator != null) "created_by": creator,
      if (type != null) "schoolday_event_type": type,
      if (reason != null) "schoolday_event_reason": reason,
      if (processed != null) "processed": processed,
      if (processedBy != null) "processed_by": processedBy,
      if (processed == false) "processed_by": null,
      if (processedAt != null) "processed_at": processedAt.formatForJson(),
      if (processed == false) "processed_at": null,
      if (day != null) "schoolday_event_day": day.formatForJson(),
    });

    final Response response =
        await _client.patch(_patchSchooldayEventUrl(id), data: data);

    if (response.statusCode != 200) {
      notificationManager.showSnackBar(
          NotificationType.warning, 'Fehler beim Patchen des Ereignisses!');

      notificationManager.apiRunningValue(false);

      throw ApiException(
          'Failed to patch an schooldayEvent', response.statusCode);
    }

    final PupilData responsePupil = PupilData.fromJson(response.data);

    locator<NotificationManager>().apiRunningValue(false);

    return responsePupil;
  }

  //- upload file to document an schooldayEvent

  //- an schooldayEvent can be documented with an image file of a document
  //- the file is encrypted before it is uploaded
  //- there are two possible endpoints for the file upload, depending on whether the schooldayEvent is processed or not

  String _patchSchooldayEventFileUrl(String id) {
    return '/schoolday_events/$id/file';
  }

  String _patchSchooldayEventProcessedFileUrl(String id) {
    return '/schoolday_events/$id/processed_file';
  }

  Future<PupilData> patchSchooldayEventWithFile(
      File imageFile, String schooldayEventId, bool isProcessed) async {
    locator<NotificationManager>().apiRunningValue(true);

    String endpoint;

    final encryptedFile = await customEncrypter.encryptFile(imageFile);

    String fileName = encryptedFile.path.split('/').last;

    var formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        encryptedFile.path,
        filename: fileName,
      ),
    });

    // choose endpoint depending on isProcessed
    if (isProcessed) {
      endpoint = _patchSchooldayEventProcessedFileUrl(schooldayEventId);
    } else {
      endpoint = _patchSchooldayEventFileUrl(schooldayEventId);
    }

    final Response response = await _client.patch(
      endpoint,
      data: formData,
    );

    if (response.statusCode != 200) {
      locator<NotificationManager>().showSnackBar(
          NotificationType.warning, 'Fehler beim Hochladen des Bildes!');

      locator<NotificationManager>().apiRunningValue(false);

      throw ApiException(
          'Failed to upload schooldayEvent file', response.statusCode);
    }

    final PupilData responsePupil = PupilData.fromJson(response.data);

    locator<NotificationManager>().apiRunningValue(false);

    return responsePupil;
  }

  //- delete schooldayEvent

  String _deleteSchooldayEventUrl(String id) {
    return '/schoolday_events/$id/delete';
  }

  Future<PupilData> deleteSchooldayEvent(String schooldayEventId) async {
    locator<NotificationManager>().apiRunningValue(true);

    Response response =
        await _client.delete(_deleteSchooldayEventUrl(schooldayEventId));
    locator<NotificationManager>().apiRunningValue(false);
    if (response.statusCode != 200) {
      locator<NotificationManager>().showSnackBar(
          NotificationType.warning, 'Fehler beim Löschen des Ereignisses!');

      throw ApiException(
          'Failed to delete schooldayEvent', response.statusCode);
    }

    final PupilData responsePupil = PupilData.fromJson(response.data);
    return responsePupil;
  }

//- delete schooldayEvent file
//- depending on isProcessed, there are two possible endpoints for the file deletion
  String _deleteSchooldayEventFileUrl(String id) {
    return '/schoolday_events/$id/file';
  }

  String _deleteSchooldayEventProcessedFileUrl(String id) {
    return '/schoolday_events/$id/processed_file';
  }

  Future<PupilData> deleteSchooldayEventFile(
      String schooldayEventId, String cacheKey, bool isProcessed) async {
    locator<NotificationManager>().apiRunningValue(true);

    // choose endpoint depending on isProcessed
    String endpoint;
    if (isProcessed) {
      endpoint = _deleteSchooldayEventProcessedFileUrl(schooldayEventId);
    } else {
      endpoint = _deleteSchooldayEventFileUrl(schooldayEventId);
    }

    final Response response = await _client.delete(endpoint);

    if (response.statusCode != 200) {
      locator<NotificationManager>().showSnackBar(
          NotificationType.warning, 'Fehler beim Löschen der Datei!');

      locator<NotificationManager>().apiRunningValue(false);

      throw ApiException(
          'Failed to delete schooldayEvent', response.statusCode);
    }

    final PupilData responsePupil = PupilData.fromJson(response.data);

    // Delete the file from the cache
    final cacheManager = locator<DefaultCacheManager>();
    await cacheManager.removeFile(cacheKey);

    notificationManager.apiRunningValue(false);

    return responsePupil;
  }
}
