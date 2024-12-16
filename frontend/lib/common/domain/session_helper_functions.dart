import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:schuldaten_hub/common/domain/env_manager.dart';
import 'package:schuldaten_hub/common/domain/session_manager.dart';
import 'package:schuldaten_hub/common/domain/models/enums.dart';
import 'package:schuldaten_hub/common/domain/models/session.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_service.dart';
import 'package:schuldaten_hub/common/utils/logger.dart';
import 'package:schuldaten_hub/common/utils/secure_storage.dart';
import 'package:schuldaten_hub/features/authorizations/domain/authorization_manager.dart';
import 'package:schuldaten_hub/features/competence/domain/competence_manager.dart';
import 'package:schuldaten_hub/features/learning_support/domain/learning_support_manager.dart';
import 'package:schuldaten_hub/features/pupil/domain/filters/pupils_filter.dart';
import 'package:schuldaten_hub/features/pupil/domain/pupil_identity_manager.dart';
import 'package:schuldaten_hub/features/pupil/domain/pupil_manager.dart';
import 'package:schuldaten_hub/features/school_lists/domain/school_list_manager.dart';
import 'package:schuldaten_hub/features/schooldays/domain/schoolday_manager.dart';
import 'package:schuldaten_hub/features/users/domain/user_manager.dart';
import 'package:schuldaten_hub/features/workbooks/domain/workbook_manager.dart';

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

  static Future<void> clearInstanceSessionServerData() async {
    logger.i('Clearing instance server data');
    await locator<DefaultCacheManager>().emptyCache();
    locator<PupilIdentityManager>().clearPupilIdentities();
    locator<PupilsFilter>().clearFilteredPupils();
    locator<PupilManager>().clearData();
    locator<UserManager>().clearUsers();
    locator<SchooldayManager>().clearData();
    locator<LearningSupportManager>().clearData();
    locator<CompetenceManager>().clearData();
    locator<SchoolListManager>().clearData();
    locator<AuthorizationManager>().clearData();
    locator<WorkbookManager>().clearData();
    return;
  }

  static void logoutAndDeleteAllData(BuildContext context) async {
    await locator<PupilIdentityManager>().deleteAllPupilIdentities();
    await locator<EnvManager>().deleteEnv();
    await locator<SessionManager>().logout();
    final cacheManager = locator<DefaultCacheManager>();

    await cacheManager.emptyCache();

    locator<NotificationService>()
        .showSnackBar(NotificationType.success, 'Alle Daten gelöscht!');
  }

  static bool isAuthorized(String createdBy) {
    return locator<SessionManager>().credentials.value.username == createdBy ||
            locator<SessionManager>().credentials.value.isAdmin!
        ? true
        : false;
  }

  static Future<Map<String, Session>?> sessionsInStorage() async {
    if (await secureStorageContainsKey(SecureStorageKey.sessions.value) ==
        true) {
      // if so, read them
      final String? storedSessions =
          await secureStorageRead(SecureStorageKey.sessions.value);
      log('Session(s) found!');
      // decode the stored sessions
      final Map<String, Session> sessions = (json.decode(storedSessions!)
              as Map<String, dynamic>)
          .map((key, value) =>
              MapEntry(key, Session.fromJson(value as Map<String, dynamic>)));
      // check if the sessions in the secure storage are empty
      if (sessions.isEmpty) {
        logger.w('Empty sessions found in secure storage! Deleting...');
        await secureStorageDelete(SecureStorageKey.sessions.value);
        return null;
      }

      return sessions;
    }

    return null;
  }
}
