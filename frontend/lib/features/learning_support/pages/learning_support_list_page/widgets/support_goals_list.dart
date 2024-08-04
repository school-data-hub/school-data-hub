import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/constants/styles.dart';
import 'package:schuldaten_hub/features/learning_support/pages/new_category_item_page/controller/new_category_item_controller.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';
import 'package:schuldaten_hub/features/learning_support/widgets/support_category_widgets/support_goal_card.dart';

class SupportGoalsList extends StatelessWidget {
  final PupilProxy pupil;
  const SupportGoalsList({required this.pupil, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: ElevatedButton(
            style: actionButtonStyle,
            onPressed: () async {
              await Navigator.of(context).push(MaterialPageRoute(
                  builder: (ctx) => NewCategoryItem(
                        appBarTitle: 'Neues Förderziel',
                        pupilId: pupil.internalId,
                        goalCategoryId: 0,
                        elementType: 'goal',
                      )));
            },
            child: const Text(
              "NEUES FÖRDERZIEL",
              style: TextStyle(
                  fontSize: 17.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const Gap(5),
        pupil.pupilGoals!.isNotEmpty
            ? ListView.builder(
                padding: const EdgeInsets.all(0),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pupil.pupilGoals!.length,
                itemBuilder: (context, int index) {
                  return SupportGoalCard(pupil: pupil, goalIndex: index);
                })
            : const SizedBox.shrink(),
        const Gap(10),
      ],
    );
  }
}
