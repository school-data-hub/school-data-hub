import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:schuldaten_hub/common/domain/env_manager.dart';
import 'package:schuldaten_hub/common/domain/models/enums.dart';
import 'package:schuldaten_hub/common/domain/models/session.dart';
import 'package:schuldaten_hub/common/domain/session_manager.dart';
import 'package:schuldaten_hub/common/services/api/api_client.dart';
import 'package:schuldaten_hub/common/services/api/api_settings.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_service.dart';
import 'package:schuldaten_hub/common/utils/logger.dart';
import 'package:schuldaten_hub/features/users/domain/models/user.dart';

class EndpointsUser {
  static const login = '/users/login';
  //- GET
  static const getAllUsers = '/users/all';
  static const getSelfUser = '/users/me';

  //- POST
  static const createUser = '/users/new';

  static String _changePassword(String publicId) {
    return '/users/$publicId/new_password';
  }

  //- PATCH
  String _patchUser(String publicId) {
    return '/users/$publicId';
  }

  //- DELETE
  static String _deleteUser(String publicId) {
    return '/users/$publicId';
  }

  //- increase credit
  static const increaseCredit = '/users/all/credit';
}

class UserApiService {
  final ApiClient _client = locator<ApiClient>();

  final _notificationService = locator<NotificationService>();

  String _baseUrl() {
    return locator<EnvManager>().env!.serverUrl;
  }

  //- login
  Future<Session> login(
      {required String username, required String password}) async {
    String auth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    _notificationService.apiRunning(true);
    final Response response = await _client.get(
        '${_baseUrl()}${EndpointsUser.login}',
        options: Options(headers: <String, String>{'Authorization': auth}));
    _notificationService.apiRunning(false);

    if (response.statusCode != 200) {
      if (response.statusCode == 401) {
        locator<NotificationService>().showSnackBar(NotificationType.warning,
            'Login fehlgeschlagen - falsches passwort!');
        throw ApiException('Failed to login', response.statusCode);
      } else {
        _notificationService.showSnackBar(
            NotificationType.error, 'Fehler beim Einloggen');
        throw ApiException('Failed to login', response.statusCode);
      }
    }

    final Map<String, dynamic> responseData = response.data;
    final Session session = Session.fromJson(responseData)
        .copyWith(server: locator<EnvManager>().env!.server);

    return session;
  }

  Future<User?> changePassword(
      {required String oldPassword, required String newPassword}) async {
    final data = jsonEncode({
      "old_password": oldPassword,
      "new_password": newPassword,
    });

    _notificationService.apiRunning(true);
    final Response response = await _client.patch(
      '${_baseUrl()}${EndpointsUser._changePassword(
        locator<SessionManager>().credentials.value.publicId!,
      )}',
      data: data,
      options: _client.hubOptions,
    );
    _notificationService.apiRunning(false);

    if (response.statusCode != 200) {
      _notificationService.showSnackBar(
          NotificationType.error, 'Fehler beim Ändern des Passworts');
      throw ApiException('Failed to change password', response.statusCode);
    }
    final User user = User.fromJson(response.data);

    return user;
  }

  Future<void> deleteUser(String publicId) async {
    final Response response = await _client.delete(
      '${_baseUrl()}${EndpointsUser._deleteUser(publicId)}',
      options: _client.hubOptions,
    );

    if (response.statusCode != 200) {
      _notificationService.showSnackBar(
          NotificationType.error, 'Fehler beim Löschen des Benutzers');
      throw ApiException('Failed to delete user', response.statusCode);
    }
    return;
  }

  Future<List<User>> increaseUsersCredit() async {
    final response = await _client.get(
      '${_baseUrl()}${EndpointsUser.increaseCredit}',
      options: _client.hubOptions,
    );

    if (response.statusCode != 200) {
      _notificationService.showSnackBar(
          NotificationType.error, 'Fehler beim Erhöhen des Guthabens');
      throw ApiException('Failed to increase credit', response.statusCode);
    }

    final List<User> users =
        (response.data as List).map((e) => User.fromJson(e)).toList();
    return users;
  }

  //- get all users
  Future<List<User>> getAllUsers() async {
    _notificationService.apiRunning(true);
    final Response response = await _client.get(
      '${_baseUrl()}${EndpointsUser.getAllUsers}',
      options: _client.hubOptions,
    );
    _notificationService.apiRunning(false);

    if (response.statusCode != 200) {
      _notificationService.showSnackBar(
          NotificationType.error, 'Fehler beim Laden der Benutzer');
      throw ApiException('Failed to fetch users', response.statusCode);
    }

    final List<User> users =
        (response.data as List).map((e) => User.fromJson(e)).toList();

    return users;
  }

  //- get self user
  Future<User> getSelfUser() async {
    _notificationService.apiRunning(true);
    final Response response = await _client.get(
      '${_baseUrl()}${EndpointsUser.getSelfUser}',
      options: _client.hubOptions,
    );
    _notificationService.apiRunning(false);

    if (response.statusCode != 200) {
      _notificationService.showSnackBar(
          NotificationType.error, 'Fehler beim Laden des Benutzers');
      throw ApiException('Failed to fetch self user', response.statusCode);
    }

    final User user = User.fromJson(response.data);

    return user;
  }

  Future<Session> updateSessionData(Session session) async {
    final client = locator<ApiClient>();

    final response = await client.get(EndpointsUser.getSelfUser);

    if (response.statusCode != 200) {
      _notificationService.showSnackBar(
          NotificationType.error, 'Fehler beim Laden des Benutzers');
      logger.f(
          'Dio error ${response.statusCode.toString()}: ${response.statusMessage.toString()} | ${StackTrace.current}');
      throw ApiException('Failed to fetch self user', response.statusCode);
    }

    final Session session = Session.fromJson(response.data);
    return session;
  }

  //- create user
  Future<User> postUser({
    required bool isAdmin,
    String? contact,
    required int credit,
    required String name,
    required String password,
    String? role,
    required int timeUnits,
    String? tutoring,
  }) async {
    final data = jsonEncode({
      "admin": isAdmin,
      if (contact != null) "contact": contact,
      "credit": credit,
      "name": name,
      "password": password,
      if (role != null) "role": role,
      "time_units": timeUnits,
      if (tutoring != null) "tutoring": tutoring,
    });

    _notificationService.apiRunning(true);
    final Response response = await _client.post(
      '${_baseUrl()}${EndpointsUser.createUser}',
      data: data,
      options: _client.hubOptions,
    );
    _notificationService.apiRunning(false);

    if (response.statusCode != 200) {
      _notificationService.showSnackBar(
          NotificationType.error, 'Fehler beim Erstellen des Benutzers');
      throw ApiException('Failed to create user', response.statusCode);
    }

    final User newUser = User.fromJson(response.data);

    return newUser;
  }

  Future<User> patchUser({
    required String publicId,
    bool? admin,
    String? contact,
    int? credit,
    String? name,
    String? password,
    String? role,
    int? timeUnits,
    String? tutoring,
  }) async {
    final data = jsonEncode({
      if (admin != null) "admin": admin,
      if (contact != null) "contact": contact,
      if (credit != null) "credit": credit,
      if (name != null) "name": name,
      if (role != null) "role": role,
      if (timeUnits != null) "time_units": timeUnits,
      if (tutoring != null) "tutoring": tutoring,
    });

    _notificationService.apiRunning(true);
    final Response response = await _client.patch(
      '${_baseUrl()}${EndpointsUser()._patchUser(publicId)}',
      data: data,
      options: _client.hubOptions,
    );
    _notificationService.apiRunning(false);

    if (response.statusCode != 200) {
      _notificationService.showSnackBar(
          NotificationType.error, 'Fehler beim Ändern des Benutzers');
      throw ApiException('Failed to patch user', response.statusCode);
    }

    final User user = User.fromJson(response.data);

    return user;
  }
}
