import 'package:collection/collection.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/features/matrix/models/matrix_room.dart';
import 'package:schuldaten_hub/features/matrix/models/matrix_user.dart';
import 'package:schuldaten_hub/features/matrix/services/matrix_policy_manager.dart';

class MatrixRoomHelper {
  static List<MatrixUser> usersInRoom(String roomId) {
    final List<MatrixUser> users =
        List.from(locator<MatrixPolicyManager>().matrixUsers.value);
    final usersInRoom = users
        .where((user) => user.matrixRooms.any((room) => room.id == roomId))
        .toList();
    return usersInRoom;
  }

  static int? powerLevelInRoom(String roomId, String userId) {
    final room = locator<MatrixPolicyManager>()
        .matrixRooms
        .value
        .firstWhere((room) => room.id == roomId);
    if (room.roomAdmins != null) {
      final RoomAdmin? userAsRoomAdmin =
          room.roomAdmins!.firstWhereOrNull((admin) => admin.id == userId);
      if (userAsRoomAdmin != null) {
        return userAsRoomAdmin.powerLevel;
      } else {
        return null;
      }
    }

    return room.powerLevelReactions;
  }

  static List<MatrixRoom> roomsFromRoomIds(List<String> roomIds) {
    final List<MatrixRoom> rooms =
        List.from(locator<MatrixPolicyManager>().matrixRooms.value);
    final roomsFromRoomIds =
        rooms.where((room) => roomIds.contains(room.id)).toList();
    return roomsFromRoomIds;
  }

  static List<String> restOfRooms(List<String> roomIds) {
    List<String> restOfRooms = [];
    final rooms = locator<MatrixPolicyManager>().matrixRooms.value;
    for (MatrixRoom room in rooms) {
      if (!roomIds.contains(room.id)) {
        restOfRooms.add(room.id);
      }
    }
    return restOfRooms;
  }
}
