import 'package:flutter/foundation.dart';
import 'package:schuldaten_hub/common/domain/models/enums.dart';

class NotificationData {
  final NotificationType type;
  final String message;

  NotificationData(this.type, this.message);
}

class NotificationService {
  final _snackBar = ValueNotifier<NotificationData>(
      NotificationData(NotificationType.success, ''));
  ValueListenable<NotificationData> get notification => _snackBar;

  final _apiRunning = ValueNotifier<bool>(false);
  ValueListenable<bool> get isRunning => _apiRunning;
  final _heavyLoading = ValueNotifier<bool>(false);
  ValueListenable<bool> get heavyLoading => _heavyLoading;

  NotificationService();

  void showSnackBar(NotificationType type, String message) {
    if (_heavyLoading.value) {
      return;
    }
    _snackBar.value = NotificationData(type, message);
  }

  void showInformationDialog(String message) {
    _snackBar.value = NotificationData(NotificationType.infoDialog, message);
  }

  void apiRunningValue(bool value) {
    _apiRunning.value = value;
  }

  void heavyLoadingValue(bool value) {
    _heavyLoading.value = value;
  }
}
