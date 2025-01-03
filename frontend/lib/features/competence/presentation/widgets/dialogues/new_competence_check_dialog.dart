import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/theme/colors.dart';
import 'package:schuldaten_hub/common/theme/styles.dart';
import 'package:schuldaten_hub/features/competence/domain/competence_manager.dart';
import 'package:schuldaten_hub/features/competence/presentation/widgets/competence_check_dropdown.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_proxy.dart';

final GlobalKey<FormState> _competenceStatusKey = GlobalKey<FormState>();
final TextEditingController _textEditingController = TextEditingController();

// based on https://mobikul.com/creating-stateful-dialog-form-in-flutter/

Future newCompetenceCheckDialog(
    {required PupilProxy pupil,
    required int competenceId,
    required bool isReport,
    required BuildContext parentContext}) async {
  return await showDialog(
      context: parentContext,
      builder: (context) {
        int competenceCheckStatusValue = 0;
        return StatefulBuilder(builder: (statefulContext, setState) {
          void onChangedFunction(int newValue) {
            setState(() {
              competenceCheckStatusValue = newValue;
            });
          }

          return AlertDialog(
            content: Form(
                key: _competenceStatusKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.backgroundColor),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      width: 300,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          maxLines: 3,
                          textAlign: TextAlign.start,
                          style: const TextStyle(fontSize: 17),
                          keyboardType: TextInputType.multiline,
                          controller: _textEditingController,
                          decoration: null,
                        ),
                      ),
                    ),
                    const Gap(10),
                    Row(
                      children: [
                        const Text(
                          'Eine Stufe auswählen:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Gap(10),
                        GrowthDropdown(
                            dropdownValue: competenceCheckStatusValue,
                            onChangedFunction: onChangedFunction),
                      ],
                    ),
                  ],
                )),
            title: const Text('Neuer Kompetenzcheck'),
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: ElevatedButton(
                  style: AppStyles.cancelButtonStyle,
                  onPressed: () {
                    _textEditingController.clear();
                    Navigator.of(parentContext).pop();
                  },
                  child: const Text(
                    "ABBRECHEN",
                    style: AppStyles.buttonTextStyle,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: ElevatedButton(
                  style: AppStyles.successButtonStyle,
                  onPressed: () {
                    if (_competenceStatusKey.currentState!.validate()) {
                      locator<CompetenceManager>().postCompetenceCheck(
                          pupilId: pupil.internalId,
                          competenceId: competenceId,
                          competenceStatus: competenceCheckStatusValue,
                          competenceComment: _textEditingController.text,
                          isReport: isReport,
                          reportId: null);
                      // reportId:
                      //     locator<SchooldayManager>().currentReportId);

                      _textEditingController.clear();
                      Navigator.of(parentContext).pop();
                    }
                  },
                  child: const Text("SENDEN", style: AppStyles.buttonTextStyle),
                ),
              ),
            ],
          );
        });
      });
}
