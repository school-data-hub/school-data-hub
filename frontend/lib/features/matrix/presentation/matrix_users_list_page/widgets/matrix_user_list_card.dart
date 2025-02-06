import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/theme/app_colors.dart';
import 'package:schuldaten_hub/common/theme/styles.dart';
import 'package:schuldaten_hub/common/widgets/avatar.dart';
import 'package:schuldaten_hub/common/widgets/custom_expansion_tile/custom_expansion_tile.dart';
import 'package:schuldaten_hub/common/widgets/custom_expansion_tile/custom_expansion_tile_content.dart';
import 'package:schuldaten_hub/common/widgets/dialogs/confirmation_dialog.dart';
import 'package:schuldaten_hub/common/widgets/dialogs/short_textfield_dialog.dart';
import 'package:schuldaten_hub/features/main_menu/widgets/landing_bottom_nav_bar.dart';
import 'package:schuldaten_hub/features/matrix/domain/matrix_policy_manager.dart';
import 'package:schuldaten_hub/features/matrix/domain/matrix_room_helpers.dart';
import 'package:schuldaten_hub/features/matrix/domain/matrix_user_helpers.dart';
import 'package:schuldaten_hub/features/matrix/domain/models/matrix_user.dart';
import 'package:schuldaten_hub/features/matrix/presentation/matrix_users_list_page/widgets/pupil_rooms_list.dart';
import 'package:schuldaten_hub/features/matrix/presentation/select_matrix_rooms_list_page/controller/select_matrix_rooms_list_controller.dart';
import 'package:schuldaten_hub/features/matrix/presentation/widgets/dialogues/logout_devices_dialog.dart';
import 'package:schuldaten_hub/features/matrix/utils/matrix_credentials_pdf_generator.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_proxy.dart';
import 'package:schuldaten_hub/features/pupil/presentation/pupil_profile_page/pupil_profile_page.dart';
import 'package:schuldaten_hub/features/pupil/presentation/pupil_profile_page/widgets/pupil_profile_navigation.dart';
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

  PupilProxy? pupil;
  @override
  Widget build(BuildContext context) {
    final matrixUser = watch<MatrixUser>(widget.matrixUser);
    final MatrixUserRelationship? userRelationship =
        MatrixUserHelper.getUserRelationship(matrixUser);

    return Card(
      color: userRelationship != null && userRelationship.isParent
          ? AppColors.selectedCardColor
          : Colors.white,
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
              const Gap(10),
              if (userRelationship?.familyPupils != null)
                ...userRelationship!.familyPupils!.map((pupil) => InkWell(
                    onTap: () {
                      locator<MainMenuBottomNavManager>()
                          .setPupilProfileNavPage(ProfileNavigation.info.value);
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (ctx) => PupilProfilePage(
                          pupil: pupil,
                        ),
                      ));
                    },
                    child: AvatarWithBadges(pupil: pupil, size: 70))),
              (userRelationship?.pupil != null)
                  ? InkWell(
                      onTap: () {
                        locator<MainMenuBottomNavManager>()
                            .setPupilProfileNavPage(
                                ProfileNavigation.info.value);
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (ctx) => PupilProfilePage(
                            pupil: userRelationship.pupil!,
                          ),
                        ));
                      },
                      child: AvatarWithBadges(
                          pupil: userRelationship!.pupil!, size: 70))
                  : (userRelationship?.isTeacher == true)
                      ? const SizedBox(
                          width: 90,
                          height: 70,
                          child: Padding(
                            padding:
                                EdgeInsets.only(left: 5, top: 15, right: 14),
                            child: Icon(Icons.school_rounded, size: 60),
                          ),
                        )
                      : (userRelationship?.familyPupils != null)
                          ? const SizedBox.shrink()
                          : const SizedBox(
                              width: 90,
                              height: 70,
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 5, top: 15, right: 14),
                                child: Icon(
                                  Icons.question_mark_rounded,
                                  size: 70,
                                  color: Colors.red,
                                ),
                              ),
                            ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Gap(5),
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
                                        textinField: matrixUser.displayName,
                                        hintText: 'Neuer Name',
                                        obscureText: false);
                                if (changedName != null) {
                                  matrixUser.displayName = changedName;
                                  locator<MatrixPolicyManager>()
                                      .pendingChangesHandler(true);
                                }
                              },
                              child: matrixUser.isParent
                                  ? Text(
                                      '${matrixUser.displayName} 👨‍👩‍👦',
                                      overflow: TextOverflow.fade,
                                      softWrap: false,
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    )
                                  : Text(
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
                                    color: userRelationship?.pupil != null ||
                                            userRelationship?.isParent == true
                                        ? Colors.green
                                        : AppColors.backgroundColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                            padding: const EdgeInsets.all(0),
                            onPressed: () async {
                              final confirmation = await confirmationDialog(
                                  context: context,
                                  title: 'Benutzer:in löschen',
                                  message:
                                      'Möchten Sie das Konto wirklich löschen?\nDas kann nicht rückgangig gemacht werden!');
                              if (confirmation == true) {
                                locator<MatrixPolicyManager>()
                                    .deleteUser(userId: matrixUser.id!);
                              }
                            },
                            icon: const Icon(Icons.delete, color: Colors.red)),
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
                        IconButton(
                            onPressed: () async {
                              final confirmation = await confirmationDialog(
                                  context: context,
                                  title: 'Passwort zurücksetzen',
                                  message:
                                      'Möchten Sie das Passwort wirklich zurücksetzen?');
                              if (confirmation != true) return;
                              final logOutDevices =
                                  await logoutDevicesDialog(context);
                              if (logOutDevices == null) return;
                              final file = await locator<MatrixPolicyManager>()
                                  .resetPassword(
                                      user: matrixUser,
                                      logoutDevices: logOutDevices,
                                      isStaff:
                                          userRelationship?.isTeacher == true
                                              ? true
                                              : false);
                              if (file != null) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PdfViewPage(pdfFile: file),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(
                              Icons.qr_code_2_rounded,
                            )),
                      ],
                    )
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
