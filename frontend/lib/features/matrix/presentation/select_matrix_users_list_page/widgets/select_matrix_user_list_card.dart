import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/features/matrix/domain/models/matrix_user.dart';
import 'package:schuldaten_hub/features/matrix/presentation/select_matrix_users_list_page/controller/select_matrix_users_list_controller.dart';
import 'package:schuldaten_hub/features/pupil/domain/filters/pupils_filter.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_proxy.dart';
import 'package:schuldaten_hub/common/widgets/avatar.dart';
import 'package:schuldaten_hub/features/pupil/presentation/pupil_profile_page/pupil_profile_page.dart';

import 'package:watch_it/watch_it.dart';

class SelectMatrixUserCard extends WatchingWidget {
  final SelectMatrixUsersListController controller;
  final MatrixUser passedUser;

  const SelectMatrixUserCard(this.controller, this.passedUser, {super.key});
  @override
  Widget build(BuildContext context) {
    final MatrixUser user = watch(passedUser);
    final PupilProxy? pupil = locator<PupilsFilter>()
        .filteredPupils
        .value
        .firstWhereOrNull((pupil) => pupil.contact! == user.id!);

    return GestureDetector(
      onLongPress: () => controller.onCardPress(user.id!),
      onTap: () =>
          controller.isSelectMode ? controller.onCardPress(user.id!) : {},
      child: Card(
          color: controller.selectedUsers.contains(user.id!)
              ? const Color.fromARGB(255, 197, 212, 255)
              : Colors.white,
          child: Row(
            children: [
              if (pupil != null) AvatarWithBadges(pupil: pupil, size: 80),
              InkWell(
                onTap: () {
                  if (pupil != null) {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) => PupilProfilePage(
                        pupil: pupil,
                      ),
                    ));
                  }
                },
                child: SizedBox(
                  width: 200,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Text(
                                user.displayName,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          )
                        ],
                      ),
                      // Gap(5),
                      // Row(
                      //   children: [
                      //     Text('bisjetzt verdient:'),
                      //     Gap(10),
                      //     Text(
                      //       pupil.creditEarned.toString(),
                      //       style: TextStyle(
                      //         fontWeight: FontWeight.bold,
                      //         fontSize: 18,
                      //       ),
                      //     )
                      //   ],
                      // )
                    ],
                  ),
                ),
              ),
            ],
          )),
    );
  }
}
