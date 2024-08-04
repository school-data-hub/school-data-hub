import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/constants/styles.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/session_manager.dart';
import 'package:schuldaten_hub/common/widgets/avatar.dart';
import 'package:schuldaten_hub/features/pupil/services/pupil_manager.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';
import 'package:schuldaten_hub/features/pupil/pages/pupil_profile_page/pupil_profile_page.dart';
import 'package:schuldaten_hub/features/pupil/pages/select_pupils_list_page/select_pupils_list_page.dart';

import 'package:schuldaten_hub/features/school_lists/services/school_list_manager.dart';

class NewSchoolListPage extends StatefulWidget {
  const NewSchoolListPage({super.key});

  @override
  NewSchoolListPageState createState() => NewSchoolListPageState();
}

class NewSchoolListPageState extends State<NewSchoolListPage> {
  final TextEditingController schoolListNameController =
      TextEditingController();
  final TextEditingController schoolListDescriptionController =
      TextEditingController();
  bool _isOn = false;
  Set<int> pupilIds = {};
  void postNewSchoolList() async {
    String listType = 'private';
    if (_isOn == true) {
      listType = 'public';
    }
    await locator<SchoolListManager>().postSchoolListWithGroup(
        name: schoolListNameController.text,
        description: schoolListDescriptionController.text,
        pupilIds: pupilIds.toList(),
        visibility: listType);
  }

  @override
  Widget build(BuildContext context) {
    List<PupilProxy> pupilsFromIds =
        locator<PupilManager>().pupilsFromPupilIds(pupilIds.toList());
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: backgroundColor,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rule_rounded, size: 25, color: Colors.white),
            Gap(10),
            Text(
              'Neue Liste',
              style: appBarTextStyle,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextField(
                  minLines: 1,
                  maxLines: 3,
                  controller: schoolListNameController,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: backgroundColor, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: backgroundColor, width: 2),
                    ),
                    labelStyle: TextStyle(color: backgroundColor),
                    labelText: 'Name der Liste',
                  ),
                ),
                const Gap(20),
                TextField(
                  minLines: 1,
                  maxLines: 3,
                  controller: schoolListDescriptionController,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: backgroundColor, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: backgroundColor, width: 2),
                    ),
                    labelStyle: TextStyle(color: backgroundColor),
                    labelText: 'Kurze Beschreibung der Liste',
                  ),
                ),
                const Gap(10),
                locator<SessionManager>().isAdmin.value == true
                    ? Row(
                        children: [
                          const Text(
                            'Öffentliche Liste:',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const Gap(10),
                          Switch(
                            value:
                                _isOn, // Boolean value representing the switch state
                            onChanged: (newValue) {
                              setState(() {
                                _isOn = newValue;
                              });
                            },
                            activeColor: Colors.blue, // Change color if desired
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
                Row(
                  children: [
                    const Text(
                      'Ausgewählte Kinder:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Gap(10),
                    Text(
                      pupilsFromIds.length.toString(),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      child: const Text('aus Liste',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: interactiveColor)),
                    ),
                  ],
                ),
                if (pupilIds.isEmpty) const Gap(30),
                pupilIds.isNotEmpty
                    ? Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: ListView.builder(
                                padding:
                                    const EdgeInsets.only(top: 5, bottom: 15),
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: pupilsFromIds.length,
                                itemBuilder: (context, int index) {
                                  PupilProxy listedPupil = pupilsFromIds[index];
                                  return Column(
                                    children: [
                                      // const Gap(5),
                                      InkWell(
                                        onLongPress: () {
                                          setState(() {
                                            pupilIds
                                                .remove(listedPupil.internalId);
                                          });
                                        },
                                        onTap: () {
                                          Navigator.of(context)
                                              .push(MaterialPageRoute(
                                            builder: (ctx) => PupilProfilePage(
                                              pupil: listedPupil,
                                            ),
                                          ));
                                        },
                                        child: Card(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              children: [
                                                Provider.value(
                                                  value: AvatarData(
                                                      avatarId:
                                                          listedPupil.avatarId,
                                                      internalId: listedPupil
                                                          .internalId,
                                                      size: 50),
                                                  child: const AvatarImage(),
                                                ),
                                                const Gap(10),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      listedPupil.firstName,
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18),
                                                    ),
                                                    //const Gap(10),
                                                    Text(
                                                      listedPupil.lastName,
                                                      style: const TextStyle(),
                                                    ),
                                                  ],
                                                ),
                                                const Spacer(),
                                                Column(
                                                  children: [
                                                    Text(
                                                      listedPupil.group,
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: groupColor,
                                                          fontSize: 18),
                                                    ),
                                                    Text(
                                                      listedPupil.schoolyear,
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              schoolyearColor,
                                                          fontSize: 18),
                                                    ),
                                                  ],
                                                ),
                                                const Gap(15),
                                              ],
                                            ),
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
                          Text('Keine Kinder ausgewählt!',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Color.fromARGB(255, 91, 91, 91),
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                if (pupilIds.isEmpty) const Spacer(),
                ElevatedButton(
                  style: actionButtonStyle,
                  onPressed: () async {
                    final List<int> selectedPupilIds =
                        await Navigator.of(context).push(MaterialPageRoute(
                              builder: (ctx) => SelectPupilsListPage(
                                  selectablePupils: locator<PupilManager>()
                                      .pupilsNotListed(pupilIds.toList())),
                            )) ??
                            [];
                    if (selectedPupilIds.isNotEmpty) {
                      setState(() {
                        pupilIds.addAll(selectedPupilIds.toSet());
                      });
                    }
                  },
                  child: const Text(
                    'KINDER AUSWÄHLEN',
                    style: buttonTextStyle,
                  ),
                ),
                const Gap(15),
                ElevatedButton(
                  style: successButtonStyle,
                  onPressed: () {
                    postNewSchoolList();
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'SENDEN',
                    style: buttonTextStyle,
                  ),
                ),
                const Gap(15),
                ElevatedButton(
                  style: cancelButtonStyle,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'ABBRECHEN',
                    style: buttonTextStyle,
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
    schoolListNameController.dispose();
    schoolListDescriptionController.dispose();
    super.dispose();
  }
}
