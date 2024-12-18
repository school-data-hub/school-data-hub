import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:schuldaten_hub/common/domain/env_manager.dart';
import 'package:schuldaten_hub/common/domain/session_manager.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/theme/colors.dart';
import 'package:schuldaten_hub/common/theme/styles.dart';
import 'package:schuldaten_hub/common/utils/extensions.dart';
import 'package:schuldaten_hub/common/widgets/dialogues/confirmation_dialog.dart';
import 'package:schuldaten_hub/common/widgets/dialogues/information_dialog.dart';
import 'package:schuldaten_hub/common/widgets/dialogues/long_textfield_dialog.dart';
import 'package:schuldaten_hub/common/widgets/document_image.dart';
import 'package:schuldaten_hub/common/widgets/upload_image.dart';
import 'package:schuldaten_hub/features/books/data/book_repository.dart';
import 'package:schuldaten_hub/features/books/domain/book_manager.dart';
import 'package:schuldaten_hub/features/books/domain/models/book.dart';
import 'package:schuldaten_hub/features/books/domain/models/pupil_book.dart';
import 'package:schuldaten_hub/features/pupil/domain/pupil_manager.dart';

class PupilBookCard extends StatelessWidget {
  const PupilBookCard(
      {required this.pupilBook, required this.pupilId, super.key});
  final PupilBook pupilBook;
  final int pupilId;

  @override
  Widget build(BuildContext context) {
    final Book book = locator<BookManager>().getBookByBookId(pupilBook.bookId)!;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Card(
          child: InkWell(
        // onTap: () {
        //   Navigator.of(context).push(MaterialPageRoute(
        //     builder: (ctx) => SchoolListPupils(
        //       workbook,
        //     ),
        //   ));
        // },
        onLongPress: () async {
          if (pupilBook.lentBy !=
                  locator<SessionManager>().credentials.value.username ||
              !locator<SessionManager>().credentials.value.isAdmin!) {
            informationDialog(context, 'Keine Berechtigung',
                'Ausleihen können nur von der eintragenden Person bearbeitet werden!');
            return;
          }
          final bool? result = await confirmationDialog(
              context: context,
              title: 'Ausleihe löschen',
              message: 'Ausleihe von "${book.title}" wirklich löschen?');
          if (result == true) {
            // locator<BookManager>()
            //     .deletePupilBook(pupilId, book.bookId);
          }
        },
        child: Padding(
          padding:
              const EdgeInsets.only(top: 8.0, bottom: 5, left: 5, right: 5),
          child: Column(
            children: [
              Row(
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
                          await locator<BookManager>()
                              .deleteBookFile(book.imageId!);
                        },
                        child: book.imageId != null
                            ? Provider<DocumentImageData>.value(
                                updateShouldNotify: (oldValue, newValue) =>
                                    oldValue.documentTag !=
                                    newValue.documentTag,
                                value: DocumentImageData(
                                    documentTag: book.imageId!,
                                    documentUrl:
                                        '${locator<EnvManager>().env.value.serverUrl}${BookRepository().getBookImage(book.bookId)}',
                                    size: 100),
                                child: const DocumentImage(),
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
                                    book.title,
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const Gap(10),
                            ],
                          ),
                          const Gap(5),
                          Row(
                            children: [
                              const Text('Erstellt von:'),
                              const Gap(5),
                              Text(
                                pupilBook.lentBy,
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
                          if (pupilBook.returnedAt != null)
                            Row(
                              children: [
                                const Text('Zurück am:'),
                                const Gap(5),
                                Text(
                                  pupilBook.returnedAt!.formatForUser(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Gap(5),
                                const Text('bei:'),
                                const Gap(5),
                                Text(
                                  pupilBook.receivedBy!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                          const Gap(10),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          const Text('Status:'),
                          const Gap(10),
                          InkWell(
                            onLongPress: () async {
                              final status = await longTextFieldDialog(
                                  title: 'Status',
                                  labelText: 'Status',
                                  textinField: pupilBook.state ?? '',
                                  parentContext: context);
                              if (status == null) return;
                              await locator<PupilManager>().patchPupilBook(
                                  lendingId: pupilBook.lendingId,
                                  state: status);
                            },
                            child: Text(
                              (pupilBook.state == null || pupilBook.state == '')
                                  ? 'Kein Eintrag'
                                  : pupilBook.state!,
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.interactiveColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Gap(10),
                ],
              ),
              const Gap(10),
              if (pupilBook.returnedAt == null) ...[
                const Gap(5),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding:
                            const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                        child: ElevatedButton(
                          onPressed: () {
                            locator<PupilManager>().returnBook(
                              lendingId: pupilBook.lendingId,
                            );
                          },
                          style: AppStyles.successButtonStyle,
                          child: const Text(
                            'BUCH ZURÜCKGEBEN',
                            style: AppStyles.buttonTextStyle,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ]
            ],
          ),
        ),
      )),
    );
  }
}
