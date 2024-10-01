import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/constants/paddings.dart';
import 'package:schuldaten_hub/features/competence/pages/learning_pupil_list_page/widgets/pupil_learning_content_list.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';

import '../../../../../../../common/services/base_state.dart';
import '../../../../../../../common/services/locator.dart';
import '../../../../../../workbooks/services/workbook_manager.dart';
import '../../../../../filters/pupils_filter.dart';

class PupilLearningContentCard extends StatefulWidget {
  final PupilProxy pupil;

  const PupilLearningContentCard({required this.pupil, super.key});

  @override
  State<PupilLearningContentCard> createState() =>
      _PupilLearningContentCardState();
}

class _PupilLearningContentCardState
    extends BaseState<PupilLearningContentCard> {
  @override
  Future<void> onInitialize() async {
    await locator.isReady<PupilsFilter>();
    await locator.isReady<WorkbookManager>();
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      return const Card(
        child: CircularProgressIndicator(),
      );
    }
    return Card(
      color: pupilProfileCardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: pupilProfileCardPadding,
        child: Column(children: [
          const Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Icon(
              Icons.lightbulb,
              color: accentColor,
              size: 24,
            ),
            Gap(5),
            Text('Lernen',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: backgroundColor,
                ))
          ]),
          const Gap(15),
          PupilLearningContent(pupil: widget.pupil)
        ]),
      ),
    );
  }
}
