import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:schuldaten_hub/common/domain/session_manager.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/theme/colors.dart';
import 'package:schuldaten_hub/features/learning_support/domain/models/support_category/support_category.dart';
import 'package:schuldaten_hub/features/learning_support/domain/models/support_category/support_category_status.dart';
import 'package:schuldaten_hub/features/learning_support/domain/models/support_goal/support_goal.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_proxy.dart';

class LearningSupportHelper {
//- overview numbers functions
  static int developmentPlan1Pupils(List<PupilProxy> filteredPupils) {
    List<PupilProxy> developmentPlan1Pupils = [];
    if (filteredPupils.isNotEmpty) {
      for (PupilProxy pupil in filteredPupils) {
        if (pupil.supportLevel == 1) {
          developmentPlan1Pupils.add(pupil);
        }
      }
      return developmentPlan1Pupils.length;
    }
    return 0;
  }

  static int developmentPlan2Pupils(List<PupilProxy> filteredPupils) {
    List<PupilProxy> developmentPlan1Pupils = [];
    if (filteredPupils.isNotEmpty) {
      for (PupilProxy pupil in filteredPupils) {
        if (pupil.supportLevel == 2) {
          developmentPlan1Pupils.add(pupil);
        }
      }
      return developmentPlan1Pupils.length;
    }
    return 0;
  }

  static int developmentPlan3Pupils(List<PupilProxy> filteredPupils) {
    List<PupilProxy> developmentPlan1Pupils = [];
    if (filteredPupils.isNotEmpty) {
      for (PupilProxy pupil in filteredPupils) {
        if (pupil.supportLevel == 3) {
          developmentPlan1Pupils.add(pupil);
        }
      }
      return developmentPlan1Pupils.length;
    }
    return 0;
  }

  static String preschoolRevision(int value) {
    switch (value) {
      case 0:
        return 'nicht da';
      case 1:
        return 'unauffällig';
      case 2:
        return 'Förderbedarf';
      case 3:
        return 'AO-SF';
      default:
        return 'keine';
    }
  }

  static List<SupportGoal> getGoalsForCategory(
      PupilProxy pupil, int categoryId) {
    List<SupportGoal> goals = [];
    if (pupil.supportGoals != null) {
      for (SupportGoal goal in pupil.supportGoals!) {
        if (goal.supportCategoryId == categoryId) {
          goals.add(goal);
        }
        return goals;
      }
    }
    return [];
  }

  //- TODO: Is this necessary?
  static SupportGoal? getGoalForCategory(PupilProxy pupil, int goalCategoryId) {
    if (pupil.supportGoals != null) {
      if (pupil.supportGoals!.isNotEmpty) {
        final SupportGoal? goal = pupil.supportGoals!.lastWhereOrNull(
            (element) => element.supportCategoryId == goalCategoryId);
        return goal;
      }
      return null;
    }
    return null;
  }

  static SupportCategoryStatus? getCategoryStatus(
      PupilProxy pupil, int goalCategoryId) {
    if (pupil.supportCategoryStatuses != null) {
      if (pupil.supportCategoryStatuses!.isNotEmpty) {
        final SupportCategoryStatus? categoryStatus =
            pupil.supportCategoryStatuses!.lastWhereOrNull(
                (element) => element.supportCategoryId == goalCategoryId);
        return categoryStatus;
      }
    }
    return null;
  }

  static bool isAuthorizedToChangeStatus(SupportCategoryStatus status) {
    if (locator<SessionManager>().isAdmin.value == true ||
        status.createdBy ==
            locator<SessionManager>().credentials.value.username) {
      return true;
    }
    return false;
  }

  static Map<int, int> generateRootCategoryMap(
      List<SupportCategory> categories) {
    // Map for quick lookup of categories by their ID
    final Map<int, SupportCategory> categoryMap = {
      for (var category in categories) category.categoryId: category
    };

    // Cache to store root category results for efficiency
    final Map<int, int> rootCategoryCache = {};

    int findRootCategory(int categoryId) {
      // Check if result is already cached
      if (rootCategoryCache.containsKey(categoryId)) {
        return rootCategoryCache[categoryId]!;
      }

      final category = categoryMap[categoryId];
      if (category == null || category.parentCategory == null) {
        // Base case: If there's no parent, this is the root category
        rootCategoryCache[categoryId] = categoryId;
        return categoryId;
      }

      // Recursive case: Find the root of the parent category
      final rootId = findRootCategory(category.parentCategory!);
      rootCategoryCache[categoryId] = rootId; // Cache the result
      return rootId;
    }

    // Build the final map
    final Map<int, int> result = {};
    for (var category in categories) {
      result[category.categoryId] = findRootCategory(category.categoryId);
    }

    return result;
  }

  static Color getRootSupportCategoryColor(SupportCategory goalCategory) {
    if (goalCategory.categoryName == 'Körper, Wahrnehmung, Motorik') {
      return AppColors.koerperWahrnehmungMotorikColor;
    } else if (goalCategory.categoryName == 'Sozialkompetenz / Emotionalität') {
      return AppColors.sozialEmotionalColor;
    } else if (goalCategory.categoryName == 'Mathematik') {
      return AppColors.mathematikColor;
    } else if (goalCategory.categoryName == 'Lernen und Leisten') {
      return AppColors.lernenLeistenColor;
    } else if (goalCategory.categoryName == 'Deutsch') {
      return AppColors.deutschColor;
    } else if (goalCategory.categoryName == 'Sprache und Sprechen') {
      return AppColors.spracheSprechenColor;
    }
    return Colors.deepPurple;
  }
}
