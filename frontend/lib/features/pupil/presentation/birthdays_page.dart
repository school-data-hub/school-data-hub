import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/theme/colors.dart';
import 'package:schuldaten_hub/common/theme/styles.dart';
import 'package:schuldaten_hub/common/utils/extensions.dart';
import 'package:schuldaten_hub/common/widgets/avatar.dart';
import 'package:schuldaten_hub/features/attendance/domain/attendance_helper_functions.dart';
import 'package:schuldaten_hub/features/pupil/domain/pupil_manager.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_proxy.dart';
import 'package:schuldaten_hub/features/pupil/presentation/pupil_profile_page/pupil_profile_page.dart';
import 'package:watch_it/watch_it.dart';

class BirthdaysView extends WatchingWidget {
  final DateTime selectedDate;
  const BirthdaysView({required this.selectedDate, super.key});

  @override
  Widget build(BuildContext context) {
    final Set<DateTime> seenBirthdays = {};
    final List<PupilProxy> pupils =
        locator<PupilManager>().pupilsWithBirthdaySinceDate(selectedDate);

    return Scaffold(
      backgroundColor: AppColors.canvasColor,
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.backgroundColor,
        title: const Text('Geburtstage', style: AppStyles.appBarTextStyle),
      ),
      body: Center(
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Geburtstage seit dem ${selectedDate.formatForUser()}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20)),
                        ListView.builder(
                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: pupils.length,
                            itemBuilder: (context, int index) {
                              PupilProxy listedPupil = pupils[index];
                              final bool isBirthdayPrinted =
                                  seenBirthdays.contains(DateTime(
                                      DateTime.now().year,
                                      listedPupil.birthday.month,
                                      listedPupil.birthday.day));
                              if (!isBirthdayPrinted) {
                                seenBirthdays.add(DateTime(
                                    DateTime.now().year,
                                    listedPupil.birthday.month,
                                    listedPupil.birthday.day));
                              }
                              return Column(
                                children: [
                                  !isBirthdayPrinted
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5.0),
                                          child: Row(
                                            children: [
                                              const Gap(5),
                                              Text(
                                                AttendanceHelper
                                                    .thisDateAsString(
                                                        context,
                                                        DateTime(
                                                            DateTime.now().year,
                                                            listedPupil
                                                                .birthday.month,
                                                            listedPupil
                                                                .birthday.day)),
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors
                                                        .backgroundColor,
                                                    fontSize: 18),
                                              )
                                            ],
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                  InkWell(
                                    onTap: () {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (ctx) => PupilProfilePage(
                                          pupil: listedPupil,
                                        ),
                                      ));
                                    },
                                    child: Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Row(
                                          children: [
                                            AvatarWithBadges(
                                                pupil: listedPupil, size: 80),
                                            const Gap(10),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  listedPupil.firstName,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18),
                                                ),
                                                Text(
                                                  listedPupil.lastName,
                                                  style: const TextStyle(
                                                      fontSize: 18),
                                                ),
                                              ],
                                            ),
                                            const Spacer(),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  listedPupil.age.toString(),
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                      fontSize: 24),
                                                ),
                                                const Gap(5),
                                                const Text(
                                                  'Jahre alt',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                      fontSize: 18),
                                                ),
                                              ],
                                            ),
                                            const Gap(20),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Gap(5)
                                ],
                              );
                            }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Icon(Icons.arrow_back),
      ),
    );
  }
}
