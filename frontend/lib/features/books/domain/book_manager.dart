import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:schuldaten_hub/common/domain/models/enums.dart';
import 'package:schuldaten_hub/common/domain/session_manager.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_service.dart';
import 'package:schuldaten_hub/features/books/data/book_repository.dart';
import 'package:schuldaten_hub/features/books/data/pupil_book_repository.dart';
import 'package:schuldaten_hub/features/books/domain/models/book.dart';
import 'package:schuldaten_hub/features/pupil/domain/pupil_manager.dart';

class BookManager {
  ValueListenable<List<Book>> get books => _books;

  final _books = ValueNotifier<List<Book>>([]);

  BookManager();

  final session = locator.get<SessionManager>().credentials.value;

  final pupilBookRepository = PupilBookRepository();

  final bookRepository = BookRepository();

  final notificationService = locator<NotificationService>();

  final pupilManager = locator<PupilManager>();

  Future<BookManager> init() async {
    await getBooks();

    return this;
  }

  void clearData() {
    _books.value = [];
  }

  Future<void> getBooks() async {
    final List<Book> responseBooks = await bookRepository.getBooks();

    // sort books by name
    if (responseBooks.isNotEmpty) {
      responseBooks.sort((a, b) => a.title.compareTo(b.title));
    }
    notificationService.showSnackBar(
        NotificationType.success, 'Bücher erfolgreich geladen');

    _books.value = responseBooks;

    return;
  }

  Future<void> postBook({
    required String title,
    required int isbn,
    required String bookId,
    String? description,
    required String location,
    String? level,
    required String author,
  }) async {
    final Book responseBook = await bookRepository.postBook(
      isbn: isbn,
      bookId: bookId,
      description: description,
      location: location,
      readingLevel: level,
      title: title,
      author: author,
    );

    _books.value = [..._books.value, responseBook];

    notificationService.showSnackBar(
        NotificationType.success, 'Arbeitsheft erfolgreich erstellt');

    return;
  }

  Future<void> updateBookProperty({
    required String bookId,
    required String? title,
    required String? description,
    required String? location,
    required String? readingLevel,
  }) async {
    final Book bookToBeUpdated = _books.value.firstWhere(
      (item) => item.bookId == bookId,
    );

    final Book updatedbook = await bookRepository.updateBookProperty(
      book: bookToBeUpdated,
      title: title,
      description: description,
      location: location,
      readingLevel: readingLevel,
    );

    List<Book> books = List.from(_books.value);
    int index = books.indexWhere((item) => item.bookId == updatedbook.bookId);

    books[index] = updatedbook;

    _books.value = books;

    notificationService.showSnackBar(
        NotificationType.success, 'Arbeitsheft erfolgreich aktualisiert');

    return;
  }

  Future<void> postBookFile(File imageFile, String bookId) async {
    final Book responsebook =
        await bookRepository.postBookFile(imageFile, bookId);

    updateBookStateWithResponse(responsebook);

    notificationService.showSnackBar(
        NotificationType.success, 'Bild erfolgreich hochgeladen');

    return;
  }

  Future<void> postBookAndImageBytes({
    required String title,
    required int isbn,
    required String bookId,
    String? description,
    required String location,
    String? level,
    required Uint8List imageBytes,
    required String author,
  }) async {
    final Book responseBook = await bookRepository.postBook(
      author: author,
      isbn: isbn,
      bookId: bookId,
      description: description,
      location: location,
      readingLevel: level,
      title: title,
    );
    final tempDir = await getTemporaryDirectory();
    final file =
        await File('${tempDir.path}/tempImage.png').writeAsBytes(imageBytes);
    final Book responseBookWithImage = await bookRepository.postBookFile(
      file,
      responseBook.bookId,
    );

    _books.value = [..._books.value, responseBookWithImage];

    notificationService.showSnackBar(
        NotificationType.success, 'Arbeitsheft erfolgreich erstellt');

    return;
  }

  Future<void> deleteBook(String bookId) async {
    final bool success = await bookRepository.deleteBook(bookId);

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

  Future<void> deleteBookFile(String bookId) async {
    final Book responsebook = await bookRepository.deleteBookFile(bookId);

    updateBookStateWithResponse(responsebook);

    notificationService.showSnackBar(
        NotificationType.success, 'Bild erfolgreich gelöscht');

    return;
  }
  //- PUPIL bookS

  // Future<void> newPupilbook(int pupilId, int isbn) async {
  //   final PupilData responsePupil =
  //       await apiPupilbookService.postNewPupilbook(pupilId, isbn);

  //   pupilManager.updatePupilProxyWithPupilData(responsePupil);

  //   notificationService.showSnackBar(
  //       NotificationType.success, 'Arbeitsheft erstellt');

  //   return;
  // }

  // Future<void> deletePupilbook(int pupilId, int isbn) async {
  //   final PupilData responsePupil =
  //       await apiPupilbookService.deletePupilbook(pupilId, isbn);

  //   pupilManager.updatePupilProxyWithPupilData(responsePupil);

  //   notificationService.showSnackBar(
  //       NotificationType.success, 'Arbeitsheft gelöscht');

  //   return;
  // }

  List<Book> getBooksByIsbn(int isbn) {
    List<Book> books = [];
    for (Book book in _books.value) {
      if (book.isbn == isbn) {
        books.add(book);
      }
    }
    return books;
  }

  //- helper function
  Book? getBookByBookId(String? bookId) {
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
