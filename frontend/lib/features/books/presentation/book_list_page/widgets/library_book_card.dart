import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/widgets/custom_expansion_tile/custom_expansion_tile.dart';
import 'package:schuldaten_hub/common/widgets/custom_expansion_tile/custom_expansion_tile_content.dart';
import 'package:schuldaten_hub/common/widgets/custom_expansion_tile/custom_expansion_tile_switch.dart';
import 'package:schuldaten_hub/features/books/domain/book_helper.dart';
import 'package:schuldaten_hub/features/books/domain/models/book.dart';
import 'package:schuldaten_hub/features/books/domain/models/pupil_book.dart';
import 'package:schuldaten_hub/features/books/presentation/book_list_page/widgets/book_pupil_card.dart';

class LibraryBookCard extends StatelessWidget {
  final BookProxy book;
  const LibraryBookCard({required this.book, super.key});
  List<PupilBorrowedBook> libraryBookPupilBooks(String bookId) {
    return BookHelpers.pupilBooksLinkedToBook(bookId: bookId);
  }

  @override
  Widget build(BuildContext context) {
    final tileController = CustomExpansionTileController();
    final bookPupilBooks =
        BookHelpers.pupilBooksLinkedToBook(bookId: book.bookId);
    BookBorrowStatus? bookBorrowStatus = bookPupilBooks.isEmpty
        ? null
        : BookHelpers.getBorrowedStatus(bookPupilBooks.first);
    final Color borrowedColor = book.available
        ? Colors.green
        : bookBorrowStatus == BookBorrowStatus.since2Weeks
            ? Colors.yellow
            : bookBorrowStatus == BookBorrowStatus.since3Weeks
                ? Colors.orange
                : Colors.red;
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Buch-ID:'),
            const Gap(10),
            Text(
              book.bookId,
              overflow: TextOverflow.fade,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const Gap(10),
            const Text('Ablageort:'),
            const Gap(10),
            Text(
              book.location,
              overflow: TextOverflow.fade,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const Spacer(),
            CustomExpansionTileSwitch(
              customExpansionTileController: tileController,
              expansionSwitchWidget: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: borrowedColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        CustomExpansionTileContent(
          title: null,
          tileController: tileController,
          widgetList: bookPupilBooks.isEmpty
              ? [
                  const Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Text(
                        'Keine Ausleihen',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ))
                ]
              : bookPupilBooks.map((pupilBook) {
                  return BookPupilCard(passedPupilBook: pupilBook);
                }).toList(),
        ),
        const Gap(5),
      ],
    );
  }
}
