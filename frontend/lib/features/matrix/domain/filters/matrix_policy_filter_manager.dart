import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/features/matrix/domain/models/matrix_room.dart';
import 'package:schuldaten_hub/features/matrix/domain/models/matrix_user.dart';
import 'package:schuldaten_hub/features/matrix/domain/matrix_policy_manager.dart';

class MatrixPolicyFilterManager {
  final _filtersOn = ValueNotifier<bool>(false);
  ValueListenable<bool> get filtersOn => _filtersOn;

  final _filteredMatrixUsers = ValueNotifier<List<MatrixUser>>(
      locator<MatrixPolicyManager>().matrixUsers.value);
  ValueListenable<List<MatrixUser>> get filteredMatrixUsers =>
      _filteredMatrixUsers;

  final _filteredMatrixRooms = ValueNotifier<List<MatrixRoom>>(
      locator<MatrixPolicyManager>().matrixRooms.value);
  ValueListenable<List<MatrixRoom>> get filteredMatrixRooms =>
      _filteredMatrixRooms;

  final _searchText = ValueNotifier<String>('');
  ValueListenable<String> get searchText => _searchText;

  final _searchController =
      ValueNotifier<TextEditingController>(TextEditingController());
  ValueListenable<TextEditingController> get searchController =>
      _searchController;

  MatrixPolicyFilterManager();

  resetAllMatrixFilters() {
    _searchText.value = '';
    _filteredMatrixUsers.value =
        locator<MatrixPolicyManager>().matrixUsers.value;
    _filteredMatrixRooms.value =
        locator<MatrixPolicyManager>().matrixRooms.value;
    _filtersOn.value = false;
    _searchController.value.clear();
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
      _filtersOn.value = false;
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
    _filtersOn.value = true;
  }

  setRoomsFilterText(String text) {
    if (text == '') {
      _searchText.value = text;
      _filteredMatrixRooms.value =
          locator<MatrixPolicyManager>().matrixRooms.value;
      _filtersOn.value = false;
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
    _filtersOn.value = true;
  }
}
