import 'package:flutter/material.dart';
import 'package:schuldaten_hub/features/learning_support/presentation/select_support_category_page/select_support_category_page.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_proxy.dart';

class SelectSupportCategory extends StatefulWidget {
  final PupilProxy pupil;
  final String elementType;
  const SelectSupportCategory({
    required this.pupil,
    required this.elementType,
    super.key,
  });

  @override
  SelectCategoryPageController createState() => SelectCategoryPageController();
}

class SelectCategoryPageController extends State<SelectSupportCategory> {
  int? selectedCategoryId;

  void selectCategory(int id) {
    setState(() {
      selectedCategoryId = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SelectSupportCategoryPage(this);
  }
}
