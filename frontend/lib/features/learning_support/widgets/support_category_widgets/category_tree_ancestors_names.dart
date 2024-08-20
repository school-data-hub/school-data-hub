import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/features/learning_support/models/support_category/support_category.dart';
import 'package:schuldaten_hub/features/learning_support/services/learning_support_manager.dart';

List<Widget> categoryTreeAncestorsNames(int categoryId) {
  // Create an empty list to store ancestors
  List<Widget> ancestors = [];

  // Use a recursive helper function to collect ancestors
  void collectAncestors(int currentCategoryId) {
    final SupportCategory currentCategory =
        locator<LearningSupportManager>().getSupportCategory(currentCategoryId);

    // Check if parent category exists before recursion
    if (currentCategory.parentCategory != null) {
      collectAncestors(currentCategory.parentCategory!);
    }
    if (currentCategory.categoryId ==
        locator<LearningSupportManager>()
            .getRootSupportCategory(categoryId)
            .categoryId) {
      ancestors.add(
        Row(
          children: [
            const Gap(10),
            Flexible(
              child: Text(
                  locator<LearningSupportManager>()
                      .getRootSupportCategory(categoryId)
                      .categoryName,
                  style: const TextStyle(
                    overflow: TextOverflow.fade,
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  )),
            ),
            const Gap(10),
          ],
        ),
      );
    }
    // Add current category name to the list after recursion
    if (currentCategory.categoryId !=
        locator<LearningSupportManager>()
            .getRootSupportCategory(categoryId)
            .categoryId) {
      if (currentCategory.categoryId != categoryId) {
        ancestors.add(
          Row(
            children: [
              const Gap(10),
              Flexible(
                child: Text(
                  currentCategory.categoryName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const Gap(10),
            ],
          ),
        );
      }
    }
  }

  // Start the recursion from the input category
  collectAncestors(categoryId);

  ancestors.add(const Gap(5));
  return ancestors;
}
