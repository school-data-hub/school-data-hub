import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:schuldaten_hub/common/domain/models/enums.dart';
import 'package:schuldaten_hub/common/domain/session_manager.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_service.dart';
import 'package:schuldaten_hub/features/books/data/book_api_service.dart';
import 'package:schuldaten_hub/features/books/data/pupil_book_api_service.dart';
import 'package:schuldaten_hub/features/books/domain/models/book.dart';
import 'package:schuldaten_hub/features/pupil/domain/pupil_manager.dart';

import '../../../common/utils/logger.dart';

class BookManager {
  final _books = ValueNotifier<List<BookProxy>>([]);
  ValueListenable<List<BookProxy>> get books => _books;

  final _isbnBooks = ValueNotifier<Map<int, List<BookProxy>>>({});
  ValueListenable<Map<int, List<BookProxy>>> get booksByIsbn => _isbnBooks;

  final _locations = ValueNotifier<List<String>>([]);
  ValueListenable<List<String>> get locations => _locations;

  final _bookTags = ValueNotifier<List<BookTag>>([]);
  ValueListenable<List<BookTag>> get bookTags => _bookTags;

  List<BookTag> selectedTags = []; // Liste für ausgewählte Buch-Tags

  final _lastSelectedLocation = ValueNotifier<String>('Bitte auswählen');
  ValueListenable<String> get lastLocationValue => _lastSelectedLocation;

  final searchResults = ValueNotifier<List<BookProxy>>([]);

  BookManager();

  final session = locator.get<SessionManager>().credentials.value;

  final pupilBookApiService = PupilBookApiService();

  final bookApiService = BookApiService();

  final notificationService = locator<NotificationService>();

  final pupilManager = locator<PupilManager>();

  Future<BookManager> init() async {
    // await getLibraryBooks();
    await getLocations();
    await getBookTags();

    return this;
  }

  void clearData() {
    _books.value = [];
    _locations.value = [];
    _bookTags.value = [];
    _lastSelectedLocation.value = 'Bitte auswählen';
  }

  void _refreshIsbnBooksMap() {
    final Map<int, List<BookProxy>> isbnBooks = <int, List<BookProxy>>{};
    for (final book in _books.value) {
      if (isbnBooks.containsKey(book.isbn)) {
        isbnBooks[book.isbn]!.add(book);
      } else {
        isbnBooks[book.isbn] = [book];
      }
    }
    _isbnBooks.value = isbnBooks;
  }

  //- BOOK TAGS

  Future<void> getBookTags() async {
    final List<BookTag> responseTags = await bookApiService.getBookTags();
    _bookTags.value = responseTags;
  }

  Future<void> addBookTag(String tag) async {
    final List<BookTag> responseTags = await bookApiService.postBookTag(tag);
    _bookTags.value = responseTags;
  }

  Future<void> deleteBookTag(String tag) async {
    final List<BookTag> responseTags = await bookApiService.deleteBookTag(tag);
    _bookTags.value = responseTags;
  }

  //- BOOK LOCATIONS

  Future<void> getLocations() async {
    final List<String> responseLocations =
    await bookApiService.getBookLocations();
    _locations.value = responseLocations;
  }

  Future<void> addLocation(String location) async {
    final List<String> responseLocations =
    await bookApiService.postBookLocation(location);
    _locations.value = responseLocations;
  }

  Future<void> deleteLocation(String location) async {
    final List<String> responseLocations =
    await bookApiService.deleteBookLocation(location);
    _locations.value = responseLocations;
  }

  void setLastLocationValue(String location) {
    _lastSelectedLocation.value = location;
  }

  //- LIBRARY BOOKS

  Future<void> getLibraryBooks() async {
    final List<BookProxy> responseBooks =
    await bookApiService.getLibraryBooks();

    if (responseBooks.isNotEmpty) {
      responseBooks.sort((a, b) => a.title.compareTo(b.title));
      _books.value = responseBooks;
    }
    _refreshIsbnBooksMap();
    notificationService.showSnackBar(
        NotificationType.success, 'Bücher erfolgreich geladen');
  }

  Future<void> postLibraryBook({
    required int isbn,
    required String bookId,
    required String location,
  }) async {
    final BookProxy responseBook = await bookApiService.postLibraryBook(
      isbn: isbn,
      bookId: bookId,
      location: location,
    );

    _books.value = [..._books.value, responseBook];

    notificationService.showSnackBar(
        NotificationType.success, 'Arbeitsheft erfolgreich erstellt');
  }

  Future<void> updateBookProperty({
    required int isbn,
    String? title,
    String? author,
    String? description,
    String? readingLevel,
    List<BookTag>? tags,
  }) async {
    final BookProxy updatedbook = await bookApiService.patchBookData(
      isbn: isbn,
      title: title,
      author: author,
      description: description,
      readingLevel: readingLevel,
      bookTags: tags,
    );

    List<BookProxy> books = List.from(_books.value);
    int index = books.indexWhere((item) => item.bookId == updatedbook.bookId);
    books[index] = updatedbook;
    _books.value = books;

    notificationService.showSnackBar(
        NotificationType.success, 'Arbeitsheft erfolgreich aktualisiert');
  }

  Future<void> patchBookImage(File imageFile, int isbn) async {
    final BookProxy responsebook =
    await bookApiService.patchBookImage(imageFile, isbn);

    updateBookStateWithResponse(responsebook);

    notificationService.showSnackBar(
        NotificationType.success, 'Bild erfolgreich hochgeladen');
  }

  Future<void> deleteLibraryBook(String bookId) async {
    final bool success = await bookApiService.deleteLibraryBook(bookId);

    if (success) {
      List<BookProxy> books = List.from(_books.value);
      books.removeWhere((item) => item.bookId == bookId);
      _books.value = books;
      notificationService.showSnackBar(
          NotificationType.success, 'Arbeitsheft erfolgreich gelöscht');
    }
  }

  //- PUPIL BOOKS

  List<BookProxy> getLibraryBooksByIsbn(int isbn) {
    List<BookProxy> books = [];
    for (BookProxy book in _books.value) {
      if (book.isbn == isbn) {
        books.add(book);
      }
    }
    return books;
  }

  //- helper function
  BookProxy? getLibraryBookByBookId(String? bookId) {
    if (bookId == null) return null;
    return _books.value.firstWhereOrNull((element) => element.bookId == bookId);
  }

  //- helper function
  void updateBookStateWithResponse(BookProxy book) {
    List<BookProxy> books = List.from(_books.value);
    int index = books.indexWhere((item) => item.bookId == book.bookId);
    books[index] = book;
    _books.value = books;
  }

  Future<void> searchBooks({
    String? title,
    String? author,
    String? keywords,
    String? location,
    String? readingLevel,
    String? borrowStatus,
  }) async {
    try {
      final List<BookProxy> results = await bookApiService.searchBooks(
        title: title?.isNotEmpty == true ? title : null,
        author: author?.isNotEmpty == true ? author : null,
        keywords: keywords?.isNotEmpty == true ? keywords : null,
        location: location?.isNotEmpty == true ? location : null,
        readingLevel:
        readingLevel?.isNotEmpty == true ? readingLevel : null,
        borrowStatus: borrowStatus?.isNotEmpty == true ? borrowStatus : null,
      );
      searchResults.value = results;
      notificationService.showSnackBar(
          NotificationType.success, 'Suchergebnisse aktualisiert');
    } catch (e, s) {
      notificationService.showSnackBar(
          NotificationType.error, 'Fehler bei der Suche: $e');
    }
  }
}