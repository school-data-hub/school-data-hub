import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:schuldaten_hub/common/domain/env_manager.dart';
import 'package:schuldaten_hub/common/domain/session_manager.dart';
import 'package:schuldaten_hub/common/services/api/api_settings.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/utils/extensions.dart';
import 'package:schuldaten_hub/common/widgets/custom_expansion_tile/custom_expansion_tile.dart';
import 'package:schuldaten_hub/common/widgets/custom_expansion_tile/custom_expansion_tile_content.dart';
import 'package:schuldaten_hub/common/widgets/custom_expansion_tile/custom_expansion_tile_switch.dart';
import 'package:schuldaten_hub/common/widgets/dialogs/confirmation_dialog.dart';
import 'package:schuldaten_hub/common/widgets/document_image.dart';
import 'package:schuldaten_hub/common/widgets/grades_widget.dart';
import 'package:schuldaten_hub/common/widgets/upload_image.dart';
import 'package:schuldaten_hub/features/workbooks/domain/models/workbook.dart';
import 'package:schuldaten_hub/features/workbooks/domain/workbook_manager.dart';
import 'package:schuldaten_hub/features/workbooks/presentation/new_workbook_page/new_workbook_controller.dart';
import 'package:watch_it/watch_it.dart';

class WorkbookCard extends WatchingWidget {
  const WorkbookCard({required this.workbook, super.key});
  final Workbook workbook;

  @override
  Widget build(BuildContext context) {
    final expansionTileController = createOnce<CustomExpansionTileController>(
        () => CustomExpansionTileController());
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Card(
          color: Colors.white,
          surfaceTintColor: Colors.white,
          child: InkWell(
            // onTap: () {
            //   Navigator.of(context).push(MaterialPageRoute(
            //     builder: (ctx) => SchoolListPupils(
            //       workbook,
            //     ),
            //   ));
            // },
            onLongPress: () async {
              // if (!locator<SessionManager>().isAdmin.value) {
              //   informationDialog(context, 'Keine Berechtigung',
              //       'Arbeitshefte können nur von Admins bearbeitet werden!');
              //   return;
              // }
              final bool? result = await confirmationDialog(
                  context: context,
                  title: 'Arbeitsheft löschen',
                  message:
                      'Arbeitsheft "${workbook.name}" wirklich löschen? ACHTUNG: Alle Arbeitshefte dieser Art werden ebenfalls gelöscht!');
              if (result == true) {
                await locator<WorkbookManager>().deleteWorkbook(workbook.isbn);
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 5),
              child: Row(
                children: [
                  const Gap(15),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Gap(10),
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
                                await locator<WorkbookManager>()
                                    .deleteWorkbookFile(workbook.isbn);
                              },
                        child: workbook.imageUrl != null
                            ? Provider<DocumentImageData>.value(
                                updateShouldNotify: (oldValue, newValue) =>
                                    oldValue.documentUrl !=
                                    newValue.documentUrl,
                                value: DocumentImageData(
                                    documentTag:
                                        workbook.imageUrl!.split('/').last,
                                    documentUrl:
                                        '${locator<EnvManager>().env!.serverUrl}${WorkbookApiService().getWorkbookImage(workbook.isbn)}',
                                    size: 140),
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
                      padding:
                          const EdgeInsets.only(top: 8.0, left: 15, bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onLongPress:
                                      (locator<SessionManager>().isAdmin.value)
                                          ? () async {
                                              Navigator.of(context)
                                                  .push(MaterialPageRoute(
                                                builder: (ctx) => NewWorkbook(
                                                  wbName: workbook.name,
                                                  wbIsbn: workbook.isbn,
                                                  wbSubject: workbook.subject,
                                                  wbLevel: workbook.level,
                                                  isEdit: true,
                                                ),
                                              ));
                                            }
                                          : () {},
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
                              ),
                              const Gap(10),
                            ],
                          ),
                          const Gap(5),
                          Row(
                            children: [
                              const Text('ISBN:'),
                              const Gap(10),
                              SelectableText(
                                workbook.isbn.displayAsIsbn(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const Gap(5),
                          Row(
                            children: [
                              const Text('Kompetenzbereich(e):'),
                              const Gap(10),
                              Text(
                                workbook.subject!,
                                overflow: TextOverflow.fade,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const Gap(5),
                          Row(
                            children: [
                              const Text('Kompetenzstufe:'),
                              const Gap(10),
                              GradesWidget(stringWithGrades: workbook.level!)
                            ],
                          ),
                          const Gap(5),
                          Row(
                            children: [
                              const Text('Bestand:'),
                              const Gap(10),
                              Text(
                                workbook.amount.toString(),
                                overflow: TextOverflow.fade,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const Spacer(),
                              CustomExpansionTileSwitch(
                                  expansionSwitchWidget:
                                      const Icon(Icons.arrow_downward),
                                  customExpansionTileController:
                                      expansionTileController),
                              const Gap(5)
                            ],
                          ),
                          const Gap(10),
                          CustomExpansionTileContent(
                              tileController: expansionTileController,
                              widgetList: [
                                // TODO: Add cards with pupilworkbooks
                              ]),
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
