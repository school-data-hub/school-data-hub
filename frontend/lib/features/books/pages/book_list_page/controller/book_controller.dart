import 'package:flutter/material.dart';

import 'package:schuldaten_hub/common/services/locator.dart';

import '../../../services/book_manager.dart';
import '../book_list_view.dart';

class BookList extends StatefulWidget {
  const BookList({
    super.key,
  });

  @override
  BookController createState() => BookController();
}

class BookController extends State<BookList> {
  @override
  Widget build(BuildContext context) {
    return BookListView(this);
  }
}
