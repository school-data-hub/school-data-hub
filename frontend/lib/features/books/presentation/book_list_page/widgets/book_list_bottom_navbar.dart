import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/theme/colors.dart';
import 'package:schuldaten_hub/common/widgets/bottom_nav_bar_layouts.dart';
import 'package:schuldaten_hub/features/books/presentation/new_book_page/new_book_page_view_model.dart';
import 'package:watch_it/watch_it.dart';

class BookListBottomNavBar extends WatchingWidget {
  const BookListBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavBarLayout(
      bottomNavBar: BottomAppBar(
        height: 60,
        padding: const EdgeInsets.all(9),
        shape: null,
        color: AppColors.backgroundColor,
        child: IconTheme(
          data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
          child: Row(
            children: <Widget>[
              const Spacer(),
              IconButton(
                tooltip: 'zurück',
                icon: const Icon(
                  Icons.arrow_back,
                  size: 35,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const Gap(15),
              IconButton(
                tooltip: 'Neues Buch',
                icon: const Icon(
                  Icons.add,
                  size: 35,
                ),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (ctx) => const NewBook(isEdit: false),
                  ));
                },
              ),
              const Gap(15)
            ],
          ),
        ),
      ),
    );
  }
}
