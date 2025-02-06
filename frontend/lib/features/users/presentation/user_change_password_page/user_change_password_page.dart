import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/domain/models/enums.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_service.dart';
import 'package:schuldaten_hub/common/theme/app_colors.dart';
import 'package:schuldaten_hub/common/theme/styles.dart';
import 'package:schuldaten_hub/features/users/domain/user_manager.dart';

class UserChangePasswordPage extends StatefulWidget {
  const UserChangePasswordPage({super.key});

  @override
  UserChangePasswordPageState createState() => UserChangePasswordPageState();
}

class UserChangePasswordPageState extends State<UserChangePasswordPage> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.backgroundColor,
        title: const Center(
          child: Text(
            'Passwort ändern',
            style: AppStyles.appBarTextStyle,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                TextField(
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                  controller: _currentPasswordController,
                  obscureText: true,
                  decoration: AppStyles.textFieldDecoration(
                      labelText: 'Aktuelles Passwort'),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: AppStyles.textFieldDecoration(
                      labelText: 'Neues Passwort'),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: AppStyles.textFieldDecoration(
                      labelText: 'Neues Passwort wiederholen'),
                ),
                const Spacer(),
                ElevatedButton(
                  style: AppStyles.actionButtonStyle,
                  onPressed: () {
                    if (_currentPasswordController.text.isEmpty ||
                        _newPasswordController.text.isEmpty ||
                        _confirmPasswordController.text.isEmpty) {
                      locator<NotificationService>().showSnackBar(
                          NotificationType.warning,
                          'Bitte füllen Sie alle Felder aus!');
                      return;
                    }
                    if (_newPasswordController.text !=
                        _confirmPasswordController.text) {
                      locator<NotificationService>().showSnackBar(
                          NotificationType.warning,
                          'Die Passwörter stimmen nicht überein!');
                      return;
                    }
                    locator<UserManager>().changePassword(
                      _currentPasswordController.text,
                      _newPasswordController.text,
                    );

                    Navigator.pop(context);
                  },
                  child: const Text('PASSWORT ÄNDERN',
                      style: AppStyles.buttonTextStyle),
                ),
                const Gap(15),
                ElevatedButton(
                  style: AppStyles.cancelButtonStyle,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child:
                      const Text('ABBRECHEN', style: AppStyles.buttonTextStyle),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
