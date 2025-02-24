import 'package:flutter/material.dart';
import 'package:schuldaten_hub/common/domain/models/enums.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_service.dart';
import 'package:schuldaten_hub/common/utils/scanner.dart';
import 'package:schuldaten_hub/common/widgets/dialogs/short_textfield_dialog.dart';
import 'package:schuldaten_hub/features/books/data/book_api_service.dart';
import 'package:schuldaten_hub/features/books/domain/book_manager.dart';
import 'package:schuldaten_hub/features/books/domain/models/book.dart';
import 'package:schuldaten_hub/features/books/domain/models/book_dto.dart'
    as dto;
import 'package:schuldaten_hub/features/books/presentation/new_book_page/new_book_page.dart';
import 'package:watch_it/watch_it.dart';

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

class NewBook extends WatchingStatefulWidget {
  final String? bookTitle;
  final int isbn;
  final String? bookId;
  final String? bookAuthor;
  final String? bookDescription;
  final String? bookImageId;
  final String? bookReadingLevel;
  final String? location;
  final bool? bookAvailable;
  final String? imageId;
  final bool isEdit;
  const NewBook(
      {required this.isEdit,
      this.bookTitle,
      required this.isbn,
      this.bookId,
      this.bookAuthor,
      this.bookDescription,
      this.bookImageId,
      this.bookReadingLevel,
      this.location,
      this.bookAvailable,
      this.imageId,
      super.key});

  @override
  NewBookController createState() => NewBookController();
}

class NewBookController extends State<NewBook> {
  final TextEditingController bookIdTextFieldController =
      TextEditingController();

  final TextEditingController bookTitleTextFieldController =
      TextEditingController();

  final TextEditingController authorTextFieldController =
      TextEditingController();

  final TextEditingController bookDescriptionTextFieldController =
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

  final List<BookTag> bookTags = locator<BookManager>().bookTags.value;

  Map<BookTag, bool> bookTagSelection = {};

  final List<String> locations = locator<BookManager>().locations.value;

  String lastLocationValue = locator<BookManager>().lastLocationValue.value;

  void switchBookTagSelection(BookTag tag) {
    setState(() {
      bookTagSelection[tag] = !bookTagSelection[tag]!;
    });
  }

  String readingLevel = ReadingLevel.notSet.value;

  String? bookImageId;

  Future<void> fetchBookData() async {
    final dto.BookDTO? bookData =
        await BookApiService().getBookData(widget.isbn);

    if (bookData != null) {
      bookTitleTextFieldController.text = bookData.title;
      authorTextFieldController.text = bookData.author;
      bookDescriptionTextFieldController.text = bookData.description ?? '';

      setState(() {
        readingLevel = bookData.readingLevel;
        bookImageId = bookData.imageId!;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchBookData();
    if (widget.isEdit) {
      bookIdTextFieldController.text = widget.bookId ?? '';
      bookTitleTextFieldController.text = widget.bookTitle ?? '';
      authorTextFieldController.text = widget.bookAuthor ?? '';
      lastLocationValue =
          widget.location ?? locator<BookManager>().lastLocationValue.value;
      readingLevel = widget.bookReadingLevel ?? ReadingLevel.notSet.value;

      bookDescriptionTextFieldController.text = widget.bookDescription ?? '';
    }

    for (var tag in locator<BookManager>().bookTags.value) {
      bookTagSelection[tag] = false;
    }
  }

  void onChangedReadingLevelDropDown(ReadingLevel? value) {
    setState(() {
      readingLevel = value!.value;
    });
  }

  void onChangedLocationDropDown(String value) {
    setState(() {
      lastLocationValue = value;
      locator<BookManager>().setLastLocationValue(value);
    });
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

  final List<DropdownMenuItem<String>> locationDropdownItems = [
    for (final location in locator<BookManager>().locations.value)
      DropdownMenuItem(
        value: location,
        child: Text(location),
      ),
    if (locator<BookManager>().lastLocationValue.value == 'Bitte auswählen')
      DropdownMenuItem(
        value: locator<BookManager>().lastLocationValue.value,
        child: Text(
          locator<BookManager>().lastLocationValue.value,
          style: const TextStyle(color: Colors.red),
        ),
      ),
  ];
  void addLocation() async {
    final String? newLocation = await shortTextfieldDialog(
        context: context,
        title: 'Neuer Ablageort',
        labelText: 'Ablageort hinzufügen',
        hintText: 'Name des Ablageorts');
    if (newLocation != null) {
      await locator<BookManager>().addLocation(newLocation);
    }
  }

  void submitBook() {
    if (!validateRequestDataPayload()) {
      return;
    }

    if (widget.isEdit) {
      // Update the book
      locator<BookManager>().updateBookProperty(
        isbn: widget.isbn,
        title: bookTitleTextFieldController.text,
        description: bookDescriptionTextFieldController.text,
        readingLevel: readingLevel,
        author: authorTextFieldController.text,
      );
    } else {
      // Create a new book
      locator<BookManager>().postLibraryBook(
        isbn: widget.isbn,
        bookId: bookIdTextFieldController.text,
        location: lastLocationValue,
      );
    }
    Navigator.pop(context);
  }

  bool validateRequestDataPayload() {
    if (bookIdTextFieldController.text.isEmpty) {
      locator<NotificationService>().showSnackBar(NotificationType.error,
          'Bitte scannen Sie die Bücherei-Id oder tippen Sie sie ein!');

      return false;
    }
    if (bookTitleTextFieldController.text.isEmpty) {
      locator<NotificationService>().showSnackBar(
          NotificationType.error, 'Bitte geben Sie den Buchtitel ein!');

      return false;
    }
    if (lastLocationValue == 'Bitte auswählen') {
      locator<NotificationService>().showSnackBar(
          NotificationType.error, 'Bitte wählen Sie den Ablageort aus!');

      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return NewBookPage(this);
  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is removed from the tree

    bookIdTextFieldController.dispose();

    bookTitleTextFieldController.dispose();

    authorTextFieldController.dispose();

    bookDescriptionTextFieldController.dispose();

    super.dispose();
  }
}
