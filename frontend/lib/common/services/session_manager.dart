import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:schuldaten_hub/common/constants/enums.dart';
import 'package:schuldaten_hub/common/models/session.dart';
import 'package:schuldaten_hub/common/services/api/api.dart';
import 'package:schuldaten_hub/common/services/api/services/api_client_service.dart';
import 'package:schuldaten_hub/common/services/env_manager.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_manager.dart';
import 'package:schuldaten_hub/common/utils/logger.dart';
import 'package:schuldaten_hub/common/utils/secure_storage.dart';
import 'package:schuldaten_hub/features/main_menu_pages/widgets/landing_bottom_nav_bar.dart';
import 'package:schuldaten_hub/features/users/models/user.dart';

class SessionManager {
  ValueListenable<Map<String, Session>> get sessions => _sessions;
  ValueListenable<Session> get credentials => _credentials;
  ValueListenable<bool> get isAuthenticated => _isAuthenticated;
  ValueListenable<bool> get isAdmin => _isAdmin;
  ValueListenable<bool> get matrixPolicyManagerRegistrationStatus =>
      _matrixPolicyManagerRegistrationStatus;

  final _sessions = ValueNotifier<Map<String, Session>>({});
  final _credentials = ValueNotifier<Session>(Session());
  final _isAuthenticated = ValueNotifier<bool>(false);
  final _isAdmin = ValueNotifier<bool>(false);
  final _matrixPolicyManagerRegistrationStatus = ValueNotifier<bool>(false);

  final userApiService = UserApiService();
  SessionManager();
  Future<SessionManager> init() async {
    await checkStoredCredentials();
    log('Returning SessionManager instance!');
    return this;
  }

  void unauthenticate() {
    _isAuthenticated.value = false;
    _credentials.value = Session();
    _isAdmin.value = false;
  }

  void setSessionNotAuthenticated() {
    _isAuthenticated.value = false;
    _credentials.value = Session();
  }

  void authenticate(Session session) {
    _credentials.value = session;
    _isAdmin.value = _credentials.value.isAdmin!;
    _isAuthenticated.value = true;
    locator<ApiClientService>()
        .setHeaders(tokenKey: 'x-access-token', token: session.jwt!);
  }

  void changeSessionCredit(int value) async {
    int oldCreditValue = _credentials.value.credit!;
    Session newSession =
        _credentials.value.copyWith(credit: oldCreditValue + value);
    _credentials.value = newSession;
    await saveSession(newSession);
  }

  Future<void> updateSessionData(Session session) async {
    final Session updatedSession =
        await userApiService.updateSessionData(session);
    _credentials.value = updatedSession.copyWith(jwt: _credentials.value.jwt);

    await saveSession(updatedSession);
  }

  Future<Map<String, Session>?> sessionsInStorage() async {
    if (await secureStorageContainsKey('sessions') == true) {
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

  Future<void> checkStoredCredentials() async {
    if (locator<EnvManager>().env.value.serverUrl == null) {
      logger.w('Checking credentials, but no environment found!',
          stackTrace: StackTrace.current);

      return;
    }

    final Map<String, Session>? storedSessions = await sessionsInStorage();
    _sessions.value = storedSessions ?? {};

    if (storedSessions == null) {
      logger.w('No sessions found in secure storage!');
      //-TODO: delete legacy code when sure it's not needed anymore
      if (await secureStorageContainsKey('session') == true) {
        // if so, read them
        final String? legacySessioninStorage =
            await secureStorageRead('session');
        log('Legacy session found!');
        // decode the stored session and add missing keys and values
        final Map<String, dynamic> legacySessionMap =
            json.decode(legacySessioninStorage!) as Map<String, dynamic>;
        legacySessionMap['server'] = locator<EnvManager>().env.value.server;
        legacySessionMap['contact'] = null;
        legacySessionMap['tutoring'] = null;
        final Session session =
            Session.fromJson(legacySessionMap); // as Session;
        saveSession(session);
      } else {
        return;
      }
    }

    final Session? linkedSession =
        _sessions.value[locator<EnvManager>().env.value.server!];

    if (linkedSession == null) {
      logger
          .w('No session found for ${locator<EnvManager>().env.value.server!}');

      return;
    }

    _credentials.value = linkedSession;

    // check if the session is still valid
    if (JwtDecoder.isExpired(linkedSession.jwt!)) {
      removeSession(server: linkedSession.server!);

      logger.w('Session found, but was not valid - deleted!',
          stackTrace: StackTrace.current);

      return;
    }

    // There are sessions stored - let's decode them
    try {
      // check if there is a session linked to the default server

      // check if the session is still valid
      // if not, delete the session

      log('Stored session is valid!');
      authenticate(_credentials.value);
      log('Session isAuthenticated is ${_isAuthenticated.value.toString()}');

      if (!locator<EnvManager>().dependentManagersRegistered.value) {
        logger.i(
            'Authenticated on first run - registering dependent managers...');
        await registerDependentManagers();
      } else {
        logger.i('Authenticated on env change - propagating new env...');
        locator<EnvManager>().propagateNewEnv();
      }

      return;
    } catch (e) {
      logger.f(
        'Error reading session from secureStorage: $e',
        stackTrace: StackTrace.current,
      );
      await removeSession(server: locator<EnvManager>().env.value.server!);

      return;
    }
  }

  Future<void> refreshToken(String password) async {
    final Session session = await userApiService.login(
        username: _credentials.value.username!, password: password);

    authenticate(session);
    await saveSession(session);
    locator<ApiClientService>().setHeaders(
      tokenKey: 'x-access-token',
      token: _credentials.value.jwt!,
    );
    return;
  }

  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    final User? user = await userApiService.changePassword(
      oldPassword: currentPassword,
      newPassword: newPassword,
    );
    // authenticate(session);
    // await saveSession(session);
    if (user == null) {
      locator<NotificationManager>().showSnackBar(
          NotificationType.error, 'Fehler beim Ändern des Passworts');
      return;
    } else {
      locator<NotificationManager>().showSnackBar(
          NotificationType.success, 'Passwort erfolgreich geändert!');
    }

    return;
  }

  Future<void> attemptLogin(
      {required String username, required String password}) async {
    final Session session = await userApiService.login(
      username: username,
      password: password,
    );
    await saveSession(session);
    authenticate(session);

    locator<NotificationManager>()
        .showSnackBar(NotificationType.success, 'Login erfolgreich!');

    await registerDependentManagers();

    return;
  }

  Future<void> saveSession(Session session) async {
    final Map<String, Session> updatedSessions = _sessions.value;
    updatedSessions[session.server!] = session;
    final updatedSessionsAsJson = json.encode(updatedSessions);
    await secureStorageWrite(
        SecureStorageKey.sessions.value, updatedSessionsAsJson);
    // let's keep them in memory as well
    _sessions.value = updatedSessions;
    logger.i('${updatedSessions.length} Session(s) stored');

    return;
  }

  Future<void> removeSession({required String server}) async {
    final Map<String, Session> updatedSessions = _sessions.value;
    updatedSessions.remove(server);
    _sessions.value = updatedSessions;
    if (updatedSessions.isNotEmpty) {
      await saveSession(_credentials.value);
    } else {
      await secureStorageDelete(SecureStorageKey.sessions.value);
    }
    _credentials.value = Session();
    locator<NotificationManager>().showSnackBar(
        NotificationType.success, 'Session erfolgreich gelöscht!');

    return;
  }

  logout() async {
    removeSession(server: _credentials.value.server!);

    locator<NotificationManager>()
        .showSnackBar(NotificationType.success, 'Logout erfolgreich!');

    locator.get<BottomNavManager>().setBottomNavPage(0);
    _isAuthenticated.value = false;
    _credentials.value = Session();
    locator<ApiClientService>().setHeaders(tokenKey: '', token: '');
    await unregisterDependentManagers();
    return;
  }

  void changeMatrixPolicyManagerRegistrationStatus(bool isRegistered) {
    _matrixPolicyManagerRegistrationStatus.value = isRegistered;
  }
}
