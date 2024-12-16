import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:schuldaten_hub/common/domain/models/enums.dart';
import 'package:schuldaten_hub/common/domain/session_manager.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_service.dart';
import 'package:schuldaten_hub/common/utils/logger.dart';
import 'package:schuldaten_hub/common/utils/secure_storage.dart';
import 'package:schuldaten_hub/features/matrix/data/matrix_repository.dart';
import 'package:schuldaten_hub/features/matrix/domain/matrix_policy_helper_functions.dart';
//import 'package:schuldaten_hub/features/matrix/filters/matrix_policy_filter_manager.dart';

import 'package:schuldaten_hub/features/matrix/domain/models/matrix_credentials.dart';
import 'package:schuldaten_hub/features/matrix/domain/models/matrix_room.dart';
import 'package:schuldaten_hub/features/matrix/domain/models/matrix_user.dart';
import 'package:schuldaten_hub/features/matrix/domain/models/policy.dart';
import 'package:schuldaten_hub/features/matrix/utils/matrix_credentials_pdf_generator.dart';

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

  final _matrixUsers = ValueNotifier<List<MatrixUser>>([]);
  ValueListenable<List<MatrixUser>> get matrixUsers => _matrixUsers;

  final _matrixRooms = ValueNotifier<List<MatrixRoom>>([]);
  ValueListenable<List<MatrixRoom>> get matrixRooms => _matrixRooms;

  final _pendingChanges = ValueNotifier<bool>(false);
  ValueListenable<bool> get pendingChanges => _pendingChanges;
  final _compulsoryRooms = List<String>.empty(growable: true);
  List<String> get compulsoryRooms => _compulsoryRooms;

  MatrixPolicyManager();

  final matrixApiService = MatrixRepository();
  final notificationService = locator<NotificationService>();

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
              matrixToken: matrixToken!,
              policyToken: corporalToken!);
          notificationService.showSnackBar(NotificationType.success,
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

  void pendingChangesHandler(bool newValue) {
    if (newValue == _pendingChanges.value) return;
    _pendingChanges.value = newValue;
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
            compulsoryRooms: [..._compulsoryRooms]).toJson()));

    await fetchMatrixPolicy();
  }

  Future<void> deleteAndDeregisterMatrixPolicyManager() async {
    _matrixAdminId = null;
    _matrixPolicy = null;
    _pendingChanges.value = false;
    _matrixToken = null;
    _matrixUsers.value = [];
    _matrixRooms.value = [];
    _corporalToken = null;
    await secureStorageDelete('matrix');

    locator<SessionManager>()
        .changeMatrixPolicyManagerRegistrationStatus(false);
    notificationService.showSnackBar(
        NotificationType.success, 'Matrix-Räumeverwaltung deaktiviert');
  }

  //- MATRIX POLICY
  Future<void> fetchMatrixPolicy() async {
    final Policy? policy = await matrixApiService.fetchMatrixPolicy();
    if (policy == null) {
      logger.e('Error fetching Matrix policy!');
      return;
    }

    _matrixPolicy = policy;

    final matrixUsers = policy.matrixUsers!;
    matrixUsers.sort((a, b) => a.displayName.compareTo(b.displayName));
    _matrixUsers.value = matrixUsers;
    notificationService.showSnackBar(
        NotificationType.success, 'Matrix-Konten geladen!');
    List<MatrixRoom> rooms = [];

    notificationService.showSnackBar(
        NotificationType.success, 'Matrix-Räume werden geladen...');

    // remove duplicates
    final List<String> roomIds = policy.managedRoomIds.toSet().toList();

    for (String roomId in roomIds) {
      MatrixRoom namedRoom =
          await matrixApiService.fetchAdditionalRoomInfos(roomId);
      rooms.add(namedRoom);
    }

    // sort the rooms by name
    rooms.sort((a, b) => a.name!.compareTo(b.name!));
    _matrixRooms.value = rooms;

    notificationService.showSnackBar(NotificationType.success, 'Räume geladen');

    logger.i('Fetched Matrix policy!');
    _pendingChanges.value = false;
    locator<SessionManager>().changeMatrixPolicyManagerRegistrationStatus(true);

    return;
  }

  Future<void> putPolicy() async {
    await matrixApiService.putMatrixPolicy();
    _pendingChanges.value = false;
  }

  MatrixRoom getRoomById(String roomId) {
    return _matrixRooms.value.firstWhere((element) => element.id == roomId);
  }

  //- ROOM REPOSITORY

  Future<void> createNewRoom(
      {required String name,
      required String topic,
      required String? aliasName,
      required ChatTypePreset chatTypePreset}) async {
    final MatrixRoom? room = await matrixApiService.createMatrixRoom(
        name: name,
        topic: topic,
        aliasName: aliasName,
        chatTypePreset: chatTypePreset);
    if (room == null) {
      return;
    }
    addManagedRoom(room);
    notificationService.showSnackBar(
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

    _pendingChanges.value = true;
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
    notificationService.showSnackBar(
        NotificationType.success, 'Power Levels gesetzt');
  }

  //- USER REPOSITORY

  Future createNewMatrixUser(String matrixId, String displayName) async {
    final password = MatrixHelperFunctions.generatePassword();
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

    await printMatrixCredentials(
        matrixDomain: _matrixUrl, matrixUser: newUser, password: password);

    _pendingChanges.value = true;
    return;
  }

  Future deleteUser(String userId) async {
    final bool success = await matrixApiService.deleteMatrixUser(userId);

    if (success == true) {
      List<MatrixUser> matrixUsers = List.from(_matrixUsers.value);
      matrixUsers.removeWhere((user) => user.id == userId);
      _matrixUsers.value = matrixUsers;
      notificationService.showSnackBar(
          NotificationType.success, 'Benutzer gelöscht');
      _pendingChanges.value = true;
    }
  }

  void addMatrixUserToRooms(String matrixUserId, List<String> roomIds) {
    final user =
        _matrixUsers.value.firstWhere((element) => element.id == matrixUserId);
    for (String roomId in roomIds) {
      user.joinRoom(MatrixRoom(id: roomId));
    }
    _pendingChanges.value = true;
  }

  void addMatrixUserToGroupRooms(MatrixUser matrixUser) {
    List<MatrixRoom> matrixRooms = List.from(_matrixRooms.value);
    for (MatrixRoom room in matrixRooms) {}
  }
}
