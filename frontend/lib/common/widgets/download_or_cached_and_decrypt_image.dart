import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:schuldaten_hub/common/domain/models/enums.dart';
import 'package:schuldaten_hub/common/services/api/api_client.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_service.dart';
import 'package:schuldaten_hub/common/utils/custom_encrypter.dart';

Future<Image> cachedOrDownloadAndDecryptImage(
    {required String imageUrl, required String cacheKey}) async {
  final cacheManager = locator<DefaultCacheManager>();
  final key = cacheKey;

  final fileInfo = await cacheManager.getFileFromCache(key);

  if (fileInfo != null && await fileInfo.file.exists()) {
    // File is already cached, decrypt it before using
    final decryptedImage =
        await customEncrypter.decryptEncryptedImage(fileInfo.file);
    return decryptedImage;
  }

  final ApiClient client = locator<ApiClient>();
  final Response response = await client.get(imageUrl,
      options: Options(responseType: ResponseType.bytes));

  if (response.statusCode != 200) {
    locator<NotificationService>()
        .showSnackBar(NotificationType.error, 'Fehler beim Laden des Bildes');
  }
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
