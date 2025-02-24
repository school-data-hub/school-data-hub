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

class BookManager {
  final _books = ValueNotifier<List<Book>>([]);
  ValueListenable<List<Book>> get books => _books;

  final _isbnBooks = Map<int, List<Book>>.from({});
  Map<int, List<Book>> get isbnBooks => _isbnBooks;

  final _locations = ValueNotifier<List<String>>([]);
  ValueListenable<List<String>> get locations => _locations;

  final _bookTags = ValueNotifier<List<BookTag>>([]);
  ValueListenable<List<BookTag>> get bookTags => _bookTags;

  final _lastSelectedLocation = ValueNotifier<String>('Bitte auswählen');
  ValueListenable<String> get lastLocationValue => _lastSelectedLocation;

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
    final Map<int, List<Book>> isbnBooks = Map<int, List<Book>>.from({});

    for (final book in _books.value) {
      if (isbnBooks.containsKey(book.isbn)) {
        isbnBooks[book.isbn]!.add(book);
      } else {
        isbnBooks[book.isbn] = [book];
      }
    }

    _isbnBooks.clear();
    _isbnBooks.addAll(isbnBooks);
  }

  //- BOOK TAGS

  Future<void> getBookTags() async {
    final List<BookTag> responseTags = await bookApiService.getBookTags();
    _bookTags.value = responseTags;
  }

  Future<void> addBookTag(String tag) async {
    final List<BookTag> responseTags = await bookApiService.postBookTag(tag);

    _bookTags.value = responseTags;

    return;
  }

  Future<void> deleteBookTag(String tag) async {
    final List<BookTag> responseTags = await bookApiService.deleteBookTag(tag);

    _bookTags.value = responseTags;

    return;
  }

  //- BOOK LOCATIONS

  Future<void> getLocations() async {
    final List<String> responseLocations =
        await bookApiService.getBookLocations();

    _locations.value = responseLocations;

    return;
  }

  Future<void> addLocation(String location) async {
    final List<String> responseLocations =
        await bookApiService.postBookLocation(location);

    _locations.value = responseLocations;

    return;
  }

  Future<void> deleteLocation(String location) async {
    final List<String> responseLocations =
        await bookApiService.deleteBookLocation(location);

    _locations.value = responseLocations;

    return;
  }

  void setLastLocationValue(String location) {
    _lastSelectedLocation.value = location;
  }

  //- LIBRARY BOOKS

  Future<void> getLibraryBooks() async {
    final List<Book> responseBooks = await bookApiService.getLibraryBooks();

    _refreshIsbnBooksMap();
    // sort books by name
    if (responseBooks.isNotEmpty) {
      responseBooks.sort((a, b) => a.title.compareTo(b.title));
      _books.value = responseBooks;
    }
    notificationService.showSnackBar(
        NotificationType.success, 'Bücher erfolgreich geladen');

    //  _libraryBooks.value = responseBooks;

    return;
  }

  Future<void> postLibraryBook({
    required int isbn,
    required String bookId,
    required String location,
  }) async {
    final Book responseBook = await bookApiService.postLibraryBook(
      isbn: isbn,
      bookId: bookId,
      location: location,
    );

    _books.value = [..._books.value, responseBook];

    notificationService.showSnackBar(
        NotificationType.success, 'Arbeitsheft erfolgreich erstellt');

    return;
  }

  Future<void> updateBookProperty({
    required int isbn,
    String? title,
    String? author,
    String? description,
    String? readingLevel,
    List<BookTag>? tags,
  }) async {
    final Book updatedbook = await bookApiService.patchBookData(
      isbn: isbn,
      title: title,
      author: author,
      description: description,
      readingLevel: readingLevel,
      bookTags: tags,
    );

    List<Book> books = List.from(_books.value);
    int index = books.indexWhere((item) => item.bookId == updatedbook.bookId);

    books[index] = updatedbook;

    _books.value = books;

    notificationService.showSnackBar(
        NotificationType.success, 'Arbeitsheft erfolgreich aktualisiert');

    return;
  }

  Future<void> patchBookImage(File imageFile, int isbn) async {
    final Book responsebook =
        await bookApiService.patchBookImage(imageFile, isbn);

    updateBookStateWithResponse(responsebook);

    notificationService.showSnackBar(
        NotificationType.success, 'Bild erfolgreich hochgeladen');

    return;
  }

  Future<void> deleteLibraryBook(String bookId) async {
    final bool success = await bookApiService.deleteLibraryBook(bookId);

    if (success) {
      List<Book> books = List.from(_books.value);
      books.removeWhere((item) => item.bookId == bookId);

      _books.value = books;
      notificationService.showSnackBar(
          NotificationType.success, 'Arbeitsheft erfolgreich gelöscht');
    }

    //- TODO: delete all pupilbooks with this isbn in memory

    return;
  }

  //- PUPIL bookS

  List<Book> getLibraryBooksByIsbn(int isbn) {
    List<Book> books = [];
    for (Book book in _books.value) {
      if (book.isbn == isbn) {
        books.add(book);
      }
    }
    return books;
  }

  //- helper function
  Book? getLibraryBookByBookId(String? bookId) {
    if (bookId == null) return null;
    final Book? book =
        _books.value.firstWhereOrNull((element) => element.bookId == bookId);
    return book;
  }

  //- helper function
  void updateBookStateWithResponse(Book book) {
    List<Book> books = List.from(_books.value);
    int index = books.indexWhere((item) => item.bookId == book.bookId);
    books[index] = book;
    _books.value = books;
  }

  deletebook(int isbn) {}
}
