import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:schuldaten_hub/common/services/locator.dart';

import 'package:schuldaten_hub/features/matrix/models/policy.dart';
import 'package:schuldaten_hub/features/matrix/services/matrix_policy_manager.dart';
import 'package:url_launcher/url_launcher.dart';

class MatrixHelperFunctions {
  static Future<File> generatePolicyJsonFile() async {
    // create a new json file with the policy

    final File file = File('matrix-policy.json');
    if (file.existsSync()) {
      file.deleteSync();
    }
    final Policy policy = locator<MatrixPolicyManager>().matrixPolicy!;
    final Map<String, dynamic> jsonString = policy.toJson();
    // transform the map into a json string
    final String policyJson = jsonEncode(jsonString);

    file.writeAsStringSync(policyJson);

    return file;
  }

  static String generatePassword() {
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

  static Future<void> launchMatrixUrl(
      BuildContext context, String contact) async {
    final Uri matrixUrl = Uri.parse('https://matrix.to/#/$contact');
    // bool canLaunchThis = await canLaunchUrl(matrixUrl);
    // if (!canLaunchThis) {
    //   if (context.mounted) {
    //     informationDialog(context, 'Verbindung nicht möglich',
    //         'Es konnte keine Verbindung mit dem Messenger hergestellt werden.');
    //   }
    // }
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
}
