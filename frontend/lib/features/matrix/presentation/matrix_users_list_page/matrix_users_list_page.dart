import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/theme/colors.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/widgets/generic_app_bar.dart';
import 'package:schuldaten_hub/common/widgets/sliver_search_app_bar.dart';
import 'package:schuldaten_hub/features/matrix/domain/filters/matrix_policy_filter_manager.dart';
import 'package:schuldaten_hub/features/matrix/domain/models/matrix_user.dart';
import 'package:schuldaten_hub/features/matrix/presentation/matrix_users_list_page/widgets/matrix_user_list_card.dart';
import 'package:schuldaten_hub/features/matrix/presentation/matrix_users_list_page/widgets/matrix_user_list_searchbar.dart';
import 'package:schuldaten_hub/features/matrix/presentation/matrix_users_list_page/widgets/matrix_users_list_view_bottom_navbar.dart';
import 'package:schuldaten_hub/features/matrix/domain/matrix_policy_manager.dart';
import 'package:watch_it/watch_it.dart';

class MatrixUsersListPage extends WatchingWidget {
  const MatrixUsersListPage({super.key});

  @override
  Widget build(BuildContext context) {
    List<MatrixUser> matrixUsers =
        watchValue((MatrixPolicyFilterManager x) => x.filteredMatrixUsers);

    return Scaffold(
      backgroundColor: AppColors.canvasColor,
      appBar: const GenericAppBar(
          iconData: Icons.chat_rounded, title: 'Matrix-Konten'),
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
                    title: MatrixUsersListSearchBar(matrixUsers: matrixUsers),
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
                            return MatrixUsersListCard(matrixUsers[index]);
                          },
                          childCount: matrixUsers
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
