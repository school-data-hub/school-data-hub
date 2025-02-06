import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:schuldaten_hub/common/domain/env_manager.dart';
import 'package:schuldaten_hub/common/domain/session_helper_functions.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/theme/app_colors.dart';
import 'package:schuldaten_hub/common/widgets/avatar.dart';
import 'package:schuldaten_hub/common/widgets/dialogs/confirmation_dialog.dart';
import 'package:schuldaten_hub/common/widgets/dialogs/long_textfield_dialog.dart';
import 'package:schuldaten_hub/common/widgets/document_image.dart';
import 'package:schuldaten_hub/common/widgets/upload_image.dart';
import 'package:schuldaten_hub/features/competence/data/competence_check_api_service.dart';
import 'package:schuldaten_hub/features/competence/domain/competence_helper.dart';
import 'package:schuldaten_hub/features/competence/domain/competence_manager.dart';
import 'package:schuldaten_hub/features/competence/domain/models/competence_check.dart';
import 'package:schuldaten_hub/features/competence/presentation/widgets/competence_check_dropdown.dart';
import 'package:schuldaten_hub/features/main_menu/widgets/landing_bottom_nav_bar.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_proxy.dart';
import 'package:schuldaten_hub/features/pupil/presentation/pupil_profile_page/pupil_profile_page.dart';
import 'package:watch_it/watch_it.dart';

class MultiPupilCompetenceCheckCard extends WatchingWidget {
  final String groupId;
  final int competenceId;
  final PupilProxy passedPupil;
  const MultiPupilCompetenceCheckCard(
      {required this.passedPupil,
      required this.groupId,
      required this.competenceId,
      super.key});

  @override
  Widget build(BuildContext context) {
    final pupil = watch(passedPupil);
    CompetenceCheck? competenceCheck =
        CompetenceHelper.getGroupCompetenceCheckFromPupil(
            pupil: pupil, groupId: groupId);

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
              AvatarWithBadges(pupil: pupil, size: 70),
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
                              onTap: () {
                                locator<MainMenuBottomNavManager>()
                                    .setPupilProfileNavPage(9);
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (ctx) => PupilProfilePage(
                                    pupil: pupil,
                                  ),
                                ));
                              },
                              child: Row(
                                children: [
                                  Text(
                                    pupil.firstName,
                                    overflow: TextOverflow.fade,
                                    softWrap: false,
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const Gap(5),
                                  Text(
                                    pupil.lastName,
                                    overflow: TextOverflow.fade,
                                    softWrap: false,
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const Gap(5),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(5),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Gap(5),
                        competenceCheck != null
                            ? GrowthDropdown(
                                dropdownValue: competenceCheck.competenceStatus,
                                onChangedFunction: (int? value) async {
                                  if (value ==
                                      competenceCheck.competenceStatus) {
                                    return;
                                  }
                                  await locator<CompetenceManager>()
                                      .updateCompetenceCheck(
                                          competenceCheckId:
                                              competenceCheck.checkId,
                                          competenceStatus: value);
                                },
                              )
                            : GrowthDropdown(
                                dropdownValue: 0,
                                onChangedFunction: (int? value) async {
                                  if (value == 0) {
                                    return;
                                  }
                                  await locator<CompetenceManager>()
                                      .postCompetenceCheck(
                                          pupilId: pupil.internalId,
                                          competenceId: competenceId,
                                          competenceComment: '',
                                          groupId: groupId,
                                          competenceStatus: value!);
                                },
                              ),
                        const Spacer(),
                        //- Take picture button only visible if there are less than 4 pictures
                        if (competenceCheck != null &&
                            competenceCheck.competenceCheckFiles!.length < 4)
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () async {
                                  final File? file =
                                      await uploadImageFile(context);
                                  if (file == null) return;
                                  await locator<CompetenceManager>()
                                      .postCompetenceCheckFile(
                                          competenceCheckId:
                                              competenceCheck.checkId,
                                          file: file);
                                },
                                onLongPress: () async {
                                  // bool? confirm = await confirmationDialog(
                                  //     context: context,
                                  //     title: 'Dokument löschen',
                                  //     message: 'Dokument löschen?');
                                  // if (confirm != true) {
                                  //   return;
                                  // }
                                  // await locator<CompetenceManager>()
                                  //     .deleteCompetenceCheckFile(
                                  //         competenceCheck.checkId,
                                  //         competenceCheck.competenceCheckFiles!
                                  //             .first.fileId!,
                                  //         true);
                                },
                                child: SizedBox(
                                  height: 70,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: Image.asset(
                                        'assets/document_camera.png'),
                                  ),
                                ),
                              )
                            ],
                          ),
                        if (competenceCheck != null &&
                            competenceCheck.competenceCheckFiles!.isNotEmpty)
                          for (CompetenceCheckFile file in competenceCheck
                              .competenceCheckFiles!) ...<Widget>[
                            const Gap(10),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () async {
                                    // final File? file = await uploadImage(context);
                                    // if (file == null) return;
                                    // await locator<CompetenceManager>()
                                    //     .patchCompetenceCheckWithFile(
                                    //         file, competenceCheck.checkId, true);
                                    // locator<NotificationService>().showSnackBar(
                                    //     NotificationType.success,
                                    //     'Vorfall geändert!');
                                  },
                                  onLongPress: () async {
                                    bool? confirm = await confirmationDialog(
                                        context: context,
                                        title: 'Dokument löschen',
                                        message: 'Dokument löschen?');
                                    if (confirm != true) {
                                      return;
                                    }
                                    await locator<CompetenceManager>()
                                        .deleteCompetenceCheckFile(
                                            competenceCheckId:
                                                competenceCheck.checkId,
                                            fileId: file.fileId);
                                  },
                                  child: Provider<DocumentImageData>.value(
                                    updateShouldNotify: (oldValue, newValue) =>
                                        oldValue.documentTag !=
                                        newValue.documentTag,
                                    value: DocumentImageData(
                                        documentTag: file.fileId,
                                        documentUrl:
                                            '${locator<EnvManager>().env!.serverUrl}${CompetenceCheckApiService().getCompetenceCheckFileUrl(file.fileId)}',
                                        size: 70),
                                    child: const DocumentImage(),
                                  ),
                                )
                              ],
                            ),
                          ],
                        if (competenceCheck == null)
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () async {
                                  final File? file =
                                      await uploadImageFile(context);

                                  if (file == null) return;
                                  await locator<CompetenceManager>()
                                      .postCompetenceCheckWithFile(
                                          pupilId: pupil.internalId,
                                          competenceId: competenceId,
                                          competenceComment: '',
                                          groupId: groupId,
                                          competenceStatus: 0,
                                          file: file);
                                },
                                child: SizedBox(
                                  height: 70,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: Image.asset(
                                        'assets/document_camera.png'),
                                  ),
                                ),
                              )
                            ],
                          ),
                        const Gap(5),
                      ],
                    ),
                    const Gap(10),
                  ],
                ),
              ),
              const Gap(5),
            ],
          ),
          if (competenceCheck != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Gap(10),
                InkWell(
                  onTap: () async {
                    if (SessionHelper.isAuthorized(competenceCheck.createdBy)) {
                      final String? comment = await longTextFieldDialog(
                        parentContext: context,
                        title: 'Kommentar',
                        labelText: 'Kommentar eingeben',
                        textinField: competenceCheck.comment,
                      );
                      if (comment != null) {
                        await locator<CompetenceManager>()
                            .updateCompetenceCheck(
                                competenceCheckId: competenceCheck.checkId,
                                competenceComment: comment);
                      }
                    }
                  },
                  child: const Text(
                    'Kommentar:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.interactiveColor,
                    ),
                  ),
                ),
                const Gap(5),
                Flexible(
                  child: InkWell(
                    onTap: () async {
                      if (SessionHelper.isAuthorized(
                          competenceCheck.createdBy)) {
                        final String? comment = await longTextFieldDialog(
                            parentContext: context,
                            title: 'Kommentar',
                            labelText: 'Kommentar eingeben',
                            textinField: competenceCheck.comment);
                        if (comment != null) {
                          await locator<CompetenceManager>()
                              .updateCompetenceCheck(
                                  competenceCheckId: competenceCheck.checkId,
                                  competenceComment: comment);
                        }
                      }
                    },
                    child: Text(
                      (competenceCheck.comment.isEmpty)
                          ? 'Kein Kommentar'
                          : competenceCheck.comment,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Gap(10),
          ]
        ],
      ),
    );
  }
}
