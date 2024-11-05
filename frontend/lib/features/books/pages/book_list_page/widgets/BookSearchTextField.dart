import 'package:flutter/material.dart';
import 'package:schuldaten_hub/features/books/services/book_manager.dart';
import 'package:schuldaten_hub/common/services/locator.dart';

class BookSearchTextField extends StatefulWidget {
  final String hintText;
  final Function refreshFunction;

  const BookSearchTextField({
    required this.hintText,
    required this.refreshFunction,
    super.key,
  });

  @override
  State<BookSearchTextField> createState() => _BookSearchTextFieldState();
}

class _BookSearchTextFieldState extends State<BookSearchTextField> {
  final textEditingController = TextEditingController();
  final bookManager = locator<BookManager>();

  @override
  void initState() {
    super.initState();
    textEditingController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    textEditingController.removeListener(_onSearchChanged);
    textEditingController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    bookManager.filterBooks(textEditingController.text);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textEditingController,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        fillColor: const Color.fromARGB(255, 255, 255, 255),
        filled: true,
        border: UnderlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(12),
        ),
        hintText: widget.hintText,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        prefixIcon: IconButton(
          onPressed: () => widget.refreshFunction(),
          icon: const Icon(
            Icons.search_outlined,
            color: Colors.black45,
          ),
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            textEditingController.clear();
            bookManager.filterBooks('');
          },
        ),
      ),
    );
  }
}
