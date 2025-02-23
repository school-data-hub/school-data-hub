import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/domain/env_manager.dart';
import 'package:schuldaten_hub/common/domain/session_manager.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/theme/app_colors.dart';
import 'package:schuldaten_hub/common/theme/styles.dart';
import 'package:schuldaten_hub/common/utils/extensions.dart';
import 'package:schuldaten_hub/common/widgets/dialogs/confirmation_dialog.dart';
import 'package:schuldaten_hub/common/widgets/dialogs/information_dialog.dart';
import 'package:schuldaten_hub/common/widgets/dialogs/long_textfield_dialog.dart';
import 'package:schuldaten_hub/common/widgets/document_image.dart';
import 'package:schuldaten_hub/common/widgets/unencrypted_image_in_card.dart';
import 'package:schuldaten_hub/features/books/data/book_api_service.dart';
import 'package:schuldaten_hub/features/books/domain/book_manager.dart';
import 'package:schuldaten_hub/features/books/domain/models/book.dart';
import 'package:schuldaten_hub/features/books/domain/models/pupil_book.dart';
import 'package:schuldaten_hub/features/competence/presentation/widgets/competence_check_dropdown.dart';
import 'package:schuldaten_hub/features/pupil/domain/pupil_manager.dart';

class PupilBookCard extends StatelessWidget {
  const PupilBookCard(
      {required this.pupilBook, required this.pupilId, super.key});
  final PupilBook pupilBook;
  final int pupilId;

  @override
  Widget build(BuildContext context) {
    final Book book =
        locator<BookManager>().getLibraryBookByBookId(pupilBook.bookId)!;
    updatepupilBookRating(int rating) {
      locator<PupilManager>()
          .patchPupilBook(lendingId: pupilBook.lendingId, rating: rating);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Card(
          child: InkWell(
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
            locator<PupilManager>()
                .deletePupilBook(lendingId: pupilBook.lendingId);
          }
        },
        child: Padding(
          padding:
              const EdgeInsets.only(top: 8.0, bottom: 5, left: 10, right: 10),
          child: Column(
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
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const Gap(10),
                ],
              ),
              const Gap(10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Gap(5),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      UnencryptedImageInCard(
                        documentImageData: DocumentImageData(
                            documentTag: book.imageId,
                            documentUrl:
                                '${locator<EnvManager>().env!.serverUrl}${BookApiService.getBookImageUrl(book.isbn)}',
                            size: 140),
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
                          const Gap(5),
                          Row(
                            children: [
                              Text(
                                pupilBook.lentBy,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Gap(2),
                              const Icon(
                                Icons.arrow_circle_right_rounded,
                                color: Colors.orange,
                              ),
                              const Gap(2),
                              Text(
                                pupilBook.lentAt.formatForUser(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          if (pupilBook.returnedAt != null)
                            Row(
                              children: [
                                Text(
                                  pupilBook.receivedBy!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Gap(2),
                                const Icon(
                                  Icons.arrow_circle_left_rounded,
                                  color: Colors.green,
                                ),
                                const Gap(2),
                                Text(
                                  pupilBook.returnedAt!.formatForUser(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          const Gap(10),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GrowthDropdown(
                          dropdownValue: pupilBook.rating ?? 0,
                          onChangedFunction: updatepupilBookRating),
                    ],
                  ),
                ],
              ),
              const Text(
                'Beobachtungen:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              InkWell(
                onLongPress: () async {
                  final status = await longTextFieldDialog(
                      title: 'Status',
                      labelText: 'Status',
                      textinField: pupilBook.state ?? '',
                      parentContext: context);
                  if (status == null) return;
                  await locator<PupilManager>().patchPupilBook(
                      lendingId: pupilBook.lendingId, comment: status);
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
                          onPressed: () async {
                            final result = await confirmationDialog(
                                context: context,
                                title: 'Buch zurückgeben',
                                message:
                                    'Buch "${book.title}" wirklich zurückgeben?');
                            if (result!) {
                              locator<PupilManager>().returnBook(
                                lendingId: pupilBook.lendingId,
                              );
                            }
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
