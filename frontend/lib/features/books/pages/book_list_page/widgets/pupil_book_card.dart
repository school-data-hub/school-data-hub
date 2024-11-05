import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:schuldaten_hub/common/services/env_manager.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/utils/extensions.dart';
import 'package:schuldaten_hub/common/widgets/dialogues/confirmation_dialog.dart';
import 'package:schuldaten_hub/common/widgets/dialogues/information_dialog.dart';
import 'book_image.dart';
import 'package:schuldaten_hub/common/widgets/upload_image.dart';

import '../../../models/book.dart';
import '../../../models/pupil_book.dart';
import '../../../services/book_api_service.dart';
import '../../../services/book_manager.dart';

class PupilBookCard extends StatelessWidget {
  const PupilBookCard(
      {required this.pupilBook, required this.pupilId, super.key});
  final PupilBook pupilBook;
  final int pupilId;

  @override
  Widget build(BuildContext context) {
    final Book book = locator<BookManager>()
        .getBookByIsbn(pupilBook.bookId)!;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Card(
          child: InkWell(
        onLongPress: () async {
          if (pupilBook.receivedBy != null && pupilBook.returnedAt != null) {
            informationDialog(context, '',
                'Das Buch wurde bereits zurück gegeben!');
            return;
          }
          final bool? result = await confirmationDialog(
              context: context,
              title: 'Buchrückgabe',
              message: 'Buch "${book.title}" wirklich zurücknehmen?');
          if (result == true) {
            locator<BookManager>()
                .patchPupilBook(pupilId, book.bookId);
          }
        },
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(5),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
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
                          },
                    child: book.imageUrl != null
                        ? Provider<BookImageData>.value(
                            updateShouldNotify: (oldValue, newValue) =>
                                oldValue.documentUrl != newValue.documentUrl,
                            value: BookImageData(
                                documentTag: book.imageUrl!,
                                documentUrl:
                                    '${locator<EnvManager>().env.value.serverUrl}${BookApiService().getBookImage(book.isbn)}',
                                size: 100),
                            child: const BookImage(),
                          )
                        : SizedBox(
                            height: 100,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Image.asset('assets/document_camera.png'),
                            ),
                          ),
                  ),
                  const Gap(10),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, bottom: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Text(
                                (book.title ?? 'Unknown Title'),
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const Gap(10),
                        ],
                      ),
                      const Gap(5),
                      Row(
                        children: [
                          Text(book.author!,
                              overflow: TextOverflow.fade,
                              style: const TextStyle(
                                fontSize: 14,
                              )),
                          const Spacer(),
                          Text(
                            book.readingLevel!,
                            maxLines: 2,
                            overflow: TextOverflow.fade,
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          const Gap(10),
                        ],
                      ),
                      const Gap(5),
                      Row(
                        children: [
                          const Text('Verliehen von:'),
                          const Gap(5),
                          Text(
                            pupilBook.lentBy!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Gap(5),
                          const Text('am'),
                          const Gap(5),
                          Text(
                            pupilBook.lentAt.formatForUser(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                      const Gap(5),
                      if (pupilBook.receivedBy != null  && pupilBook.returnedAt != null)
                      Row(
                        children: [
                          const Text('Zurückgenommen von:'),
                          const Gap(5),
                          Text(
                            pupilBook.receivedBy!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Gap(5),
                          const Text('am'),
                          const Gap(5),
                          Text(
                            DateFormat('dd.MM.yyyy').format(pupilBook.returnedAt!),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          )
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
