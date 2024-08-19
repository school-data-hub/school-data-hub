import 'package:flutter/material.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';

import 'package:schuldaten_hub/features/users/models/user.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/widgets/generic_app_bar.dart';
import 'package:schuldaten_hub/features/users/pages/users_list_page/widgets/users_list_page_bottom_navbar.dart';
import 'package:schuldaten_hub/features/users/services/user_manager.dart';
import 'package:watch_it/watch_it.dart';

class UsersListPage extends WatchingWidget {
  const UsersListPage({super.key});

  @override
  Widget build(BuildContext context) {
    List<User> users = watchValue((UserManager x) => x.users);
    return Scaffold(
      backgroundColor: canvasColor,
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
                return Card(
                  color: Colors.white,
                  child: ListTile(
                    title: GestureDetector(
                        onLongPress: () async {
                          await locator<UserManager>().deleteUser(users[index]);
                        },
                        child: Text(users[index].name)),
                    subtitle: Text(users[index].timeUnits.toString()),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: usersListPageBottomNavBar(context),
    );
  }
}
