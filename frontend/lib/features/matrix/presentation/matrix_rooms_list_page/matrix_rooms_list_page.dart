import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/theme/app_colors.dart';
import 'package:schuldaten_hub/common/theme/styles.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/widgets/list_view_components/generic_sliver_list.dart';
import 'package:schuldaten_hub/features/matrix/domain/filters/matrix_policy_filter_manager.dart';
import 'package:schuldaten_hub/features/matrix/domain/models/matrix_room.dart';
import 'package:schuldaten_hub/features/matrix/presentation/matrix_rooms_list_page/widgets/room_list_card.dart';
import 'package:schuldaten_hub/features/matrix/presentation/matrix_rooms_list_page/widgets/room_list_searchbar.dart';
import 'package:schuldaten_hub/features/matrix/presentation/matrix_rooms_list_page/widgets/room_list_view_bottom_navbar.dart';
import 'package:schuldaten_hub/features/matrix/domain/matrix_policy_manager.dart';
import 'package:watch_it/watch_it.dart';

class RoomListPage extends WatchingWidget {
  const RoomListPage({super.key});

  @override
  Widget build(BuildContext context) {
    List<MatrixRoom> matrixRooms =
        watchValue((MatrixPolicyFilterManager x) => x.filteredMatrixRooms);

    return Scaffold(
      backgroundColor: AppColors.canvasColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: AppColors.backgroundColor,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_rounded,
              size: 25,
              color: Colors.white,
            ),
            Gap(10),
            Text(
              'Matrix-Räume',
              style: AppStyles.appBarTextStyle,
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async =>
            locator<MatrixPolicyManager>().fetchMatrixPolicy(),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: CustomScrollView(
              slivers: [
                const SliverGap(5),
                SliverAppBar(
                  pinned: false,
                  floating: true,
                  scrolledUnderElevation: null,
                  automaticallyImplyLeading: false,
                  leading: const SizedBox.shrink(),
                  backgroundColor: Colors.transparent,
                  collapsedHeight: 110,
                  expandedHeight: 110.0,
                  stretch: false,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.only(
                        left: 5, top: 5, right: 5, bottom: 5),
                    collapseMode: CollapseMode.none,
                    title: RoomListSearchBar(matrixRooms: matrixRooms),
                  ),
                ),
                GenericSliverListWithEmptyListCheck(
                  items: matrixRooms,
                  itemBuilder: (_, room) => RoomListCard(room),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const RoomListPageBottomNavBar(),
    );
  }
}
