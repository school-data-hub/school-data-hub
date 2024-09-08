import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/features/matrix/models/matrix_user.dart';
import 'package:schuldaten_hub/features/matrix/services/matrix_policy_manager.dart';

class MatrixUserHelper {
  static List<MatrixUser> usersFromUserIds(List<String> userIds) {
    final List<MatrixUser> users =
        List.from(locator<MatrixPolicyManager>().matrixUsers.value);
    final usersFromUserIds =
        users.where((user) => userIds.contains(user.id)).toList();
    return usersFromUserIds;
  }

  static List<String> userIdsFromUsers(List<MatrixUser> users) {
    final List<String> userIds = users.map((user) => user.id!).toList();
    return userIds;
  }

  static List<String> restOfUsers(List<String> userIds) {
    List<String> restOfUsers = [];
    final users = locator<MatrixPolicyManager>().matrixUsers.value;
    for (MatrixUser user in users) {
      if (!userIds.contains(user.id)) {
        restOfUsers.add(user.id!);
      }
    }
    return restOfUsers;
  }
}
