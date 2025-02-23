import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/domain/models/enums.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_service.dart';
import 'package:schuldaten_hub/common/theme/styles.dart';
import 'package:schuldaten_hub/common/utils/scanner.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_proxy.dart';
import 'package:schuldaten_hub/features/workbooks/domain/models/pupil_workbook.dart';
import 'package:schuldaten_hub/features/workbooks/domain/workbook_manager.dart';
import 'package:schuldaten_hub/features/workbooks/presentation/new_workbook_page/new_workbook_controller.dart';
import 'package:schuldaten_hub/features/workbooks/presentation/workbook_list_page/widgets/pupil_workbook_card.dart';

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
          style: AppStyles.actionButtonStyle,
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
                      builder: (ctx) => NewWorkbook(
                            isEdit: false,
                            wbIsbn: scannedIsbn,
                          )));
                }
                locator<NotificationService>().showInformationDialog(
                    'Das Arbeitsheft wurde noch nicht erfasst. Bitte hinzufügen!');
                return;
              }
              if (pupil.pupilWorkbooks!.isNotEmpty) {
                if (pupil.pupilWorkbooks!.any((element) =>
                    element.workbookIsbn == int.parse(scanResult))) {
                  locator<NotificationService>().showSnackBar(
                      NotificationType.error,
                      'Dieses Arbeitsheft ist schon erfasst!');
                  return;
                }
              }
              locator<WorkbookManager>()
                  .newPupilWorkbook(pupil.internalId, int.parse(scanResult));
              return;
            }
            locator<NotificationService>()
                .showSnackBar(NotificationType.error, 'Fehler beim Scannen');
          },
          child: const Text(
            "NEUES ARBEITSHEFT",
            style: AppStyles.buttonTextStyle,
          ),
        ),
        const Gap(15),
        if (pupil.pupilWorkbooks!.isNotEmpty) ...[
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
