import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/theme/app_colors.dart';
import 'package:schuldaten_hub/common/widgets/dialogs/int_dialog.dart';
import 'package:schuldaten_hub/common/widgets/dialogs/short_textfield_dialog.dart';
import 'package:schuldaten_hub/features/users/domain/models/user.dart';
import 'package:schuldaten_hub/features/users/domain/user_manager.dart';
import 'package:watch_it/watch_it.dart';

class UserListCard extends WatchingWidget {
  final User passedUser;
  const UserListCard({required this.passedUser, super.key});

  @override
  Widget build(BuildContext context) {
    final user = watchValue((UserManager x) => x.users)
        .firstWhere((element) => element.publicId == passedUser.publicId);
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
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 70,
                    height: 60,
                    child: Center(
                      child: Text(
                        user.name,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: user.admin
                                ? AppColors.accentColor
                                : Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
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
                                final role = await shortTextfieldDialog(
                                    context: context,
                                    title: 'Rolle bearbeiten',
                                    labelText: 'Rolle eingeben',
                                    hintText: 'Rolle eingeben');
                                if (role != null && role != user.role) {
                                  locator<UserManager>().updateUserProperties(
                                      user: user, role: role);
                                }
                              },
                              child: Text(
                                user.role == '' ? 'kein Eintrag' : user.role,
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
                        const Gap(5),
                        const Text('\$'),
                        const Gap(5),
                        InkWell(
                          onLongPress: () async {
                            final credit = await intDialog(context);
                            if (credit != null && credit != user.credit) {
                              locator<UserManager>().updateUserProperties(
                                  user: user, credit: credit);
                            }
                          },
                          child: Text(
                            user.credit.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
                                InkWell(
                                  onLongPress: () async {
                                    final contact = await shortTextfieldDialog(
                                        context: context,
                                        title: 'Kontakt bearbeiten',
                                        labelText: 'Kontakt eingeben',
                                        hintText: 'Kontakt eingeben');
                                    if (contact != null &&
                                        contact != user.contact) {
                                      locator<UserManager>()
                                          .updateUserProperties(
                                              user: user, contact: contact);
                                    }
                                  },
                                  child: Text(
                                    user.contact == null || user.contact == ''
                                        ? 'kein Kontakt eingetragen'
                                        : user.contact!,
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const Gap(10),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(5),
                    Row(
                      children: [
                        const Icon(Icons.punch_clock),
                        const Gap(5),
                        InkWell(
                          onLongPress: () async {
                            final timeUnits = await intDialog(context);
                            if (timeUnits != null &&
                                timeUnits != user.timeUnits) {
                              locator<UserManager>().updateUserProperties(
                                  user: user, timeUnits: timeUnits);
                            }
                          },
                          child: Text(
                            user.timeUnits.toString(),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const Gap(10),
                  ],
                ),
              ),
              const Gap(20),
            ],
          ),
        ],
      ),
    );
  }
}
