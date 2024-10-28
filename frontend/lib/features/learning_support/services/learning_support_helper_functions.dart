import 'package:collection/collection.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/session_manager.dart';
import 'package:schuldaten_hub/features/learning_support/models/support_category/support_category_status.dart';
import 'package:schuldaten_hub/features/learning_support/models/support_goal/support_goal.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';

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
}
