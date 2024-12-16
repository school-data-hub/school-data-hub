import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:schuldaten_hub/common/domain/env_manager.dart';
import 'package:schuldaten_hub/common/domain/session_manager.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/utils/extensions.dart';
import 'package:schuldaten_hub/common/widgets/custom_expansion_tile/custom_expansion_tile_content.dart';
import 'package:schuldaten_hub/common/widgets/custom_expansion_tile/custom_expansion_tile_switch.dart';
import 'package:schuldaten_hub/common/widgets/custom_expansion_tile/custom_expasion_tile_hook.dart';
import 'package:schuldaten_hub/common/widgets/dialogues/confirmation_dialog.dart';
import 'package:schuldaten_hub/common/widgets/dialogues/information_dialog.dart';
import 'package:schuldaten_hub/common/widgets/document_image.dart';
import 'package:schuldaten_hub/common/widgets/upload_image.dart';
import 'package:schuldaten_hub/features/books/data/book_repository.dart';
import 'package:schuldaten_hub/features/books/domain/book_helper.dart';
import 'package:schuldaten_hub/features/books/domain/book_manager.dart';
import 'package:schuldaten_hub/features/books/domain/models/book.dart';
import 'package:schuldaten_hub/features/books/presentation/book_list_page/widgets/book_pupil_card.dart';
import 'package:schuldaten_hub/features/books/presentation/new_book_page/new_book_page_view_model.dart';
import 'package:schuldaten_hub/features/workbooks/domain/workbook_manager.dart';

class BookCard extends HookWidget {
  const BookCard({required this.book, super.key});
  final Book book;

  @override
  Widget build(BuildContext context) {
    final tileController = useCustomExpansionTileController();
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Card(
          color: Colors.white,
          surfaceTintColor: Colors.white,
          child: InkWell(
            // onTap: () {
            //   Navigator.of(context).push(MaterialPageRoute(
            //     builder: (ctx) => SchoolListPupils(
            //       workbook,
            //     ),
            //   ));
            // },
            onLongPress: () async {
              if (!locator<SessionManager>().isAdmin.value) {
                informationDialog(context, 'Keine Berechtigung',
                    'Bücher können nur von Admins bearbeitet werden!');
                return;
              }
              final bool? result = await confirmationDialog(
                  context: context,
                  title: 'Buch löschen',
                  message:
                      'Buch "${book.title}" wirklich löschen? ACHTUNG: Alle Ausleihen dieses Buches werden werden ebenfalls gelöscht!');
              if (result == true) {
                await locator<BookManager>().deleteBook(book.bookId);
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 10, left: 15, right: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: InkWell(
                      onLongPress: (locator<SessionManager>().isAdmin.value)
                          ? () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (ctx) => NewBook(
                                  isEdit: true,
                                  bookAuthor: book.author,
                                  bookId: book.bookId,
                                  bookIsbn: book.isbn,
                                  bookReadingLevel: book.readingLevel,
                                  bookTitle: book.title,
                                  bookDescription: book.description,
                                  bookImageId: book.imageId,
                                ),
                              ));
                            }
                          : () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            book.title,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          book.author,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          InkWell(
                            onTap: () async {
                              final File? file = await uploadImage(context);
                              if (file == null) return;
                              await locator<BookManager>()
                                  .postBookFile(file, book.bookId);
                            },
                            onLongPress: () async {
                              if (book.imageId == null) {
                                return;
                              }
                              final bool? result = await confirmationDialog(
                                  context: context,
                                  title: 'Bild löschen',
                                  message: 'Bild löschen?');
                              if (result != true) return;
                              await locator<WorkbookManager>()
                                  .deleteWorkbookFile(book.isbn);
                            },
                            child: book.imageId != null
                                ? Provider<DocumentImageData>.value(
                                    updateShouldNotify: (oldValue, newValue) =>
                                        oldValue.documentTag !=
                                        newValue.documentTag,
                                    value: DocumentImageData(
                                        documentTag: book.imageId!,
                                        documentUrl:
                                            '${locator<EnvManager>().env.value.serverUrl}${BookRepository.getBookImageUrl(book.bookId)}',
                                        size: 140),
                                    child: const DocumentImage(),
                                  )
                                : SizedBox(
                                    height: 100,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: Image.asset(
                                          'assets/document_camera.png'),
                                    ),
                                  ),
                          ),
                          const Gap(10),
                        ],
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 8.0, left: 15, bottom: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text('ISBN:'),
                                  const Gap(10),
                                  Text(
                                    book.isbn.displayAsIsbn(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              Row(children: [
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
                              ]),
                              Row(
                                children: [
                                  const Text('LeseStufe:'),
                                  const Gap(10),
                                  Text(
                                    book.readingLevel,
                                    overflow: TextOverflow.fade,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
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
                                    customExpansionTileController:
                                        tileController,
                                    expansionSwitchWidget: Container(
                                      width: 25,
                                      height: 25,
                                      decoration: BoxDecoration(
                                        color: borrowedColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(10),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  CustomExpansionTileContent(
                    title: null,
                    tileController: tileController,
                    widgetList: bookPupilBooks.map((pupilBook) {
                      return BookPupilCard(pupilBook: pupilBook);
                    }).toList(),
                  ),
                  const Gap(10),
                ],
              ),
            ),
          )),
    );
  }
}