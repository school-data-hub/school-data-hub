import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/theme/app_colors.dart';
import 'package:schuldaten_hub/common/theme/paddings.dart';
import 'package:schuldaten_hub/features/attendance/domain/attendance_manager.dart';
import 'package:schuldaten_hub/features/attendance/domain/models/missed_class.dart';
import 'package:schuldaten_hub/features/attendance/presentation/missed_classes_pupil_list_page/missed_classes_pupil_list_page.dart';
import 'package:schuldaten_hub/features/attendance/presentation/widgets/attendance_stats_pupil.dart';
import 'package:schuldaten_hub/features/attendance/presentation/widgets/missed_class_card.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_proxy.dart';

class PupilAttendanceContent extends StatelessWidget {
  final PupilProxy pupil;
  const PupilAttendanceContent({required this.pupil, super.key});

  @override
  Widget build(BuildContext context) {
    final List<int> missedHoursForActualReport =
        locator<AttendanceManager>().missedHoursforSemesterOrSchoolyear(pupil);
    List<MissedClass> missedClasses = pupil.missedClasses!;
    // sort by missedDay
    missedClasses.sort((b, a) => a.missedDay.compareTo(b.missedDay));
    return Card(
      color: AppColors.pupilProfileCardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: AppPaddings.pupilProfileCardPadding,
        child: Column(children: [
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Icon(
              Icons.calendar_month_rounded,
              color: Colors.grey[700],
              size: 24,
            ),
            const Gap(5),
            InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (ctx) => const MissedClassesPupilListPage(),
                ));
              },
              child: const Text('Fehlzeiten',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.backgroundColor,
                  )),
            )
          ]),
          const Gap(15),
          attendanceStats(pupil),
          const Gap(10),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text(
                'Fehlstunden:',
                style: TextStyle(fontSize: 14),
              ),
              Text(
                ' ${missedHoursForActualReport[0].toString()}',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Gap(5),
              const Text(
                'davon unent:',
                style: TextStyle(fontSize: 14),
              ),
              Text(
                ' ${missedHoursForActualReport[1].toString()}',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Gap(15),
            ],
          ),
          const Gap(10),
          ListView.builder(
            padding: const EdgeInsets.only(top: 5, bottom: 15),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: missedClasses.length,
            itemBuilder: (BuildContext context, int index) {
              // pupil.pupilMissedClasses.sort(
              //     (a, b) => a.missedDay.compareTo(b.missedDay));

              return MissedClassCard(
                  pupil: pupil, missedClass: missedClasses[index]);
            },
          ),
        ]),
      ),
    );
  }
}

List<Widget> pupilAttendanceContentList(PupilProxy pupil, context) {
  List<MissedClass> missedClasses = List.from(pupil.missedClasses!);
  // sort by missedDay
  missedClasses.sort((b, a) => a.missedDay.compareTo(b.missedDay));
  return [
    ListView.builder(
      padding: const EdgeInsets.only(top: 5, bottom: 15),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: missedClasses.length,
      itemBuilder: (BuildContext context, int index) {
        // pupil.pupilMissedClasses.sort(
        //     (a, b) => a.missedDay.compareTo(b.missedDay));

        return MissedClassCard(pupil: pupil, missedClass: missedClasses[index]);
      },
    ),
  ];
}
