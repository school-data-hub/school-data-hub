import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:schuldaten_hub/common/domain/models/enums.dart';
import 'package:schuldaten_hub/common/services/api/api_settings.dart';
import 'package:schuldaten_hub/common/services/api/api_client.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_service.dart';
import 'package:schuldaten_hub/common/utils/custom_encrypter.dart';
import 'package:schuldaten_hub/common/utils/logger.dart';
import 'package:schuldaten_hub/features/books/domain/models/book.dart';

class BookRepository {
  final ApiClient _client = locator<ApiClient>();
  final notificationService = locator<NotificationService>();

  //- get workbooks

  static const _getBooksUrl = '/books/all/flat';

  Future<List<Book>> getBooks() async {
    notificationService.apiRunning(true);

    final Response response = await _client.get(_getBooksUrl);

    notificationService.apiRunning(false);

    if (response.statusCode != 200) {
      notificationService.showSnackBar(
          NotificationType.error, 'Fehler beim Laden der Arbeitshefte');

      throw ApiException('Failed to fetch workbooks', response.statusCode);
    }
    if (response.data == []) {
      return [];
    }
    final List<Book> books =
        (response.data as List).map((e) => Book.fromJson(e)).toList();

    return books;
  }

  //- post new workbook

  static const _postBookUrl = '/books/new';

  Future<Book> postBook({
    String? author,
    required int isbn,
    required String bookId,
    required String? description,
    required String location,
    String? readingLevel,
    required String title,
  }) async {
    final data = jsonEncode({
      "author": author,
      "book_id": bookId,
      "description": description,
      "isbn": isbn,
      "location": location,
      "reading_level": readingLevel,
      "title": title
    });

    notificationService.apiRunning(true);
    final Response response = await _client.post(_postBookUrl, data: data);
    logger.d('${response.statusCode} ${response.data}');
    notificationService.apiRunning(false);

    if (response.statusCode != 200) {
      notificationService.showSnackBar(
          NotificationType.error, 'Fehler beim Erstellen des Arbeitshefts');

      throw ApiException('Failed to fetch workbooks', response.statusCode);
    }

    Book newBook = Book.fromJson(response.data);

    return newBook;
  }

  //- patch workbook

  String _patchBookImage(String bookId) {
    return '/books/$bookId';
  }

  Future<Book> updateBookProperty({
    required String bookId,
    String? author,
    String? description,
    String? location,
    String? readingLevel,
    String? imageId,
    String? title,
  }) async {
    final data = jsonEncode({
      if (author != null) "author": author,
      if (description != null) "description": description,
      if (location != null) "location": location,
      "reading_level": readingLevel,
      if (imageId != null) "image_id": imageId,
      if (imageId != null) "title": title
    });

    notificationService.apiRunning(true);

    final Response response = await _client.patch(
      _patchBookImage((bookId)),
      data: data,
    );

    notificationService.apiRunning(false);

    if (response.statusCode != 200) {
      notificationService.showSnackBar(
          NotificationType.error, 'Fehler beim Aktualisieren des Arbeitshefts');

      throw ApiException('Failed to update a workbook', response.statusCode);
    }

    final Book updatedBook = Book.fromJson(response.data);

    return updatedBook;
  }

  //- post book image

  String _patchBookWithImageUrl(String bookId) {
    return '/books/$bookId/file';
  }

  // Future<Book> postBookWithImageBytes(
  //     {required Uint8List imageBytes,
  //     required String bookId,
  //     required String author,
  //     required String? description,
  //     required int isbn,
  //     required String location,
  //     required String readingLevel,
  //     required String title}) async {
  //   final encryptedBytes = customEncrypter.encryptTheseBytes(imageBytes);

  //   var formData = FormData.fromMap({
  //     'file': MultipartFile.fromBytes(
  //       encryptedBytes,
  //       filename: bookId,
  //     ),
  //     'json': jsonEncode({
  //       "author": author,
  //       "book_id": bookId,
  //       "description": description,
  //       "isbn": isbn,
  //       "location": location,
  //       "level": readingLevel,
  //       "image_url": null,
  //       "title": title
  //     }),
  //   });
  //   notificationService.apiRunningValue(true);
  //   final Response response = await _client.patch(
  //     _patchBookWithImageUrl(bookId),
  //     data: formData,
  //   );
  //   notificationService.apiRunningValue(false);

  //   // Handle errors.
  //   if (response.statusCode != 200) {
  //     notificationService.showSnackBar(
  //         NotificationType.error, 'Fehler beim Hochladen des Bildes');

  //     throw ApiException(
  //         'Failed to upload workbook image', response.statusCode);
  //   }

  //   final Book workbook = Book.fromJson(response.data);

  //   return workbook;
  // }

  Future<Book> postBookFile(File imageFile, String bookId) async {
    final encryptedFile = await customEncrypter.encryptFile(imageFile);

    String fileName = encryptedFile.path.split('/').last;

    var formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        encryptedFile.path,
        filename: fileName,
      ),
    });

    notificationService.apiRunning(true);
    final Response response = await _client.patch(
      _patchBookWithImageUrl(bookId),
      data: formData,
    );
    notificationService.apiRunning(false);

    // Handle errors.
    if (response.statusCode != 200) {
      notificationService.showSnackBar(
          NotificationType.error, 'Fehler beim Hochladen des Bildes');

      throw ApiException(
          'Failed to upload workbook image', response.statusCode);
    }

    final Book book = Book.fromJson(response.data);

    return book;
  }

  static String getBookImageUrl(String imageId) {
    return '/books/$imageId/file';
  }

  //- get workbook image
  String _getBookImage(String bookId) {
    return '/books/$bookId/file';
  }

  Future<File> getBookImage(String bookId) async {
    notificationService.apiRunning(true);
    final Response response = await _client.get(_getBookImage(bookId),
        options: Options(responseType: ResponseType.bytes));
    notificationService.apiRunning(false);

    if (response.statusCode != 200) {
      notificationService.showSnackBar(
          NotificationType.error, 'Fehler beim Laden des Bildes');

      throw ApiException('Failed to fetch workbook image', response.statusCode);
    }

    final encryptedBytes = Uint8List.fromList(response.data!);
    final decryptedBytes = customEncrypter.decryptTheseBytes(encryptedBytes);

    final tempDir = await Directory.systemTemp.createTemp();
    final file = File('${tempDir.path}/$bookId.png');
    await file.writeAsBytes(decryptedBytes);

    return file;
  }

  //- delete workbook
  String deleteBookUrl(String bookId) {
    return '/books/$bookId';
  }

  Future<Book> deleteBookFile(String bookId) async {
    notificationService.apiRunning(true);
    final Response response = await _client.delete(_getBookImage(bookId));
    notificationService.apiRunning(false);

    if (response.statusCode != 200) {
      notificationService.showSnackBar(
          NotificationType.error, 'Fehler beim Löschen des Bildes');

      throw ApiException(
          'Failed to delete workbook image', response.statusCode);
    }

    final Book workbook = Book.fromJson(response.data);

    return workbook;
  }

  Future<bool> deleteBook(String bookId) async {
    notificationService.apiRunning(true);

    final Response response =
        await _client.delete(BookRepository().deleteBookUrl(bookId));
    notificationService.apiRunning(false);

    if (response.statusCode != 200) {
      notificationService.showSnackBar(
          NotificationType.error, 'Fehler beim Löschen des Arbeitshefts');

      throw ApiException('Failed to delete a workbook', response.statusCode);
    }

    return true;
  }

  //- these are not being used
  static const getBooksWithPupils = '/books/all';

  String getBook(int isbn) {
    return '/workbooks/$isbn';
  }
}
