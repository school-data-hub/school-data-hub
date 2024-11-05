import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:schuldaten_hub/common/services/api/api.dart';
import 'package:schuldaten_hub/common/services/api/services/api_client_service.dart';

import 'package:schuldaten_hub/common/constants/enums.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_manager.dart';
import 'package:schuldaten_hub/common/utils/custom_encrypter.dart';
import 'package:schuldaten_hub/common/utils/logger.dart';

import '../../../common/services/env_manager.dart';
import '../models/book.dart';

class BookApiService {
  final ApiClientService _client = locator<ApiClientService>();
  final notificationManager = locator<NotificationManager>();

  //- get books

  static const _getBooksUrl = '/books/all/flat';

  Future<List<Book>> getBooks() async {
    notificationManager.apiRunningValue(true);
    final Response response = await _client.get(_getBooksUrl);
    notificationManager.apiRunningValue(false);

    if (response.statusCode != 200) {
      notificationManager.showSnackBar(
          NotificationType.error, 'Fehler beim Laden der Arbeitshefte');

      throw ApiException('Failed to fetch books', response.statusCode);
    }

    final List<Book> books =
        (response.data as List).map((e) => Book.fromJson(e)).toList();

    return books;
  }

  //- post new book

  static const _postBookUrl = '/books/new';

  Future<Book> postBook({
    required int isbn,
    required String readingLevel,
    required String location,
    required String id,
  }) async {
    final data = {
      "book_id": id,
      "isbn": isbn,
      "reading_level": readingLevel,
      "image_url": "null",
      "location": location,
    };
    notificationManager.apiRunningValue(true);
    final Response response = await _client.post(_postBookUrl, data: data);
    logger.d('${response.statusCode} ${response.data}');
    notificationManager.apiRunningValue(false);

    if (response.statusCode != 200) {
      notificationManager.showSnackBar(
          NotificationType.error, 'Fehler beim Erstellen des Buches');

      throw ApiException('Failed to fetch books', response.statusCode);
    }

    Book newBook = Book.fromJson(response.data);

    return newBook;
  }

  //- patch book
  String _patchBookUrl(String isbn) {
    return '/books/$isbn';
  }

  Future<Book> updateBookProperty(
      {required Book book,
      String? title,
      int? isbn,
      String? location,
      String? readingLevel}) async {
    final data = jsonEncode({
      "book_id": book.bookId,
      "title": title ?? book.title,
      "location": location ?? book.author,
      "reading_level": readingLevel ?? book.readingLevel,
      "isbn": isbn ?? book.isbn,
    });

    notificationManager.apiRunningValue(true);
    final Response response =
        await _client.patch(_patchBookUrl((book.bookId)), data: data);
    notificationManager.apiRunningValue(false);

    if (response.statusCode != 200) {
      notificationManager.showSnackBar(
          NotificationType.error, 'Fehler beim Aktualisieren des Buches');

      throw ApiException('Failed to update a book', response.statusCode);
    }

    final Book updatedBook = Book.fromJson(response.data);

    return updatedBook;
  }

  //- post book image
  String _patchBookWithImageUrl(int isbn) {
    return '/books/$isbn/image';
  }

  Future<Book> postBookFile(File imageFile, int isbn) async {
    final encryptedFile = await customEncrypter.encryptFile(imageFile);

    String fileName = encryptedFile.path.split('/').last;

    var formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        encryptedFile.path,
        filename: fileName,
      ),
    });
    notificationManager.apiRunningValue(true);
    final Response response = await _client.patch(
      _patchBookWithImageUrl(isbn),
      data: formData,
    );
    notificationManager.apiRunningValue(false);

    // Handle errors.
    if (response.statusCode != 200) {
      notificationManager.showSnackBar(
          NotificationType.error, 'Fehler beim Hochladen des Bildes');

      throw ApiException('Failed to upload book image', response.statusCode);
    }

    final Book book = Book.fromJson(response.data);

    return book;
  }

  //- get book image
  String getBookImage(int isbn) {
    return '/books/$isbn/image';
  }

  //- get book qr
  String getBookQr(String bookId) {
    return '/books/$bookId/qrcode';
  }

  Future<Uint8List?> fetchQrCode(String bookId) async {
    final qrCodeUrl =
        '${locator<EnvManager>().env.value.serverUrl}${getBookQr(bookId)}';
    try {
      final response = await _client.get(
        qrCodeUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      if (response.statusCode == 200) {
        return response.data;
      } else {
        notificationManager.showSnackBar(NotificationType.error,
            'Failed to fetch QR code. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error while fetching QR code: $e');
      return null;
    }
  }

  //- delete book
  String deleteBookUrl(String isbn) {
    return '/books/$isbn';
  }

  Future<Book> deleteBookFile(int isbn) async {
    notificationManager.apiRunningValue(true);
    final Response response = await _client.delete(getBookImage(isbn));
    notificationManager.apiRunningValue(false);

    if (response.statusCode != 200) {
      notificationManager.showSnackBar(
          NotificationType.error, 'Fehler beim Löschen des Bildes');

      throw ApiException('Failed to delete book image', response.statusCode);
    }

    final Book book = Book.fromJson(response.data);

    return book;
  }

  Future<List<Book>> deleteBook(String isbn) async {
    notificationManager.apiRunningValue(true);

    final Response response =
        await _client.delete(BookApiService().deleteBookUrl(isbn));
    notificationManager.apiRunningValue(false);

    if (response.statusCode != 200) {
      notificationManager.showSnackBar(
          NotificationType.error, 'Fehler beim Löschen des Arbeitshefts');

      throw ApiException('Failed to delete a book', response.statusCode);
    }

    return getBooks();
  }

  //- these are not being used
  static const getBooksWithPupils = '/books/all';

  String getBook(int isbn) {
    return '/books/$isbn';
  }
}
