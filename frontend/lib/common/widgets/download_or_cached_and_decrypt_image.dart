import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:schuldaten_hub/common/domain/models/enums.dart';
import 'package:schuldaten_hub/common/services/api/api_client.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_service.dart';
import 'package:schuldaten_hub/common/utils/custom_encrypter.dart';

Future<Image> cachedOrDownloadImage(
    {required String imageUrl,
    required String cacheKey,
    required bool decrypt}) async {
  final cacheManager = locator<DefaultCacheManager>();
  final key = cacheKey;

  final fileInfo = await cacheManager.getFileFromCache(key);

  if (fileInfo != null && await fileInfo.file.exists()) {
    // File is already cached, if necessary, decrypt it before using
    if (!decrypt) {
      final fileBytes = await fileInfo.file.readAsBytes();
      return Image.memory(fileBytes);
    }
    final decryptedImage =
        await customEncrypter.decryptEncryptedImage(fileInfo.file);
    return decryptedImage;
  }

  final ApiClient client = locator<ApiClient>();
  final options = client.hubOptions.copyWith(responseType: ResponseType.bytes);

  final Response response = await client.get(imageUrl, options: options);

  if (response.statusCode != 200) {
    locator<NotificationService>()
        .showSnackBar(NotificationType.error, 'Fehler beim Laden des Bildes');
  }
  if (decrypt) {
    final encryptedBytes = Uint8List.fromList(response.data!);
    // Cache the encrypted bytes
    await cacheManager.putFile(key, encryptedBytes);
    // Decrypt the bytes before returning
    //- This is because isolate performance is horrible in debug mode
    final decryptedBytes = (kReleaseMode || kProfileMode)
        ? await compute(customEncrypter.decryptTheseBytes, encryptedBytes)
        : customEncrypter.decryptTheseBytes(encryptedBytes);
    return Image.memory(decryptedBytes);
  }
  final imageBytes = Uint8List.fromList(response.data!);
  // Cache the image bytes
  await cacheManager.putFile(key, imageBytes);
  return Image.memory(imageBytes);
}
