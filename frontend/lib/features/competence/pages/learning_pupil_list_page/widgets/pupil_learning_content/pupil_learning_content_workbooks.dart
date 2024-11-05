import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/constants/enums.dart';
import 'package:schuldaten_hub/common/constants/styles.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_manager.dart';
import 'package:schuldaten_hub/common/utils/scanner.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';
import 'package:schuldaten_hub/features/workbooks/models/pupil_workbook.dart';
import 'package:schuldaten_hub/features/workbooks/pages/new_workbook_page/new_workbook_page.dart';
import 'package:schuldaten_hub/features/workbooks/pages/workbook_list_page/widgets/pupil_workbook_card.dart';
import 'package:schuldaten_hub/features/workbooks/services/workbook_manager.dart';

class PupilLearningContentWorkbooks extends StatelessWidget {
  final PupilProxy pupil;
  const PupilLearningContentWorkbooks({required this.pupil, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          children: [
            Text(
              'Arbeitshefte',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const Gap(10),
        ElevatedButton(
          style: actionButtonStyle,
          //- TODO: strip this logic and use a controller instead
          onPressed: () async {
            final scanResult = await scanner(context, 'ISBN code scannen');
            if (scanResult != null) {
              final scannedIsbn = int.parse(scanResult);
              if (!locator<WorkbookManager>()
                  .workbooks
                  .value
                  .any((element) => element.isbn == scannedIsbn)) {
                if (context.mounted) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) => NewWorkbookPage(
                            isEdit: false,
                            wbIsbn: scannedIsbn,
                          )));
                }
                locator<NotificationManager>().showInformationDialog(
                    'Das Arbeitsheft wurde noch nicht erfasst. Bitte hinzufügen!');
                return;
              }
              if (pupil.pupilWorkbooks!.isNotEmpty) {
                if (pupil.pupilWorkbooks!.any((element) =>
                    element.workbookIsbn == int.parse(scanResult))) {
                  locator<NotificationManager>().showSnackBar(
                      NotificationType.error,
                      'Dieses Arbeitsheft ist schon erfasst!');
                  return;
                }
              }
              locator<WorkbookManager>()
                  .newPupilWorkbook(pupil.internalId, int.parse(scanResult));
              return;
            }
            locator<NotificationManager>()
                .showSnackBar(NotificationType.error, 'Fehler beim Scannen');
          },
          child: const Text(
            "NEUES ARBEITSHEFT",
            style: buttonTextStyle,
          ),
        ),
        if (pupil.pupilWorkbooks!.isNotEmpty) ...[
          const Gap(15),
          ListView.builder(
            padding: const EdgeInsets.all(0),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: pupil.pupilWorkbooks!.length,
            itemBuilder: (context, int index) {
              List<PupilWorkbook> pupilWorkbooks = pupil.pupilWorkbooks!;

              return ClipRRect(
                borderRadius: BorderRadius.circular(25.0),
                child: Column(
                  children: [
                    PupilWorkbookCard(
                        pupilWorkbook: pupilWorkbooks[index],
                        pupilId: pupil.internalId),
                  ],
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}
