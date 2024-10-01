import 'package:flutter/material.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/constants/styles.dart';
import 'package:schuldaten_hub/features/learning_support/pages/goal_category_list_page/controller/category_list_controller.dart';
import 'package:schuldaten_hub/features/learning_support/pages/goal_category_list_page/widgets/category_tree.dart';
import 'package:schuldaten_hub/features/learning_support/services/learning_support_manager.dart';
import 'package:watch_it/watch_it.dart';

import '../../../../common/services/base_state.dart';
import '../../../../common/services/locator.dart';
import '../../../../common/widgets/generic_app_bar.dart';

class CategoryListView extends WatchingStatefulWidget {
  final CategoryListController controller;

  const CategoryListView(this.controller, {super.key});

  @override
  State<CategoryListView> createState() => _CategoryListViewState();
}

class _CategoryListViewState extends BaseState<CategoryListView> {
  @override
  Future<void> onInitialize() async {
    await locator.isReady<LearningSupportManager>();
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      return Scaffold(
        backgroundColor: canvasColor,
        appBar: AppBar(
          foregroundColor: Colors.white,
          centerTitle: true,
          backgroundColor: backgroundColor,
          title: const Text(
            'Förderkategorien',
            style: appBarTextStyle,
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        centerTitle: true,
        backgroundColor: backgroundColor,
        title: const Text(
          'Förderkategorien',
          style: appBarTextStyle,
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding:
              const EdgeInsets.only(top: 8.0, left: 10, right: 10, bottom: 10),
          child: Center(
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: const SupportCategoryTree(
                    parentId: null, indentation: 0, backGroundColor: null)),
          ),
        ),
      ),
    );
  }
}
