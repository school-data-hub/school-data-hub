import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:isbn/isbn.dart';
import 'package:schuldaten_hub/common/domain/models/enums.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_service.dart';
import 'package:schuldaten_hub/common/utils/logger.dart';
import 'package:schuldaten_hub/common/utils/scanner.dart';
import 'package:schuldaten_hub/features/workbooks/domain/workbook_manager.dart';
import 'package:schuldaten_hub/features/workbooks/presentation/new_workbook_page/new_workbook_page.dart';
import 'package:watch_it/watch_it.dart';

class NewWorkbook extends WatchingStatefulWidget {
  final String? wbName;
  final int? wbIsbn;
  final String? wbSubject;
  final String? wbLevel;
  final String? wbAmount;
  final bool isEdit;
  const NewWorkbook(
      {required this.isEdit,
      this.wbName,
      this.wbIsbn,
      this.wbSubject,
      this.wbLevel,
      this.wbAmount,
      super.key});

  @override
  State<NewWorkbook> createState() => NewWorkbookController();
}

class NewWorkbookController extends State<NewWorkbook> {
  final TextEditingController workbookNameTextFieldController =
      TextEditingController();
  final TextEditingController isbnTextFieldController = TextEditingController();
  final TextEditingController subjectTextFieldController =
      TextEditingController();
  final TextEditingController level = TextEditingController();
  final TextEditingController amountTextFieldController =
      TextEditingController();

  late final bool isEdit;
  final isbn = Isbn();
  Image? workbookImage;
  Uint8List? bookImageBytes;
  @override
  void initState() {
    super.initState();
    isEdit = widget.isEdit;
    if (widget.isEdit) {
      workbookNameTextFieldController.text = widget.wbName ?? '';

      if (isbnTextFieldController.text == '') {
        isbnTextFieldController.text = widget.wbIsbn?.toString() ?? '';
      }

      subjectTextFieldController.text = widget.wbSubject ?? '';

      level.text = widget.wbLevel ?? '';

      amountTextFieldController.text = widget.wbAmount ?? '';
    }
    isbnTextFieldController.addListener(_listenToIsbn);
  }

  bool validateRequestDataPayload() {
    if (amountTextFieldController.text.isEmpty) {
      locator<NotificationService>().showSnackBar(
          NotificationType.error, 'Bitte geben Sie den Bestand ein!');
      return false;
    }
    if (int.parse(amountTextFieldController.text) < 0) {
      locator<NotificationService>().showSnackBar(
          NotificationType.error, 'Der Bestand kann nicht negativ sein!');
      return false;
    }
    if (workbookNameTextFieldController.text.isEmpty) {
      locator<NotificationService>().showSnackBar(
          NotificationType.error, 'Bitte geben Sie den Namen ein!');
      return false;
    }
    if (isbnTextFieldController.text.isEmpty) {
      locator<NotificationService>().showSnackBar(
          NotificationType.error, 'Bitte geben Sie die ISBN ein!');
      return false;
    }
    return true;
  }

  void postNewWorkbook() async {
    if (locator<WorkbookManager>().workbooks.value.any((element) =>
        element.isbn ==
        int.parse(isbnTextFieldController.text.replaceAll('-', '')))) {
      locator<NotificationService>().showSnackBar(
          NotificationType.error, 'Dieses Arbeitsheft gibt es schon!');

      return;
    }
    String workbookName = workbookNameTextFieldController.text;
    int workbookIsbn =
        int.parse(isbnTextFieldController.text.replaceAll('-', ''));
    String workbookSubject = subjectTextFieldController.text;
    String workbookLevel = level.text;
    int amount = int.parse(amountTextFieldController.text);

    await locator<WorkbookManager>().postWorkbook(
        workbookName, workbookIsbn, workbookSubject, workbookLevel, amount);
  }

  void patchWorkbook() async {
    String workbookName = workbookNameTextFieldController.text;
    int workbookIsbn =
        int.parse(isbnTextFieldController.text.replaceAll('-', ''));
    String workbookSubject = subjectTextFieldController.text;
    String workbookLevel = level.text;

    await locator<WorkbookManager>().updateWorkbookProperty(
        workbookName, workbookIsbn, workbookSubject, workbookLevel);
    return;
  }

  // Future<void> getIsbnData() async {
  //   final IsbnApiData isbnData =
  //       await getIsbnApiData(isbnTextFieldController.text);

  //   if (isbnData.image != null) {
  //     setState(() {
  //       workbookImage = Image.memory(isbnData.image!);
  //       bookImageBytes = isbnData.image;
  //       workbookNameTextFieldController.text = isbnData.title;
  //     });
  //   }
  // }

  void _listenToIsbn() {
    final String text = isbnTextFieldController.text;
    if (isbn.isIsbn13(text.replaceAll('-', ''))) {
      //  getIsbnData();
      return;
    }
    final String formattedText = _formatISBN(text);
    if (text != formattedText) {
      isbnTextFieldController.value = isbnTextFieldController.value.copyWith(
        text: formattedText,
        selection: TextSelection.collapsed(offset: formattedText.length),
      );
    }
  }

  String _formatISBN(String text) {
    // Remove all existing dashes
    text = text.replaceAll('-', '');

    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i == 3 || i == 4 || i == 6 || i == 12) {
        buffer.write('-');
      }
      buffer.write(text[i]);
    }

    return buffer.toString();
  }

  Future<void> scanIsbn() async {
    final String? scannedIsbn = await scanner(context, 'Isbn code scannen');
    logger.i('Scanned ISBN: $scannedIsbn');
    if (scannedIsbn == null) {
      return;
    }
    if (locator<WorkbookManager>()
        .workbooks
        .value
        .any((element) => element.isbn == int.parse(scannedIsbn))) {
      locator<NotificationService>().showSnackBar(
          NotificationType.error, 'Dieses Arbeitsheft gibt es schon!');

      return;
    }
    setState(() {
      isbnTextFieldController.text = scannedIsbn;
    });
  }

  void sendWorkbookRequest() {
    if (widget.isEdit) {
      final validate = validateRequestDataPayload();
      if (!validate) {
        return;
      } else {
        patchWorkbook();
        Navigator.pop(context);
        return;
      }
    } else {
      postNewWorkbook();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return NewWorkbookPage(controller: this);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the tree
    workbookNameTextFieldController.dispose();
    isbnTextFieldController.removeListener(_listenToIsbn);
    isbnTextFieldController.dispose();
    subjectTextFieldController.dispose();
    level.dispose();
    amountTextFieldController.dispose();
    super.dispose();
  }
}
