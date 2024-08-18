import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/constants/styles.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/widgets/dialogues/information_dialog.dart';
import 'package:schuldaten_hub/features/users/services/user_manager.dart';

class NewUserPage extends StatefulWidget {
  const NewUserPage({super.key});

  @override
  NewUserPageState createState() => NewUserPageState();
}

class NewUserPageState extends State<NewUserPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController displayNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController repeatPasswordController =
      TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final TextEditingController timeUnitsController = TextEditingController();
  final TextEditingController creditController = TextEditingController();
  final TextEditingController tutoringController = TextEditingController();
  bool isAdmin = false;

  //Set<int> pupilIds = {};
  Future<void> postNewUser() async {
    if (passwordController.text != repeatPasswordController.text) {
      informationDialog(context, 'Passwörter stimmen nicht überein',
          'Bitte Passwörter überprüfen');
      return;
    }
    locator<UserManager>().createUser(
      name: nameController.text,
      password: passwordController.text,
      isAdmin: isAdmin,
      timeUnits: int.parse(timeUnitsController.text),
      credit: int.parse(creditController.text),
      contact: contactController.text,
      role: roleController.text,
      tutoring: tutoringController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: backgroundColor,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_box_rounded,
              size: 25,
              color: Colors.white,
            ),
            Gap(10),
            Text(
              'Neues MPT-Konto',
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center, // Add this
                  children: <Widget>[
                    const Text(
                      'Kürzel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(5),
                    SizedBox(
                      width: 70,
                      child: TextField(
                        minLines: 1,
                        maxLines: 1,
                        controller: nameController,
                        inputFormatters: [LengthLimitingTextInputFormatter(3)],
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(10),
                          border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: backgroundColor, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: backgroundColor, width: 2),
                          ),
                          labelStyle: TextStyle(color: backgroundColor),
                          labelText: 'Kürzel',
                        ),
                      ),
                    ),
                    const Gap(15),
                    const Text(
                      'Ist Admin:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Checkbox(
                        value: isAdmin,
                        onChanged: (bool? newValue) {
                          setState(() {
                            isAdmin = newValue ?? false;
                          });
                        }),
                    const Gap(5),
                  ],
                ),
                const Gap(20),
                Row(
                  children: [
                    const Text(
                      'Passwort:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(5),
                    Expanded(
                      child: TextField(
                        minLines: 1,
                        maxLines: 1,
                        controller: passwordController,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(10),
                          border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: backgroundColor, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: backgroundColor, width: 2),
                          ),
                          labelStyle: TextStyle(color: backgroundColor),
                          labelText: 'Passwort',
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(20),
                Row(
                  children: [
                    const Text(
                      'Passwort wiederholen:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(5),
                    Expanded(
                      child: TextField(
                        minLines: 1,
                        maxLines: 1,
                        controller: repeatPasswordController,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(10),
                          border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: backgroundColor, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: backgroundColor, width: 2),
                          ),
                          labelStyle: TextStyle(color: backgroundColor),
                          labelText: 'Passwort',
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(20),
                Row(
                  children: [
                    const Text(
                      'Kontakt:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(5),
                    Expanded(
                      child: TextField(
                        minLines: 1,
                        maxLines: 1,
                        controller: contactController,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(10),
                          border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: backgroundColor, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: backgroundColor, width: 2),
                          ),
                          labelStyle: TextStyle(color: backgroundColor),
                          labelText: 'Kontakt',
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(20),
                Row(
                  children: [
                    const Text(
                      'Guthaben:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(5),
                    Expanded(
                      child: TextField(
                        minLines: 1,
                        maxLines: 1,
                        controller: creditController,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(10),
                          border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: backgroundColor, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: backgroundColor, width: 2),
                          ),
                          labelStyle: TextStyle(color: backgroundColor),
                          labelText: 'Guthaben',
                        ),
                      ),
                    ),
                    const Gap(15),
                    const Text(
                      'Stunden:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(5),
                    Expanded(
                      child: TextField(
                        minLines: 1,
                        maxLines: 1,
                        controller: timeUnitsController,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(10),
                          border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: backgroundColor, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: backgroundColor, width: 2),
                          ),
                          labelStyle: TextStyle(color: backgroundColor),
                          labelText: 'Stunden',
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const Gap(15),
                ElevatedButton(
                  style: successButtonStyle,
                  onPressed: () async {
                    await postNewUser();
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
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
    nameController.dispose();
    displayNameController.dispose();
    passwordController.dispose();
    repeatPasswordController.dispose();
    contactController.dispose();
    roleController.dispose();
    timeUnitsController.dispose();
    creditController.dispose();

    super.dispose();
  }
}
