import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/domain/models/enums.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_service.dart';
import 'package:schuldaten_hub/common/theme/styles.dart';
import 'package:schuldaten_hub/common/utils/scanner.dart';
import 'package:schuldaten_hub/common/widgets/dialogs/short_textfield_dialog.dart';
import 'package:schuldaten_hub/features/books/domain/models/pupil_book.dart';
import 'package:schuldaten_hub/features/books/presentation/widgets/pupil_book_card.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_proxy.dart';
import 'package:schuldaten_hub/features/pupil/domain/pupil_manager.dart';

class PupilLearningContentBooks extends StatelessWidget {
  final PupilProxy pupil;
  const PupilLearningContentBooks({required this.pupil, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          children: [
            Text(
              'Bücher',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const Gap(10),
        ElevatedButton(
          style: AppStyles.actionButtonStyle,
          onPressed: () async {
            String? bookId;
            if (Platform.isIOS || Platform.isAndroid) {
              final scannedBookId = await scanner(context, 'Buch-ID scannen');
              if (!(scannedBookId != null)) {
                locator<NotificationService>().showSnackBar(
                    NotificationType.error,
                    'Buch-ID konnte nicht gescannt werden');
                return;
              }
              bookId = scannedBookId.replaceFirst('Buch ID: ', '');
            } else {
              bookId = await shortTextfieldDialog(
                  context: context,
                  title: 'Buch-Id',
                  labelText: 'Buch-Id eingeben',
                  hintText: 'Buch-Id',
                  obscureText: false);
            }
            if (bookId != null) {
              locator<PupilManager>()
                  .borrowBook(pupilId: pupil.internalId, bookId: bookId);
              return;
            }
          },
          child: const Text(
            "BUCH AUSLEIHEN",
            style: AppStyles.buttonTextStyle,
          ),
        ),
        const Gap(5),
        if (pupil.pupilBooks!.isNotEmpty) ...[
          const Gap(10),
          ListView.builder(
            padding: const EdgeInsets.all(0),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: pupil.pupilBooks!.length,
            itemBuilder: (context, int index) {
              List<PupilBook> pupilBooks = pupil.pupilBooks!;

              return ClipRRect(
                borderRadius: BorderRadius.circular(25.0),
                child: Column(
                  children: [
                    PupilBookCard(
                        pupilBook: pupilBooks[index],
                        pupilId: pupil.internalId),
                  ],
                ),
              );
            },
          ),
        ],
        const Gap(10),
      ],
    );
  }
}
