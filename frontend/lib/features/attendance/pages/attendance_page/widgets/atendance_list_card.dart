import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/constants/enums.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_manager.dart';
import 'package:schuldaten_hub/common/utils/logger.dart';
import 'package:schuldaten_hub/common/widgets/avatar.dart';
import 'package:schuldaten_hub/features/attendance/services/attendance_helper_functions.dart';
import 'package:schuldaten_hub/features/attendance/services/attendance_manager.dart';
import 'package:schuldaten_hub/features/attendance/pages/attendance_page/widgets/attendance_dropdown_menu_items.dart';
import 'package:schuldaten_hub/features/attendance/pages/attendance_page/widgets/dialogues/late_in_minutes_dialog.dart';
import 'package:schuldaten_hub/features/attendance/pages/attendance_page/widgets/dialogues/multiple_entries_dialog.dart';
import 'package:schuldaten_hub/features/attendance/pages/attendance_page/widgets/dialogues/returned_time_picker.dart';
import 'package:schuldaten_hub/features/main_menu_pages/widgets/landing_bottom_nav_bar.dart';
import 'package:schuldaten_hub/features/pupil/services/pupil_manager.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';

import 'package:schuldaten_hub/features/pupil/pages/pupil_profile_page/pupil_profile_page.dart';

import 'package:watch_it/watch_it.dart';

class AttendanceCard extends WatchingWidget {
  final int internalId;
  final DateTime thisDate;
  const AttendanceCard(this.internalId, this.thisDate, {super.key});
  @override
  Widget build(BuildContext context) {
    PupilProxy pupil =
        watch(locator<PupilManager>().findPupilById(internalId)!);

    final attendanceManager = locator<AttendanceManager>();
    DateTime thisDate = this.thisDate;
    AttendanceValues attendanceInfo =
        AttendanceHelper.setAttendanceInfo(internalId, thisDate);
    // MissedType dropdownMissedValue =
    //     AttendanceHelper.setMissedTypeValue(internalId, thisDate);
    // bool? excusedValue = AttendanceHelper.setExcusedValue(internalId, thisDate);
    // ContactedType dropdownContactedValue =
    //     AttendanceHelper.setContactedValue(internalId, thisDate);
    // bool? returnedValue =
    //     AttendanceHelper.setReturnedValue(internalId, thisDate);
    // String? createdModifiedValue(pupilId) {
    //   return AttendanceHelper.setCreatedModifiedValue(pupilId, thisDate);
    // }

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
          child: Row(
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
                                    locator<BottomNavManager>()
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
                                  FocusManager.instance.primaryFocus!.unfocus();
                                },
                                value: attendanceInfo.missedTypeValue,
                                items: missedTypeMenuItems,
                                onChanged: (newValue) async {
                                  FocusManager.instance.primaryFocus!.unfocus();
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
                                        pupil.internalId, newValue!, thisDate);
                                  }
                                },
                              ),
                            ),
                            const Gap(8),
                            Checkbox(
                              checkColor: Colors.white,
                              activeColor: excusedCheckColor,
                              value: attendanceInfo.excusedValue,
                              onChanged: (bool? newvalue) {
                                attendanceManager.changeExcusedValue(
                                    pupil.internalId, thisDate, newvalue!);
                              },
                            ),
                            const Gap(4),
                            (attendanceInfo.missedTypeValue ==
                                            MissedType.isMissed &&
                                        attendanceInfo.excusedValue == true) ||
                                    attendanceInfo.contactedTypeValue !=
                                        ContactedType.notSet ||
                                    attendanceInfo.returnedValue == true
                                ? DropdownButtonHideUnderline(
                                    child: DropdownButton<ContactedType>(
                                        icon: const Visibility(
                                            visible: false,
                                            child: Icon(Icons.arrow_downward)),
                                        onTap: () {
                                          FocusManager.instance.primaryFocus!
                                              .unfocus();
                                        },
                                        value:
                                            attendanceInfo.contactedTypeValue,
                                        items: dropdownContactedMenuItems,
                                        onChanged: (newValue) {
                                          if (attendanceInfo
                                                      .contactedTypeValue ==
                                                  newValue ||
                                              attendanceInfo.excusedValue ==
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
                              activeColor: goneHomeColor,
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
                              child: attendanceInfo.createdOrModifiedByValue !=
                                      null
                                  ? Text(
                                      attendanceInfo.createdOrModifiedByValue!,
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
                                  color: excusedCheckColor,
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
                                  color: homeColor,
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
        child: Row(
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
                                  locator<BottomNavManager>()
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
                                        attendanceInfo.returnedValue == true) {
                                      locator<NotificationManager>().showSnackBar(
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
                                      attendanceManager.changeMissedTypeValue(
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
                            ],
                          ),
                          const Gap(10),
                          Column(
                            children: [
                              const Gap(10),
                              Checkbox(
                                checkColor: Colors.white,
                                activeColor: excusedCheckColor,
                                value: attendanceInfo.excusedValue,
                                onChanged: (bool? newvalue) {
                                  attendanceManager.changeExcusedValue(
                                      pupil.internalId, thisDate, newvalue!);
                                },
                              ),
                              const Gap(8),
                              Container(
                                width: 20.0,
                                height: 20.0,
                                decoration: const BoxDecoration(
                                  color: excusedCheckColor,
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
                                        attendanceInfo.excusedValue == true) ||
                                    attendanceInfo.contactedTypeValue !=
                                        ContactedType.notSet ||
                                    attendanceInfo.returnedValue == true
                                ? DropdownButtonHideUnderline(
                                    child: DropdownButton<ContactedType>(
                                        icon: const Visibility(
                                            visible: false,
                                            child: Icon(Icons.arrow_downward)),
                                        onTap: () {
                                          FocusManager.instance.primaryFocus!
                                              .unfocus();
                                        },
                                        value:
                                            attendanceInfo.contactedTypeValue,
                                        items: dropdownContactedMenuItems,
                                        onChanged: (newValue) {
                                          if (attendanceInfo
                                                      .contactedTypeValue ==
                                                  newValue ||
                                              attendanceInfo.excusedValue ==
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
                                  activeColor: goneHomeColor,
                                  value: attendanceInfo.returnedValue,
                                  onChanged: (bool? newValue) async {
                                    if (newValue == true) {
                                      if (attendanceInfo.missedTypeValue ==
                                          MissedType.isMissed) {
                                        locator<NotificationManager>().showSnackBar(
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
                                    color: homeColor,
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
                      attendanceInfo.missedTypeValue != MissedType.notSet
                          ? Row(
                              children: [
                                Text(attendanceInfo.commentValue ??
                                    'Kein Kommentar')
                              ],
                            )
                          : const SizedBox.shrink(),
                    ]),
              ),
            ),
          ],
        ),
      );
    }
  }
}
