import 'package:flutter/material.dart';
import 'package:schuldaten_hub/common/constants/enums.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/features/matrix/filters/matrix_policy_filter_manager.dart';

import 'package:schuldaten_hub/features/pupil/filters/pupils_filter.dart';
import 'package:watch_it/watch_it.dart';

class MatrixSearchTextField extends WatchingStatefulWidget {
  final SearchType searchType;
  final String hintText;
  final Function refreshFunction;
  const MatrixSearchTextField(
      {required this.searchType,
      required this.hintText,
      required this.refreshFunction,
      super.key});

  @override
  State<MatrixSearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<MatrixSearchTextField> {
  FocusNode focusNode = FocusNode();
  final textEditingController = TextEditingController();
  final matrixFilterManager = locator<MatrixPolicyFilterManager>();
  @override
  Widget build(BuildContext context) {
    // final textFilter = watch(locator<PupilsFilter>().textFilter);
    final filtersOn = watchValue((MatrixPolicyFilterManager x) => x.filtersOn);

    return TextField(
      focusNode: focusNode,
      controller: textEditingController,
      textInputAction: TextInputAction.search,
      onChanged: (value) {
        if (widget.searchType == SearchType.room) {
          matrixFilterManager.setRoomsFilterText(value);
        } else {
          matrixFilterManager.setUsersFilterText(value);
        }
      },
      decoration: InputDecoration(
        fillColor: const Color.fromARGB(255, 255, 255, 255),
        filled: true,
        border: UnderlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(
            12,
          ),
        ),
        hintText: widget.hintText,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        prefixIcon: filtersOn
            ? IconButton(
                icon: const Icon(
                  Icons.close_outlined,
                ),
                onPressed: () => locator<PupilsFilter>().resetFilters(),
                color: Colors.black45,
              )
            : IconButton(
                onPressed: () => widget.refreshFunction,
                icon: const Icon(
                  Icons.search_outlined,
                  color: Colors.black45,
                ),
              ),
        suffixIcon: const SizedBox.shrink(),
      ),
    );
  }

  @override
  void dispose() {
    focusNode.dispose();
    textEditingController.dispose();
    super.dispose();
  }
}
