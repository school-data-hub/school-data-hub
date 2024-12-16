import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/theme/colors.dart';
import 'package:schuldaten_hub/common/theme/styles.dart';
import 'package:schuldaten_hub/features/workbooks/presentation/new_workbook_page/new_workbook_view_model.dart';

class NewWorkbookPage extends StatelessWidget {
  final NewWorkbookViewModel viewModel;
  const NewWorkbookPage({required this.viewModel, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.backgroundColor,
        title: Center(
          child: Text(
            (viewModel.isEdit) ? 'Arbeitsheft bearbeiten' : 'Neues Arbeitsheft',
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
                  TextField(
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                      minLines: 2,
                      maxLines: 2,
                      controller: viewModel.nameTextFieldController,
                      decoration: AppStyles.textFieldDecoration(
                          labelText: 'Name des Heftes')),
                  const Gap(20),
                  TextField(
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                      minLines: 1,
                      maxLines: 1,
                      controller: viewModel.isbnTextFieldController,
                      decoration:
                          AppStyles.textFieldDecoration(labelText: 'ISBN')),
                  const Gap(20),
                  TextField(
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    minLines: 1,
                    maxLines: 1,
                    controller: viewModel.subjectTextFieldController,
                    decoration:
                        AppStyles.textFieldDecoration(labelText: 'Fach'),
                  ),
                  const Gap(20),
                  TextField(
                      minLines: 1,
                      maxLines: 1,
                      controller: viewModel.level,
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                      decoration: AppStyles.textFieldDecoration(
                          labelText: 'Kompetenzstufe')),
                  const Gap(20),
                  TextField(
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                      minLines: 1,
                      maxLines: 1,
                      controller: viewModel.amountTextFieldController,
                      decoration:
                          AppStyles.textFieldDecoration(labelText: 'Bestand')),
                  const Gap(30),
                  if (!viewModel.isEdit) ...<Widget>[
                    ElevatedButton(
                      style: AppStyles.actionButtonStyle,
                      onPressed: () async => viewModel.scanIsbn(),
                      child: const Text(
                        'ISBN SCANNEN',
                        style: AppStyles.buttonTextStyle,
                      ),
                    ),
                    const Gap(15)
                  ],
                  ElevatedButton(
                    style: AppStyles.successButtonStyle,
                    onPressed: () => viewModel.sendWorkbookRequest(),
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
