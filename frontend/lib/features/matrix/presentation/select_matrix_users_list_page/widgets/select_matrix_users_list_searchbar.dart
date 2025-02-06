import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/domain/models/enums.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/theme/app_colors.dart';
import 'package:schuldaten_hub/features/pupil/presentation/widgets/pupil_search_text_field.dart';
import 'package:schuldaten_hub/features/matrix/domain/filters/matrix_policy_filter_manager.dart';
import 'package:schuldaten_hub/features/matrix/domain/models/matrix_user.dart';
import 'package:schuldaten_hub/features/matrix/presentation/select_matrix_users_list_page/controller/select_matrix_users_list_controller.dart';
import 'package:watch_it/watch_it.dart';

class SelectUserListSearchBar extends WatchingWidget {
  final List<MatrixUser> matrixUsers;
  final SelectMatrixUsersListController controller;
  const SelectUserListSearchBar(
      {required this.matrixUsers, required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    final bool filtersOn =
        watchValue((MatrixPolicyFilterManager x) => x.filtersOn);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.canvasColor,
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
                    Icons.meeting_room_rounded,
                    color: AppColors.backgroundColor,
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
                  const Text(
                    'Ausgewählt:',
                    style: TextStyle(
                      fontSize: 13,
                    ),
                  ),
                  const Gap(10),
                  Text(
                    controller.selectedUsers.length.toString(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
            child: Row(
              children: [
                Expanded(
                    child: PupilSearchTextField(
                        searchType: SearchType.room,
                        hintText: 'Matrix-Konto suchen',
                        refreshFunction: locator<MatrixPolicyFilterManager>()
                            .setUsersFilterText)),
                InkWell(
                  onTap: () => {},
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
