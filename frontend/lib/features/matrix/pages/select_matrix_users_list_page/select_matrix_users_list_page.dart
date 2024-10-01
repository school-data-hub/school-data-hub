import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/constants/styles.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/features/matrix/models/matrix_user.dart';
import 'package:schuldaten_hub/features/matrix/pages/select_matrix_users_list_page/controller/select_matrix_users_list_controller.dart';
import 'package:schuldaten_hub/features/matrix/pages/select_matrix_users_list_page/widgets/select_matrix_user_list_card.dart';
import 'package:schuldaten_hub/features/matrix/pages/select_matrix_users_list_page/widgets/select_matrix_users_filter_bottom_sheet.dart';
import 'package:schuldaten_hub/features/matrix/pages/select_matrix_users_list_page/widgets/select_matrix_users_list_searchbar.dart';
import 'package:schuldaten_hub/features/matrix/pages/select_matrix_users_list_page/widgets/select_matrix_users_list_view_bottom_navbar.dart';

import 'package:schuldaten_hub/features/pupil/filters/pupil_filter_manager.dart';
import 'package:schuldaten_hub/features/pupil/services/pupil_manager.dart';
import 'package:watch_it/watch_it.dart';

class SelectMatrixUsersListPage extends WatchingWidget {
  final SelectMatrixUsersListController controller;
  final List<MatrixUser> filteredPupilsInLIst;
  const SelectMatrixUsersListPage(this.controller, this.filteredPupilsInLIst,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: canvasColor,
      appBar: AppBar(
        leading: controller.isSelectMode
            ? IconButton(
                onPressed: () {
                  controller.cancelSelect();
                },
                icon: const Icon(Icons.close))
            : null,
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: backgroundColor,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Kind/Kinder auswählen', style: appBarTextStyle),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => locator<PupilManager>().fetchAllPupils(),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
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
                      background: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SelectUserListSearchBar(
                            matrixUsers: filteredPupilsInLIst,
                            controller: controller),
                      ),
                    ),
                  ),
                  filteredPupilsInLIst.isEmpty
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
                              return SelectMatrixUserCard(
                                  controller, filteredPupilsInLIst[index]);
                            },
                            childCount: filteredPupilsInLIst.length,
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar:
          SelectMatrixUsersListPageBottomNavBar(controller: controller),
    );
  }
}
