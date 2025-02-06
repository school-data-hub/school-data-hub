import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/theme/app_colors.dart';
import 'package:schuldaten_hub/common/theme/styles.dart';
import 'package:schuldaten_hub/features/workbooks/presentation/new_workbook_page/new_workbook_controller.dart';

class NewWorkbookPage extends StatelessWidget {
  final NewWorkbookController controller;
  const NewWorkbookPage({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.backgroundColor,
        title: Center(
          child: Text(
            (controller.isEdit)
                ? 'Arbeitsheft bearbeiten'
                : 'Neues Arbeitsheft',
            style: AppStyles.appBarTextStyle,
          ),
        ),
      ),
      body: Center(
        heightFactor: 1,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: [
                      if (controller.workbookImage != null) ...<Widget>[
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: controller.workbookImage!),
                              const Gap(20),
                            ],
                          ),
                        ),
                        const Gap(10),
                      ],
                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Gap(20),
                            TextField(
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                                minLines: 1,
                                maxLines: 1,
                                controller: controller.isbnTextFieldController,
                                decoration: AppStyles.textFieldDecoration(
                                    labelText: 'ISBN')),
                          ],
                        ),
                      ),
                    ],
                  ),
                  TextField(
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                      minLines: 2,
                      maxLines: 2,
                      controller: controller.workbookNameTextFieldController,
                      decoration: AppStyles.textFieldDecoration(
                          labelText: 'Name des Heftes')),
                  const Gap(20),

                  TextField(
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    minLines: 1,
                    maxLines: 1,
                    controller: controller.subjectTextFieldController,
                    decoration:
                        AppStyles.textFieldDecoration(labelText: 'Fach'),
                  ),
                  const Gap(20),
                  TextField(
                      minLines: 1,
                      maxLines: 1,
                      controller: controller.level,
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                      decoration: AppStyles.textFieldDecoration(
                          labelText: 'Kompetenzstufe')),
                  // const Gap(20),
                  // TextField(
                  //     style: const TextStyle(
                  //         color: Colors.black, fontWeight: FontWeight.bold),
                  //     minLines: 1,
                  //     maxLines: 1,
                  //     controller: controller.amountTextFieldController,
                  //     decoration:
                  //         AppStyles.textFieldDecoration(labelText: 'Bestand')),
                  const Gap(30),
                  if (!controller.isEdit) ...<Widget>[
                    ElevatedButton(
                      style: AppStyles.actionButtonStyle,
                      onPressed: () async => controller.scanIsbn(),
                      child: const Text(
                        'ISBN SCANNEN',
                        style: AppStyles.buttonTextStyle,
                      ),
                    ),
                    const Gap(15)
                  ],
                  ElevatedButton(
                    style: AppStyles.successButtonStyle,
                    onPressed: () => controller.sendWorkbookRequest(),
                    child: const Text(
                      'SENDEN',
                      style: AppStyles.buttonTextStyle,
                    ),
                  ),
                  const Gap(15),
                  ElevatedButton(
                    style: AppStyles.cancelButtonStyle,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'ABBRECHEN',
                      style: AppStyles.buttonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
