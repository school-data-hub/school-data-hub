import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:schuldaten_hub/common/domain/env_manager.dart';
import 'package:schuldaten_hub/common/domain/session_manager.dart';
import 'package:schuldaten_hub/common/services/api/api_settings.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/theme/app_colors.dart';
import 'package:schuldaten_hub/common/utils/extensions.dart';
import 'package:schuldaten_hub/common/widgets/dialogs/confirmation_dialog.dart';
import 'package:schuldaten_hub/common/widgets/dialogs/information_dialog.dart';
import 'package:schuldaten_hub/common/widgets/dialogs/long_textfield_dialog.dart';
import 'package:schuldaten_hub/common/widgets/dialogs/short_textfield_dialog.dart';
import 'package:schuldaten_hub/common/widgets/document_image.dart';
import 'package:schuldaten_hub/common/widgets/grades_widget.dart';
import 'package:schuldaten_hub/common/widgets/upload_image.dart';
import 'package:schuldaten_hub/features/competence/domain/models/enums.dart';
import 'package:schuldaten_hub/features/competence/presentation/widgets/competence_check_dropdown.dart';
import 'package:schuldaten_hub/features/workbooks/domain/models/pupil_workbook.dart';
import 'package:schuldaten_hub/features/workbooks/domain/models/workbook.dart';
import 'package:schuldaten_hub/features/workbooks/domain/workbook_manager.dart';
import 'package:watch_it/watch_it.dart';

class PupilWorkbookCard extends WatchingWidget {
  const PupilWorkbookCard(
      {required this.pupilWorkbook, required this.pupilId, super.key});
  final PupilWorkbook pupilWorkbook;
  final int pupilId;

  void onChangedGrowthDropdown(int value) {
    locator<WorkbookManager>().updatePupilWorkbook(
        pupilId: pupilId, isbn: pupilWorkbook.workbookIsbn, status: value);
  }

  @override
  Widget build(BuildContext context) {
    final Workbook workbook = locator<WorkbookManager>()
        .getWorkbookByIsbn(pupilWorkbook.workbookIsbn)!;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Card(
          child: InkWell(
        onLongPress: () async {
          if (pupilWorkbook.createdBy !=
                  locator<SessionManager>().credentials.value.username ||
              !locator<SessionManager>().credentials.value.isAdmin!) {
            informationDialog(context, 'Keine Berechtigung',
                'Arbeitshefte können nur von der eintragenden Person bearbeitet werden!');
            return;
          }
          final bool? result = await confirmationDialog(
              context: context,
              title: 'Arbeitsheft löschen',
              message: 'Arbeitsheft "${workbook.name}" wirklich löschen?');
          if (result == true) {
            locator<WorkbookManager>()
                .deletePupilWorkbook(pupilId, workbook.isbn);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Gap(5),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () async {
                          final File? file = await uploadImageFile(context);
                          if (file == null) return;
                          await locator<WorkbookManager>()
                              .postWorkbookFile(file, workbook.isbn);
                        },
                        onLongPress: (workbook.imageUrl == null)
                            ? () {}
                            : () async {
                                if (workbook.imageUrl == null) {
                                  return;
                                }
                                final bool? result = await confirmationDialog(
                                    context: context,
                                    title: 'Bild löschen',
                                    message: 'Bild löschen?');
                                if (result != true) return;
                                // await locator<WorkbookManager>()
                                //     .deleteAuthorizationFile(
                                //   pupil.internalId,
                                //   authorizationId,
                                //   pupilAuthorization.fileId!,
                                // );
                              },
                        child: workbook.imageUrl != null
                            ? Provider<DocumentImageData>.value(
                                updateShouldNotify: (oldValue, newValue) =>
                                    oldValue.documentUrl !=
                                    newValue.documentUrl,
                                value: DocumentImageData(
                                    documentTag: workbook.imageUrl!,
                                    documentUrl:
                                        '${locator<EnvManager>().env!.serverUrl}${WorkbookApiService().getWorkbookImage(workbook.isbn)}',
                                    size: 100),
                                child: const DocumentImage(),
                              )
                            : SizedBox(
                                height: 100,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child:
                                      Image.asset('assets/document_camera.png'),
                                ),
                              ),
                      ),
                      const Gap(10),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, bottom: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Text(
                                    workbook.name,
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const Gap(10),
                            ],
                          ),
                          const Gap(5),
                          // Row(
                          //   children: [
                          //     const Text('ISBN:'),
                          //     const Gap(10),
                          //     Text(
                          //       workbook.isbn.toString(),
                          //       style: const TextStyle(
                          //         fontSize: 16,
                          //         fontWeight: FontWeight.bold,
                          //         color: Colors.black,
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          // const Gap(5),
                          Row(children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                        RootCompetenceType
                                            .stringToValue[workbook.subject!]!
                                            .value,
                                        overflow: TextOverflow.fade,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        )),
                                    const Gap(5),
                                    GradesWidget(
                                        stringWithGrades: workbook.level!),
                                  ],
                                ),
                                const Gap(5),
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () async {
                                        if (!locator<SessionManager>()
                                            .isAuthorized(
                                                pupilWorkbook.createdBy)) {
                                          informationDialog(
                                              context,
                                              'Keine Berechtigung',
                                              'Arbeitshefte können nur von der eingetragenen Person oder von einem Admin bearbeitet werden!');
                                          return;
                                        }
                                        final createdBy =
                                            await shortTextfieldDialog(
                                                context: context,
                                                title: 'Betreuer:in ändern',
                                                labelText:
                                                    'Betreuer:in eintragen',
                                                hintText:
                                                    'Wer soll das Arbeitsheft betreuen?');
                                        if (createdBy == null) return;
                                        locator<WorkbookManager>()
                                            .updatePupilWorkbook(
                                                pupilId: pupilId,
                                                isbn:
                                                    pupilWorkbook.workbookIsbn,
                                                createdBy: createdBy);
                                      },
                                      child: Text(
                                        pupilWorkbook.createdBy,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const Gap(2),
                                    const Icon(
                                      Icons.arrow_circle_right_rounded,
                                      color: Colors.orange,
                                    ),
                                    const Gap(2),
                                    Text(
                                      pupilWorkbook.createdAt.formatForUser(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  ],
                                ),
                                const Gap(10),
                              ],
                            ),
                            const Spacer(),
                            Column(
                              children: [
                                GrowthDropdown(
                                    dropdownValue: pupilWorkbook.status ?? 0,
                                    onChangedFunction: onChangedGrowthDropdown),
                              ],
                            )
                          ])
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(10),
              const Text('Kommentar:'),
              const Gap(5),
              InkWell(
                onTap: () async {
                  final comment = await longTextFieldDialog(
                      title: 'Kommentar',
                      textinField: pupilWorkbook.comment ?? '',
                      labelText: 'Kommentar eintragen',
                      parentContext: context);
                  if (comment == null) return;
                  locator<WorkbookManager>().updatePupilWorkbook(
                      pupilId: pupilId,
                      isbn: pupilWorkbook.workbookIsbn,
                      comment: comment);
                },
                child: Text(
                  pupilWorkbook.comment == null || pupilWorkbook.comment! == ''
                      ? 'Kein Kommentar'
                      : pupilWorkbook.comment!,
                  style: const TextStyle(
                      fontSize: 16, color: AppColors.interactiveColor),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
