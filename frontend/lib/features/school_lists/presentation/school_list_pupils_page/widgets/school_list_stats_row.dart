import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/theme/app_colors.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_proxy.dart';
import 'package:schuldaten_hub/features/school_lists/domain/models/school_list.dart';
import 'package:schuldaten_hub/features/school_lists/domain/school_list_helper_functions.dart';

Widget schoolListStatsRow(SchoolList schoolList, List<PupilProxy> pupils) {
  final Map<String, int> stats = SchoolListHelper.schoolListStats(
    schoolList,
    pupils,
  );
  return Row(
    children: [
      const Icon(
        Icons.people_alt_rounded,
        color: AppColors.backgroundColor,
      ),
      const Gap(10),
      Text(
        pupils.length.toString(),
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      const Gap(10),
      const Icon(
        Icons.close,
        color: Colors.red,
      ),
      const Gap(5),
      Text(
        stats['no'].toString(),
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      const Gap(10),
      const Icon(
        Icons.done,
        color: Colors.green,
      ),
      const Gap(5),
      Text(
        stats['yes'].toString(),
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      const Gap(10),
      const Icon(
        Icons.question_mark_rounded,
        color: AppColors.accentColor,
      ),
      const Gap(5),
      Text(
        stats['null'].toString(),
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      const Gap(10),
      const Icon(
        Icons.create,
        color: AppColors.backgroundColor,
      ),
      const Gap(5),
      Text(
        stats['comment'].toString(),
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    ],
  );
}
