import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:schuldaten_hub/common/constants/enums.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_manager.dart';
import 'package:schuldaten_hub/common/services/session_manager.dart';
import 'package:schuldaten_hub/features/books/services/pupil_book_api_service.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_data.dart';
import 'package:schuldaten_hub/features/pupil/services/pupil_manager.dart';

import '../models/book.dart';
import 'book_api_service.dart';

class BookManager {
  ValueListenable<List<Book>> get books => _books;

  final List<Book> _allBooks = [];
  final _books = ValueNotifier<List<Book>>([]);

  BookManager();

  final session = locator
      .get<SessionManager>()
      .credentials
      .value;
  final apiPupilBookService = PupilBookApiService();
  final apiBookService = BookApiService();
  final notificationManager = locator<NotificationManager>();
  final pupilManager = locator<PupilManager>();

  bool get isAllBooksEmpty => _allBooks.isEmpty;

  Future<BookManager> init() async {
    await getBooks();
    return this;
  }

  void clearData() {
    _books.value = [];
    _allBooks.clear();
  }

  Future<void> getBooks() async {
    final List<Book> responseBooks =
    await apiBookService.getBooks();
    responseBooks.sort((a, b) => (a.title ?? '').compareTo(b.title ?? ''));
    _allBooks.clear();
    _allBooks.addAll(responseBooks);

    _books.value = List.from(_allBooks);

    notificationManager.showSnackBar(
        NotificationType.success, 'Bücher erfolgreich geladen');

    _books.value = responseBooks;

    return;
  }

  void filterBooks(String query) {
    if (query.isEmpty) {
      _books.value = List.from(_allBooks);
    } else {
      _books.value = _allBooks.where((book) =>
      book.title?.toLowerCase().contains(query.toLowerCase()) ?? false
      ).toList();
    }
  }

  Future<void> postBook(
      int isbn,
      String id,
      String readingLevel,
      String location,) async {
    try {
      final Book responseBook = await apiBookService.postBook(
        isbn: isbn,
        id: id,
        readingLevel: readingLevel,
        location: location,);
      _books.value = [..._books.value, responseBook];
      notificationManager.showSnackBar(
          NotificationType.success, 'Buch erfolgreich erstellt');
    }on DioException catch (e) {
      notificationManager.showSnackBar(
          NotificationType.error, 'Fehler beim Erstellen des Buches');
    }
    return;
  }

  Future<void> updateBookProperty(bookId, isbn, location, readingLevel) async {
    final Book bookToUpdate = _books.value.firstWhere(
          (book) => book.bookId == bookId,
    );

    final Book updatedBook =
    await apiBookService.updateBookProperty(
      book: bookToUpdate,
      isbn: isbn,
      location: location,
      readingLevel: readingLevel,
    );

    List<Book> books = List.from(_books.value);
    int index = books
        .indexWhere((book) => book.bookId == updatedBook.bookId);

    books[index] = updatedBook;

    _books.value = books;

    notificationManager.showSnackBar(
        NotificationType.success, 'Buch erfolgreich aktualisiert');

    return;
  }

  Future<void> postBookFile(File imageFile, int isbn) async {
    final Book responseBook =
    await apiBookService.postBookFile(imageFile, isbn);

    updateBookInRepositoryWithResponse(responseBook);

    notificationManager.showSnackBar(
        NotificationType.success, 'Bild erfolgreich hochgeladen');

    return;
  }

  Future<void> deleteBook(String isbn) async {
    final List<Book> books =
    await apiBookService.deleteBook(isbn);

    _books.value = books;

    notificationManager.showSnackBar(
        NotificationType.success, 'Buch erfolgreich gelöscht');

    locator<PupilManager>().fetchAllPupils();
    return;
  }

  Future<void> deleteBookFile(int isbn) async {
    final Book responseBook =
    await apiBookService.deleteBookFile(isbn);

    updateBookInRepositoryWithResponse(responseBook);

    notificationManager.showSnackBar(
        NotificationType.success, 'Bild erfolgreich gelöscht');

    return;
  }

  Future<Uint8List?> fetchQrCode(String bookId) async {
    return await apiBookService.fetchQrCode(bookId);
  }

  //- PUPIL BOOKS

  Future<void> newPupilBook(int pupilId, String bookId) async {
    final PupilData responsePupil =
    await apiPupilBookService.postNewPupilBook(pupilId, bookId);

    pupilManager.updatePupilProxyWithPupilData(responsePupil);

    notificationManager.showSnackBar(
        NotificationType.success, 'Buch erstellt');

    return;
  }

  Future<void> patchPupilBook(int pupilId, String isbn) async {
    final PupilData responsePupil =
    await apiPupilBookService.patchPupilBook(pupilId, isbn);

    pupilManager.updatePupilProxyWithPupilData(responsePupil);

    notificationManager.showSnackBar(
        NotificationType.success, 'Buch zurückgenommen');

    return;
  }

  //- helper function
  Book? getBookByIsbn(String? isbn) {
    if (isbn == null) return null;
    final Book? book =
    _books.value.firstWhereOrNull((element) => element.bookId == isbn);
    return book;
  }

  //- helper function
  void updateBookInRepositoryWithResponse(Book book) {
    List<Book> books = List.from(_books.value);
    int index = books.indexWhere((b) => b.isbn == book.isbn);
    books[index] = book;
    _books.value = books;
  }



}
