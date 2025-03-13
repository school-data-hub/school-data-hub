import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:schuldaten_hub/features/books/presentation/book_search_page/book_search_page.dart';

import '../../../../common/theme/app_colors.dart';
import '../../../../common/theme/styles.dart';
import '../../../../common/utils/scanner.dart';
import '../../../../common/widgets/dialogs/short_textfield_dialog.dart';
import '../../../competence/presentation/competence_list_page/competence_list_page.dart';
import '../book_list_page/book_list_page.dart';
import '../new_book_page/new_book_controller.dart';

class BookSelectionPage extends StatelessWidget {
  const BookSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.canvasColor,
      appBar: AppBar(
        foregroundColor: Colors.white,
        centerTitle: true,
        backgroundColor: AppColors.backgroundColor,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lightbulb,
              size: 25,
              color: Colors.white,
            ),
            Gap(10),
            Text(
              'Bücher',
              style: AppStyles.appBarTextStyle,
            ),
          ],
        ),
      ),
      body: Center(
        child: SizedBox(
          width: 380,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildButton(context, "WIP", () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (ctx) => const Placeholder(),
                ));
              }),
              const SizedBox(height: 20),
              _buildButton(context, "Ausgeliehene Bücher", () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (ctx) => const BookListPage(),
                ));
              }),
              const SizedBox(height: 20),
              _buildButton(context, "Buch erstellen", () async {
                await _showNewBookDialog(context);
              }),
              const SizedBox(height: 20),
              _buildButton(context, "Bücher suchen", () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (ctx) => const BookSearchPage(),
                ));
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: InkWell(
        onTap: onTap,
        child: Card(
          color: AppColors.backgroundColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            alignment: Alignment.center,
            child: Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize:
                        18)),
          ),
        ),
      ),
    );
  }
}

Future<void> _showNewBookDialog(BuildContext context) async {
  if (Platform.isWindows) {
    final isbn = await shortTextfieldDialog(
        context: context,
        title: 'ISBN eingeben',
        labelText: 'ISBN',
        hintText: 'Bitte geben Sie die ISBN ein');

    if (isbn != null && isbn.isNotEmpty) {
      final cleanIsbn = isbn.replaceAll('-', '');

      Navigator.of(context).push(MaterialPageRoute(
        builder: (ctx) => NewBook(isEdit: false, isbn: int.parse(cleanIsbn)),
      ));
    }
  } else {
    final String? scannedIsbn = await scanner(context, 'ISBN scannen');
    if (scannedIsbn != null && scannedIsbn.isNotEmpty) {
      final cleanScannedIsbn = scannedIsbn.replaceAll('-', '');
      Navigator.of(context).push(MaterialPageRoute(
        builder: (ctx) =>
            NewBook(isEdit: false, isbn: int.parse(cleanScannedIsbn)),
      ));
    }
  }
}
