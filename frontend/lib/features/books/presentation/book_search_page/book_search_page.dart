import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/theme/app_colors.dart';
import 'package:schuldaten_hub/features/books/domain/book_manager.dart';
import 'package:schuldaten_hub/features/books/presentation/book_list_page/widgets/book_card.dart';

import '../../../../common/theme/styles.dart';
import '../../../../common/widgets/themed_filter_chip.dart';
import '../widgets/book_search_text_field.dart';

class BookSearchPage extends StatefulWidget {
  const BookSearchPage({super.key});

  @override
  _BookSearchPageState createState() => _BookSearchPageState();
}

class _BookSearchPageState extends State<BookSearchPage> {
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    locator<BookManager>().getLibraryBooks();

    searchController.addListener(() {
      if (searchController.text.length >= 3) {
        performSearch(searchController.text);
      } else {
        setState(() {
          locator<BookManager>().searchResults.value.clear();
        });
      }
    });
  }

  void performSearch(String query) async {
    final bookManager = locator<BookManager>();
    setState(() {
      bookManager.searchBooks(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookManager = locator<BookManager>();

    return Scaffold(
      backgroundColor: AppColors.canvasColor,
      appBar: AppBar(
        foregroundColor: Colors.white,
        automaticallyImplyLeading: true,
        centerTitle: true,
        backgroundColor: AppColors.backgroundColor,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book,
              size: 25,
              color: Colors.white,
            ),
            Gap(10),
            Text(
              'Bücher suchen',
              style: AppStyles.appBarTextStyle,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
        Column(children:[
          BookSearchTextField(
            hintText:'Buch suchen',
            refreshFunction : () {
              performSearch(searchController.text);
            },
              controller : searchController
          ),
          const SizedBox(height :20),
        Wrap(
          spacing: 5,
          runSpacing: 5,
          children:
          bookManager.bookTags.value.map((tag) => ThemedFilterChip(
            label: tag.name,
            selected: bookManager.selectedTags.contains(tag),
            onSelected:(bool selected) {
              setState(() {
                if (selected) {
                  bookManager.selectedTags.add(tag);
                } else {
                  bookManager.selectedTags.remove(tag);
                }
                performSearch(searchController.text);
              });
            },
          )).toList(),
        ),
          ),
          const SizedBox(height :20),

          Expanded(
              child:
              bookManager.searchResults.value.isEmpty
                  ? const Center(child : Text('Keine Ergebnisse', style : TextStyle(fontSize :18)))
                  : ListView.builder (
                itemCount : bookManager.searchResults.value.length ,
                itemBuilder :(context , index ) =>
                    BookCard(isbn : bookManager.searchResults.value[index].isbn),
              )
          ),

        ]),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}