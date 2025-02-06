import 'package:flutter/material.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/theme/app_colors.dart';
import 'package:schuldaten_hub/common/widgets/list_view_components/generic_app_bar.dart';
import 'package:schuldaten_hub/features/users/domain/models/user.dart';
import 'package:schuldaten_hub/features/users/domain/user_manager.dart';
import 'package:schuldaten_hub/features/users/presentation/users_list_page/widgets/user_list_card.dart';
import 'package:schuldaten_hub/features/users/presentation/users_list_page/widgets/users_list_page_bottom_navbar.dart';
import 'package:watch_it/watch_it.dart';

class UsersListPage extends WatchingWidget {
  const UsersListPage({super.key});

  @override
  Widget build(BuildContext context) {
    List<User> users = watchValue((UserManager x) => x.users);
    return Scaffold(
      backgroundColor: AppColors.canvasColor,
      appBar: const GenericAppBar(
          iconData: Icons.manage_accounts_rounded, title: 'MPT-Konten'),
      body: RefreshIndicator(
        onRefresh: () async => locator<UserManager>().fetchUsers(),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (BuildContext context, int index) {
                return UserListCard(passedUser: users[index]);
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: usersListPageBottomNavBar(context),
    );
  }
}
