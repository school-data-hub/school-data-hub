import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/constants/styles.dart';
import 'package:schuldaten_hub/features/books/models/pupil_book.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';

import '../../../../../books/pages/book_list_page/widgets/pupil_book_card.dart';

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
          style: actionButtonStyle,
          onPressed: () async {},
          child: const Text(
            "BUCH AUSLEIHEN",
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
      ],
    );
  }
}
