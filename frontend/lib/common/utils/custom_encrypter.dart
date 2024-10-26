import 'dart:async';
import 'dart:io';

import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:schuldaten_hub/common/services/env_manager.dart';
import 'package:schuldaten_hub/common/services/locator.dart';

final customEncrypter = CustomEncrypter();

class CustomEncrypter {
  final encrypter = enc.Encrypter(enc.AES(
      enc.Key.fromUtf8(locator<EnvManager>().env.value.key!),
      mode: enc.AESMode.cbc));

  final iv = enc.IV.fromUtf8(locator<EnvManager>().env.value.iv!);

  String encrypt(String nonEncryptedString) {
    final encryptedString =
        encrypter.encrypt(nonEncryptedString, iv: iv).base64;
    return encryptedString;
  }

  String decrypt(String encryptedString) {
    final thisEncryptedString = enc.Encrypted.fromBase64(encryptedString);
    final decryptedString = encrypter.decrypt(thisEncryptedString, iv: iv);
    return decryptedString;
  }

  Future<File> encryptFile(File file) async {
    final List<int> fileBytes = await file.readAsBytes();
    final encrypted = encrypter.encryptBytes(fileBytes, iv: iv);
    final Directory tempDir = await getTemporaryDirectory();
    final Uri uri = Uri.parse(file.path);
    final String extension = uri.pathSegments.last.split('.').last;
    final File tempFile = File('${tempDir.path}/encrypted_file.$extension');
    await tempFile.writeAsBytes(encrypted.bytes);
    return tempFile;
  }

  Future<File> decryptFile(File file, int pupilId) async {
    // Read the encrypted file as bytes
    final encryptedBytes = await file.readAsBytes();

    // Decrypt the bytes
    final decrypted =
        encrypter.decryptBytes(enc.Encrypted(encryptedBytes), iv: iv);

    // Get the temporary directory
    final tempDir = await getTemporaryDirectory();

    // Create a temporary file for the decrypted content
    final uri = Uri.parse(file.path);
    final extension = uri.pathSegments.last.split('.').last;

    final tempFile =
        File('${tempDir.path}/${pupilId}_decrypted_file.$extension');
    // debug.warning(tempFile.path);
    // Write the decrypted bytes to the temporary file
    await tempFile.writeAsBytes(decrypted);

    return tempFile;
  }

  Uint8List decryptTheseBytes(Uint8List encryptedBytes) {
    final List<int> decrypted =
        encrypter.decryptBytes(enc.Encrypted(encryptedBytes), iv: iv);

    final Uint8List decryptedBytes = Uint8List.fromList(decrypted);
    return decryptedBytes;
  }

  static void generateNewEncryptionKeys() async {
    final oldKey = locator<EnvManager>().env.value.key!;
    final oldIv = locator<EnvManager>().env.value.iv!;
    final oldKeyBase64 = enc.Key.fromUtf8(oldKey).base64;
    final oldIvBase64 = enc.IV.fromUtf8(oldIv).base64;
    final key = enc.Key.fromSecureRandom(32);
    // Generate a 16-byte (128-bit) IV
    final iv = enc.IV.fromSecureRandom(16);

    // Convert to base64 strings
    final keyBase64 = key.base64;
    final ivBase64 = iv.base64;

    // Save to a text file
    final file = File('encryption_keys.txt');
    await file.writeAsString(
        'Old Key: $oldKeyBase64\nOld IV: $oldIvBase64\n Key: $keyBase64\nIV: $ivBase64');
  }
}
