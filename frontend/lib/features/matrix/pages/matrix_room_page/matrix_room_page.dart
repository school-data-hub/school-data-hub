import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/widgets/generic_app_bar.dart';
import 'package:schuldaten_hub/common/widgets/sliver_search_app_bar.dart';
import 'package:schuldaten_hub/features/matrix/filters/matrix_policy_filter_manager.dart';
import 'package:schuldaten_hub/features/matrix/models/matrix_room.dart';
import 'package:schuldaten_hub/features/matrix/models/matrix_user.dart';
import 'package:schuldaten_hub/features/matrix/pages/matrix_users_list_page/widgets/matrix_user_list_card.dart';
import 'package:schuldaten_hub/features/matrix/pages/matrix_users_list_page/widgets/matrix_user_list_searchbar.dart';
import 'package:schuldaten_hub/features/matrix/pages/matrix_users_list_page/widgets/matrix_users_list_view_bottom_navbar.dart';
import 'package:schuldaten_hub/features/matrix/services/matrix_policy_manager.dart';
import 'package:schuldaten_hub/features/matrix/services/matrix_room_helpers.dart';
import 'package:watch_it/watch_it.dart';

class MatrixRoomPage extends WatchingWidget {
  final MatrixRoom matrixRoom;
  const MatrixRoomPage({required this.matrixRoom, super.key});

  @override
  Widget build(BuildContext context) {
    List<MatrixUser> matrixUsers =
        watchValue((MatrixPolicyManager x) => x.matrixUsers);
    List<MatrixUser> filteredMatrixUsers =
        watchValue((MatrixPolicyFilterManager x) => x.filteredMatrixUsers);
    final List<MatrixUser> matrixUsersInRoom = filteredMatrixUsers
        .where((user) =>
            MatrixRoomHelper.usersInRoom(matrixRoom.id).contains(user))
        .toList();

    return Scaffold(
      appBar: GenericAppBar(iconData: Icons.room, title: matrixRoom.name!),
      body: RefreshIndicator(
        onRefresh: () async =>
            locator<MatrixPolicyManager>().fetchMatrixPolicy(),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: CustomScrollView(
              slivers: [
                const SliverGap(5),
                SliverSearchAppBar(
                    title: MatrixUsersListSearchBar(
                        matrixUsers: matrixUsersInRoom),
                    height: 110),
                matrixUsers.isEmpty
                    ? const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Keine Ergebnisse',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            // Your list view items go here
                            return MatrixUsersListCard(
                                matrixUsersInRoom[index]);
                          },
                          childCount: matrixUsersInRoom
                              .length, // Adjust this based on your data
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const MatrixUsersListViewBottomNavbar(),
    );
  }
}
