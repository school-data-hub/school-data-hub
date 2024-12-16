import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/theme/colors.dart';
import 'package:schuldaten_hub/common/theme/paddings.dart';
import 'package:schuldaten_hub/common/utils/extensions.dart';
import 'package:schuldaten_hub/features/competence/presentation/widgets/pupil_learning_content_expansion_tile_nav_bar.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_proxy.dart';

class PupilLearningContent extends StatelessWidget {
  final PupilProxy pupil;
  const PupilLearningContent({required this.pupil, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.pupilProfileCardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: AppPaddings.pupilProfileCardPadding,
        child: Column(children: [
          const Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Icon(
              Icons.lightbulb,
              color: AppColors.accentColor,
              size: 24,
            ),
            Gap(5),
            Text('Lernen',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.backgroundColor,
                ))
          ]),
          const Gap(10),
          Row(
            children: [
              const Gap(5),
              const Text('3 Jahre Eingangsphase?'),
              const Gap(5),
              Text(
                pupil.fiveYears != null
                    ? pupil.fiveYears!.formatForUser()
                    : 'nein',
              ),
            ],
          ),
          const Gap(10),
          PupilLearningContentExpansionTileNavBar(
            pupil: pupil,
          ),
        ]),
      ),
    );
  }
}
