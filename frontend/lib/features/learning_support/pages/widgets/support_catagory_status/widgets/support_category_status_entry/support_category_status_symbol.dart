import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:schuldaten_hub/features/learning_support/models/support_category/support_category_status.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';

Widget getSupportCategoryStatusSymbol(
    PupilProxy pupil, int goalCategoryId, String statusId) {
  if (pupil.supportCategoryStatuses!.isNotEmpty) {
    final SupportCategoryStatus categoryStatus = pupil.supportCategoryStatuses!
        .firstWhere((element) =>
            element.supportCategoryId == goalCategoryId &&
            element.statusId == statusId);

    switch (categoryStatus.state) {
      case 'none':
        return SizedBox(width: 50, child: Image.asset('assets/growth_1-4.png'));
      case 'green':
        return SizedBox(width: 50, child: Image.asset('assets/growth_4-4.png'));
      case 'yellow':
        return SizedBox(width: 50, child: Image.asset('assets/growth_3-4.png'));
      case 'red':
        return SizedBox(width: 50, child: Image.asset('assets/growth_2-4.png'));
    }
    return SizedBox(width: 50, child: Image.asset('assets/growth_1-4.png'));
  }

  return SizedBox(width: 50, child: Image.asset('assets/growth_1-4.png'));
}

Widget getLastCategoryStatusSymbol(PupilProxy pupil, int goalCategoryId) {
  if (pupil.supportCategoryStatuses!.isNotEmpty) {
    final SupportCategoryStatus? categoryStatus = pupil.supportCategoryStatuses!
        .lastWhereOrNull(
            (element) => element.supportCategoryId == goalCategoryId);

    if (categoryStatus != null) {
      switch (categoryStatus.state) {
        case 'none':
          return SizedBox(
              width: 50, child: Image.asset('assets/growth_1-4.png'));
        case 'green':
          return SizedBox(
              width: 50, child: Image.asset('assets/growth_4-4.png'));
        case 'yellow':
          return SizedBox(
              width: 50, child: Image.asset('assets/growth_3-4.png'));
        // case 'orange':
        //   return Colors.orange;
        case 'red':
          return SizedBox(
              width: 50, child: Image.asset('assets/growth_2-4.png'));
      }
    }
    return SizedBox(width: 50, child: Image.asset('assets/growth_1-4.png'));
  }

  return SizedBox(width: 40, child: Image.asset('assets/growth_1-4.png'));
}
