import 'package:flutter/material.dart';
import 'package:schuldaten_hub/common/widgets/list_view_components/generic_app_bar.dart';
import 'package:schuldaten_hub/features/books/presentation/book_list_page/widgets/book_list_bottom_navbar.dart';
import 'package:watch_it/watch_it.dart';

class BookSearchFormPage extends WatchingWidget {
  const BookSearchFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final titleSearchController =
        createOnce<TextEditingController>(() => TextEditingController());

    return Scaffold(
      appBar:
          const GenericAppBar(iconData: Icons.search, title: 'Bücher suchen'),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: titleSearchController,
                  decoration: const InputDecoration(
                    labelText: 'Titel',
                    hintText: 'Titel des Buches',
                  ),
                ),
              ),
              Text(
                  'Hier soll eine Suchmaske mit folgenden Kriterien: \n Titel,\n  Autor,\n  ISBN, \n Schlagwörter, ... \n Ablageort \n  Lesestufe \n verfügbar.. \n Wenn möglich, auch die meistgelesene Bücher n\ Das wären die Summe der Pupilbooks verbunden mit einer ISBN mit mit den meisten Pupilbooks Objekten',
                  style: TextStyle(fontSize: 18))
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BookListBottomNavBar(),
    );
  }
}
