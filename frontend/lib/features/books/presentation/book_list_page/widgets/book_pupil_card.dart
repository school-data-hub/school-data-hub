import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/theme/colors.dart';
import 'package:schuldaten_hub/common/utils/extensions.dart';
import 'package:schuldaten_hub/common/widgets/avatar.dart';
import 'package:schuldaten_hub/common/widgets/dialogs/long_textfield_dialog.dart';
import 'package:schuldaten_hub/features/books/domain/models/pupil_book.dart';
import 'package:schuldaten_hub/features/main_menu/widgets/landing_bottom_nav_bar.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_proxy.dart';
import 'package:schuldaten_hub/features/pupil/domain/pupil_manager.dart';
import 'package:schuldaten_hub/features/pupil/presentation/pupil_profile_page/pupil_profile_page.dart';
import 'package:watch_it/watch_it.dart';

class BookPupilCard extends WatchingWidget {
  final PupilBook pupilBook;
  const BookPupilCard({required this.pupilBook, super.key});

  @override
  Widget build(BuildContext context) {
    final pupil = watch<PupilProxy>(
        locator<PupilManager>().findPupilById(pupilBook.pupilId)!);

    return Card(
      color: AppColors.cardInCardColor,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 1.0,
      margin:
          const EdgeInsets.only(left: 4.0, right: 4.0, top: 4.0, bottom: 4.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              AvatarWithBadges(pupil: pupil!, size: 80),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Gap(10),
                    Row(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: InkWell(
                              onTap: () {
                                locator<BottomNavManager>()
                                    .setPupilProfileNavPage(9);
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (ctx) => PupilProfilePage(
                                    pupil: pupil,
                                  ),
                                ));
                              },
                              child: Row(
                                children: [
                                  Text(
                                    pupil.firstName,
                                    overflow: TextOverflow.fade,
                                    softWrap: false,
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const Gap(5),
                                  Text(
                                    pupil.lastName,
                                    overflow: TextOverflow.fade,
                                    softWrap: false,
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const Gap(5),
                                ],
                              ),
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
                                const Text('ausgeliehen am:'),
                                const Gap(10),
                                Text(
                                  pupilBook.lentAt.formatForUser(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const Gap(10),
                                const Text('von:'),
                                const Gap(10),
                                Text(
                                  pupilBook.lentBy.toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (pupilBook.returnedAt != null) ...[
                      Row(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  const Text('zurückgegeben am:'),
                                  const Gap(10),
                                  Text(
                                    pupilBook.returnedAt!.formatForUser(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const Gap(10),
                                  const Text('von:'),
                                  const Gap(10),
                                  Text(
                                    pupilBook.receivedBy.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const Gap(20),
            ],
          ),
          const Gap(10),
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Row(
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
                                lendingId: pupilBook.lendingId, state: status);
                          },
                          child: Text(
                            pupilBook.state ?? 'Keine Einträge',
                            style: const TextStyle(
                              fontSize: 16,
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
          ),
          const Gap(10),
        ],
      ),
    );
  }
}
