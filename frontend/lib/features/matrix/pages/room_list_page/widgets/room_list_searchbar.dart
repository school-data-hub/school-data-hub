import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/constants/enums.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/widgets/search_text_field.dart';
import 'package:schuldaten_hub/features/matrix/models/matrix_room.dart';
import 'package:schuldaten_hub/features/matrix/filters/matrix_policy_filter_manager.dart';
import 'package:schuldaten_hub/features/matrix/pages/room_list_page/widgets/rooms_filter_bottom_sheet.dart';
import 'package:schuldaten_hub/features/pupil/filters/pupil_filter_manager.dart';

class RoomListSearchBar extends StatelessWidget {
  final List<MatrixRoom> matrixRooms;
  final bool filtersOn;
  const RoomListSearchBar(
      {required this.matrixRooms, required this.filtersOn, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: canvasColor,
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Column(
        children: [
          const Gap(5),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.meeting_room_rounded,
                    color: backgroundColor,
                  ),
                  const Gap(10),
                  Text(
                    matrixRooms.length.toString(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
            child: Row(
              children: [
                Expanded(
                    child: SearchTextField(
                        searchType: SearchType.room,
                        hintText: 'Raum suchen',
                        refreshFunction: locator<MatrixPolicyFilterManager>()
                            .filterRoomsWithSearchText)),
                InkWell(
                  onTap: () => const RoomsFilterBottomSheet(),
                  onLongPress: () =>
                      locator<PupilFilterManager>().resetFilters(),
                  // onPressed: () => showBottomSheetFilters(context),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Icon(
                      Icons.filter_list,
                      color: filtersOn ? Colors.deepOrange : Colors.grey,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
