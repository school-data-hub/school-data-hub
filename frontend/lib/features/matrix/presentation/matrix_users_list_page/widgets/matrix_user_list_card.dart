import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/theme/colors.dart';
import 'package:schuldaten_hub/common/theme/styles.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/widgets/custom_expansion_tile/custom_expansion_tile.dart';
import 'package:schuldaten_hub/common/widgets/custom_expansion_tile/custom_expansion_tile_content.dart';
import 'package:schuldaten_hub/common/widgets/dialogues/short_textfield_dialog.dart';
import 'package:schuldaten_hub/features/matrix/domain/models/matrix_user.dart';
import 'package:schuldaten_hub/features/matrix/presentation/matrix_users_list_page/widgets/pupil_rooms_list.dart';
import 'package:schuldaten_hub/features/matrix/presentation/select_matrix_rooms_list_page/controller/select_matrix_rooms_list_controller.dart';
import 'package:schuldaten_hub/features/matrix/domain/matrix_policy_manager.dart';
import 'package:schuldaten_hub/features/matrix/domain/matrix_room_helpers.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_proxy.dart';
import 'package:schuldaten_hub/features/pupil/domain/pupil_manager.dart';
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
      color: Colors.white,
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
                              onTap: () async {
                                final String? changedName =
                                    await shortTextfieldDialog(
                                        context: context,
                                        title: 'Name ändern',
                                        labelText: 'Name ändern',
                                        hintText: matrixUser.displayName,
                                        obscureText: false);
                                if (changedName != null) {
                                  matrixUser.displayName = changedName;
                                  locator<MatrixPolicyManager>()
                                      .pendingChangesHandler(true);
                                }
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
                                  style: TextStyle(
                                    color: isLinked
                                        ? Colors.green
                                        : AppColors.backgroundColor,
                                    fontWeight: FontWeight.bold,
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
                          color: AppColors.backgroundColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(20),
            ],
          ),
          CustomExpansionTileContent(
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
                      style: AppStyles.successButtonStyle,
                      onPressed: () async {
                        final availableRooms = MatrixRoomHelper.restOfRooms(
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
                        style: AppStyles.buttonTextStyle,
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
