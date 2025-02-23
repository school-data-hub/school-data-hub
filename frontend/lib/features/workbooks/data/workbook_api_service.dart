import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:schuldaten_hub/common/domain/env_manager.dart';
import 'package:schuldaten_hub/common/domain/models/enums.dart';
import 'package:schuldaten_hub/common/services/api/api_client.dart';
import 'package:schuldaten_hub/common/services/api/api_settings.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_service.dart';
import 'package:schuldaten_hub/common/utils/custom_encrypter.dart';
import 'package:schuldaten_hub/common/utils/logger.dart';
import 'package:schuldaten_hub/features/workbooks/domain/models/workbook.dart';

class WorkbookApiService {
  final ApiClient _client = locator<ApiClient>();
  final _notificationService = locator<NotificationService>();

  String _baseUrl() {
    return locator<EnvManager>().env!.serverUrl;
  }
  //- get workbooks

  static const _getWorkbooksUrl = '/workbooks/all/flat';

  Future<List<Workbook>> getWorkbooks() async {
    _notificationService.apiRunning(true);
    final Response response = await _client.get(
      '${_baseUrl()}$_getWorkbooksUrl',
      options: _client.hubOptions,
    );
    _notificationService.apiRunning(false);

    if (response.statusCode != 200) {
      _notificationService.showSnackBar(
          NotificationType.error, 'Fehler beim Laden der Arbeitshefte');

      throw ApiException('Failed to fetch workbooks', response.statusCode);
    }

    final List<Workbook> workbooks =
        (response.data as List).map((e) => Workbook.fromJson(e)).toList();

    return workbooks;
  }

  //- post new workbook

  static const _postWorkbookUrl = '/workbooks/new';

  Future<Workbook> postWorkbook({
    String? name,
    required int isbn,
    String? subject,
    String? level,
    int? amount,
  }) async {
    final data = jsonEncode({
      "name": name,
      "isbn": isbn,
      "subject": subject,
      "level": level,
      "image_url": null,
      "amount": amount
    });

    _notificationService.apiRunning(true);
    final Response response = await _client.post(
      '${_baseUrl()}$_postWorkbookUrl',
      data: data,
      options: _client.hubOptions,
    );
    logger.d('${response.statusCode} ${response.data}');
    _notificationService.apiRunning(false);

    if (response.statusCode != 200) {
      _notificationService.showSnackBar(
          NotificationType.error, 'Fehler beim Erstellen des Arbeitshefts');

      throw ApiException('Failed to fetch workbooks', response.statusCode);
    }

    Workbook newWorkbook = Workbook.fromJson(response.data);

    return newWorkbook;
  }

  //- patch workbook
  String _patchWorkbookUrl(int isbn) {
    return '/workbooks/$isbn';
  }

  Future<Workbook> updateWorkbookProperty(
      {required Workbook workbook,
      String? name,
      int? isbn,
      String? subject,
      String? level}) async {
    final data = jsonEncode({
      "name": name ?? workbook.name,
      "subject": subject ?? workbook.subject,
      "level": level ?? workbook.level,
      "image_url": workbook.imageUrl
    });

    _notificationService.apiRunning(true);
    final Response response = await _client.patch(
      '${_baseUrl()}${_patchWorkbookUrl((workbook.isbn))}',
      data: data,
      options: _client.hubOptions,
    );
    _notificationService.apiRunning(false);

    if (response.statusCode != 200) {
      _notificationService.showSnackBar(
          NotificationType.error, 'Fehler beim Aktualisieren des Arbeitshefts');

      throw ApiException('Failed to update a workbook', response.statusCode);
    }

    final Workbook updatedWorkbook = Workbook.fromJson(response.data);

    return updatedWorkbook;
  }

  //- post workbook image
  String _patchWorkbookWithImageUrl(int isbn) {
    return '/workbooks/$isbn/image';
  }

  Future<Workbook> postWorkbookFile(File imageFile, int isbn) async {
    final encryptedFile = await customEncrypter.encryptFile(imageFile);

    String fileName = encryptedFile.path.split('/').last;

    var formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        encryptedFile.path,
        filename: fileName,
      ),
    });

    _notificationService.apiRunning(true);

    final Response response = await _client.patch(
      '${_baseUrl()}${_patchWorkbookWithImageUrl(isbn)}',
      data: formData,
      options: _client.hubOptions,
    );

    _notificationService.apiRunning(false);

    // Handle errors.
    if (response.statusCode != 200) {
      _notificationService.showSnackBar(
          NotificationType.error, 'Fehler beim Hochladen des Bildes');

      throw ApiException(
          'Failed to upload workbook image', response.statusCode);
    }

    final Workbook workbook = Workbook.fromJson(response.data);

    return workbook;
  }

  //- get workbook image
  String getWorkbookImage(int isbn) {
    return '/workbooks/$isbn/image';
  }

  //- delete workbook
  static String _deleteWorkbookUrl(int isbn) {
    return '/workbooks/$isbn';
  }

  String _deleteWorkbookImage(int isbn) {
    return '/library_book/$isbn/image';
  }

  Future<Workbook> deleteWorkbookFile(int isbn) async {
    _notificationService.apiRunning(true);

    final Response response = await _client.delete(
      '${_baseUrl()}${_deleteWorkbookImage(isbn)}',
      options: _client.hubOptions,
    );
    _notificationService.apiRunning(false);

    if (response.statusCode != 200) {
      _notificationService.showSnackBar(
          NotificationType.error, 'Fehler beim Löschen des Bildes');

      throw ApiException(
          'Failed to delete workbook image', response.statusCode);
    }

    final Workbook workbook = Workbook.fromJson(response.data);

    return workbook;
  }

  Future<List<Workbook>> deleteWorkbook(int isbn) async {
    _notificationService.apiRunning(true);

    final Response response = await _client.delete(
      '${_baseUrl()}${_deleteWorkbookUrl(isbn)}',
      options: _client.hubOptions,
    );
    _notificationService.apiRunning(false);

    if (response.statusCode != 200) {
      _notificationService.showSnackBar(
          NotificationType.error, 'Fehler beim Löschen des Arbeitshefts');

      throw ApiException('Failed to delete a workbook', response.statusCode);
    }

    final List<Workbook> workbooks =
        (response.data as List).map((e) => Workbook.fromJson(e)).toList();

    return workbooks;
  }

  //- these are not being used
  static const getWorkbooksWithPupils = '/workbooks/all';

  String getWorkbook(int isbn) {
    return '/workbooks/$isbn';
  }
}
