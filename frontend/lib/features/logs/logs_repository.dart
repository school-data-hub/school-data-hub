import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:schuldaten_hub/common/domain/models/enums.dart';
import 'package:schuldaten_hub/common/services/api/api_client.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_service.dart';

class LogsRepository {
  final ApiClient _client = locator<ApiClient>();
  final NotificationService _notificationService =
      locator<NotificationService>();

  final String _downloadUrl = '/log/download';
  final String _uploadUrl = '/log/upload';

  Future<String?> downloadLog() async {
    try {
      final response = await _client.get(
        _downloadUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse =
            jsonDecode(utf8.decode(response.data));
        final String logContent = jsonResponse['log'];
        debugger();
        return logContent;
      } else {
        _notificationService.showSnackBar(
            NotificationType.error, 'Failed to download log file');
        return null;
      }
    } catch (e) {
      _notificationService.showSnackBar(
          NotificationType.error, 'Error downloading log file: $e');
      return null;
    }
  }

  String extractTextFromLog() {
    final file = File('schuldaten_hub.log');
    if (!file.existsSync()) {
      return 'Log file not found';
    }
    return file.readAsStringSync();
  }

  Future<bool> uploadLog(File file) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path,
            filename: 'schuldaten_hub.log'),
      });

      final response = await _client.post(
        _uploadUrl,
        data: formData,
      );

      if (response.statusCode == 200) {
        _notificationService.showSnackBar(
            NotificationType.success, 'Log file uploaded successfully');
        return true;
      } else {
        _notificationService.showSnackBar(
            NotificationType.error, 'Failed to upload log file');
        return false;
      }
    } catch (e) {
      _notificationService.showSnackBar(
          NotificationType.error, 'Error uploading log file: $e');
      return false;
    }
  }
}
