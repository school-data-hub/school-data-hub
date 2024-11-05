import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/constants/paddings.dart';
import 'package:schuldaten_hub/common/utils/extensions.dart';
import 'package:schuldaten_hub/features/competence/pages/widgets/pupil_learning_content_expansion_tile_nav_bar.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';

import '../../../../../../../common/services/base_state.dart';
import '../../../../../../../common/services/locator.dart';
import '../../../../../../workbooks/services/workbook_manager.dart';
import '../../../../../filters/pupils_filter.dart';

class PupilLearningContent extends StatefulWidget {
  final PupilProxy pupil;

  const PupilLearningContent({required this.pupil, super.key});

  @override
  State<PupilLearningContent> createState() =>
      _PupilLearningContentState();
}

class _PupilLearningContentState
    extends BaseState<PupilLearningContent> {
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
          const Gap(10),
          Row(
            children: [
              const Gap(5),
              const Text('3 Jahre Eingangsphase?'),
              const Gap(5),
              Text(
                widget.pupil.fiveYears != null
                    ? widget.pupil.fiveYears!.formatForUser()
                    : 'nein',
              ),
            ],
          ),
          const Gap(10),
          PupilLearningContentExpansionTileNavBar(
            pupil: widget.pupil,
          ),
        ]),
      ),
    );
  }
}
