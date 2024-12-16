import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:isbn/isbn.dart';
import 'package:schuldaten_hub/common/domain/env_manager.dart';
import 'package:schuldaten_hub/common/domain/models/enums.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_service.dart';
import 'package:schuldaten_hub/common/utils/isbn_book_data_scraper.dart';
import 'package:schuldaten_hub/common/utils/scanner.dart';
import 'package:schuldaten_hub/features/books/data/book_repository.dart';
import 'package:schuldaten_hub/features/books/domain/book_manager.dart';
import 'package:schuldaten_hub/features/books/presentation/new_book_page/new_book_page.dart';

enum ReadingLevel {
  beginner('Anfänger'),
  easy('leicht'),
  medium('mittel'),
  hard('schwer'),
  notSet('nicht angegeben');

  final String value;
  static fromString(String value) {
    switch (value) {
      case 'Anfänger':
        return ReadingLevel.beginner;
      case 'leicht':
        return ReadingLevel.easy;
      case 'mittel':
        return ReadingLevel.medium;
      case 'schwer':
        return ReadingLevel.hard;
      case 'nicht angegeben':
        return ReadingLevel.notSet;
      default:
        return ReadingLevel.notSet;
    }
  }

  const ReadingLevel(this.value);
}

class NewBook extends StatefulWidget {
  final String? bookTitle;
  final int? bookIsbn;
  final String? bookId;
  final String? bookAuthor;
  final String? bookDescription;
  final String? bookImageId;
  final String? bookReadingLevel;
  final bool? bookAvailable;
  final String? imageId;
  final bool isEdit;
  const NewBook(
      {required this.isEdit,
      this.bookTitle,
      this.bookIsbn,
      this.bookId,
      this.bookAuthor,
      this.bookDescription,
      this.bookImageId,
      this.bookReadingLevel,
      this.bookAvailable,
      this.imageId,
      super.key});

  @override
  NewBookViewModel createState() => NewBookViewModel();
}

class NewBookViewModel extends State<NewBook> {
  final TextEditingController isbnTextFieldController = TextEditingController();

  final TextEditingController bookIdTextFieldController =
      TextEditingController();

  final TextEditingController bookTitleTextFieldController =
      TextEditingController();

  final TextEditingController authorTextFieldController =
      TextEditingController();

  final TextEditingController locationTextFieldController =
      TextEditingController();

  final List<DropdownMenuItem<ReadingLevel>> readingLevelDropdownItems = [
    DropdownMenuItem(
      value: ReadingLevel.beginner,
      child: Text(ReadingLevel.beginner.value),
    ),
    DropdownMenuItem(
      value: ReadingLevel.easy,
      child: Text(ReadingLevel.easy.value),
    ),
    DropdownMenuItem(
      value: ReadingLevel.medium,
      child: Text(ReadingLevel.medium.value),
    ),
    DropdownMenuItem(
      value: ReadingLevel.hard,
      child: Text(ReadingLevel.hard.value),
    ),
    DropdownMenuItem(
      value: ReadingLevel.notSet,
      child: Text(ReadingLevel.notSet.value),
    ),
  ];

  final TextEditingController bookDescriptionTextFieldController =
      TextEditingController();

  final isbn = Isbn();

  Image? bookImage;
  Uint8List? bookImageBytes;

  String readingLevel = ReadingLevel.notSet.value;

  void onChangedReadingLevelDropDown(ReadingLevel? value) {
    if (value != null) {
      readingLevel = value.value;
    }
  }

  void _listenToIsbn() async {
    final String text = isbnTextFieldController.text;

    final String formattedText = _formatISBN(text);
    if (isbn.isIsbn13(formattedText.replaceAll('-', '')) &&
        bookTitleTextFieldController.text.isEmpty) {
      getIsbnApiData(isbnTextFieldController.text);
      return;
    }
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

  Future<void> getIsbnData() async {
    final IsbnApiData isbnData =
        await getIsbnApiData(isbnTextFieldController.text);

    if (isbnData.image != null) {
      setState(() {
        bookImage = Image.memory(isbnData.image!);
        bookImageBytes = isbnData.image;
        bookTitleTextFieldController.text = isbnData.title;
        authorTextFieldController.text = isbnData.author;
        bookDescriptionTextFieldController.text = isbnData.description;
      });
    }
  }

  Future<void> scanIsbn() async {
    final String? scannedIsbn = await scanner(context, 'Isbn code scannen');

    if (scannedIsbn == null) {
      locator<NotificationService>()
          .showSnackBar(NotificationType.error, 'Fehler beim Scannen');
      return;
    }

    isbnTextFieldController.text = scannedIsbn;
    getIsbnData();
  }

  Future<void> scanBookId() async {
    final String? scannedBookId = await scanner(context, 'Bücherei-Id scannen');

    if (scannedBookId == null) {
      locator<NotificationService>()
          .showSnackBar(NotificationType.error, 'Fehler beim Scannen');
      return;
    }
    final bookId = scannedBookId.replaceFirst('Buch ID: ', '').trim();
    bookIdTextFieldController.text = bookId;
  }

  void submitBook() {
    if (!validateRequestDataPayload()) {
      return;
    }

    if (widget.isEdit) {
      // Update the book
      locator<BookManager>().updateBookProperty(
        bookId: widget.bookImageId!,
        title: bookTitleTextFieldController.text,
        description: bookDescriptionTextFieldController.text,
        location: locationTextFieldController.text,
        readingLevel: readingLevel,
      );
    } else {
      // Create a new book
      locator<BookManager>().postBookAndImageBytes(
        author: authorTextFieldController.text,
        bookId: bookIdTextFieldController.text,
        imageBytes: bookImageBytes!,
        isbn: int.parse(isbnTextFieldController.text.replaceAll('-', '')),
        title: bookTitleTextFieldController.text,
        description: bookDescriptionTextFieldController.text,
        location: locationTextFieldController.text,
        level: readingLevel,
      );
    }
    Navigator.pop(context);
  }

  bool validateRequestDataPayload() {
    if (isbnTextFieldController.text.isEmpty) {
      locator<NotificationService>().showSnackBar(
          NotificationType.error, 'Bitte geben Sie die ISBN ein!');

      return false;
    }
    if (bookIdTextFieldController.text.isEmpty) {
      locator<NotificationService>().showSnackBar(NotificationType.error,
          'Bitte scannen Sie die Bücherei-Id oder tippen Sie sie ein!');

      return false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      isbnTextFieldController.text = widget.bookIsbn?.toString() ?? '';
      bookIdTextFieldController.text = widget.bookId ?? '';
      bookTitleTextFieldController.text = widget.bookTitle ?? '';
      authorTextFieldController.text = widget.bookAuthor ?? '';
      locationTextFieldController.text = widget.bookAuthor ?? '';
      readingLevel = widget.bookReadingLevel ?? ReadingLevel.notSet.value;
      bookDescriptionTextFieldController.text = widget.bookDescription ?? '';
      if (widget.bookImageId != null) {
        bookImage = Image.network(
            '${locator<EnvManager>().env.value.serverUrl}${BookRepository.getBookImageUrl(widget.bookId!)}');
      }
    }
    isbnTextFieldController.addListener(_listenToIsbn);
  }

  @override
  Widget build(BuildContext context) {
    return NewBookPage(this);
  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is removed from the tree

    isbnTextFieldController.removeListener(_listenToIsbn);
    isbnTextFieldController.dispose();

    bookIdTextFieldController.dispose();

    bookTitleTextFieldController.dispose();

    authorTextFieldController.dispose();

    locationTextFieldController.dispose();

    bookDescriptionTextFieldController.dispose();

    super.dispose();
  }
}
