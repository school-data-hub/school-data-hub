import 'package:flutter/material.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import '../../domain/book_manager.dart';

class BookSearchTextField extends StatefulWidget {
  final String hintText;
  final Function refreshFunction;
  final TextEditingController controller;

  const BookSearchTextField({
    required this.hintText,
    required this.refreshFunction,
    required this.controller,
    super.key,
  });

  @override
  State<BookSearchTextField> createState() => _BookSearchTextFieldState();
}

class _BookSearchTextFieldState extends State<BookSearchTextField> {

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
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
            widget.controller.clear();
            locator<BookManager>().searchBooks('');
          },
        ),
      ),
    );
  }
}