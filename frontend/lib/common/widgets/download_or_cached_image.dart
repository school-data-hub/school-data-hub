import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:schuldaten_hub/common/services/api/services/api_client_service.dart';
import 'package:schuldaten_hub/common/constants/enums.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_manager.dart';

Future<Widget> downloadOrCachedImage(String? imageUrl, String? tag) async {
  if (imageUrl == null) {
    return const Icon(Icons.camera_alt_rounded);
  }

  final cacheManager = locator<DefaultCacheManager>();
  final cacheKey = tag!;

  final fileInfo = await cacheManager.getFileFromCache(cacheKey);

  if (fileInfo != null && await fileInfo.file.exists()) {
    return Image.file(fileInfo.file);
  }

  final ApiClientService client = locator<ApiClientService>();
  final Response response = await client.get(imageUrl,
      options: Options(responseType: ResponseType.bytes));

  if (response.statusCode != 200) {
    locator<NotificationManager>()
        .showSnackBar(NotificationType.error, 'Fehler beim Laden des Bildes');
    return const Icon(Icons.error_outline);
  }

  final imageBytes = Uint8List.fromList(response.data!);
  await cacheManager.putFile(cacheKey, imageBytes);

  return Image.memory(imageBytes);
}