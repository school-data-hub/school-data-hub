import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/constants/enums.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/widgets/matrix_search_text_field.dart';
import 'package:schuldaten_hub/features/matrix/models/matrix_user.dart';
import 'package:schuldaten_hub/features/matrix/filters/matrix_policy_filter_manager.dart';

import 'package:schuldaten_hub/features/credit/credit_list_page/widgets/credit_filter_bottom_sheet.dart';
import 'package:watch_it/watch_it.dart';

class MatrixUsersListSearchBar extends WatchingWidget {
  final List<MatrixUser> matrixUsers;

  const MatrixUsersListSearchBar({required this.matrixUsers, super.key});

  @override
  Widget build(BuildContext context) {
    bool filtersOn = watchValue((MatrixPolicyFilterManager x) => x.filtersOn);
    return Container(
      decoration: BoxDecoration(
        color: canvasColor,
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Column(
        children: [
          const Gap(5),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.people_alt_rounded,
                    color: backgroundColor,
                  ),
                  const Gap(10),
                  Text(
                    matrixUsers.length.toString(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const Gap(10),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
            child: Row(
              children: [
                Expanded(
                    child: MatrixSearchTextField(
                        searchType: SearchType.matrixUser,
                        hintText: 'Schüler/in suchen',
                        refreshFunction: locator<MatrixPolicyFilterManager>()
                            .setUsersFilterText)),
                InkWell(
                  onTap: () => showCreditFilterBottomSheet(context),
                  onLongPress: () => locator<MatrixPolicyFilterManager>()
                      .resetAllMatrixFilters(),
                  // onPressed: () => showBottomSheetFilters(context),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Icon(
                      Icons.filter_list,
                      color: filtersOn ? Colors.deepOrange : Colors.grey,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
