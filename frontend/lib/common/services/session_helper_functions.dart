import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:schuldaten_hub/common/constants/enums.dart';
import 'package:schuldaten_hub/common/services/env_manager.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/session_manager.dart';
import 'package:schuldaten_hub/common/services/notification_manager.dart';
import 'package:schuldaten_hub/features/pupil/services/pupil_identity_manager.dart';

class SessionHelper {
  static String tokenLifetimeLeft(String token) {
    Duration remainingTime = JwtDecoder.getRemainingTime(token);
    String days = remainingTime.inDays == 1 ? 'Tag' : 'Tage';
    String hours = remainingTime.inHours == 1 ? 'Stunde' : 'Stunden';
    String minutes = remainingTime.inMinutes == 1 ? 'Minute' : 'Minuten';
    String timeLeft =
        '${remainingTime.inDays} $days, ${remainingTime.inHours % 24} $hours, ${remainingTime.inMinutes % 60} $minutes';
    return timeLeft;
  }

  static void logoutAndDeleteAllData(BuildContext context) async {
    await locator<PupilIdentityManager>().deleteAllPupilIdentities();
    await locator<EnvManager>().deleteEnv();
    await locator<SessionManager>().logout();
    final cacheManager = locator<DefaultCacheManager>();

    await cacheManager.emptyCache();

    locator<NotificationManager>()
        .showSnackBar(NotificationType.success, 'Alle Daten gelöscht!');
  }

  static bool isAuthorized(String user) {
    return locator<SessionManager>().credentials.value.username == user ||
            locator<SessionManager>().credentials.value.isAdmin!
        ? true
        : false;
  }
}
