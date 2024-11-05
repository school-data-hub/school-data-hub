import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/constants/styles.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/features/books/pages/book_list_page/widgets/BookSearchTextField.dart';
import 'package:schuldaten_hub/features/books/pages/book_list_page/widgets/book_card.dart';
import 'package:schuldaten_hub/features/books/pages/book_list_page/widgets/book_list_bottom_navbar.dart';
import 'package:schuldaten_hub/features/pupil/filters/pupil_filter_manager.dart';
import 'package:schuldaten_hub/features/pupil/filters/pupils_filter.dart';
import 'package:watch_it/watch_it.dart';

import '../../../../common/services/base_state.dart';
import '../../../../common/widgets/generic_app_bar.dart';
import '../../models/book.dart';
import '../../services/book_manager.dart';
import 'controller/book_controller.dart';

class BookListView extends WatchingStatefulWidget {
  final BookController controller;

  const BookListView(this.controller, {super.key});

  @override
  State<BookListView> createState() => _BookListViewState();
}

class _BookListViewState extends BaseState<BookListView> {
  @override
  Future<void> onInitialize() async {
    await locator.isReady<PupilFilterManager>();
    await locator.isReady<BookManager>();
    await locator.isReady<PupilsFilter>();
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      return const Scaffold(
        backgroundColor: canvasColor,
        appBar: GenericAppBar(
            iconData: Icons.note_alt_rounded, title: 'Bücher'),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    bool filtersOn = watchValue((PupilFilterManager x) => x.filtersOn);
    List<Book> books = watchValue((BookManager x) => x.books);
    final bookManager = locator<BookManager>();

    return Scaffold(
      backgroundColor: canvasColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: backgroundColor,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note_alt_rounded,
              size: 25,
              color: Colors.white,
            ),
            Gap(10),
            Text(
              'Bücher',
              style: appBarTextStyle,
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => locator<BookManager>().getBooks(),
        child: bookManager.isAllBooksEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(30.0),
                  child: Text(
                    'Es wurden noch keine Bücher angelegt!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
              )
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 10.0, top: 15.0, right: 10.00),
                        child: Row(
                          children: [
                            const Text(
                              'Gesamt:',
                              style: TextStyle(
                                fontSize: 13,
                              ),
                            ),
                            const Gap(10),
                            Text(
                              books.length.toString(),
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: BookSearchTextField(
                                  hintText: 'Buch suchen',
                                  refreshFunction:
                                      locator<BookManager>().getBooks),
                            ),
                            //---------------------------------
                            InkWell(
                              onTap: () {},

                              onLongPress: () =>
                                  locator<PupilsFilter>().resetFilters(),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Icon(
                                  Icons.filter_list,
                                  color: filtersOn
                                      ? Colors.deepOrange
                                      : Colors.grey,
                                  size: 30,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      books.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Keine Ergebnisse',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            )
                          : Expanded(
                              child: ListView.builder(
                                itemCount: books.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return BookCard(
                                      book: books[index]);
                                },
                              ),
                            ),
                    ],
                  ),
                ),
              ),
      ),
      bottomNavigationBar: bookListBottomNavBar(context),
    );
  }
}
