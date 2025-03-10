import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/features/books/domain/models/pupil_book.dart';
import 'package:schuldaten_hub/features/pupil/domain/pupil_manager.dart';

enum BookBorrowStatus { since2Weeks, since3Weeks, since5weeks }

class BookHelpers {
  static List<PupilBorrowedBook> pupilBooksLinkedToBook(
      {required String bookId}) {
    // returned starting with the most recent
    final pupilBooks = locator<PupilManager>()
        .allPupils
        .map((pupil) => pupil.pupilBooks)
        .expand((element) => element as Iterable<PupilBorrowedBook>)
        .where((pupilBook) => pupilBook.bookId.contains(bookId))
        .toList();

    pupilBooks.sort((a, b) => b.lentAt.compareTo(a.lentAt));
    return pupilBooks;
  }

  static BookBorrowStatus getBorrowedStatus(PupilBorrowedBook book) {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(book.lentAt);
    if (difference.inDays < 21) {
      return BookBorrowStatus.since2Weeks;
    } else if (difference.inDays < 35) {
      return BookBorrowStatus.since3Weeks;
    } else {
      return BookBorrowStatus.since5weeks;
    }
  }
}
