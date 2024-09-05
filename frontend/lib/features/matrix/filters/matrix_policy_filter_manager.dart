import 'package:flutter/foundation.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/features/matrix/models/matrix_room.dart';
import 'package:schuldaten_hub/features/matrix/models/matrix_user.dart';
import 'package:schuldaten_hub/features/matrix/services/matrix_policy_manager.dart';

class MatrixPolicyFilterManager {
  ValueListenable<List<MatrixUser>> get filteredMatrixUsers =>
      _filteredMatrixUsers;
  ValueListenable<List<MatrixRoom>> get filteredMatrixRooms =>
      _filteredMatrixRooms;
  ValueListenable<String> get searchText => _searchText;
  ValueListenable<bool> get filtersOn => _filtersOn;
  final _filteredMatrixUsers = ValueNotifier<List<MatrixUser>>(
      locator<MatrixPolicyManager>().matrixUsers.value);
  final _filteredMatrixRooms = ValueNotifier<List<MatrixRoom>>(
      locator<MatrixPolicyManager>().matrixRooms.value);
  final _searchText = ValueNotifier<String>('');
  final _filtersOn = ValueNotifier<bool>(false);

  MatrixPolicyFilterManager();

  resetAllMatrixFilters() {
    _searchText.value = '';
    _filteredMatrixUsers.value =
        locator<MatrixPolicyManager>().matrixUsers.value;
    _filteredMatrixRooms.value =
        locator<MatrixPolicyManager>().matrixRooms.value;
  }

  refreshFilteredMatrixUsers() {
    final matrixUsers = locator<MatrixPolicyManager>().matrixUsers.value;
    final filteredMatrixUsers = _filteredMatrixUsers.value;
    for (var user in matrixUsers) {
      final index = filteredMatrixUsers
          .indexWhere((filteredUser) => filteredUser.id == user.id);
      if (index != -1) {
        if (filteredMatrixUsers[index] != user) {
          filteredMatrixUsers[index] = user;
        }
      }
    }

    _filteredMatrixUsers.value = filteredMatrixUsers;
  }

  setUsersFilterText(String text) {
    if (text == '') {
      _searchText.value = text;
      _filteredMatrixUsers.value =
          locator<MatrixPolicyManager>().matrixUsers.value;
      return;
    }
    List<MatrixUser> matrixUsers =
        List.from(locator<MatrixPolicyManager>().matrixUsers.value);
    List<MatrixUser> filteredMatrixUsers = [];
    filteredMatrixUsers = matrixUsers
        .where((MatrixUser user) =>
            user.displayName.toLowerCase().contains(text.toLowerCase()) ||
            user.id!.toLowerCase().contains(text.toLowerCase()))
        .toList();
    _filteredMatrixUsers.value = filteredMatrixUsers;
  }

  setRoomsFilterText(String text) {
    if (text == '') {
      _searchText.value = text;
      _filteredMatrixRooms.value =
          locator<MatrixPolicyManager>().matrixRooms.value;
      return;
    }
    final List<MatrixRoom> matrixRooms =
        List.from(locator<MatrixPolicyManager>().matrixRooms.value);
    List<MatrixRoom> filteredMatrixRooms = [];
    filteredMatrixRooms = matrixRooms
        .where((MatrixRoom room) =>
            room.name!.toLowerCase().contains(text.toLowerCase()) ||
            room.id.toLowerCase().contains(text.toLowerCase()))
        .toList();
    _filteredMatrixRooms.value = filteredMatrixRooms;
  }
}
