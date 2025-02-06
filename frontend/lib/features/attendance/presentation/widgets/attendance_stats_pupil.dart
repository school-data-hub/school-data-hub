import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/features/attendance/domain/attendance_helper_functions.dart';
import 'package:schuldaten_hub/features/attendance/presentation/widgets/attendance_badges.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_proxy.dart';

Widget attendanceStats(PupilProxy pupil) {
  return Row(
    children: [
      excusedBadge(false),
      const Gap(3),
      Text(
        AttendanceHelper.missedclassSum(pupil).toString(),
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      const Gap(5),
      excusedBadge(true),
      const Gap(3),
      Text(
        AttendanceHelper.missedclassUnexcusedSum(pupil).toString(),
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      const Gap(5),
      missedTypeBadge('late'),
      const Gap(3),
      Text(
        AttendanceHelper.lateUnexcusedSum(pupil).toString(),
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      const Gap(5),
      contactedBadge(1),
      const Gap(3),
      Text(
        AttendanceHelper.contactedSum(pupil).toString(),
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      const Gap(5),
      returnedBadge(true),
      const Gap(3),
      Text(
        AttendanceHelper.goneHomeSum(pupil).toString(),
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    ],
  );
}
