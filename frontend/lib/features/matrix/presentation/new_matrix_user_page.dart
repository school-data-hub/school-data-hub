import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/theme/colors.dart';
import 'package:schuldaten_hub/common/theme/styles.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/domain/session_manager.dart';
import 'package:schuldaten_hub/features/matrix/domain/models/matrix_room.dart';
import 'package:schuldaten_hub/features/matrix/presentation/select_matrix_rooms_list_page/controller/select_matrix_rooms_list_controller.dart';
import 'package:schuldaten_hub/features/matrix/domain/matrix_policy_manager.dart';
import 'package:schuldaten_hub/features/matrix/domain/matrix_room_helpers.dart';

class NewMatrixUserPage extends StatefulWidget {
  const NewMatrixUserPage({super.key});

  @override
  NewMatrixUserPageState createState() => NewMatrixUserPageState();
}

class NewMatrixUserPageState extends State<NewMatrixUserPage> {
  final TextEditingController matrixIdController = TextEditingController();
  final TextEditingController displayNameController = TextEditingController();
  Set<String> roomIds = {};
  //Set<int> pupilIds = {};
  void postNewMatrixUser() async {
    String matrixId = '@${matrixIdController.text}:hermannschule.de';
    String displayName = displayNameController.text;
    List<String> roomIdsList = roomIds.toList();
    await locator<MatrixPolicyManager>()
        .createNewMatrixUser(matrixId, displayName);

    locator<MatrixPolicyManager>().addMatrixUserToRooms(matrixId, roomIdsList);
    // await locator<SchoolListManager>()
    //     .postSchoolListWithGroup(text1, text2, pupilIds.toList(), listType);
  }

  @override
  Widget build(BuildContext context) {
    List<MatrixRoom> roomsFromIds =
        MatrixRoomHelper.roomsFromRoomIds(roomIds.toList());
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: AppColors.backgroundColor,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_rounded,
              size: 25,
              color: Colors.white,
            ),
            Gap(10),
            Text(
              'Neues Matrix-Konto',
              style: AppStyles.appBarTextStyle,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center, // Add this
                  children: <Widget>[
                    const Text(
                      '@',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(5),
                    SizedBox(
                      width: 160,
                      child: TextField(
                        minLines: 1,
                        maxLines: 3,
                        controller: matrixIdController,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(10),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: AppColors.backgroundColor, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: AppColors.backgroundColor, width: 2),
                          ),
                          labelStyle:
                              TextStyle(color: AppColors.backgroundColor),
                          labelText: 'Matrix-Id',
                        ),
                      ),
                    ),
                    const Gap(5),
                    const Text(
                      ':hermannschule.de',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Gap(20),
                TextField(
                  minLines: 1,
                  maxLines: 3,
                  controller: displayNameController,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: AppColors.backgroundColor, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: AppColors.backgroundColor, width: 2),
                    ),
                    labelStyle: TextStyle(color: AppColors.backgroundColor),
                    labelText: 'Anzeigename',
                  ),
                ),
                const Gap(10),
                locator<SessionManager>().isAdmin.value == true
                    ? const Row(
                        children: [
                          Text(
                            'Öffentliche Liste:',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Gap(10),
                        ],
                      )
                    : const SizedBox.shrink(),
                Row(
                  children: [
                    const Text(
                      'Ausgewählte Räume:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Gap(10),
                    Text(
                      roomsFromIds.length.toString(),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      child: const Text('aus Liste',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.interactiveColor)),
                    ),
                  ],
                ),
                if (roomIds.isEmpty) const Gap(30),
                roomIds.isNotEmpty
                    ? Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: ListView.builder(
                                padding: const EdgeInsets.only(
                                    left: 10, top: 5, bottom: 15),
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: roomsFromIds.length,
                                itemBuilder: (context, int index) {
                                  MatrixRoom listedRoom = roomsFromIds[index];
                                  return Column(
                                    children: [
                                      const Gap(5),
                                      InkWell(
                                        onLongPress: () {
                                          setState(() {
                                            roomIds.remove(listedRoom.id);
                                          });
                                        },
                                        onTap: () {},
                                        child: Card(
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                child: Text(
                                                  listedRoom.name!,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              const Gap(10),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                          ),
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Keine Räume ausgewählt!',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Color.fromARGB(255, 91, 91, 91),
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                if (roomIds.isEmpty) const Spacer(),
                ElevatedButton(
                  style: AppStyles.actionButtonStyle,
                  onPressed: () async {
                    final List<String> selectedRoomIds =
                        await Navigator.of(context).push(MaterialPageRoute(
                              builder: (ctx) => SelectMatrixRoomsList(
                                  MatrixRoomHelper.restOfRooms(
                                      roomIds.toList())),
                            )) ??
                            [];
                    if (selectedRoomIds.isNotEmpty) {
                      setState(() {
                        roomIds.addAll(selectedRoomIds.toSet());
                      });
                    }
                  },
                  child: const Text(
                    'RÄUME AUSWÄHLEN',
                    style: AppStyles.buttonTextStyle,
                  ),
                ),
                const Gap(15),
                ElevatedButton(
                  style: AppStyles.successButtonStyle,
                  onPressed: () async {
                    postNewMatrixUser();
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'SENDEN',
                    style: AppStyles.buttonTextStyle,
                  ),
                ),
                const Gap(15),
                ElevatedButton(
                  style: AppStyles.cancelButtonStyle,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'ABBRECHEN',
                    style: AppStyles.buttonTextStyle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the tree
    matrixIdController.dispose();
    displayNameController.dispose();
    super.dispose();
  }
}
