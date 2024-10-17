import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/features/competence/pages/widgets/competence_check_dropdown_items.dart';
import 'package:schuldaten_hub/features/competence/services/competence_manager.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';

final GlobalKey<FormState> _competenceStatusKey = GlobalKey<FormState>();
final TextEditingController _textEditingController = TextEditingController();

// based on https://mobikul.com/creating-stateful-dialog-form-in-flutter/

Future competenceStatusDialog(
    PupilProxy pupil, int competenceId, BuildContext parentContext) async {
  return await showDialog(
      context: parentContext,
      builder: (context) {
        int competenceCheckStatusValue = 1;
        return StatefulBuilder(builder: (statefulContext, setState) {
          return AlertDialog(
            content: Form(
                key: _competenceStatusKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: backgroundColor),
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
                        Padding(
                          padding: const EdgeInsets.only(right: 5.0),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              icon: const Visibility(
                                  visible: false,
                                  child: Icon(Icons.arrow_downward)),
                              onTap: () {
                                FocusManager.instance.primaryFocus!.unfocus();
                              },
                              value: competenceCheckStatusValue,
                              items: competenceCheckDropdownItems,
                              onChanged: (newValue) {
                                setState(() {
                                  competenceCheckStatusValue = newValue!;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )),
            title: const Text('Neuer Competence Check'),
            actions: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.only(left: 15, right: 15, bottom: 10.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: dangerButtonColor,
                      minimumSize: const Size.fromHeight(50)),
                  onPressed: () {
                    _textEditingController.clear();
                    Navigator.of(parentContext).pop();
                  },
                  child: const Text(
                    "ABBRECHEN",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17.0,
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 15, right: 15, bottom: 10.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size.fromHeight(50)),
                  onPressed: () {
                    if (_competenceStatusKey.currentState!.validate()) {
                      locator<CompetenceManager>().postCompetenceCheck(
                          pupilId: pupil.internalId,
                          competenceId: competenceId,
                          competenceStatus: competenceCheckStatusValue,
                          competenceComment: _textEditingController.text,
                          isReport: false,
                          reportId: null);

                      _textEditingController.clear();
                      Navigator.of(parentContext).pop();
                    }
                  },
                  child: const Text(
                    "OKAY",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        });
      });
}
