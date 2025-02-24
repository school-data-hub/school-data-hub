import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/domain/models/enums.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_service.dart';
import 'package:schuldaten_hub/common/theme/app_colors.dart';
import 'package:schuldaten_hub/common/utils/logger.dart';
import 'package:schuldaten_hub/common/widgets/avatar.dart';
import 'package:schuldaten_hub/common/widgets/dialogs/long_textfield_dialog.dart';
import 'package:schuldaten_hub/features/attendance/domain/attendance_helper_functions.dart';
import 'package:schuldaten_hub/features/attendance/domain/attendance_manager.dart';
import 'package:schuldaten_hub/features/attendance/presentation/attendance_page/widgets/attendance_dropdown_menu_items.dart';
import 'package:schuldaten_hub/features/attendance/presentation/attendance_page/widgets/dialogues/late_in_minutes_dialog.dart';
import 'package:schuldaten_hub/features/attendance/presentation/attendance_page/widgets/dialogues/multiple_entries_dialog.dart';
import 'package:schuldaten_hub/features/attendance/presentation/attendance_page/widgets/dialogues/returned_time_picker.dart';
import 'package:schuldaten_hub/features/main_menu/widgets/landing_bottom_nav_bar.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_proxy.dart';
import 'package:schuldaten_hub/features/pupil/presentation/pupil_profile_page/pupil_profile_page.dart';
import 'package:watch_it/watch_it.dart';

class AttendanceCard extends WatchingWidget {
  final PupilProxy passedPupil;
  final DateTime thisDate;
  const AttendanceCard(this.passedPupil, this.thisDate, {super.key});
  @override
  Widget build(BuildContext context) {
    PupilProxy pupil = watch(passedPupil);

    final attendanceManager = locator<AttendanceManager>();
    DateTime thisDate = this.thisDate;
    AttendanceValues attendanceInfo =
        AttendanceHelper.setAttendanceValues(passedPupil.internalId, thisDate);

    //- TODO: This widget is a mess, should be refactored!

    if (Platform.isAndroid) {
      return Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Card(
          color: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 1.0,
          margin: const EdgeInsets.only(
              left: 4.0, right: 4.0, top: 4.0, bottom: 4.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AvatarWithBadges(pupil: pupil, size: 80),
                  Expanded(
                    child: GestureDetector(
                      onLongPress: () => createMissedClassList(context, pupil),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (ctx) => PupilProfilePage(
                            pupil: pupil,
                          ),
                        ));
                      },
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Gap(10),
                            Row(
                              children: [
                                Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: InkWell(
                                      onTap: () {
                                        locator<MainMenuBottomNavManager>()
                                            .setPupilProfileNavPage(3);
                                        Navigator.of(context)
                                            .pushReplacement(MaterialPageRoute(
                                          builder: (ctx) => PupilProfilePage(
                                            pupil: pupil,
                                          ),
                                        ));
                                      },
                                      child: Text(
                                        '${pupil.firstName} ${pupil.lastName}',
                                        overflow: TextOverflow.fade,
                                        softWrap: false,
                                        textAlign: TextAlign.left,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Gap(20),
                                DropdownButtonHideUnderline(
                                  child: DropdownButton<MissedType>(
                                    icon: const Visibility(
                                        visible: false,
                                        child: Icon(Icons.arrow_downward)),
                                    onTap: () {
                                      FocusManager.instance.primaryFocus!
                                          .unfocus();
                                    },
                                    value: attendanceInfo.missedTypeValue,
                                    items: missedTypeMenuItems,
                                    onChanged: (newValue) async {
                                      FocusManager.instance.primaryFocus!
                                          .unfocus();
                                      if (attendanceInfo.missedTypeValue ==
                                          newValue) {
                                        return;
                                      }
                                      if (newValue == MissedType.isLate) {
                                        final int minutesLate =
                                            await minutesLateDialog(context);
                                        attendanceManager.changeLateTypeValue(
                                            pupil.internalId,
                                            newValue!,
                                            thisDate,
                                            minutesLate);
                                      } else {
                                        attendanceManager.changeMissedTypeValue(
                                            pupil.internalId,
                                            newValue!,
                                            thisDate);
                                      }
                                    },
                                  ),
                                ),
                                const Gap(8),
                                Checkbox(
                                  checkColor: Colors.white,
                                  activeColor: AppColors.excusedCheckColor,
                                  value: attendanceInfo.unexcusedValue,
                                  onChanged: (bool? newvalue) {
                                    attendanceManager.changeExcusedValue(
                                        pupil.internalId, thisDate, newvalue!);
                                  },
                                ),
                                const Gap(4),
                                (attendanceInfo.missedTypeValue ==
                                                MissedType.isMissed &&
                                            attendanceInfo.unexcusedValue ==
                                                true) ||
                                        attendanceInfo.contactedTypeValue !=
                                            ContactedType.notSet ||
                                        attendanceInfo.returnedValue == true
                                    ? DropdownButtonHideUnderline(
                                        child: DropdownButton<ContactedType>(
                                            icon: const Visibility(
                                                visible: false,
                                                child:
                                                    Icon(Icons.arrow_downward)),
                                            onTap: () {
                                              FocusManager
                                                  .instance.primaryFocus!
                                                  .unfocus();
                                            },
                                            value: attendanceInfo
                                                .contactedTypeValue,
                                            items: dropdownContactedMenuItems,
                                            onChanged: (newValue) {
                                              if (attendanceInfo
                                                          .contactedTypeValue ==
                                                      newValue ||
                                                  attendanceInfo
                                                          .unexcusedValue ==
                                                      false) {
                                                return;
                                              }
                                              attendanceManager
                                                  .changeContactedValue(
                                                      pupil.internalId,
                                                      newValue!,
                                                      thisDate);
                                            }),
                                      )
                                    : Container(
                                        height: 45,
                                        width: 30,
                                        decoration: const BoxDecoration(
                                            color: Colors.white),
                                      ),
                                const Gap(4),
                                Checkbox(
                                  checkColor: Colors.white,
                                  activeColor: AppColors.goneHomeColor,
                                  value: attendanceInfo.returnedValue,
                                  onChanged: (bool? newValue) async {
                                    if (attendanceInfo.missedTypeValue ==
                                        MissedType.isMissed) {
                                      return;
                                    }
                                    if (newValue == true) {
                                      final String? returnedTime =
                                          await returnedDayTime(context);
                                      logger.i('returned time : $returnedTime');
                                      if (returnedTime == null) {
                                        return;
                                      }
                                      attendanceManager.changeReturnedValue(
                                          pupil.internalId,
                                          newValue!,
                                          thisDate,
                                          returnedTime);
                                      return;
                                    }
                                    attendanceManager.changeReturnedValue(
                                        pupil.internalId,
                                        newValue!,
                                        thisDate,
                                        null);
                                  },
                                ),
                              ],
                            ),
                            Row(children: [
                              SizedBox(
                                width: 70,
                                child: Center(
                                  child:
                                      attendanceInfo.createdOrModifiedByValue !=
                                              null
                                          ? Text(
                                              attendanceInfo
                                                  .createdOrModifiedByValue!,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            )
                                          : const SizedBox.shrink(),
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 25.0,
                                    height: 25.0,
                                    decoration: const BoxDecoration(
                                      color: AppColors.excusedCheckColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'U',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  const Gap(18),
                                  Container(
                                    width: 25.0,
                                    height: 25.0,
                                    decoration: BoxDecoration(
                                      color: Colors.red[900],
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'K',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  const Gap(19),
                                  Container(
                                    width: 25.0,
                                    height: 25.0,
                                    decoration: const BoxDecoration(
                                      color: AppColors.homeColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'H',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ]),
                            const Gap(15),
                          ]),
                    ),
                  ),
                ],
              ),
              if (attendanceInfo.missedTypeValue !=
                  MissedType.notSet) ...<Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Gap(10),
                    const Text('Kommentar:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const Gap(10),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final String? commentValue =
                              await longTextFieldDialog(
                            title: 'Kommentar eintragen',
                            labelText: 'Kommentar',
                            textinField: null,
                            parentContext: context,
                          );
                          if (commentValue == null ||
                              commentValue.isEmpty ||
                              commentValue == attendanceInfo.commentValue) {
                            return;
                          }
                          attendanceManager.changeCommentValue(
                            pupil.internalId,
                            commentValue,
                            thisDate,
                          );
                        },
                        child: Text(
                          attendanceInfo.commentValue ?? 'Kein Kommentar',
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    )
                  ],
                ),
                const Gap(10),
              ],
            ],
          ),
        ),
      );
    } else {
      return Card(
        color: Colors.white,
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
                AvatarWithBadges(pupil: pupil, size: 80),
                Expanded(
                  child: GestureDetector(
                    onLongPress: () => createMissedClassList(context, pupil),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (ctx) => PupilProfilePage(
                          pupil: pupil,
                        ),
                      ));
                    },
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Gap(15),
                          Row(
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: InkWell(
                                    onTap: () {
                                      locator<MainMenuBottomNavManager>()
                                          .setPupilProfileNavPage(3);
                                      Navigator.of(context)
                                          .pushReplacement(MaterialPageRoute(
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  const Gap(2),
                                  DropdownButtonHideUnderline(
                                    child: DropdownButton<MissedType>(
                                      icon: const Visibility(
                                          visible: false,
                                          child: Icon(Icons.arrow_downward)),
                                      onTap: () {
                                        FocusManager.instance.primaryFocus!
                                            .unfocus();
                                      },
                                      value: attendanceInfo.missedTypeValue,
                                      items: missedTypeMenuItems,
                                      onChanged: (newValue) async {
                                        FocusManager.instance.primaryFocus!
                                            .unfocus();
                                        if (attendanceInfo.missedTypeValue ==
                                            newValue) {
                                          return;
                                        }
                                        if (newValue == MissedType.isMissed &&
                                            attendanceInfo.returnedValue ==
                                                true) {
                                          locator<NotificationService>()
                                              .showSnackBar(
                                                  NotificationType.error,
                                                  'Ein Kind, das abgeholt wurde, gilt nicht als fehlend für den Tag!');

                                          return;
                                        }
                                        if (newValue == MissedType.isLate) {
                                          final int minutesLate =
                                              await minutesLateDialog(context);
                                          attendanceManager.changeLateTypeValue(
                                              pupil.internalId,
                                              newValue!,
                                              thisDate,
                                              minutesLate);
                                        } else {
                                          attendanceManager
                                              .changeMissedTypeValue(
                                                  pupil.internalId,
                                                  newValue!,
                                                  thisDate);
                                        }
                                      },
                                    ),
                                  ),
                                  //const Gap(20),
                                  SizedBox(
                                    width: 50,
                                    child: Center(
                                      child: attendanceInfo
                                                  .createdOrModifiedByValue !=
                                              null
                                          ? Text(
                                              attendanceInfo
                                                  .createdOrModifiedByValue!,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            )
                                          : const SizedBox.shrink(),
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(10),
                              Column(
                                children: [
                                  const Gap(10),
                                  Checkbox(
                                    checkColor: Colors.white,
                                    activeColor: AppColors.excusedCheckColor,
                                    value: attendanceInfo.unexcusedValue,
                                    onChanged: (bool? newvalue) {
                                      attendanceManager.changeExcusedValue(
                                          pupil.internalId,
                                          thisDate,
                                          newvalue!);
                                    },
                                  ),
                                  const Gap(8),
                                  Container(
                                    width: 20.0,
                                    height: 20.0,
                                    decoration: const BoxDecoration(
                                      color: AppColors.excusedCheckColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'U',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(5),
                              Column(children: [
                                (attendanceInfo.missedTypeValue ==
                                                MissedType.isMissed &&
                                            attendanceInfo.unexcusedValue ==
                                                true) ||
                                        attendanceInfo.contactedTypeValue !=
                                            ContactedType.notSet ||
                                        attendanceInfo.returnedValue == true
                                    ? DropdownButtonHideUnderline(
                                        child: DropdownButton<ContactedType>(
                                            icon: const Visibility(
                                                visible: false,
                                                child:
                                                    Icon(Icons.arrow_downward)),
                                            onTap: () {
                                              FocusManager
                                                  .instance.primaryFocus!
                                                  .unfocus();
                                            },
                                            value: attendanceInfo
                                                .contactedTypeValue,
                                            items: dropdownContactedMenuItems,
                                            onChanged: (newValue) {
                                              if (attendanceInfo
                                                          .contactedTypeValue ==
                                                      newValue ||
                                                  attendanceInfo
                                                          .unexcusedValue ==
                                                      false) {
                                                return;
                                              }
                                              attendanceManager
                                                  .changeContactedValue(
                                                      pupil.internalId,
                                                      newValue!,
                                                      thisDate);
                                            }),
                                      )
                                    : Container(
                                        height: 48,
                                        width: 30,
                                        decoration: const BoxDecoration(
                                            color: Colors.white),
                                      ),
                                const Gap(2),
                                Container(
                                  width: 20.0,
                                  height: 20.0,
                                  decoration: BoxDecoration(
                                    color: Colors.red[900],
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'K',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              ]),
                              const Gap(5),
                              Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Gap(10),
                                    Checkbox(
                                      checkColor: Colors.white,
                                      activeColor: AppColors.goneHomeColor,
                                      value: attendanceInfo.returnedValue,
                                      onChanged: (bool? newValue) async {
                                        if (newValue == true) {
                                          if (attendanceInfo.missedTypeValue ==
                                              MissedType.isMissed) {
                                            locator<NotificationService>()
                                                .showSnackBar(
                                                    NotificationType.error,
                                                    'Ein fehlendes Kind kann nicht abgeholt werden!');
                                            return;
                                          }
                                          final String? returnedTime =
                                              await returnedDayTime(context);

                                          if (returnedTime == null) {
                                            return;
                                          }
                                          attendanceManager.changeReturnedValue(
                                              pupil.internalId,
                                              newValue!,
                                              thisDate,
                                              returnedTime);
                                          return;
                                        }
                                        attendanceManager.changeReturnedValue(
                                            pupil.internalId,
                                            newValue!,
                                            thisDate,
                                            null);
                                      },
                                    ),
                                    const Gap(8),
                                    Container(
                                      width: 20.0,
                                      height: 20.0,
                                      decoration: const BoxDecoration(
                                        color: AppColors.homeColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'H',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ]),
                            ],
                          ),
                          const Gap(15),
                        ]),
                  ),
                ),
              ],
            ),
            if (attendanceInfo.missedTypeValue != MissedType.notSet ||
                attendanceInfo.returnedValue) ...<Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Gap(10),
                  const Text('Kommentar:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Gap(10),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final String? commentValue = await longTextFieldDialog(
                            title: 'Kommentar',
                            labelText: 'Kommentar',
                            textinField: attendanceInfo.commentValue,
                            parentContext: context);
                        if (commentValue == attendanceInfo.commentValue) {
                          return;
                        }

                        attendanceManager.changeCommentValue(
                          pupil.internalId,
                          commentValue ?? '',
                          thisDate,
                        );
                      },
                      child: Text(
                        attendanceInfo.commentValue == null ||
                                attendanceInfo.commentValue!.isEmpty
                            ? 'Kein Eintrag'
                            : attendanceInfo.commentValue!,
                        softWrap: true,
                      ),
                    ),
                  )
                ],
              ),
              const Gap(10),
            ],
          ],
        ),
      );
    }
  }
}
