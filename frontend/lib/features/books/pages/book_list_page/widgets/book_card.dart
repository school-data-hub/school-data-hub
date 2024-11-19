import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:schuldaten_hub/common/services/env_manager.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/session_manager.dart';
import 'package:schuldaten_hub/common/utils/extensions.dart';
import 'package:schuldaten_hub/common/widgets/dialogues/confirmation_dialog.dart';
import 'package:schuldaten_hub/common/widgets/dialogues/information_dialog.dart';
import 'package:schuldaten_hub/common/widgets/upload_image.dart';
import '../../../../../common/widgets/qr_widgets.dart';
import '../../../models/book.dart';
import '../../../services/book_api_service.dart';
import '../../../services/book_manager.dart';
import '../../new_book_page/new_book_page.dart';
import 'book_image.dart';

class BookCard extends StatelessWidget {
  const BookCard({required this.book, super.key});

  final Book book;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Card(
          color: Colors.white,
          surfaceTintColor: Colors.white,
          child: InkWell(
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
                      'Buch "${book.title}" wirklich löschen? ACHTUNG: Alle Bücher dieser Art werden ebenfalls gelöscht!');
              if (result == true) {
                await locator<BookManager>().deleteBook(book.bookId);
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 5),
              child: Row(
                children: [
                  const Gap(15),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Gap(10),
                      InkWell(
                        onTap: () async {
                          final File? file = await uploadImage(context);
                          if (file == null) return;
                          await locator<BookManager>()
                              .postBookFile(file, book.isbn);
                        },
                        onLongPress: (book.imageUrl == null)
                            ? () {}
                            : () async {
                                if (book.imageUrl == null) {
                                  return;
                                }
                                final bool? result = await confirmationDialog(
                                    context: context,
                                    title: 'Bild löschen',
                                    message: 'Bild löschen?');
                                if (result != true) return;
                                await locator<BookManager>()
                                    .deleteBookFile(book.isbn);
                              },
                        child: book.imageUrl != null
                            ? Provider<BookImageData>.value(
                                updateShouldNotify: (oldValue, newValue) =>
                                    oldValue.documentUrl !=
                                    newValue.documentUrl,
                                value: BookImageData(
                                    documentTag: book.imageUrl!.split('/').last,
                                    documentUrl:
                                        '${locator<EnvManager>().env.value.serverUrl}${BookApiService().getBookImage(book.isbn)}',
                                    size: 140),
                                child: const BookImage(),
                              )
                            : SizedBox(
                                height: 100,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child:
                                      Image.asset('assets/document_camera.png'),
                                ),
                              ),
                      ),
                      const Gap(10),
                      ElevatedButton.icon(
                        onPressed: () {
                          showQrCode(book.bookId, context);
                        },
                        icon: const Icon(Icons.qr_code),
                        label: const Text('QR-Code'),
                      ),
                      const Gap(10),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 8.0, left: 15, bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onLongPress:
                                      (locator<SessionManager>().isAdmin.value)
                                          ? () async {
                                              Navigator.of(context)
                                                  .push(MaterialPageRoute(
                                                builder: (ctx) => NewBookPage(
                                                  wbIsbn: book.isbn,
                                                  wbId: book.bookId,
                                                  wbLocation: book.location,
                                                  wbLevel: book.readingLevel,
                                                  isEdit: true,
                                                ),
                                              ));
                                            }
                                          : () {},
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Text(
                                      book.title ?? 'Unknown Title',
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                              const Gap(10),
                            ],
                          ),
                          const Gap(5),
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
                          const Gap(5),
                          Row(
                            children: [
                              const Text('Autor:'),
                              const Gap(10),
                              Text(
                                book.author!,
                                overflow: TextOverflow.fade,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const Gap(5),
                          Row(
                            children: [
                              const Text('Ort:'),
                              const Gap(10),
                              Text(
                                book.location!,
                                overflow: TextOverflow.fade,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const Gap(5),
                          Row(
                            children: [
                              const Text('Kompetenzstufe:'),
                              const Gap(10),
                              Text(
                                book.readingLevel!,
                                overflow: TextOverflow.fade,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const Gap(5),
                          Row(
                            children: [
                              const Text('ID:'),
                              const Gap(10),
                              Text(
                                book.bookId!,
                                overflow: TextOverflow.fade,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
