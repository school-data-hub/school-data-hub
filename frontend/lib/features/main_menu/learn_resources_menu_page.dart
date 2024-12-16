import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/theme/colors.dart';
import 'package:schuldaten_hub/common/theme/styles.dart';
import 'package:schuldaten_hub/features/books/presentation/book_list_page/controller/book_list_controller.dart';
import 'package:schuldaten_hub/features/competence/presentation/competence_list_page/competence_list_page.dart';
import 'package:schuldaten_hub/features/learning_support/presentation/goal_category_list_page/controller/category_list_controller.dart';
import 'package:schuldaten_hub/features/workbooks/presentation/workbook_list_page/controller/workbook_list_view_model.dart';
import 'package:watch_it/watch_it.dart';

class LearnResourcesMenuPage extends WatchingWidget {
  const LearnResourcesMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.canvasColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.backgroundColor,
        title: Text(
          locale.learningresources,
          style: AppStyles.appBarTextStyle,
        ),
      ),
      body: Center(
        child: SizedBox(
          width: 380,
          height: 380,
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            padding: const EdgeInsets.all(20),
            physics: const NeverScrollableScrollPhysics(),
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) => const CompetenceListPage(),
                    ));
                  },
                  child: Card(
                    color: AppColors.backgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.lightbulb,
                          size: 50,
                          color: AppColors.gridViewColor,
                        ),
                        const Gap(10),
                        Text(
                          locale.competences,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Card(
                  color: AppColors.backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (ctx) => const CategoryList(),
                      ));
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.support_rounded,
                          size: 50,
                          color: AppColors.gridViewColor,
                        ),
                        const Gap(10),
                        Text(
                          locale.supportCategories,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Card(
                  color: AppColors.backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (ctx) => const WorkbookList(),
                      ));
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.note_alt,
                          size: 50,
                          color: AppColors.gridViewColor,
                        ),
                        const Gap(10),
                        Text(
                          locale.workbooks,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Card(
                  color: AppColors.backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (ctx) => const BookList(),
                      ));
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.book,
                          size: 50,
                          color: AppColors.gridViewColor,
                        ),
                        const Gap(10),
                        Text(
                          locale.books,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
