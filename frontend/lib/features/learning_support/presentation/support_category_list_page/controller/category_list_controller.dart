import 'package:flutter/material.dart';
import 'package:schuldaten_hub/features/learning_support/presentation/support_category_list_page/support_category_list_page.dart';

class CategoryList extends StatefulWidget {
  const CategoryList({
    super.key,
  });

  @override
  CategoryListController createState() => CategoryListController();
}

class CategoryListController extends State<CategoryList> {
  @override
  Widget build(BuildContext context) {
    return CategoryListPage(this);
  }
}
