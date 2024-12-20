import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/domain/models/enums.dart';
import 'package:schuldaten_hub/common/domain/session_manager.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_service.dart';
import 'package:schuldaten_hub/common/theme/colors.dart';
import 'package:schuldaten_hub/common/widgets/avatar.dart';
import 'package:schuldaten_hub/common/widgets/dialogs/confirmation_dialog.dart';
import 'package:schuldaten_hub/common/widgets/dialogs/information_dialog.dart';
import 'package:schuldaten_hub/common/widgets/dialogs/long_textfield_dialog.dart';
import 'package:schuldaten_hub/features/main_menu/widgets/landing_bottom_nav_bar.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_proxy.dart';
import 'package:schuldaten_hub/features/pupil/domain/pupil_manager.dart';
import 'package:schuldaten_hub/features/pupil/presentation/pupil_profile_page/pupil_profile_page.dart';
import 'package:schuldaten_hub/features/school_lists/domain/models/pupil_list.dart';
import 'package:schuldaten_hub/features/school_lists/domain/models/school_list.dart';
import 'package:schuldaten_hub/features/school_lists/domain/school_list_helper_functions.dart';
import 'package:schuldaten_hub/features/school_lists/domain/school_list_manager.dart';
import 'package:watch_it/watch_it.dart';

class SchoolListPupilCard extends WatchingWidget {
  final int internalId;

  final SchoolList originList;

  SchoolListPupilCard(this.internalId, this.originList, {super.key});

  final schoolListLocator = locator<SchoolListManager>();

  @override
  Widget build(BuildContext context) {
    final PupilProxy pupil = locator<PupilManager>().findPupilById(internalId)!;

    final thisSchoolList = watchValue((SchoolListManager x) => x.schoolLists)
        .firstWhere((element) => element.listId == originList.listId);

    final PupilList pupilList = thisSchoolList.pupilLists
        .firstWhere((element) => element.listedPupilId == internalId);

    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8, right: 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AvatarWithBadges(pupil: pupil, size: 80),
            const SizedBox(width: 10), // Add some spacing
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        locator<BottomNavManager>().setPupilProfileNavPage(6);
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (ctx) => PupilProfilePage(
                            pupil: pupil,
                          ),
                        ));
                      },
                      onLongPress: () async {
                        if (!locator<SessionManager>().isAdmin.value) {
                          if (SchoolListHelper.listOwner(
                                  pupilList.originList) !=
                              locator<SessionManager>()
                                  .credentials
                                  .value
                                  .username) {
                            locator<NotificationService>().showSnackBar(
                                NotificationType.error,
                                'Löschen nicht möglich - keine Berechtigung!');

                            return;
                          }
                        }
                        final bool? confirm = await confirmationDialog(
                            context: context,
                            title: 'Kind aus der Liste löschen',
                            message:
                                '${pupil.firstName} wirklich aus der Liste löschen?');
                        if (confirm != true) {
                          return;
                        }
                        await locator<SchoolListManager>()
                            .deletePupilsFromSchoolList(
                                [pupil.internalId], originList.listId);
                        if (context.mounted) {
                          informationDialog(context, 'Kind aus Liste gelöscht',
                              'Das Kind wurde gelöscht!');
                        }
                      },
                      child: Text(
                        '${pupil.firstName} ${pupil.lastName}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Gap(5),
                    InkWell(
                      onTap: () async {
                        final listComment = await longTextFieldDialog(
                            title: 'Kommentar ändern',
                            labelText: 'Kommentar',
                            textinField: pupilList.pupilListComment ?? '',
                            parentContext: context);
                        if (listComment == null) {
                          return;
                        }
                        await locator<SchoolListManager>().patchPupilList(
                          pupil.internalId,
                          originList.listId,
                          null,
                          listComment == '' ? null : listComment,
                        );
                      },
                      child: Text(
                          pupilList.pupilListComment != null &&
                                  pupilList.pupilListComment != ''
                              ? pupilList.pupilListComment!
                              : 'kein Kommentar',
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.backgroundColor,
                          )),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 5), // Add some spacing
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Gap(10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.close,
                      color: Colors.red,
                    ),
                    SizedBox(
                      width: 25,
                      height: 25,
                      child: Checkbox(
                        activeColor: Colors.red,
                        value: (pupilList.pupilListStatus == null ||
                                pupilList.pupilListStatus == true)
                            ? false
                            : true,
                        onChanged: (value) async {
                          await schoolListLocator.patchPupilList(
                            pupil.internalId,
                            originList.listId,
                            false,
                            null,
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const Gap(15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(
                      Icons.done,
                      color: Colors.green,
                    ),
                    SizedBox(
                      width: 25,
                      height: 25,
                      child: Checkbox(
                        activeColor: Colors.green,
                        value: (pupilList.pupilListStatus != true ||
                                pupilList.pupilListStatus == null)
                            ? false
                            : true,
                        onChanged: (value) async {
                          await schoolListLocator.patchPupilList(
                            pupil.internalId,
                            originList.listId,
                            true,
                            null,
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const Gap(10),
                if (pupilList.pupilListEntryBy != null)
                  Row(
                    children: [
                      Text(
                        pupilList.pupilListEntryBy!,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
