import 'package:flutter/foundation.dart';
import 'package:schuldaten_hub/common/services/session_manager.dart';
import 'package:schuldaten_hub/features/users/services/user_api_service.dart';
import 'package:schuldaten_hub/common/constants/enums.dart';
import 'package:schuldaten_hub/features/users/models/user.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_manager.dart';

class UserManager {
  ValueListenable<List<User>> get users => _users;
  final _users = ValueNotifier<List<User>>([]);

  UserManager();
  Future<UserManager> init() async {
    await fetchUsers();
    return this;
  }

  final userApiService = UserApiService();
  Future<void> fetchUsers() async {
    if (locator<SessionManager>().isAdmin.value == false) {
      return;
    }
    final List<User> responseUsers = await userApiService.getAllUsers();

    // reorder the list alphabetically by the user's name
    responseUsers.sort((a, b) => a.name.compareTo(b.name));
    _users.value = responseUsers;

    return;
  }

  final notificationManager = locator<NotificationManager>();

  Future<void> createUser(
      {required String name,
      required String password,
      required bool isAdmin,
      required int timeUnits,
      required int credit,
      required String contact,
      String? role,
      String? tutoring}) async {
    final User user = await userApiService.postUser(
        name: name,
        password: password,
        isAdmin: isAdmin,
        timeUnits: timeUnits,
        credit: credit,
        contact: contact,
        role: role,
        tutoring: tutoring);
    addUser(user);

    notificationManager.showSnackBar(
        NotificationType.success, 'User erstellt!');
    return;
  }

  Future<void> deleteUser(User user) async {
    await userApiService.deleteUser(user.publicId);
    removeUser(user);
    notificationManager.showSnackBar(
        NotificationType.success, 'User gelöscht!');
    return;
  }

  void setUsers(List<User> users) {
    _users.value = users;
  }

  void addUser(User user) {
    final List<User> users = List.from(_users.value);
    users.add(user);

    users.sort((a, b) => a.name.compareTo(b.name));
    _users.value = users;
  }

  void removeUser(User user) {
    _users.value = _users.value
        .where((element) => element.publicId != user.publicId)
        .toList();
  }

  void updateUser(User user) {
    _users.value = _users.value
        .map((e) => e.publicId == user.publicId ? user : e)
        .toList();
  }

  void clearUsers() {
    _users.value = [];
  }

  void removeUsers(List<User> users) {
    _users.value =
        _users.value.where((element) => !users.contains(element)).toList();
  }

  void addUsers(List<User> users) {
    _users.value = [..._users.value, ...users];
  }

  void updateUsers(List<User> users) {
    _users.value = users;
  }

  void addOrUpdateUser(User user) {
    if (_users.value.any((element) => element.publicId == user.publicId)) {
      updateUser(user);
    } else {
      addUser(user);
    }
  }

  Future<void> increaseUsersCredit() async {
    final List<User> users = await userApiService.increaseUsersCredit();
    updateUsers(users);
    locator<NotificationManager>()
        .showSnackBar(NotificationType.success, 'Guthaben erfolgreich erhöht!');
  }
}
