import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/widgets/bottom_nav_bar_layouts.dart';

import '../../new_book_page/new_book_page.dart';

Widget bookListBottomNavBar(BuildContext context) {
  return BottomNavBarLayout(
    bottomNavBar: BottomAppBar(
      padding: const EdgeInsets.all(9),
      shape: null,
      color: backgroundColor,
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
                  builder: (ctx) => const NewBookPage(isEdit: false),
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
