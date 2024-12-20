import 'package:flutter/material.dart';
import 'package:schuldaten_hub/common/theme/colors.dart';
import 'package:schuldaten_hub/common/theme/styles.dart';

Future<String?> longTextFieldDialog(
    {required String title,
    required String? textinField,
    required String labelText,
    required BuildContext parentContext}) async {
  return await showDialog(
      context: parentContext,
      builder: (context) {
        return StatefulBuilder(builder: (statefulContext, setState) {
          final TextEditingController textEditingController =
              TextEditingController();
          setState(() {
            textEditingController.text = textinField ?? '';
          });
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 400,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      maxLines: 4,
                      textAlign: TextAlign.start,
                      textAlignVertical: TextAlignVertical.top,
                      style: const TextStyle(fontSize: 17),
                      keyboardType: TextInputType.multiline,
                      controller: textEditingController,
                      decoration:
                          AppStyles.textFieldDecoration(labelText: labelText),
                    ),
                  ),
                ),
              ],
            ),
            title: Text(title,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  textEditingController.dispose();
                  Navigator.of(parentContext).pop(null);
                  return;
                },
                child: const Text(
                  "ZURÜCK",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17.0,
                    color: AppColors.dangerButtonColor,
                  ),
                ),
              ),
              textinField != null
                  ? TextButton(
                      onPressed: () {
                        String newSpecialInformation = '';

                        textEditingController.dispose();
                        Navigator.of(parentContext).pop(newSpecialInformation);
                      },
                      child: const Text(
                        "LÖSCHEN",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17.0,
                          color: AppColors.warningButtonColor,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
              TextButton(
                onPressed: () {
                  String? newSpecialInformation = textEditingController.text;

                  if (newSpecialInformation.isEmpty) {
                    return;
                  }

                  textEditingController.dispose();
                  Navigator.of(parentContext).pop(newSpecialInformation);
                },
                child: const Text(
                  "OKAY",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17.0,
                    color: AppColors.successButtonColor,
                  ),
                ),
              ),
            ],
          );
        });
      });
}
