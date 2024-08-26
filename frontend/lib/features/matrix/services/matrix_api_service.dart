import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:schuldaten_hub/common/constants/enums.dart';
import 'package:schuldaten_hub/common/services/api/api.dart';
import 'package:schuldaten_hub/common/services/api/services/api_client_service.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_manager.dart';
import 'package:schuldaten_hub/features/matrix/models/matrix_room.dart';
import 'package:schuldaten_hub/features/matrix/models/matrix_user.dart';
import 'package:schuldaten_hub/features/matrix/models/policy.dart';

import 'package:schuldaten_hub/features/matrix/services/matrix_policy_manager.dart';

enum MatrixAuthType { matrix, corporal }

class MatrixApiService {
  final _dioClient = locator<ApiClientService>();
  String? _matrixUrl;
  String? _matrixToken;
  String? _corporalToken;
  final notificationManager = locator<NotificationManager>();

  void setMatrixEnvironmentValues(
      {required String url,
      required String matrixToken,
      required String policyToken}) {
    _matrixUrl = url;
    _matrixToken = matrixToken;
    _corporalToken = policyToken;
    return;
  }

  void setClientMatrixCredentials({required MatrixAuthType authType}) {
    if (_matrixUrl == null || _matrixToken == null || _corporalToken == null) {
      final matrixPolicyManager = locator<MatrixPolicyManager>();
      _matrixUrl = matrixPolicyManager.matrixUrl;
      _matrixToken = matrixPolicyManager.matrixToken;
      _corporalToken = matrixPolicyManager.corporalToken;
    }

    final url = _matrixUrl;
    final token =
        authType == MatrixAuthType.matrix ? _matrixToken : _matrixToken;

    _dioClient.setCustomDioClientOptions(
      baseUrl: url,
      tokenKey: 'Authorization',
      token: token,
    );
  }

  Future<Policy?> fetchMatrixPolicy() async {
    setClientMatrixCredentials(authType: MatrixAuthType.corporal);

    final response = await _dioClient.get(
      '/_matrix/corporal/policy',
    );

    if (response.statusCode != 200) {
      notificationManager.showSnackBar(
          NotificationType.error, 'Fehler: status code ${response.statusCode}');
      throw ApiException('Fehler beim Laden der Policy', response.statusCode);
    }
    final Policy policy = Policy.fromJson(response.data['policy']);
    notificationManager.showSnackBar(
        NotificationType.success, 'Matrix-Räumeverwaltung geladen');
    _dioClient.setDefaultDioClientOptions();
    return policy;
  }

//- CREATE ROOM

  static const String _createRoom = '/_matrix/client/v3/createRoom';
// https://spec.matrix.org/v1.10/client-server-api/#creation

// XPOST -d '{
//   "creation_content": {
//     "m.federate": false
//   },
//   "name": "Testraum",
//   "preset": "private_chat",
//   "room_alias_name": "testraum",
//   "topic": "Das ist ein Testraum"
// }' "https://post.hermannschule.de/_matrix/client/v3/createRoom"

  Future<MatrixRoom?> createMatrixRoom(
      String name, String topic, String? aliasName) async {
    setClientMatrixCredentials(authType: MatrixAuthType.matrix);

    MatrixRoom? room;

    final data = jsonEncode({
      {
        "creation_content": {"m.federate": false},
        "name": name,
        "preset": "private_chat",
        if (aliasName != null) "room_alias_name": "testraum2",
        "topic": topic
      }
    });

    final Response response = await _dioClient.post(_createRoom, data: data);
    if (response.statusCode == 200) {
      // extract the value of "room_id" out of the response
      final String roomId = jsonDecode(response.data)['room_id'];
      room = await fetchAdditionalRoomInfos(roomId);
    }
    _dioClient.setDefaultDioClientOptions();
    return room;
  }

  //- GET ROOMS

  // Future<List<MatrixRoom>?> fetchMatrixRooms() async {
  //   List<MatrixRoom> rooms = [];
  //   // use a custom client with the right token to fetch the policy
  //   _dioClient.setCustomDioClientOptions(
  //       baseUrl: _matrixUrl,
  //       tokenKey: 'Authorization',
  //       token: 'Bearer $_synapseToken');

  //   notificationManager.showSnackBar(
  //       NotificationType.success, 'Matrix-Räume werden geladen...');

  //   for (String roomId in policy.managedRoomIds) {
  //     MatrixRoom namedRoom = await _fetchAdditionalRoomInfos(roomId);
  //     rooms.add(namedRoom);
  //   }
  // }

  //- PUT POLICY

  //**- USER

  //- PUT USER
  String _createMatrixUser(String userId) {
    return '/_synapse/admin/v2/users/$userId';
  }

  Future<MatrixUser?> createNewMatrixUser({
    required String matrixId,
    required String displayName,
    required String password,
  }) async {
    setClientMatrixCredentials(authType: MatrixAuthType.matrix);

    final data = jsonEncode({
      "user_id": matrixId,
      "password": password,
      "admin": false,
      "displayname": displayName,
      "threepids": [],
      "avatar_url": ""
    });

    final Response response = await _dioClient.put(
      _createMatrixUser(matrixId),
      data: data,
    );
    if (response.statusCode != 201 || response.statusCode != 200) {
      notificationManager.showSnackBar(
          NotificationType.error, 'Fehler: status code ${response.statusCode}');
      throw ApiException(
          'Fehler beim Erstellen des Benutzers', response.statusCode);
    }
    final MatrixUser newUser = MatrixUser(
      id: matrixId,
      displayName: displayName,
    );
    if (response.statusCode == 200) {
      notificationManager.showSnackBar(
          NotificationType.success, 'Benutzer erstellt');
    }
    if (response.statusCode == 201) {
      notificationManager.showSnackBar(
          NotificationType.success, 'Deaktivierter Benutzer reaktiviert');
    }
    _dioClient.setDefaultDioClientOptions();

    return newUser;
  }

  //- DELETE USER
  String _deleteMatrixUser(String userId) {
    return '/_synapse/admin/v2/users/$userId/deactivate';
  }

  Future<bool> deleteMatrixUser(String userId) async {
    setClientMatrixCredentials(authType: MatrixAuthType.matrix);

    final data = jsonEncode({
      "erase": true,
    });
    final Response response =
        await _dioClient.delete(_deleteMatrixUser(userId), data: data);

    if (response.statusCode != 200) {
      notificationManager.showSnackBar(
          NotificationType.error, 'Fehler: status code ${response.statusCode}');
      _dioClient.setDefaultDioClientOptions();
      return false;
    }

    _dioClient.setDefaultDioClientOptions();
    return true;
  }

  //- GET USER
  String _fetchMatrixUser(String userId) {
    return '/_synapse/admin/v2/users/$userId';
  }

  Future<MatrixUser?> fetchMatrixUserById(String userId) async {
    setClientMatrixCredentials(authType: MatrixAuthType.matrix);

    final Response response = await _dioClient.get(
      _fetchMatrixUser(userId),
    );

    if (response.statusCode == 200) {
      final MatrixUser user = MatrixUser.fromJson(response.data);
      _dioClient.setDefaultDioClientOptions();
      return user;
    }
    _dioClient.setDefaultDioClientOptions();
    return null;
  }

//- PUT

//- GET MEDIA
// https://spec.matrix.org/v1.10/client-server-api/#get_matrixmediav3downloadservernamemediaid
// GET /_matrix/media/v3/download/{serverName}/{mediaId}
  //- GET ROOM NAME
  // String fetchRoomName(String roomId) {
  //   return '_synapse/admin/v1/rooms/$roomId';
  // }
  String _fetchRoomName(String roomId) {
    return '/_matrix/client/v3/rooms/$roomId/state/m.room.name';
    //return '_synapse/admin/v1/rooms/$roomId/state';
  }

  String _fetchRoomPowerLevelsUrl(String roomId) {
    return '/_matrix/client/v3/rooms/$roomId/state/m.room.power_levels';
  }

  Future<MatrixRoom> fetchAdditionalRoomInfos(String roomId) async {
    setClientMatrixCredentials(authType: MatrixAuthType.matrix);

    late String name;
    late int powerLevelReactions;
    late int eventsDefault;
    late List<RoomAdmin> roomAdmins;

    // First API call
    final responseRoomSPowerLevels = await _dioClient.get(
      // ignore: unnecessary_string_interpolations
      '${_fetchRoomPowerLevelsUrl(roomId)}',
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
    final responseRoomName = await _dioClient.get(
      // ignore: unnecessary_string_interpolations
      '${_fetchRoomName(roomId)}',
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
    _dioClient.setDefaultDioClientOptions();
    return roomWithAdditionalInfos;
  }

  //- PUT ROOM POWER LEVELS
  String _putRoomPowerLevels(String roomId) {
    final roomIdforUrl = roomId.replaceAllMapped(
      RegExp(r'[!:]'),
      (match) {
        switch (match.group(0)) {
          case '!':
            return '%21';
          case ':':
            return '%3A';
          default:
            return match.group(0)!;
        }
      },
    );
    return '/_matrix/client/v3/rooms/$roomIdforUrl/state/m.room.power_levels';
  }

  Future<MatrixRoom> changeRoomPowerLevels(
      {required String roomId,
      RoomAdmin? newRoomAdmin,
      bool? removeAsAdmin,
      int? eventsDefault,
      int? reactions}) async {
    List<RoomAdmin> adminPowerLevels = [];
    Map<String, dynamic> adminPowerLevelsMap = {};
    final matrixPolicyManager = locator<MatrixPolicyManager>();
    final matrixRoom = matrixPolicyManager.getRoomById(roomId);
// We make sure that the instance admin has admin power level in the room
    adminPowerLevels = matrixRoom.roomAdmins ??
        [RoomAdmin(id: matrixPolicyManager.matrixAdmin!, powerLevel: 100)];
    if (newRoomAdmin != null) {
      adminPowerLevels.add(newRoomAdmin);
    }
    for (RoomAdmin admin in adminPowerLevels) {
      adminPowerLevelsMap[admin.id] = admin.powerLevel;
    }
    setClientMatrixCredentials(authType: MatrixAuthType.matrix);

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
        "m.reaction": reactions ?? matrixRoom.powerLevelReactions,
        "m.room.redaction": 0,
        "org.matrix.msc3401.call": 50,
        "org.matrix.msc3401.call.member": 50,
        "im.vector.modular.widgets": 50,
        "io.element.voice_broadcast_info": 50
      },
      "events_default": eventsDefault ?? matrixRoom.eventsDefault,
      "invite": 50,
      "kick": 50,
      "notifications": {"room": 20},
      "redact": 50,
      "state_default": 50,
      "users": adminPowerLevelsMap,
      "users_default": 0
    });

    final Response response = await _dioClient.put(
      _putRoomPowerLevels(roomId),
      data: data,
    );

    if (response.statusCode != 200) {
      notificationManager.showSnackBar(
          NotificationType.error, 'Fehler: status code ${response.statusCode}');
      throw ApiException(
          'Fehler beim Setzen der Power Levels', response.statusCode);
    }

    final MatrixRoom room = await fetchAdditionalRoomInfos(roomId);
    _dioClient.setDefaultDioClientOptions();
    return room;
  }
}
