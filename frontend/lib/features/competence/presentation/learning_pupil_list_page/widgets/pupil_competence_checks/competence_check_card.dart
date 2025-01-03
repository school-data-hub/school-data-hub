import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:schuldaten_hub/common/domain/env_manager.dart';
import 'package:schuldaten_hub/common/domain/session_helper_functions.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/theme/colors.dart';
import 'package:schuldaten_hub/common/utils/extensions.dart';
import 'package:schuldaten_hub/common/widgets/date_picker.dart';
import 'package:schuldaten_hub/common/widgets/dialogs/confirmation_dialog.dart';
import 'package:schuldaten_hub/common/widgets/dialogs/short_textfield_dialog.dart';
import 'package:schuldaten_hub/common/widgets/document_image.dart';
import 'package:schuldaten_hub/common/widgets/upload_image.dart';
import 'package:schuldaten_hub/features/competence/data/competence_check_repository.dart';
import 'package:schuldaten_hub/features/competence/domain/competence_helper.dart';
import 'package:schuldaten_hub/features/competence/domain/competence_manager.dart';
import 'package:schuldaten_hub/features/competence/domain/models/competence_check.dart';
import 'package:schuldaten_hub/features/competence/presentation/widgets/competence_check_dropdown.dart';
import 'package:schuldaten_hub/features/schooldays/domain/schoolday_manager.dart';

class CompetenceCheckCard extends StatelessWidget {
  final CompetenceCheck competenceCheck;
  const CompetenceCheckCard({required this.competenceCheck, super.key});

  @override
  Widget build(BuildContext context) {
    final isAuthorized = SessionHelper.isAuthorized(competenceCheck.createdBy);
    return Padding(
      padding: const EdgeInsets.only(left: 5.0, right: 5),
      child: InkWell(
        onLongPress: () async {
          final bool? confirm = await confirmationDialog(
              context: context,
              title: 'Kompetenzcheck löschen',
              message: 'Kompetenzcheck löschen?');
          if (confirm == true) {
            locator<CompetenceManager>()
                .deleteCompetenceCheck(competenceCheck.checkId);
          }
        },
        child: Card(
          color: AppColors.cardInCardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(
              color: AppColors.cardInCardBorderColor,
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    isAuthorized
                        ? InkWell(
                            onTap: () async {
                              DateTime? date = await selectSchooldayDate(
                                  context,
                                  locator<SchooldayManager>().thisDate.value);
                              if (date == null) return;
                              await locator<CompetenceManager>()
                                  .updateCompetenceCheck(
                                      competenceCheckId:
                                          competenceCheck.checkId,
                                      createdAt: date);
                            },
                            child: Text(
                              competenceCheck.createdAt.formatForUser(),
                              style: const TextStyle(
                                color: AppColors.interactiveColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          )
                        : Text(
                            competenceCheck.createdAt.formatForUser(),
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                    const Spacer(),
                    const Text('Erstellt von:', style: TextStyle(fontSize: 16)),
                    const Gap(5),
                    // only admin can change the admonishing user
                    isAuthorized
                        ? InkWell(
                            onTap: () async {
                              final String? user = await shortTextfieldDialog(
                                  context: context,
                                  title: 'Erstellt von:',
                                  labelText: 'Kürzel eingeben',
                                  hintText: 'Kürzel eingeben',
                                  obscureText: false);
                              if (user != null) {
                                await locator<CompetenceManager>()
                                    .updateCompetenceCheck(
                                  competenceCheckId: competenceCheck.checkId,
                                  createdBy: user,
                                );
                              }
                            },
                            child: Text(
                              competenceCheck.createdBy,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: AppColors.backgroundColor),
                            ),
                          )
                        : Text(
                            competenceCheck.createdBy,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                    const Gap(5),
                  ],
                ),
                const Gap(10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Gap(5),
                    isAuthorized
                        ? GrowthDropdown(
                            dropdownValue: competenceCheck.competenceStatus,
                            onChangedFunction: (int? value) async {
                              if (value == competenceCheck.competenceStatus) {
                                return;
                              }
                              await locator<CompetenceManager>()
                                  .updateCompetenceCheck(
                                      competenceCheckId:
                                          competenceCheck.checkId,
                                      competenceStatus: value);
                            },
                          )
                        : Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: CompetenceHelper.getCompetenceCheckSymbol(
                                status: competenceCheck.competenceStatus,
                                size: 60),
                          ),
                    const Spacer(),
                    //- Take picture button only visible if there are less than 4 pictures
                    if (competenceCheck.competenceCheckFiles!.length < 4)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () async {
                              final File? file = await uploadImage(context);
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
                                child:
                                    Image.asset('assets/document_camera.png'),
                              ),
                            ),
                          )
                        ],
                      ),
                    if (competenceCheck.competenceCheckFiles!.isNotEmpty)
                      for (CompetenceCheckFile file
                          in competenceCheck.competenceCheckFiles!) ...<Widget>[
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
                                        '${locator<EnvManager>().env.value.serverUrl}${CompetenceCheckRepository().getCompetenceCheckFileUrl(file.fileId)}',
                                    size: 70),
                                child: const DocumentImage(),
                              ),
                            )
                          ],
                        ),
                      ],

                    const Gap(5),
                  ],
                ),
                const Gap(15),
                Row(
                  children: [
                    InkWell(
                      onTap: () async {
                        if (isAuthorized) {
                          final String? comment = await shortTextfieldDialog(
                              context: context,
                              title: 'Status',
                              labelText: 'Status eingeben',
                              hintText: 'Status eingeben',
                              obscureText: false);
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
                          if (isAuthorized) {
                            final String? comment = await shortTextfieldDialog(
                                context: context,
                                title: 'Kommentar',
                                labelText: 'Kommentar eingeben',
                                hintText: 'Kommentar eingeben',
                                obscureText: false);
                            if (comment != null) {
                              await locator<CompetenceManager>()
                                  .updateCompetenceCheck(
                                      competenceCheckId:
                                          competenceCheck.checkId,
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CompetenceFileCheck {}
