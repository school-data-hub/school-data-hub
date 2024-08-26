import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:schuldaten_hub/features/matrix/models/matrix_credentials.dart';
import 'package:schuldaten_hub/features/matrix/services/matrix_api_service.dart';
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

class MatrixPolicyManager {
  // TODO: move matrix environment values to a separate class
  late final String _matrixUrl;
  String get matrixUrl => _matrixUrl;

  String? _matrixAdminId;
  String? get matrixAdmin => _matrixAdminId;

  String? _matrixToken;
  String? get matrixToken => 'Bearer $_matrixToken';

  String? _corporalToken;
  String? get corporalToken => 'Bearer $_corporalToken';

  Policy? _matrixPolicy;
  Policy? get matrixPolicy => _matrixPolicy;
  bool get isMatrixPolicyLoaded => _matrixPolicy != null;
  bool _pendingChanges = false;
  bool get pendingChanges => _pendingChanges;

  final _matrixUsers = ValueNotifier<List<MatrixUser>>([]);
  ValueListenable<List<MatrixUser>> get matrixUsers => _matrixUsers;

  final _matrixRooms = ValueNotifier<List<MatrixRoom>>([]);
  ValueListenable<List<MatrixRoom>> get matrixRooms => _matrixRooms;

  final _compulsoryRooms = List<String>.empty(growable: true);
  List<String> get compulsoryRooms => _compulsoryRooms;

  MatrixPolicyManager();

  final matrixApiService = MatrixApiService();
  final notificationManager = locator<NotificationManager>();

  Future<MatrixPolicyManager> init() async {
    if (locator<SessionManager>().isAdmin.value == true) {
      if (await secureStorageContainsKey(SecureStorageKey.matrix.value)) {
        try {
          String? matrixStoredValues =
              await secureStorageRead(SecureStorageKey.matrix.value);
          if (matrixStoredValues == null) {
            throw Exception('Matrix stored values are null');
          }
          final MatrixCredentials credentials =
              MatrixCredentials.fromJson(jsonDecode(matrixStoredValues));
          _matrixUrl = credentials.url;
          _matrixToken = credentials.matrixToken;
          _corporalToken = credentials.policyToken;

          // set the variables in the matrixApiService
          matrixApiService.setMatrixEnvironmentValues(
              url: _matrixUrl,
              matrixToken: _matrixToken!,
              policyToken: _corporalToken!);
          notificationManager.showSnackBar(NotificationType.success,
              'Matrix-Räumeverwaltung wird geladen...');
          await fetchMatrixPolicy();
        } catch (e) {
          logger.f('Error reading matrix credentials from secureStorage: $e',
              stackTrace: StackTrace.current);

          await secureStorageDelete(SecureStorageKey.matrix.value);
        }
      }
    }
    return this;
  }

  void pendingChangesHandler(bool value) {
    if (value == _pendingChanges) return;
    _pendingChanges = value;
  }

  MatrixUser getUserById(String userId) {
    return _matrixUsers.value.firstWhere((element) => element.id == userId);
  }

  void setMatrixEnvironmentValues(
      {required String url,
      required String policyToken,
      required String matrixToken,
      required List<String> compulsoryRooms}) async {
    _matrixUrl = url;
    _corporalToken = policyToken;
    _matrixToken = matrixToken;
    _compulsoryRooms.addAll(compulsoryRooms);

    secureStorageWrite(
        SecureStorageKey.matrix.value,
        jsonEncode(MatrixCredentials(
                url: url,
                matrixToken: matrixToken,
                policyToken: policyToken,
                compulsorayRooms: _compulsoryRooms)
            .toJson()));

    await fetchMatrixPolicy();
  }

  Future<void> deleteAndDeregisterMatrixPolicyManager() async {
    _matrixAdminId = null;
    _matrixPolicy = null;
    _pendingChanges = false;
    _matrixToken = null;
    _matrixUsers.value = [];
    _matrixRooms.value = [];
    _corporalToken = null;
    await secureStorageDelete('matrix');

    locator<SessionManager>()
        .changeMatrixPolicyManagerRegistrationStatus(false);
    notificationManager.showSnackBar(
        NotificationType.success, 'Matrix-Räumeverwaltung deaktiviert');
  }

  //- MATRIX POLICY
  Future<void> fetchMatrixPolicy() async {
    final Policy? policy = await matrixApiService.fetchMatrixPolicy();
    if (policy == null) {
      return;
    }

    _matrixPolicy = policy;

    final matrixUsers = policy.matrixUsers!;
    matrixUsers.sort((a, b) => a.displayName.compareTo(b.displayName));
    _matrixUsers.value = matrixUsers;
    notificationManager.showSnackBar(
        NotificationType.success, 'Matrix-Konten geladen!');
    List<MatrixRoom> rooms = [];

    notificationManager.showSnackBar(
        NotificationType.success, 'Matrix-Räume werden geladen...');

    for (String roomId in policy.managedRoomIds) {
      MatrixRoom namedRoom =
          await matrixApiService.fetchAdditionalRoomInfos(roomId);
      rooms.add(namedRoom);
    }

    // sort the rooms by name
    rooms.sort((a, b) => a.name!.compareTo(b.name!));
    _matrixRooms.value = rooms;

    notificationManager.showSnackBar(NotificationType.success, 'Räume geladen');

    logger.i('Fetched Matrix policy!');

    locator<SessionManager>().changeMatrixPolicyManagerRegistrationStatus(true);

    return;
  }

  MatrixRoom getRoomById(String roomId) {
    return _matrixRooms.value.firstWhere((element) => element.id == roomId);
  }

  //- ROOM REPOSITORY

  Future<void> createNewRoom(
      String name, String topic, String? aliasName) async {
    final MatrixRoom? room =
        await matrixApiService.createMatrixRoom(name, topic, aliasName);
    if (room == null) {
      return;
    }
    addManagedRoom(room);
    notificationManager.showSnackBar(
        NotificationType.success, 'Raum ${room.name} erstellt');
  }

  void addManagedRoom(MatrixRoom newRoom) {
    final matrixRooms = [..._matrixRooms.value];
    matrixRooms.add(newRoom);
    _matrixRooms.value = matrixRooms;
    // _matrixRooms.add(newRoom);

    final admin = _matrixUsers.value
        .firstWhere((element) => element.id == _matrixAdminId);

    admin.joinRoom(newRoom);

    _pendingChanges = true;
  }

  Future<void> changeRoomPowerLevels(
      {required String roomId,
      RoomAdmin? roomAdmin,
      bool? removeAsAdmin,
      int? eventsDefault,
      int? reactions}) async {
    final MatrixRoom room = await matrixApiService.changeRoomPowerLevels(
        roomId: roomId,
        newRoomAdmin: roomAdmin,
        removeAsAdmin: removeAsAdmin,
        eventsDefault: eventsDefault,
        reactions: reactions);

    _matrixRooms.value = {..._matrixRooms.value, room}.toList();
    notificationManager.showSnackBar(
        NotificationType.success, 'Power Levels gesetzt');
  }

  //- USER REPOSITORY

  Future createNewMatrixUser(String matrixId, String displayName) async {
    final password = generatePassword();
    final MatrixUser? newUser = await matrixApiService.createNewMatrixUser(
      matrixId: matrixId,
      displayName: displayName,
      password: password,
    );
    if (newUser == null) {
      return;
    }

    final matrixUsers = [..._matrixUsers.value];
    matrixUsers.add(newUser);

    await printMatrixCredentials(_matrixUrl, newUser, password);

    _pendingChanges = true;
    return;
  }

  Future deleteUser(String userId) async {
    final bool success = await matrixApiService.deleteMatrixUser(userId);

    if (success == true) {
      List<MatrixUser> matrixUsers = List.from(_matrixUsers.value);
      matrixUsers.removeWhere((user) => user.id == userId);
      _matrixUsers.value = matrixUsers;
      notificationManager.showSnackBar(
          NotificationType.success, 'Benutzer gelöscht');
      _pendingChanges = true;
    }
  }

  Future addMatrixUserToRooms(String matrixUserId, List<String> roomIds) async {
    final user =
        _matrixUsers.value.firstWhere((element) => element.id == matrixUserId);
    for (String roomId in roomIds) {
      user.joinRoom(MatrixRoom.fromPolicyId(roomId));
    }
    _pendingChanges = true;
  }
}
