import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/widgets/bottom_nav_bar_layouts.dart';
import 'package:schuldaten_hub/features/matrix/filters/matrix_policy_filter_manager.dart';
import 'package:schuldaten_hub/features/matrix/pages/matrix_users_list_page/matrix_users_list_page.dart';
import 'package:schuldaten_hub/features/matrix/pages/room_list_page/widgets/rooms_filter_bottom_sheet.dart';

class RoomListPageBottomNavBar extends StatelessWidget {
  final bool filtersOn;
  const RoomListPageBottomNavBar({required this.filtersOn, super.key});

  @override
  Widget build(BuildContext context) {
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
                const Gap(30),
                IconButton(
                  tooltip: 'Neuer Raum',
                  icon: const Icon(
                    Icons.add,
                    size: 30,
                  ),
                  onPressed: () {
                    // Navigator.of(context).push(MaterialPageRoute(
                    //   builder: (ctx) => const MatrixUsersList(),
                    // ));
                  },
                ),
                const Gap(30),
                IconButton(
                  tooltip: 'Matrix-Konten',
                  icon: const Icon(
                    Icons.people_alt_rounded,
                    size: 30,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) => const MatrixUsersListPage(),
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
                  onTap: () => showRoomsFilterBottomSheet(context),
                  onLongPress: () => locator<MatrixPolicyFilterManager>()
                      .resetAllMatrixFilters(),
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
