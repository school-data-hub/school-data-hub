import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:schuldaten_hub/common/domain/env_manager.dart';
import 'package:schuldaten_hub/common/domain/models/enums.dart';
import 'package:schuldaten_hub/common/domain/models/session.dart';
import 'package:schuldaten_hub/common/domain/session_helper_functions.dart';
import 'package:schuldaten_hub/common/services/api/api_client.dart';
//import 'package:schuldaten_hub/common/services/api/api_settings.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_service.dart';
import 'package:schuldaten_hub/common/utils/logger.dart';
import 'package:schuldaten_hub/common/utils/secure_storage.dart';
import 'package:schuldaten_hub/features/main_menu/widgets/landing_bottom_nav_bar.dart';
import 'package:schuldaten_hub/features/users/data/user_api_service.dart';
import 'package:schuldaten_hub/features/users/domain/models/user.dart';

class SessionManager {
  final _sessions = ValueNotifier<Map<String, Session>>({});
  ValueListenable<Map<String, Session>> get sessions => _sessions;

  final _credentials = ValueNotifier<Session>(Session());
  ValueListenable<Session> get credentials => _credentials;

  final _isAuthenticated = ValueNotifier<bool>(false);
  ValueListenable<bool> get isAuthenticated => _isAuthenticated;

  final _isAdmin = ValueNotifier<bool>(false);
  ValueListenable<bool> get isAdmin => _isAdmin;

  bool _isCalendarPopulated = false;
  bool get isCalendarPopulated => _isCalendarPopulated;

  bool _isSchoolSemesterPopulated = false;
  bool get isSchoolSemesterPopulated => _isSchoolSemesterPopulated;

  void setCalendarPopulated(bool value) {
    _isCalendarPopulated = value;
  }

  void setSchoolSemesterPopulated(bool value) {
    _isSchoolSemesterPopulated = value;
  }

  final _matrixPolicyManagerRegistrationStatus = ValueNotifier<bool>(false);
  ValueListenable<bool> get matrixPolicyManagerRegistrationStatus =>
      _matrixPolicyManagerRegistrationStatus;

  final userApiService = UserApiService();

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
    locator<ApiClient>()
        .setApiOptions(tokenKey: Token.hub, token: _credentials.value.jwt!);
  }

  bool isAuthorized(String user) {
    return _credentials.value.username == user || _isAdmin.value;
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

  Future<void> checkStoredCredentials() async {
    if (locator<EnvManager>().env == null) {
      logger.w('Checking credentials, but no environment found!',
          stackTrace: StackTrace.current);
      _isAuthenticated.value = false;
      return;
    }

    final Map<String, Session>? storedSessions =
        await SessionHelper.sessionsInStorage();
    _sessions.value = storedSessions ?? {};

    if (storedSessions == null) {
      logger.w('No sessions found in secure storage!');
    }

    final Session? linkedSession =
        _sessions.value[locator<EnvManager>().env!.server];

    if (linkedSession == null) {
      logger.w('No session found for ${locator<EnvManager>().env!.server}');
      //- TODO: this call is there in case the credentials are checked
      //- after calling a new instance and is hacky
      //- find a better way to handle this
      locator<NotificationService>().setNewInstanceLoadingValue(false);
      return;
    }
    logger.i('Session found for ${linkedSession.server!}');
    _credentials.value = linkedSession;

    // check if the session is still valid
    if (JwtDecoder.isExpired(linkedSession.jwt!)) {
      removeSession(server: linkedSession.server!);

      logger.w('Session found, but was not valid - deleted!',
          stackTrace: StackTrace.current);
      _isAuthenticated.value = false;

      //- TODO: this call is there in case the credentials are checked
      //- after calling a new instance and is hacky
      //- find a better way to handle this
      locator<NotificationService>().setNewInstanceLoadingValue(false);
      return;
    }

    // There are sessions stored - let's decode them
    try {
      // check if the session is still valid

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
      // if not, delete the session
      await removeSession(server: locator<EnvManager>().env!.server);

      return;
    }
  }

  Future<void> refreshToken(String password) async {
    final Session session = await userApiService.login(
        username: _credentials.value.username!, password: password);

    authenticate(session);
    await saveSession(session);
    locator<ApiClient>()
        .setApiOptions(tokenKey: Token.hub, token: _credentials.value.jwt!);

    return;
  }

  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    final User? user = await userApiService.changePassword(
      oldPassword: currentPassword,
      newPassword: newPassword,
    );
    //- TO-DO: Not finished - implement this!!
    // authenticate(session);
    // await saveSession(session);
    if (user == null) {
      locator<NotificationService>().showSnackBar(
          NotificationType.error, 'Fehler beim Ändern des Passworts');
      return;
    } else {
      locator<NotificationService>().showSnackBar(
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

    locator<NotificationService>()
        .showSnackBar(NotificationType.success, 'Login erfolgreich!');

    await registerDependentManagers();

    return;
  }

  Future<void> saveSession(Session session) async {
    final Map<String, Session> updatedSessions = _sessions.value;
    updatedSessions[session.server!] = session;
    final updatedSessionsAsJson = json.encode(updatedSessions);
    await AppSecureStorage.write(
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
      await AppSecureStorage.delete(SecureStorageKey.sessions.value);
    }
    _credentials.value = Session();
    locator<NotificationService>().showSnackBar(
        NotificationType.success, 'Session erfolgreich gelöscht!');

    return;
  }

  logout() async {
    removeSession(server: _credentials.value.server!);

    locator<NotificationService>()
        .showSnackBar(NotificationType.success, 'Logout erfolgreich!');

    locator.get<MainMenuBottomNavManager>().setBottomNavPage(0);
    _isAuthenticated.value = false;
    _credentials.value = Session();

    await unregisterDependentManagers();
    return;
  }

  void changeMatrixPolicyManagerRegistrationStatus(bool isRegistered) {
    _matrixPolicyManagerRegistrationStatus.value = isRegistered;
  }
}
