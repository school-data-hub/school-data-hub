import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/theme/styles.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/widgets/dialogs/confirmation_dialog.dart';
import 'package:schuldaten_hub/features/matrix/domain/models/matrix_room.dart';
import 'package:schuldaten_hub/features/matrix/domain/models/matrix_user.dart';
import 'package:schuldaten_hub/features/matrix/presentation/select_matrix_users_list_page/controller/select_matrix_users_list_controller.dart';
import 'package:schuldaten_hub/features/matrix/domain/matrix_policy_manager.dart';
import 'package:schuldaten_hub/features/matrix/domain/matrix_room_helpers.dart';
import 'package:schuldaten_hub/features/matrix/domain/matrix_user_helpers.dart';

List<Widget> usersInRoomList(
    List<MatrixUser> matrixUsers, String roomId, BuildContext context) {
  return [
    Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        //margin: const EdgeInsets.only(bottom: 16),
        width: double.infinity,
        child: ElevatedButton(
          style: AppStyles.successButtonStyle,
          onPressed: () async {
            final availableUsers = MatrixUserHelper.restOfUsers(
                MatrixUserHelper.userIdsFromUsers(matrixUsers));

            final List<String> selectedUserIds =
                await Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) => SelectMatrixUsersList(availableUsers),
                    )) ??
                    [];
            if (selectedUserIds.isNotEmpty) {
              for (final String userId in selectedUserIds) {
                locator<MatrixPolicyManager>()
                    .addMatrixUserToRooms(userId, [roomId]);
              }
            }
          },
          child: const Text(
            "KONTO HINZUFÜGEN",
            style: AppStyles.buttonTextStyle,
          ),
        ),
      ),
    ),
    const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Text(
        //   'Räume:',
        //   style: TextStyle(fontSize: 18.0),
        //   textAlign: TextAlign.left,
        // ),
        Gap(5),
        // Text(pupil.creditEarned.toString(),
        //     style:
        //         const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
      ],
    ),
    const Gap(10),
    const Row(
      children: [
        Padding(
          padding: EdgeInsets.only(left: 22),
          child: Text(
            'Konten:',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
          ),
        ),
      ],
    ),
    const Gap(5),
    ListView.builder(
      padding: const EdgeInsets.only(left: 20, top: 5, bottom: 15),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: matrixUsers.length,
      itemBuilder: (BuildContext context, int index) {
        final List<MatrixUser> matrixUserList = List.from(matrixUsers);
        MatrixUser matrixUser = matrixUserList[index];
        return Padding(
          padding: const EdgeInsets.all(0.0),
          child: GestureDetector(
            onTap: () {},
            onLongPress: () async {},
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      onLongPress: () async {
                        final bool? result = await confirmationDialog(
                            context: context,
                            message:
                                'Moderationsrechte für ${matrixUser.displayName} vergeben?',
                            title: 'Moderationsrechte vergeben');
                        if (result == true) {
                          locator<MatrixPolicyManager>().changeRoomPowerLevels(
                              roomId: roomId,
                              roomAdmin: RoomAdmin(
                                  id: matrixUser.id!, powerLevel: 50));
                        }
                      },
                      child: Text(
                        matrixUser.displayName,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    if (MatrixRoomHelper.powerLevelInRoom(
                            roomId, matrixUser.id!) !=
                        null)
                      const Icon(
                        Icons.check,
                        color: Colors.green,
                      )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
  ];
}
