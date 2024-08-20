import 'package:flutter/material.dart';
import 'package:schuldaten_hub/features/learning_support/pages/selectable_support_category_tree_page/selectable_support_category_tree_page.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';

class SelectableCategoryTree extends StatefulWidget {
  final PupilProxy pupil;
  final String elementType;
  const SelectableCategoryTree(
    this.pupil,
    this.elementType, {
    super.key,
  });

  @override
  SelectableCategoryTreeController createState() =>
      SelectableCategoryTreeController();
}

class SelectableCategoryTreeController extends State<SelectableCategoryTree> {
  int? selectedCategoryId;

  void selectCategory(int id) {
    setState(() {
      selectedCategoryId = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SelectableSupportCategoryTreePage(this);
  }
}
