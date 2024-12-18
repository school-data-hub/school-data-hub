import 'package:flutter/material.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/features/learning_support/domain/learning_support_helper_functions.dart';
import 'package:schuldaten_hub/features/learning_support/domain/learning_support_manager.dart';

class SupportCategoryCardBanner extends StatelessWidget {
  final int categoryId;
  const SupportCategoryCardBanner({required this.categoryId, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: LearningSupportHelper.getRootSupportCategoryColor(
              locator<LearningSupportManager>()
                  .getRootSupportCategory(categoryId)),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    locator<LearningSupportManager>()
                        .getRootSupportCategory(categoryId)
                        .categoryName,
                    style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
