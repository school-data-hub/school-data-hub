import 'package:flutter/material.dart';
import 'package:schuldaten_hub/common/theme/colors.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/features/schooldays/domain/schoolday_manager.dart';

Future<DateTime?> selectSchooldayDate(
    BuildContext context, DateTime thisDate) async {
  List<DateTime> availableDates =
      locator<SchooldayManager>().availableDates.value;
  bool selectableSchooldayDates(DateTime day) {
    dynamic validDate = availableDates.contains(day);
    return validDate;
  }

  if (!availableDates.contains(thisDate)) {
    thisDate = availableDates.last;
  }
  final DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: thisDate,
    selectableDayPredicate: selectableSchooldayDates,
    firstDate: DateTime(2020),
    lastDate: DateTime(2025),
    builder: (context, child) {
      return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.backgroundColor,
              onPrimary: Color.fromARGB(255, 241, 241, 241),
              onSurface: Colors.deepPurple,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accentColor, // button text color
              ),
            ),
          ),
          child: child!);
    },
  );
  if (pickedDate != null) {
    return pickedDate;
  }
  return thisDate;
}
