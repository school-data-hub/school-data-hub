import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:schuldaten_hub/api/dio/dio_client.dart';
import 'package:schuldaten_hub/api/dio/dio_exceptions.dart';
import 'package:schuldaten_hub/api/api.dart';
import 'package:schuldaten_hub/common/constants/enums.dart';

import 'package:schuldaten_hub/common/services/env_manager.dart';
import 'package:schuldaten_hub/common/services/notification_manager.dart';

import 'package:schuldaten_hub/common/utils/logger.dart';
import 'package:schuldaten_hub/common/utils/secure_storage.dart';
import 'package:schuldaten_hub/common/models/session_models/session.dart';

import 'package:schuldaten_hub/common/services/locator.dart';

import 'package:schuldaten_hub/features/main_menu_pages/widgets/landing_bottom_nav_bar.dart';

class SessionManager {
  ValueListenable<Map<String, Session>> get sessions => _sessions;
  ValueListenable<Session> get credentials => _credentials;
  ValueListenable<bool> get isAuthenticated => _isAuthenticated;
  ValueListenable<bool> get isAdmin => _isAdmin;
  ValueListenable<bool> get matrixPolicyManagerRegistrationStatus =>
      _matrixPolicyManagerRegistrationStatus;
  // ValueListenable<int> get credit => _credit;

  final _sessions = ValueNotifier<Map<String, Session>>({});
  final _credentials = ValueNotifier<Session>(Session());
  final _isAuthenticated = ValueNotifier<bool>(false);
  final _isAdmin = ValueNotifier<bool>(false);
  final _matrixPolicyManagerRegistrationStatus = ValueNotifier<bool>(false);
  // final _credit = ValueNotifier<int>(0);

  late final Dio _dio = Dio(
    BaseOptions(
      baseUrl: locator<EnvManager>().env.value.serverUrl!,
      connectTimeout: ApiSettings.connectionTimeout,
      receiveTimeout: ApiSettings.receiveTimeout,
      responseType: ResponseType.json,
    ),
  );

  SessionManager();
  Future<SessionManager> init() async {
    await checkStoredCredentials();
    logger.i('Returning SessionManager instance!');
    return this;
  }

  void setSessionNotAuthenticated() {
    _isAuthenticated.value = false;
    _credentials.value = Session();
  }

  void authenticate(Session session) {
    _credentials.value = session;
    _isAdmin.value = _credentials.value.isAdmin!;
    _isAuthenticated.value = true;
  }

  void changeSessionCredit(int value) async {
    int oldCreditValue = _credentials.value.credit!;
    Session newSession =
        _credentials.value.copyWith(credit: oldCreditValue + value);
    _credentials.value = newSession;
    await saveSession(newSession);
  }

  Future<void> updateSessionData(Session session) async {
    final client = locator<DioClient>();
    try {
      final response = await client.get(EndpointsUser.getSelfUser);
      if (response.statusCode == 200) {
        final jsonData = response.data;
        Map<String, dynamic> data = jsonDecode(jsonData);
        _credentials.value = _credentials.value.copyWith(
          username: data['name'],
          publicId: data['public_id'],
          credit: data['credit'],
          isAdmin: data['admin'],
          role: data['role'],
          timeUnits: data['time_units'],
          contact: data['contact'],
          tutoring: data['tutoring'],
        );
      }
    } on DioException catch (e) {
      final errorMessage = DioExceptions.fromDioError(e);
      logger.f('Dio error: ${errorMessage.toString()} | ${StackTrace.current}');
    }
  }

  Future<void> checkStoredCredentials() async {
    if (locator<EnvManager>().env.value.serverUrl == null) {
      logger.w('No environment found!', stackTrace: StackTrace.current);
      locator<NotificationManager>().isRunningValue(false);
      return;
    }
    if (_sessions.value.isEmpty) {
      // check if there are sessions stored in the secure storage
      if (await secureStorageContains('sessions') == true) {
        // if so, read them
        final String? storedSessions =
            await secureStorageRead(SecureStorageKey.sessions.value);
        logger.i('Session(s) found!');
        // decode the stored sessions
        final Map<String, Session> sessions = (json.decode(storedSessions!)
                as Map<String, dynamic>)
            .map((key, value) =>
                MapEntry(key, Session.fromJson(value as Map<String, dynamic>)));
        // check if the sessions in the secure storage are empty
        if (sessions.isEmpty) {
          logger.i('No session found');
          return;
        }
        //read the default server from the secure storage
        final String? defaultServer =
            await secureStorageRead(SecureStorageKey.defaultEnv.value);
        // set the sessions to the value notifier
        _sessions.value = sessions;
      }
    }
    // There are sessions stored - let's decode them
    try {
      // check if there is a session linked to the default server
      final Session? linkedSession =
          _sessions.value[locator<EnvManager>().env.value.server!];
      if (linkedSession == null) {
        logger.i(
            'No session found for ${locator<EnvManager>().env.value.server!}');

        return;
      }

      _credentials.value = linkedSession;

      // check if the session is still valid
      // if not, delete the session
      if (JwtDecoder.isExpired(linkedSession.jwt!)) {
        removeSession(server: linkedSession.server!);
        final Map<String, Session> updatedSessions = _sessions.value;
        updatedSessions.remove(linkedSession.server!);
        _sessions.value = updatedSessions;
        if (updatedSessions.isNotEmpty) {
          await saveSession(_credentials.value);
        } else {
          await secureStorageDelete(SecureStorageKey.sessions.value);

          return;
        }
        logger.w('Session was not valid - deleted!',
            stackTrace: StackTrace.current);
        locator<NotificationManager>().isRunningValue(false);
        return;
      }
      if (locator<EnvManager>().env.value.serverUrl == null) {
        logger.w('No environment found!', stackTrace: StackTrace.current);
        locator<NotificationManager>().isRunningValue(false);
        return;
      }

      logger.i('Stored session is valid!');
      authenticate(_credentials.value);
      logger.i(
          'SessionManager: isAuthenticated is ${_isAuthenticated.value.toString()}');

      if (!locator.isRegistered<DioClient>()) {
        registerDependentManagers(_credentials.value.jwt!);
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

  Future<int> refreshToken(String password) async {
    final String username = _credentials.value.username!;
    String auth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';
    final response = await _dio.get(EndpointsUser.login,
        options: Options(headers: <String, String>{'Authorization': auth}));
    if (response.statusCode == 200) {
      final Session session =
          Session.fromJson(response.data).copyWith(username: username);
      authenticate(session);
      await saveSession(_credentials.value);
      locator<DioClient>().setHeaders(
        tokenKey: 'x-access-token',
        token: _credentials.value.jwt!,
      );

      return response.statusCode!;
    }
    return response.statusCode!;
  }

  Future<bool> increaseUsersCredit() async {
    final response = await _dio.get(EndpointsUser.increaseCredit);
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<void> attemptLogin(
      {required String username, required String password}) async {
    String auth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';
    //_operationReport.value = Report(null, null);
    locator<NotificationManager>().isRunningValue(true);
    final response = await _dio.get(EndpointsUser.login,
        options: Options(headers: <String, String>{'Authorization': auth}));
    if (response.statusCode == 200) {
      final Session session = Session.fromJson(response.data)
          .copyWith(server: locator<EnvManager>().env.value.server);
      await saveSession(session);
      authenticate(session);
      if (!locator.isRegistered<DioClient>()) {
        await registerDependentManagers(_credentials.value.jwt!);
      }

      //await locator.allReady();
      locator<NotificationManager>()
          .showSnackBar(NotificationType.success, 'Login erfolgreich!');
      locator<NotificationManager>().isRunningValue(false);
      return;
    }
    if (response.statusCode == 401) {
      locator<NotificationManager>().showSnackBar(NotificationType.warning,
          'Login fehlgeschlagen - falsches passwort!');

      return;
    }
    locator<NotificationManager>().isRunningValue(false);
    return;
  }

  Future<void> saveSession(Session session) async {
    final Map<String, Session> updatedSessions = _sessions.value;
    updatedSessions[session.server!] = session;
    final updatedSessionsAsJson = json.encode(updatedSessions);
    await secureStorageWrite('sessions', updatedSessionsAsJson);
    logger.i('Session(s) stored');
    logger.i(updatedSessionsAsJson);
    return;
  }

  Future<void> removeSession({required String server}) async {
    final Map<String, Session> updatedSessions = _sessions.value;
    updatedSessions.remove(server);
    _sessions.value = updatedSessions;
    if (updatedSessions.isNotEmpty) {
      await saveSession(_credentials.value);
    } else {
      await secureStorageDelete('sessions');
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
    locator<NotificationManager>().showSnackBar(
        NotificationType.success, 'Zugangsdaten und QR-IDs gelöscht');

    await unregisterDependentManagers();
    return;
  }

  void changeMatrixPolicyManagerRegistrationStatus(bool isRegistered) {
    _matrixPolicyManagerRegistrationStatus.value = isRegistered;
  }
}
