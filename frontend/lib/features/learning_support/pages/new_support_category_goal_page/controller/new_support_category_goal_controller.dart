import 'package:flutter/material.dart';

import 'package:schuldaten_hub/features/learning_support/services/learning_support_manager.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/features/learning_support/pages/new_support_category_goal_page/new_supporz_category_goal_page.dart';

class NewSupportCategoryGoal extends StatefulWidget {
  final String appBarTitle;
  final int pupilId;
  final int goalCategoryId;
  final String elementType;

  const NewSupportCategoryGoal(
      {super.key,
      required this.appBarTitle,
      required this.pupilId,
      required this.goalCategoryId,
      required this.elementType});

  @override
  NewSupportCategoryGoalController createState() =>
      NewSupportCategoryGoalController();
}

class NewSupportCategoryGoalController extends State<NewSupportCategoryGoal> {
  @override
  void initState() {
    super.initState();
    goalCategoryId = widget.goalCategoryId;
  }

  final TextEditingController descriptionTextFieldController =
      TextEditingController();
  final TextEditingController strategiesTextField2Controller =
      TextEditingController();
  int? goalCategoryId;
  String categoryStatusValue = 'white';
  void setGoalCategoryId(int id) {
    setState(() {
      goalCategoryId = id;
    });
  }

  void setCategoryStatusValue(String value) {
    setState(() {
      categoryStatusValue = value;
    });
  }

  Future postCategoryGoal() async {
    if (goalCategoryId == null) {
      return;
    }

    await locator<LearningSupportManager>().postNewSupportCategoryGoal(
        goalCategoryId: goalCategoryId!,
        pupilId: widget.pupilId,
        description: descriptionTextFieldController.text,
        strategies: strategiesTextField2Controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return NewCategoryGoalView(this);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the tree
    descriptionTextFieldController.dispose();
    strategiesTextField2Controller.dispose();
    super.dispose();
  }
}
