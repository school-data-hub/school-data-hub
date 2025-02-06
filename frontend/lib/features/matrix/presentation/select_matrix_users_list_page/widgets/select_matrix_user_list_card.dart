import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/theme/app_colors.dart';
import 'package:schuldaten_hub/common/widgets/avatar.dart';
import 'package:schuldaten_hub/features/main_menu/widgets/landing_bottom_nav_bar.dart';
import 'package:schuldaten_hub/features/matrix/domain/matrix_user_helpers.dart';
import 'package:schuldaten_hub/features/matrix/domain/models/matrix_user.dart';
import 'package:schuldaten_hub/features/matrix/presentation/select_matrix_users_list_page/controller/select_matrix_users_list_controller.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_proxy.dart';
import 'package:schuldaten_hub/features/pupil/presentation/pupil_profile_page/pupil_profile_page.dart';
import 'package:schuldaten_hub/features/pupil/presentation/pupil_profile_page/widgets/pupil_profile_navigation.dart';
import 'package:watch_it/watch_it.dart';

class SelectMatrixUserCard extends WatchingWidget {
  final SelectMatrixUsersListController controller;
  final MatrixUser passedUser;

  const SelectMatrixUserCard(this.controller, this.passedUser, {super.key});
  @override
  Widget build(BuildContext context) {
    PupilProxy? pupil;

    final matrixUser = watch<MatrixUser>(passedUser);
    final MatrixUserRelationship? userRelationship =
        MatrixUserHelper.getUserRelationship(matrixUser);

    return GestureDetector(
      onLongPress: () => controller.onCardPress(matrixUser.id!),
      onTap: () =>
          controller.isSelectMode ? controller.onCardPress(matrixUser.id!) : {},
      child: Card(
          color: controller.selectedUsers.contains(matrixUser.id!)
              ? AppColors.selectedCardColor
              : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 1.0,
          margin: const EdgeInsets.only(
              left: 4.0, right: 4.0, top: 4.0, bottom: 4.0),
          child: Row(
            children: [
              const Gap(10),
              if (userRelationship?.isParent == true)
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
                          height: 90,
                          child: Padding(
                            padding: EdgeInsets.only(left: 5, right: 14),
                            child: Icon(Icons.school_rounded, size: 60),
                          ),
                        )
                      : const SizedBox(
                          width: 90,
                          height: 90,
                          child: Padding(
                            padding: EdgeInsets.only(left: 5, right: 14),
                            child: Icon(
                              Icons.question_mark_rounded,
                              size: 70,
                              color: Colors.red,
                            ),
                          ),
                        ),
              InkWell(
                onTap: () {
                  if (pupil != null) {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) => PupilProfilePage(
                        pupil: pupil!,
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
                                matrixUser.displayName,
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
