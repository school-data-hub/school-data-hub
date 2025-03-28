import 'package:flutter/material.dart';
import 'package:collection/collection.dart'; // For groupBy
import 'package:schuldaten_hub/features/books/domain/models/book.dart';
import 'package:schuldaten_hub/features/books/domain/book_manager.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/features/books/presentation/book_list_page/widgets/book_list_bottom_navbar.dart';
import 'package:watch_it/watch_it.dart';

import '../../../../common/widgets/list_view_components/generic_app_bar.dart';
import 'book_search_result_card.dart';

class BookSearchResultsPage extends WatchingWidget {
  const BookSearchResultsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Hole den BookManager aus dem locator.
    final bookManager = locator<BookManager>();

    return Scaffold(
      appBar: const GenericAppBar(iconData: Icons.search, title: 'Suchergebnisse'),
      body: ValueListenableBuilder<List<BookProxy>>(
        valueListenable: bookManager.searchResults,
        builder: (context, searchResults, _) {
          final groupedMap =
          groupBy(searchResults, (BookProxy book) => book.isbn);

          if (groupedMap.isEmpty) {
            return const Center(child: Text("Keine Ergebnisse"));
          }

          final groups = groupedMap.values.toList();

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: ListView.builder(
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  final group = groups[index];
                  if (group.isEmpty) return const SizedBox.shrink();
                  return SearchResultBookCard(group: group);
                },
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const BookListBottomNavBar(),
    );
  }
}