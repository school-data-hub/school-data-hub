import 'package:flutter/material.dart';
import 'package:schuldaten_hub/features/books/models/pupil_book.dart';
import 'package:watch_it/watch_it.dart';

class PupilBookCard extends WatchingWidget {
  const PupilBookCard(
      {required this.pupilBook, required this.pupilId, super.key});
  final PupilBook pupilBook;
  final int pupilId;

  @override
  Widget build(BuildContext context) {
    // final Workbook workbook = locator<WorkbookManager>()
    //     .getWorkbookByIsbn(pupilBook.workbookIsbn)!;
    return const Placeholder();
  }
}
