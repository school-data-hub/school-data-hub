import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/constants/enums.dart';
import 'package:schuldaten_hub/common/constants/styles.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_manager.dart';
import 'package:schuldaten_hub/common/utils/logger.dart';
import 'package:schuldaten_hub/common/utils/scanner.dart';

import '../../services/book_manager.dart';

class NewBookPage extends StatefulWidget {
  final int? wbIsbn;
  final String? wbId;
  final String? wbLocation;
  final String? wbLevel;
  final bool isEdit;

  const NewBookPage(
      {required this.isEdit,
      this.wbIsbn,
      this.wbId,
      this.wbLocation,
      this.wbLevel,
      super.key});

  @override
  NewBookPageState createState() => NewBookPageState();
}

class NewBookPageState extends State<NewBookPage> {
  final TextEditingController isbnTextFieldController = TextEditingController();
  final TextEditingController idTextFieldController = TextEditingController();
  final TextEditingController locationTextFieldController =
      TextEditingController();
  final TextEditingController level = TextEditingController();
  final TextEditingController amountTextFieldController =
      TextEditingController();

  Set<int> pupilIds = {};

  void postNewBook() async {
    int bookIsbn = int.parse(isbnTextFieldController.text.replaceAll('-', ''));
    String bookId = idTextFieldController.text;
    String bookLocation = locationTextFieldController.text;
    String bookLevel = level.text;

    await locator<BookManager>()
        .postBook(bookIsbn, bookId, bookLevel, bookLocation);
  }

  void patchBook() async {
    String bookId = idTextFieldController.text;
    int bookIsbn = int.parse(isbnTextFieldController.text.replaceAll('-', ''));
    String bookLocation = locationTextFieldController.text;
    String bookLevel = level.text;

    await locator<BookManager>()
        .updateBookProperty(bookId, bookIsbn, bookLocation, bookLevel);
  }

  void _listenToQr() {
    final String text = isbnTextFieldController.text;
    isbnTextFieldController.value = isbnTextFieldController.value.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  void _listenToIsbn() {
    final String text = isbnTextFieldController.text;
    final String formattedText = _formatISBN(text);
    if (text != formattedText) {
      isbnTextFieldController.value = isbnTextFieldController.value.copyWith(
        text: formattedText,
        selection: TextSelection.collapsed(offset: formattedText.length),
      );
    }
  }

  String _formatISBN(String text) {
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

  @override
  Widget build(BuildContext context) {
    if (isbnTextFieldController.text == '') {
      isbnTextFieldController.text = widget.wbIsbn?.toString() ?? '';
    }
    if (idTextFieldController.text == '') {
      idTextFieldController.text = widget.wbId?.toString() ?? '';
    }
    locationTextFieldController.text = widget.wbLocation ?? '';
    level.text = widget.wbLevel ?? '';

    isbnTextFieldController.addListener(_listenToIsbn);
    idTextFieldController.addListener(_listenToQr);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: backgroundColor,
        title: Center(
          child: Text(
            (widget.isEdit) ? 'Buch bearbeiten' : 'Neues Buch',
            style: appBarTextStyle,
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
                    minLines: 1,
                    maxLines: 1,
                    controller: idTextFieldController,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(10),
                      border: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: backgroundColor, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: backgroundColor, width: 2),
                      ),
                      labelStyle: TextStyle(color: backgroundColor),
                      labelText: 'Id des Buches',
                    ),
                  ),
                  const Gap(20),
                  TextField(
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    minLines: 1,
                    maxLines: 1,
                    controller: isbnTextFieldController,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(10),
                      border: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: backgroundColor, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: backgroundColor, width: 2),
                      ),
                      labelStyle: TextStyle(color: backgroundColor),
                      labelText: 'ISBN',
                    ),
                  ),
                  const Gap(20),
                  TextField(
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    minLines: 1,
                    maxLines: 1,
                    controller: locationTextFieldController,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(10),
                      border: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: backgroundColor, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: backgroundColor, width: 2),
                      ),
                      labelStyle: TextStyle(color: backgroundColor),
                      labelText: 'Ort',
                    ),
                  ),
                  const Gap(20),
                  TextField(
                    minLines: 1,
                    maxLines: 1,
                    controller: level,
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(10),
                      border: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: backgroundColor, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: backgroundColor, width: 2),
                      ),
                      labelStyle: TextStyle(color: backgroundColor),
                      labelText: 'Kompetenzstufe',
                    ),
                  ),
                  const Gap(30),
                  if (!widget.isEdit) ...<Widget>[
                    ElevatedButton(
                      style: actionButtonStyle,
                      onPressed: () async {
                        final String? scannedQr =
                            await scanner(context, 'Qr code scannen');
                        logger.i('Scanned Qr: $scannedQr');
                        if (scannedQr == null) {
                          return;
                        }
                        if (locator<BookManager>()
                            .books
                            .value
                            .any((element) => element.bookId == scannedQr)) {
                          locator<NotificationManager>().showSnackBar(
                              NotificationType.error,
                              'Dieses Buch gibt es schon!');

                          return;
                        }
                        setState(() {
                          idTextFieldController.text = scannedQr;
                        });
                      },
                      child: const Text(
                        'QR-CODE SCANNEN',
                        style: buttonTextStyle,
                      ),
                    ),
                    const Gap(15)
                  ],
                  if (!widget.isEdit) ...<Widget>[
                    ElevatedButton(
                      style: actionButtonStyle,
                      onPressed: () async {
                        final String? scannedIsbn =
                            await scanner(context, 'Isbn code scannen');
                        logger.i('Scanned ISBN: $scannedIsbn');
                        if (scannedIsbn == null) {
                          return;
                        }
                        if (locator<BookManager>().books.value.any((element) =>
                            element.isbn == int.parse(scannedIsbn))) {
                          locator<NotificationManager>().showSnackBar(
                              NotificationType.error,
                              'Dieses Buch gibt es schon!');

                          return;
                        }
                        setState(() {
                          isbnTextFieldController.text = scannedIsbn;
                        });
                      },
                      child: const Text(
                        'ISBN SCANNEN',
                        style: buttonTextStyle,
                      ),
                    ),
                    const Gap(15)
                  ],
                  ElevatedButton(
                    style: successButtonStyle,
                    onPressed: () {
                      if (widget.isEdit) {
                        patchBook();
                        Navigator.pop(context);
                        return;
                      }
                      {
                        if (locator<BookManager>().books.value.any((element) =>
                            element.bookId == idTextFieldController.text)) {
                          locator<NotificationManager>().showSnackBar(
                              NotificationType.error,
                              'Dieses Buch gibt es schon!');

                          return;
                        }
                        postNewBook();
                        Navigator.pop(context);
                        return;
                      }
                    },
                    child: const Text(
                      'SENDEN',
                      style: buttonTextStyle,
                    ),
                  ),
                  const Gap(15),
                  ElevatedButton(
                    style: cancelButtonStyle,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'ABBRECHEN',
                      style: buttonTextStyle,
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

  @override
  void dispose() {
    isbnTextFieldController.removeListener(_listenToIsbn);
    isbnTextFieldController.dispose();
    idTextFieldController.removeListener(_listenToQr);
    idTextFieldController.dispose();
    locationTextFieldController.dispose();
    level.dispose();
    amountTextFieldController.dispose();
    super.dispose();
  }
}
