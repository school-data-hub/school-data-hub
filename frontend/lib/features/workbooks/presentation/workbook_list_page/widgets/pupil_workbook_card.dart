import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:schuldaten_hub/common/domain/env_manager.dart';
import 'package:schuldaten_hub/common/domain/session_manager.dart';
import 'package:schuldaten_hub/common/services/api/api_settings.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/utils/extensions.dart';
import 'package:schuldaten_hub/common/widgets/dialogues/confirmation_dialog.dart';
import 'package:schuldaten_hub/common/widgets/dialogues/information_dialog.dart';
import 'package:schuldaten_hub/common/widgets/document_image.dart';
import 'package:schuldaten_hub/common/widgets/upload_image.dart';
import 'package:schuldaten_hub/features/workbooks/domain/models/pupil_workbook.dart';
import 'package:schuldaten_hub/features/workbooks/domain/models/workbook.dart';
import 'package:schuldaten_hub/features/workbooks/domain/workbook_manager.dart';
import 'package:watch_it/watch_it.dart';

class PupilWorkbookCard extends WatchingWidget {
  const PupilWorkbookCard(
      {required this.pupilWorkbook, required this.pupilId, super.key});
  final PupilWorkbook pupilWorkbook;
  final int pupilId;

  @override
  Widget build(BuildContext context) {
    final Workbook workbook = locator<WorkbookManager>()
        .getWorkbookByIsbn(pupilWorkbook.workbookIsbn)!;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Card(
          child: InkWell(
        // onTap: () {
        //   Navigator.of(context).push(MaterialPageRoute(
        //     builder: (ctx) => SchoolListPupils(
        //       workbook,
        //     ),
        //   ));
        // },
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
          padding: const EdgeInsets.only(top: 8.0, bottom: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(5),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () async {
                      final File? file = await uploadImage(context);
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
                                oldValue.documentUrl != newValue.documentUrl,
                            value: DocumentImageData(
                                documentTag: workbook.imageUrl!,
                                documentUrl:
                                    '${locator<EnvManager>().env.value.serverUrl}${WorkbookRepository().getWorkbookImage(workbook.isbn)}',
                                size: 100),
                            child: const DocumentImage(),
                          )
                        : SizedBox(
                            height: 100,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Image.asset('assets/document_camera.png'),
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
                                    fontSize: 20, fontWeight: FontWeight.bold),
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
                      Row(
                        children: [
                          Text(workbook.subject!,
                              overflow: TextOverflow.fade,
                              style: const TextStyle(
                                fontSize: 14,
                              )),
                          const Spacer(),
                          Text(
                            workbook.level!,
                            maxLines: 2,
                            overflow: TextOverflow.fade,
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          const Gap(10),
                        ],
                      ),
                      const Gap(5),
                      Row(
                        children: [
                          const Text('Erstellt von:'),
                          const Gap(5),
                          Text(
                            pupilWorkbook.createdBy,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Gap(5),
                          const Text('am'),
                          const Gap(5),
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
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
