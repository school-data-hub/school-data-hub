import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/constants/enums.dart';
import 'package:schuldaten_hub/common/constants/styles.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_manager.dart';
import 'package:schuldaten_hub/common/utils/scanner.dart';
import 'package:schuldaten_hub/features/books/pages/book_list_page/widgets/pupil_book_card.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';

import '../../../models/pupil_book.dart';
import '../../../services/book_manager.dart';
import '../../new_book_page/new_book_page.dart';

class PupilBookContent extends StatelessWidget {
  final PupilProxy pupil;
  const PupilBookContent({required this.pupil, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          children: [
            Text(
              'Bücher',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            )
          ],
        ),
        const Gap(10),
        ElevatedButton(
          style: actionButtonStyle,
          onPressed: () async {
            final scanResult = await scanner(context, 'QR code scannen');
            if (scanResult != null) {
              final scannedId = int.parse(scanResult);
              if (!locator<BookManager>()
                  .books
                  .value
                  .any((element) => element.bookId == scannedId)) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (ctx) => NewBookPage(
                          isEdit: false,
                          wbIsbn: scannedId,
                        )));
                locator<NotificationManager>().showInformationDialog(
                    'Das Buch wurde noch nicht erfasst. Bitte hinzufügen!');
                return;
              }
              if (pupil.pupilBooks!.isNotEmpty) {
                if (pupil.pupilBooks!.any((element) =>
                    element.bookId == scanResult)) {
                  locator<NotificationManager>().showSnackBar(
                      NotificationType.error,
                      'Dieses Buch ist schon erfasst!');
                  return;
                }
              }
              locator<BookManager>()
                  .newPupilBook(pupil.internalId, scanResult);
              return;
            }
            locator<NotificationManager>()
                .showSnackBar(NotificationType.error, 'Fehler beim Scannen');
          },
          child: const Text(
            "NEUES BUCH",
            style: buttonTextStyle,
          ),
        ),
        if (pupil.pupilBooks!.isNotEmpty) ...[
          const Gap(15),
          ListView.builder(
            padding: const EdgeInsets.all(0),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: pupil.pupilBooks!.length,
            itemBuilder: (context, int index) {
              List<PupilBook> pupilBooks = pupil.pupilBooks!;

              return ClipRRect(
                borderRadius: BorderRadius.circular(25.0),
                child: Card(
                  child: Column(
                    children: [
                      PupilBookCard(
                          pupilBook: pupilBooks[index],
                          pupilId: pupil.internalId),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
        const Gap(15),
      ],
    );
  }
}