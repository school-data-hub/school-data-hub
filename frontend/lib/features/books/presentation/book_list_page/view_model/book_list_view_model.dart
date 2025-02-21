import 'package:flutter/material.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/features/books/domain/book_manager.dart';
import 'package:schuldaten_hub/features/books/presentation/book_list_page/book_list_page.dart';

class BookList extends StatefulWidget {
  const BookList({
    super.key,
  });

  @override
  BookListViewModel createState() => BookListViewModel();
}

class BookListViewModel extends State<BookList> {
  @override
  void initState() {
    locator<BookManager>().getLibraryBooks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BookListPage(this);
  }
}
