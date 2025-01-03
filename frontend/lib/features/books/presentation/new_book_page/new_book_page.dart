import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/theme/colors.dart';
import 'package:schuldaten_hub/common/theme/styles.dart';
import 'package:schuldaten_hub/common/widgets/themed_filter_chip.dart';
import 'package:schuldaten_hub/features/books/presentation/new_book_page/new_book_page_view_model.dart';

class NewBookPage extends StatelessWidget {
  final NewBookViewModel viewModel;

  const NewBookPage(
    this.viewModel, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.backgroundColor,
        title: Center(
          child: Text(
            (viewModel.widget.isEdit) ? 'Buch bearbeiten' : 'Neues Buch',
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
                      if (viewModel.bookImage != null) ...<Widget>[
                        ClipRRect(
                            borderRadius: BorderRadius.circular(
                                10.0), // Adjust the radius as needed
                            child: viewModel.bookImage!),
                        const Gap(20),
                      ],
                      Flexible(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            TextField(
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                              minLines: 1,
                              maxLines: 1,
                              controller: viewModel.isbnTextFieldController,
                              decoration: AppStyles.textFieldDecoration(
                                  labelText: 'ISBN'),
                            ),
                            const Gap(20),
                            TextField(
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                              minLines: 1,
                              maxLines: 1,
                              controller: viewModel.bookIdTextFieldController,
                              decoration: AppStyles.textFieldDecoration(
                                  labelText: 'Bücherei-ID'),
                            ),
                            const Gap(20),
                            DropdownButtonFormField<ReadingLevel>(
                                decoration: AppStyles.textFieldDecoration(
                                    labelText: 'Lesestufe'),
                                items: viewModel.readingLevelDropdownItems,
                                value: ReadingLevel.fromString(
                                    viewModel.readingLevel),
                                onChanged: (value) => viewModel
                                    .onChangedReadingLevelDropDown(value)),
                            const Gap(20),
                            DropdownButtonFormField<String>(
                              decoration: AppStyles.textFieldDecoration(
                                  labelText: 'Ablageort'),
                              items: viewModel.locationDropdownItems,
                              value: viewModel.lastLocationValue,
                              onChanged: (value) =>
                                  viewModel.onChangedLocationDropDown(value!),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const Gap(20),
                  TextField(
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    minLines: 2,
                    maxLines: 2,
                    controller: viewModel.bookTitleTextFieldController,
                    decoration:
                        AppStyles.textFieldDecoration(labelText: 'Buchtitel'),
                  ),
                  const Gap(20),
                  TextField(
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    minLines: 1,
                    maxLines: 1,
                    controller: viewModel.authorTextFieldController,
                    decoration:
                        AppStyles.textFieldDecoration(labelText: 'Author*in'),
                  ),
                  const Gap(20),
                  TextField(
                    minLines: 3,
                    maxLines: 3,
                    controller: viewModel.bookDescriptionTextFieldController,
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    decoration: AppStyles.textFieldDecoration(
                        labelText: 'Buchbeschreibung'),
                  ),
                  const Gap(20),
                  Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: viewModel.bookTagSelection.entries.map((entry) {
                      return ThemedFilterChip(
                        label: entry.key.name,
                        selected: entry.value,
                        onSelected: (bool selected) {
                          viewModel.switchBookTagSelection(entry.key);
                        },
                      );
                    }).toList(),
                  ),
                  const Gap(30),
                  ...<Widget>[
                    ElevatedButton(
                      style: AppStyles.actionButtonStyle,
                      onPressed: () async => viewModel.scanIsbn(),
                      child: const Text(
                        'ISBN SCANNEN',
                        style: AppStyles.buttonTextStyle,
                      ),
                    ),
                    const Gap(15),
                    ElevatedButton(
                      style: AppStyles.actionButtonStyle,
                      onPressed: () => viewModel.getIsbnData(),
                      child: const Text(
                        'DATEN AUS ISBN API HOLEN',
                        style: AppStyles.buttonTextStyle,
                      ),
                    ),
                    const Gap(15),
                    if (!viewModel.widget.isEdit) ...<Widget>[
                      ElevatedButton(
                        style: AppStyles.actionButtonStyle,
                        onPressed: () async => viewModel.scanBookId(),
                        child: const Text(
                          'BÜCHEREI-ID SCANNEN',
                          style: AppStyles.buttonTextStyle,
                        ),
                      ),
                      const Gap(15)
                    ],
                    ElevatedButton(
                      style: AppStyles.successButtonStyle,
                      onPressed: () => viewModel.submitBook(),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
