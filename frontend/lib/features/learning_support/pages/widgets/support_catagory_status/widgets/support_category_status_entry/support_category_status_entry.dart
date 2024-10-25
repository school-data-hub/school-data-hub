import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/utils/extensions.dart';
import 'package:schuldaten_hub/common/widgets/dialogues/confirmation_dialog.dart';
import 'package:schuldaten_hub/common/widgets/dialogues/information_dialog.dart';
import 'package:schuldaten_hub/common/widgets/dialogues/long_textfield_dialog.dart';
import 'package:schuldaten_hub/common/widgets/dialogues/short_textfield_dialog.dart';
import 'package:schuldaten_hub/features/learning_support/models/support_category/support_category_status.dart';
import 'package:schuldaten_hub/features/learning_support/services/learning_support_helper_functions.dart';
import 'package:schuldaten_hub/features/learning_support/services/learning_support_manager.dart';
import 'package:schuldaten_hub/features/learning_support/pages/widgets/support_catagory_status/widgets/support_category_status_entry/support_category_status_symbol.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';

class SupportCategoryStatusEntry extends StatelessWidget {
  final PupilProxy pupil;
  final SupportCategoryStatus status;

  const SupportCategoryStatusEntry(
      {required this.pupil, required this.status, super.key});

  @override
  Widget build(BuildContext context) {
    final bool authorizedToChangeStatus =
        LearningSupportHelper.isAuthorizedToChangeStatus(status);
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 8),
      child: InkWell(
        onLongPress: () async {
          if (!authorizedToChangeStatus) {
            informationDialog(context, 'Keine Berechtigung',
                'Keine Berechtigung für das Löschen des Status!');
            return;
          }
          bool? confirm = await confirmationDialog(
              context: context,
              title: 'Status löschen?',
              message: 'Status löschen?');
          if (confirm != true) return;
          locator<LearningSupportManager>()
              .deleteSupportCategoryStatus(status.statusId);
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                getSupportCategoryStatusSymbol(
                    pupil, status.supportCategoryId, status.statusId),
              ],
            ),
            const Gap(10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  authorizedToChangeStatus
                      ? InkWell(
                          onTap: () async {
                            final String? correctedComment =
                                await longTextFieldDialog('Status korrigieren',
                                    status.comment, context);
                            if (correctedComment != null) {
                              locator<LearningSupportManager>()
                                  .updateSupportCategoryStatusProperty(
                                pupil: pupil,
                                statusId: status.statusId,
                                comment: correctedComment,
                              );
                            }
                          },
                          child: Text(status.comment,
                              style: const TextStyle(
                                color: interactiveColor,
                                fontWeight: FontWeight.bold,
                              )))
                      : Text(status.comment),
                  const Gap(5),
                  Wrap(
                    children: [
                      const Text('Eingetragen von '),
                      const Gap(5),
                      authorizedToChangeStatus
                          ? InkWell(
                              onTap: () async {
                                final String? correctedCreatedBy =
                                    await shortTextfieldDialog(
                                        title: 'Ersteller ändern',
                                        obscureText: false,
                                        hintText: 'Kürzel eintragen',
                                        labelText: status.createdBy,
                                        context: context);
                                if (correctedCreatedBy != null) {
                                  locator<LearningSupportManager>()
                                      .updateSupportCategoryStatusProperty(
                                    pupil: pupil,
                                    statusId: status.statusId,
                                    createdBy: correctedCreatedBy,
                                  );
                                }
                              },
                              child: Text(
                                status.createdBy,
                                style: const TextStyle(
                                  color: interactiveColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : Text(
                              status.createdBy,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      const Text(' am '),
                      authorizedToChangeStatus
                          ? InkWell(
                              onTap: () async {
                                final DateTime? correctedCreatedAt =
                                    await showDatePicker(
                                  context: context,
                                  initialDate: status.createdAt,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime.now(),
                                );
                                if (correctedCreatedAt != null) {
                                  locator<LearningSupportManager>()
                                      .updateSupportCategoryStatusProperty(
                                    pupil: pupil,
                                    statusId: status.statusId,
                                    createdAt:
                                        correctedCreatedAt.formatForJson(),
                                  );
                                }
                              },
                              child: Text(
                                status.createdAt.formatForUser(),
                                style: const TextStyle(
                                  color: interactiveColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : Text(
                              status.createdAt.formatForUser(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
