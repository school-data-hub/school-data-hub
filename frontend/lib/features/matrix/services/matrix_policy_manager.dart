import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:listenable_collections/listenable_collections.dart';
import 'package:schuldaten_hub/api/api.dart';
import 'package:schuldaten_hub/api/services/dio/api_client_service.dart';
import 'package:schuldaten_hub/api/endpoints/matrix_endpoints.dart';
import 'package:schuldaten_hub/common/constants/enums.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_manager.dart';
import 'package:schuldaten_hub/common/services/session_manager.dart';
import 'package:schuldaten_hub/common/utils/logger.dart';
import 'package:schuldaten_hub/common/utils/secure_storage.dart';
import 'package:schuldaten_hub/features/matrix/models/matrix_room.dart';
import 'package:schuldaten_hub/features/matrix/models/matrix_user.dart';
import 'package:schuldaten_hub/features/matrix/models/policy.dart';
import 'package:schuldaten_hub/features/matrix/services/matrix_policy_helper_functions.dart';
import 'package:schuldaten_hub/features/matrix/services/pdf_printer/matrix_credentials_printer.dart';
import 'package:watch_it/watch_it.dart';

class MatrixCredentials {
  final String url;
  final String matrixToken;
  final String policyToken;

  MatrixCredentials(
      {required this.url,
      required this.matrixToken,
      required this.policyToken});

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'matrixToken': matrixToken,
      'policyToken': policyToken,
    };
  }

  factory MatrixCredentials.fromJson(Map<String, dynamic> json) {
    return MatrixCredentials(
      url: json['url'] as String,
      matrixToken: json['matrixToken'] as String,
      policyToken: json['policyToken'] as String,
    );
  }
}

class MatrixPolicyManager {
  ValueListenable<Policy?> get matrixPolicy => _matrixPolicy;
  ValueListenable<bool> get pendingChanges => _pendingChanges;
  ValueListenable<List<MatrixUser>> get matrixUsers => _matrixUsers;
  ValueListenable<List<MatrixRoom>> get matrixRooms => _matrixRooms;
  String get matrixUrl => _matrixUrl;
  ValueListenable<String> get synapseToken => _synapseToken;
  ValueListenable<String> get matrixAdmin => _matrixAdminId;
  ValueListenable<String> get corporalToken => _corporalToken;

  final _matrixAdminId = ValueNotifier<String>('');
  final _matrixPolicy = ValueNotifier<Policy?>(null);
  final _pendingChanges = ValueNotifier<bool>(false);
  final _synapseToken = ValueNotifier<String>('');
  final _matrixUsers = ListNotifier<MatrixUser>();
  final _matrixRooms = ListNotifier<MatrixRoom>();
  late final String _matrixUrl;
  final _corporalToken = ValueNotifier<String>('');

  MatrixPolicyManager() {
    logger.i('MatrixPolicyManager constructor called');
  }
  final dioClient = locator<ApiClientService>();
  final notificationManager = locator<NotificationManager>();

  Future<MatrixPolicyManager> init() async {
    if (locator<SessionManager>().isAdmin.value == true) {
      if (await secureStorageContains('matrix')) {
        try {
          String? matrixStoredValues = await secureStorageRead('matrix');
          if (matrixStoredValues == null) {
            throw Exception('Matrix stored values are null');
          }
          final MatrixCredentials credentials =
              MatrixCredentials.fromJson(jsonDecode(matrixStoredValues));
          _matrixUrl = credentials.url;
          _synapseToken.value = credentials.matrixToken;
          _corporalToken.value = credentials.policyToken;
          notificationManager.showSnackBar(NotificationType.success,
              'Matrix-Räumeverwaltung wird geladen...');
          await fetchMatrixPolicy();
        } catch (e) {
          logger.f('Error reading matrix credentials from secureStorage: $e',
              stackTrace: StackTrace.current);

          await secureStorageDelete('matrix');
        }
      }
    }
    return this;
  }

  Future<void> deleteAndDeregisterMatrixPolicyManager() async {
    _matrixAdminId.value = '';
    _matrixPolicy.value = null;
    _pendingChanges.value = false;
    _synapseToken.value = '';
    _matrixUsers.clear();
    _matrixRooms.clear();
    _corporalToken.value = '';
    await secureStorageDelete('matrix');
    locator<SessionManager>()
        .changeMatrixPolicyManagerRegistrationStatus(false);
    notificationManager.showSnackBar(
        NotificationType.success, 'Matrix-Räumeverwaltung deaktiviert');
  }

  //-TOOLS
  void pendingChangesHandler(bool value) {
    if (value == _pendingChanges.value) return;
    _pendingChanges.value = value;
  }

  void setMatrixEnvironmentValues(
      {required String url,
      required String policyToken,
      required String matrixToken}) async {
    _matrixUrl = url;
    _corporalToken.value = policyToken;
    _synapseToken.value = matrixToken;
    secureStorageWrite(
        'matrix',
        jsonEncode(MatrixCredentials(
                url: url, matrixToken: matrixToken, policyToken: policyToken)
            .toJson()));
    await fetchMatrixPolicy();
  }

  //- MATRIX POLICY
  Future<void> fetchMatrixPolicy() async {
    // use a custom client with the right token to fetch the policy
    dioClient.setCustomDioClientOptions(
        baseUrl: _matrixUrl,
        tokenKey: 'Authorization',
        token: 'Bearer ${_corporalToken.value}');

    final response = await dioClient.get(
      '${_matrixUrl}_matrix/corporal/policy',
    );

    if (response.statusCode != 200) {
      notificationManager.showSnackBar(
          NotificationType.error, 'Fehler: status code ${response.statusCode}');
      throw ApiException('Fehler beim Laden der Policy', response.statusCode);
    }
    final Policy policy = Policy.fromJson(response.data['policy']);
    notificationManager.showSnackBar(
        NotificationType.success, 'Matrix-Räumeverwaltung geladen');

    List<MatrixRoom> rooms = [];
    dioClient.setCustomDioClientOptions(token: 'Bearer ${_synapseToken.value}');

    notificationManager.showSnackBar(
        NotificationType.success, 'Matrix-Räume werden geladen...');
    for (MatrixUser user in policy.matrixUsers!) {
      _matrixUsers.add(user);
    }

    for (String roomId in policy.managedRoomIds) {
      MatrixRoom namedRoom = await _fetchAdditionalRoomInfos(roomId);
      rooms.add(namedRoom);
    }
    _matrixRooms.addAll(rooms);
    _matrixPolicy.value = policy;

    notificationManager.showSnackBar(NotificationType.success, 'Räume geladen');

    logger.i('Fetched Matrix policy!');

    locator<SessionManager>().changeMatrixPolicyManagerRegistrationStatus(true);
    dioClient.setDefaultDioClientOptions();
    return;
  }

  //- ROOM REPOSITORY

  Future<void> createNewRoom(
      String name, String topic, String? aliasName) async {
    dioClient.setCustomDioClientOptions(
        baseUrl: _matrixUrl,
        tokenKey: 'Authorization',
        token: 'Bearer ${_synapseToken.value}');

    final data = jsonEncode({
      {
        "creation_content": {"m.federate": false},
        "name": name,
        "preset": "private_chat",
        if (aliasName != null) "room_alias_name": "testraum2",
        "topic": topic
      }
    });

    final Response response =
        await dioClient.post(MatrixEndpoints.createRoom, data: data);
    if (response.statusCode == 200) {
      // extract the value of "room_id" out of the response
      final String roomId = jsonDecode(response.data)['room_id'];
      final room = await _fetchAdditionalRoomInfos(roomId);
      addManagedRoom(room);
    }
    dioClient.setDefaultDioClientOptions();
  }

  void addManagedRoom(MatrixRoom newRoom) {
    _matrixRooms.add(newRoom);

    final admin = _matrixUsers.value
        .firstWhere((element) => element.id == _matrixAdminId.value);

    admin.joinRoom(newRoom);

    _pendingChanges.value = true;
  }

  Future setRoomPowerLevels(String roomId, List<RoomAdmin>? adminPowerLevels,
      int eventsDefault, int reactions) async {
    dioClient.setCustomDioClientOptions(
        baseUrl: _matrixUrl,
        tokenKey: 'Authorization',
        token: 'Bearer ${_synapseToken.value}');

    final data = jsonEncode({
      "ban": 50,
      "events": {
        "m.room.name": 50,
        "m.room.power_levels": 100,
        "m.room.history_visibility": 100,
        "m.room.canonical_alias": 50,
        "m.room.avatar": 50,
        "m.room.tombstone": 100,
        "m.room.server_acl": 100,
        "m.room.encryption": 100,
        "m.space.child": 50,
        "m.room.topic": 50,
        "m.room.pinned_events": 50,
        "m.reaction": reactions,
        "m.room.redaction": 0,
        "org.matrix.msc3401.call": 50,
        "org.matrix.msc3401.call.member": 50,
        "im.vector.modular.widgets": 50,
        "io.element.voice_broadcast_info": 50
      },
      "events_default": eventsDefault,
      "invite": 50,
      "kick": 50,
      "notifications": {"room": 20},
      "redact": 50,
      "state_default": 50,
      if (adminPowerLevels != null) "users": adminPowerLevels,
      if (adminPowerLevels == null) "users": {_matrixAdminId.value: 100},
      "users_default": 0
    });

    final response = await dioClient.put(
        '$_matrixUrl${MatrixEndpoints().putRoomPowerLevels(roomId)}',
        data: data);
    logger.i('Response: ${response.data}');
    dioClient.setDefaultDioClientOptions();
  }

  Future<MatrixRoom> _fetchAdditionalRoomInfos(String roomId) async {
    dioClient.setCustomDioClientOptions(
        baseUrl: _matrixUrl,
        tokenKey: 'Authorization',
        token: 'Bearer ${_synapseToken.value}');

    late String name;
    late int powerLevelReactions;
    late int eventsDefault;
    late List<RoomAdmin> roomAdmins;

    // First API call
    final responseRoomSPowerLevels = await dioClient.get(
      '$_matrixUrl${MatrixEndpoints().fetchRoomPowerLevels(roomId)}',
    );

    if (responseRoomSPowerLevels.statusCode == 200) {
      powerLevelReactions =
          responseRoomSPowerLevels.data['events']['m.reaction'] ?? 0;
      eventsDefault = responseRoomSPowerLevels.data['events_default'] ?? 0;

      if (responseRoomSPowerLevels.data['users'] is Map<String, dynamic>) {
        final usersMap =
            responseRoomSPowerLevels.data['users'] as Map<String, dynamic>;
        roomAdmins = usersMap.keys
            .map(
                (userId) => RoomAdmin(id: userId, powerLevel: usersMap[userId]))
            .toList();
      }
    }

    // Second API call
    final responseRoomName = await dioClient.get(
      '$_matrixUrl${MatrixEndpoints().fetchRoomName(roomId)}',
    );

    if (responseRoomName.statusCode == 200) {
      name = responseRoomName.data['name'] ?? 'No Room Name';
    }

    MatrixRoom roomWithAdditionalInfos = MatrixRoom(
      id: roomId,
      name: name,
      powerLevelReactions: powerLevelReactions,
      eventsDefault: eventsDefault,
      roomAdmins: roomAdmins,
    );
    dioClient.setDefaultDioClientOptions();
    return roomWithAdditionalInfos;
  }
  //- USER REPOSITORY

  Future createNewMatrixUser(String matrixId, String displayName) async {
    dioClient.setCustomDioClientOptions(
        baseUrl: _matrixUrl,
        tokenKey: 'Authorization ',
        token: 'Bearer ${_synapseToken.value}');

    final password = generatePassword();
    final data = jsonEncode({
      "user_id": matrixId,
      "password": password,
      "admin": false,
      "displayname": displayName,
      "threepids": [],
      "avatar_url": ""
    });

    final Response response = await dioClient.put(
      MatrixEndpoints().createMatrixUser(matrixId),
      data: data,
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      final MatrixUser newUser = MatrixUser(
        id: matrixId,
        displayName: displayName,
      );
      _matrixUsers.add(newUser);
      await printMatrixCredentials(_matrixUrl, newUser, password);
    }
    dioClient.setDefaultDioClientOptions();

    _pendingChanges.value = true;
    return;
  }

  Future deleteUser(String userId) async {
    dioClient.setCustomDioClientOptions(
        baseUrl: _matrixUrl,
        tokenKey: 'Authorization',
        token: 'Bearer ${_synapseToken.value}');

    final data = jsonEncode({
      "erase": true,
    });
    final Response response = await dioClient
        .delete(MatrixEndpoints().deleteMatrixUser(userId), data: data);

    if (response.statusCode == 200) {
      _matrixUsers.removeWhere((user) => user.id == userId);
    }
    _pendingChanges.value = true;
    dioClient.setDefaultDioClientOptions();
  }

  Future addMatrixUserToRooms(String matrixUserId, List<String> roomIds) async {
    final user =
        _matrixUsers.value.firstWhere((element) => element.id == matrixUserId);
    for (String roomId in roomIds) {
      user.joinRoom(MatrixRoom.fromPolicyId(roomId));
    }
    _pendingChanges.value = true;
  }
}
