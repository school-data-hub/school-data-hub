import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:schuldaten_hub/common/domain/models/enums.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_service.dart';
import 'package:schuldaten_hub/common/theme/app_colors.dart';
import 'package:schuldaten_hub/common/widgets/dialogs/confirmation_dialog.dart';
import 'package:schuldaten_hub/features/attendance/domain/attendance_manager.dart';
import 'package:schuldaten_hub/features/attendance/domain/models/missed_class.dart';
import 'package:schuldaten_hub/features/attendance/presentation/widgets/attendance_badges.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_proxy.dart';

class MissedClassCard extends StatelessWidget {
  final PupilProxy pupil;
  final MissedClass missedClass;
  const MissedClassCard(
      {required this.pupil, required this.missedClass, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      color: AppColors.cardInCardColor,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: GestureDetector(
          onTap: () {
            //- TO-DO: change missed class function
          },
          onLongPress: () async {
            bool? confirm = await confirmationDialog(
                context: context,
                title: 'Fehlzeit löschen',
                message: 'Die Fehlzeit löschen?');
            if (confirm != true) return;
            await locator<AttendanceManager>()
                .deleteMissedClass(pupil.internalId, missedClass.missedDay);

            locator<NotificationService>()
                .showSnackBar(NotificationType.success, 'Fehlzeit gelöscht!');
          },
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('dd.MM.yyyy')
                        .format(missedClass.missedDay)
                        .toString(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const Gap(5),
                  missedTypeBadge(missedClass.missedType),
                  const Gap(3),
                  excusedBadge(missedClass.unexcused),
                  const Gap(3),
                  contactedDayBadge(missedClass.contacted),
                  const Gap(3),
                  returnedBadge(missedClass.backHome),
                  const Spacer(),
                  Text(
                    missedClass.createdBy,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const Gap(5),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (missedClass.missedType == MissedType.isLate.value)
                    Row(
                      children: [
                        const Text('Verspätung:'),
                        const Gap(5),
                        Text('${missedClass.minutesLate ?? 0} min',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const Gap(5),
                      ],
                    ),
                  if (missedClass.backHome == true) ...[
                    RichText(
                        text: TextSpan(
                      text: 'abgeholt um: ',
                      style: DefaultTextStyle.of(context).style,
                      children: <TextSpan>[
                        TextSpan(
                            text: missedClass.backHomeAt,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    )),
                  ]
                ],
              ),
              const Gap(5),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text('Kommentar:'),
                  const Gap(5),
                  Text(
                    missedClass.comment ?? 'kein Eintrag',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  // TO-DO: check why no modifiedBy values are stored
                  if (missedClass.modifiedBy != null)
                    const Text('zuletzt geändert von: '),
                  if (missedClass.modifiedBy != null)
                    Text(
                      missedClass.modifiedBy!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
