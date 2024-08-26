import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/widgets/dialogues/information_dialog.dart';
import 'package:schuldaten_hub/features/matrix/models/matrix_room.dart';
import 'package:schuldaten_hub/features/matrix/models/matrix_user.dart';
import 'package:schuldaten_hub/features/matrix/models/policy.dart';
import 'package:schuldaten_hub/features/matrix/services/matrix_policy_manager.dart';
import 'package:url_launcher/url_launcher.dart';

Future<bool> generatePolicyJsonFile() async {
  // create a new json file with the policy
  final directory = await getApplicationDocumentsDirectory();
  final File file = File('${directory.path}/matrix_policy.json');
  if (file.existsSync()) {
    file.deleteSync();
  }
  final Policy policy = locator<MatrixPolicyManager>().matrixPolicy!;
  final Map<String, dynamic> jsonString = policy.toJson();
  // transform the map into a json string
  final String policyJson = jsonEncode(jsonString);

  file.writeAsStringSync(policyJson);
  return true;
}

List<MatrixUser> usersInRoom(String roomId) {
  final List<MatrixUser> users =
      List.from(locator<MatrixPolicyManager>().matrixUsers.value);
  final usersInRoom = users
      .where((user) => user.matrixRooms.any((room) => room.id == roomId))
      .toList();
  return usersInRoom;
}

int? powerLevelInRoom(String roomId, String userId) {
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

List<MatrixRoom> roomsFromRoomIds(List<String> roomIds) {
  final List<MatrixRoom> rooms =
      List.from(locator<MatrixPolicyManager>().matrixRooms.value);
  final roomsFromRoomIds =
      rooms.where((room) => roomIds.contains(room.id)).toList();
  return roomsFromRoomIds;
}

List<String> restOfRooms(List<String> roomIds) {
  List<String> restOfRooms = [];
  final rooms = locator<MatrixPolicyManager>().matrixRooms.value;
  for (MatrixRoom room in rooms) {
    if (!roomIds.contains(room.id)) {
      restOfRooms.add(room.id);
    }
  }
  return restOfRooms;
}

String generatePassword() {
  const characters =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!?@#&';
  const digits = '0123456789';
  final random = Random();

  // Generate 8 random characters
  final randomCharacters = List.generate(8, (_) {
    final index = random.nextInt(characters.length);
    return characters[index];
  });

  // Generate 4 random digits
  final randomDigits = List.generate(4, (_) {
    final index = random.nextInt(digits.length);
    return digits[index];
  });

  // Combine the characters and digits to form the password
  final password = randomCharacters.followedBy(randomDigits).join();
  return password;
}

Future<void> launchMatrixUrl(BuildContext context, String contact) async {
  final Uri matrixUrl = Uri.parse('https://matrix.to/#/$contact');
  bool canLaunchThis = await canLaunchUrl(matrixUrl);
  if (!canLaunchThis) {
    if (context.mounted) {
      informationDialog(context, 'Verbindung nicht möglich',
          'Es konnte keine Verbindung mit dem Messenger hergestellt werden.');
    }
  }
  try {
    final bool launched = await launchUrl(
      matrixUrl,
      mode: LaunchMode.externalApplication,
    );
    if (!launched) {
      developer.log('Failed to launch $matrixUrl');
    }
  } catch (e) {
    developer.log('An error occurred while launching $matrixUrl: $e');
  }

  return;
}
