import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/constants/styles.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/widgets/custom_expansion_tile.dart';
import 'package:schuldaten_hub/common/widgets/custom_list_tiles.dart';
import 'package:schuldaten_hub/features/matrix/models/matrix_user.dart';
import 'package:schuldaten_hub/features/matrix/pages/matrix_users_list_page/widgets/pupil_rooms_list.dart';
import 'package:schuldaten_hub/features/matrix/pages/select_matrix_rooms_list_page/controller/select_matrix_rooms_list_controller.dart';
import 'package:schuldaten_hub/features/matrix/services/matrix_policy_helper_functions.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';
import 'package:schuldaten_hub/features/pupil/services/pupil_manager.dart';
import 'package:watch_it/watch_it.dart';

class MatrixUsersListCard extends WatchingStatefulWidget {
  final MatrixUser matrixUser;
  const MatrixUsersListCard(this.matrixUser, {super.key});

  @override
  State<MatrixUsersListCard> createState() => _MatrixUsersListCardState();
}

class _MatrixUsersListCardState extends State<MatrixUsersListCard> {
  late CustomExpansionTileController _tileController;
  @override
  void initState() {
    super.initState();
    _tileController = CustomExpansionTileController();
  }

  @override
  Widget build(BuildContext context) {
    final matrixUser = watch<MatrixUser>(widget.matrixUser);
    final pupilManager = locator<PupilManager>();
    final List<PupilProxy> pupils = watch<PupilManager>(pupilManager).allPupils;
    final bool isLinked = pupils.any((pupil) =>
        pupil.contact == matrixUser.id ||
        pupil.parentsContact == matrixUser.id);

    return Card(
      color: isLinked ? Colors.green : Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 1.0,
      margin:
          const EdgeInsets.only(left: 4.0, right: 4.0, top: 4.0, bottom: 4.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              //AvatarWithBadges(pupil: pupil, size: 80),
              const Gap(10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Gap(15),
                    Row(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: InkWell(
                              onTap: () {
                                // locator<BottomNavManager>()
                                //     .setPupilProfileNavPage(2);
                                // Navigator.of(context).push(MaterialPageRoute(
                                //   builder: (ctx) => PupilProfile(
                                //     pupil,
                                //   ),
                                // ));
                              },
                              child: Text(
                                matrixUser.displayName,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(5),
                    Row(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                Text(
                                  matrixUser.id!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                const Gap(20),
                                IconButton(
                                  icon: const Icon(Icons.copy),
                                  onPressed: () {
                                    Clipboard.setData(
                                        ClipboardData(text: matrixUser.id!));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Copied to clipboard')),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(10),
                  ],
                ),
              ),
              const Gap(20),
              InkWell(
                onTap: () {
                  _tileController.isExpanded
                      ? _tileController.collapse()
                      : _tileController.expand();
                },
                child: Column(
                  children: [
                    const Gap(20),
                    const Text('Räume'),
                    Center(
                      child: Text(
                        matrixUser.matrixRooms.length.toString(),
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          color: backgroundColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(20),
            ],
          ),
          CustomListTiles(
              title: null,
              tileController: _tileController,
              widgetList: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    //margin: const EdgeInsets.only(bottom: 16),
                    width: double.infinity,
                    child: ElevatedButton(
                      style: successButtonStyle,
                      onPressed: () async {
                        final availableRooms =
                            MatrixHelperFunctions.restOfRooms(
                                matrixUser.joinedRoomIds);
                        final List<String> selectedRoomIds =
                            await Navigator.of(context).push(MaterialPageRoute(
                                  builder: (ctx) =>
                                      SelectMatrixRoomsList(availableRooms),
                                )) ??
                                [];
                        if (selectedRoomIds.isNotEmpty) {
                          matrixUser.joinRooms(selectedRoomIds);
                        }
                      },
                      child: const Text(
                        "RÄUME HINZUFÜGEN",
                        style: buttonTextStyle,
                      ),
                    ),
                  ),
                ),
                MatrixUserRoomsList(
                    matrixUser: matrixUser, matrixRooms: matrixUser.matrixRooms)
              ]),
        ],
      ),
    );
  }
}
