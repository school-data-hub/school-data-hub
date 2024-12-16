import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:schuldaten_hub/common/domain/models/enums.dart';
import 'package:schuldaten_hub/common/services/api/api.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_service.dart';
import 'package:schuldaten_hub/common/theme/colors.dart';
import 'package:schuldaten_hub/features/learning_support/domain/models/support_category/support_category.dart';
import 'package:schuldaten_hub/features/learning_support/domain/models/support_goal/support_goal.dart';
import 'package:schuldaten_hub/features/pupil/domain/pupil_manager.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_data.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_proxy.dart';

class LearningSupportManager {
  ValueListenable<List<SupportCategory>> get goalCategories => _goalCategories;
  ValueListenable<bool> get isRunning => _isRunning;

  final _goalCategories = ValueNotifier<List<SupportCategory>>([]);
  final _isRunning = ValueNotifier<bool>(false);

  LearningSupportManager();

  Future<LearningSupportManager> init() async {
    await fetchSupportCategories();
    return this;
  }

  final notificationService = locator<NotificationService>();

  final apiLearningSupportService = LearningSupportRepository();

  void clearData() {
    _goalCategories.value = [];
  }

  Future<void> fetchSupportCategories() async {
    final List<SupportCategory> goalCategories =
        await apiLearningSupportService.fetchGoalCategories();

    _goalCategories.value = goalCategories;

    notificationService.showSnackBar(NotificationType.success,
        '${goalCategories.length} Kategorien geladen');

    return;
  }

  //- this function does not call the API
  List<SupportGoal> getGoalsForSupportCategory(int categoryId) {
    List<SupportGoal> goals = [];
    final List<PupilProxy> pupils = locator<PupilManager>().allPupils;
    for (PupilProxy pupil in pupils) {
      for (SupportGoal goal in pupil.supportGoals!) {
        if (goal.supportCategoryId == categoryId) {
          goals.add(goal);
        }
      }
    }
    return goals;
  }

  Future<void> postSupportCategoryStatus(
    PupilProxy pupil,
    int goalCategoryId,
    String state,
    String comment,
  ) async {
    final PupilData responsePupil =
        await apiLearningSupportService.postSupportCategoryStatus(
            pupilInternalId: pupil.internalId,
            goalCategoryId: goalCategoryId,
            state: state,
            comment: comment);

    locator<PupilManager>().updatePupilProxyWithPupilData(responsePupil);

    notificationService.showSnackBar(
        NotificationType.success, 'Status hinzugefügt');

    return;
  }

  Future<void> updateSupportCategoryStatusProperty({
    required PupilProxy pupil,
    required String statusId,
    String? state,
    String? comment,
    String? createdBy,
    String? createdAt,
  }) async {
    final PupilData responsePupil =
        await apiLearningSupportService.updateCategoryStatusProperty(
            pupil, statusId, state, comment, createdBy, createdAt);

    locator<PupilManager>().updatePupilProxyWithPupilData(responsePupil);

    notificationService.showSnackBar(
        NotificationType.success, 'Status aktualisiert');

    return;
  }

  Future<void> deleteSupportCategoryStatus(String statusId) async {
    final PupilData responsePupil =
        await apiLearningSupportService.deleteCategoryStatus(statusId);

    notificationService.showSnackBar(
        NotificationType.success, 'Status gelöscht');

    locator<PupilManager>().updatePupilProxyWithPupilData(responsePupil);
    return;
  }

  Future postNewSupportCategoryGoal(
      {required int goalCategoryId,
      required int pupilId,
      required String description,
      required String strategies}) async {
    final PupilData responsePupil =
        await apiLearningSupportService.postNewCategoryGoal(
            goalCategoryId: goalCategoryId,
            pupilId: pupilId,
            description: description,
            strategies: strategies);

    locator<PupilManager>().updatePupilProxyWithPupilData(responsePupil);

    notificationService.showSnackBar(
        NotificationType.success, 'Ziel hinzugefügt');

    return;
  }

  Future deleteGoal(String goalId) async {
    final PupilData responsePupil =
        await apiLearningSupportService.deleteGoal(goalId);

    locator<PupilManager>().updatePupilProxyWithPupilData(responsePupil);

    notificationService.showSnackBar(NotificationType.success, 'Ziel gelöscht');

    return;
  }

  //- these functions do not call the API
  SupportCategory getSupportCategory(int categoryId) {
    final SupportCategory goalCategory = goalCategories.value
        .firstWhere((element) => element.categoryId == categoryId);
    return goalCategory;
  }

  SupportCategory getRootSupportCategory(int categoryId) {
    SupportCategory goalCategory = _goalCategories.value
        .firstWhere((element) => element.categoryId == categoryId);
    if (goalCategory.parentCategory == null) {
      return goalCategory;
    } else {
      return getRootSupportCategory(goalCategory.parentCategory!);
    }
  }

  Color getCategoryColor(int categoryId) {
    final SupportCategory rootCategory = getRootSupportCategory(categoryId);
    return getRootSupportCategoryColor(rootCategory);
  }

  Color getRootSupportCategoryColor(SupportCategory goalCategory) {
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