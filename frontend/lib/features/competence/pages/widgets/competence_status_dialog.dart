import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';
import 'package:schuldaten_hub/features/learning_support/widgets/support_category_widgets/support_category_status_dropdown_items.dart';

final GlobalKey<FormState> _competenceStatusKey = GlobalKey<FormState>();
final TextEditingController _textEditingController = TextEditingController();

// based on https://mobikul.com/creating-stateful-dialog-form-in-flutter/

Future competenceStatusDialog(
    PupilProxy pupil, int goalCategoryId, BuildContext parentContext) async {
  return await showDialog(
      context: parentContext,
      builder: (context) {
        String categoryStatusValue = 'white';
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
                            child: DropdownButton<String>(
                              icon: const Visibility(
                                  visible: false,
                                  child: Icon(Icons.arrow_downward)),
                              onTap: () {
                                FocusManager.instance.primaryFocus!.unfocus();
                              },
                              value: categoryStatusValue,
                              items: supportCategoryStatusDropdownItems,
                              onChanged: (newValue) {
                                setState(() {
                                  categoryStatusValue = newValue!;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )),
            title: const Text('Neuer Kategoriestatus'),
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
                    // if (_competenceStatusKey.currentState!.validate()) {
                    //   locator<CompetenceManager>().po(pupil, goalCategoryId,
                    //       categoryStatusValue, _textEditingController.text);

                    //   _textEditingController.clear();
                    //   Navigator.of(parentContext).pop();
                    // }
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
