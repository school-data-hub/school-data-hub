import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/widgets/bottom_nav_bar_layouts.dart';
import 'package:schuldaten_hub/features/credit/credit_list_page/widgets/credit_filter_bottom_sheet.dart';
import 'package:schuldaten_hub/features/matrix/filters/matrix_policy_filter_manager.dart';
import 'package:schuldaten_hub/features/matrix/pages/new_matrix_user_view.dart';
import 'package:schuldaten_hub/features/matrix/pages/room_list_page/room_list_page.dart';
import 'package:schuldaten_hub/features/matrix/services/matrix_policy_manager.dart';
import 'package:watch_it/watch_it.dart';

import '../../../../pupil/filters/pupil_filter_manager.dart';

class MatrixUsersListViewBottomNavbar extends WatchingWidget {
  const MatrixUsersListViewBottomNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    final bool filtersOn =
        watchValue((MatrixPolicyFilterManager x) => x.filtersOn);
    final bool pendingChanges =
        watchValue((MatrixPolicyManager x) => x.pendingChanges);
    return BottomNavBarLayout(
      bottomNavBar: BottomAppBar(
        padding: const EdgeInsets.all(10),
        shape: null,
        color: backgroundColor,
        child: IconTheme(
          data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Row(
              children: [
                const Spacer(),
                IconButton(
                  tooltip: 'zurück',
                  icon: const Icon(
                    Icons.arrow_back,
                    size: 30,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                if (pendingChanges) ...<Widget>[
                  const Gap(30),
                  IconButton(
                    tooltip: 'Änderungen speichern',
                    icon: const Icon(
                      Icons.save,
                      size: 30,
                    ),
                    onPressed: () {
                      locator<MatrixPolicyManager>().putPolicy();
                    },
                  ),
                ],
                const Gap(30),
                IconButton(
                  tooltip: 'neues Matrix-Konto',
                  icon: const Icon(
                    Icons.add,
                    size: 30,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) => const NewMatrixUserView(),
                    ));
                  },
                ),
                const Gap(30),
                IconButton(
                  tooltip: 'Matrix-Räume',
                  icon: const Icon(
                    Icons.meeting_room_rounded,
                    size: 30,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) => const RoomListPage(),
                    ));
                  },
                ),
                const Gap(30),
                IconButton(
                    tooltip: 'Zur Startseite',
                    onPressed: () =>
                        Navigator.popUntil(context, (route) => route.isFirst),
                    icon: const Icon(
                      Icons.home,
                      size: 35,
                    )),
                const Gap(30),
                InkWell(
                  onTap: () => showCreditFilterBottomSheet(context),
                  onLongPress: () =>
                      locator<PupilFilterManager>().resetFilters(),
                  child: Icon(
                    Icons.filter_list,
                    color: filtersOn ? Colors.deepOrange : Colors.white,
                    size: 30,
                  ),
                ),
                const Gap(15)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
