import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/constants/paddings.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/utils/extensions.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';
import 'package:schuldaten_hub/features/pupil/services/pupil_manager.dart';
import 'package:schuldaten_hub/features/pupil/pages/pupil_profile_page/widgets/pupil_profile_page_content/widgets/pupil_communication_content_language_values.dart';
import 'package:schuldaten_hub/features/pupil/pages/pupil_profile_page/widgets/dialogs/language_dialog.dart';

import '../../../../../../../common/services/base_state.dart';
import '../../../../../filters/pupils_filter.dart';

class PupilCommunicationContent extends StatefulWidget {
  final PupilProxy pupil;

  const PupilCommunicationContent({required this.pupil, super.key});

  @override
  State<PupilCommunicationContent> createState() =>
      _PupilCommunicationContentState();
}

class _PupilCommunicationContentState
    extends BaseState<PupilCommunicationContent> {
  @override
  Future<void> onInitialize() async {
    await locator.isReady<PupilsFilter>();
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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.language_rounded,
                color: groupColor,
                size: 24,
              ),
              Gap(5),
              Text(
                'Sprache(n)',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: backgroundColor),
              ),
            ],
          ),
          const Gap(15),
          Row(
            children: [
              const Text('Familiensprache:', style: TextStyle(fontSize: 18.0)),
              const Gap(10),
              Text(widget.pupil.language,
                  style: const TextStyle(
                      fontSize: 18.0, fontWeight: FontWeight.bold))
            ],
          ),
          const Gap(10),
          Row(
            children: [
              const Text('Erstförderung:', style: TextStyle(fontSize: 18.0)),
              const Gap(10),
              Text(
                  widget.pupil.migrationSupportEnds != null
                      ? 'bis : ${widget.pupil.migrationSupportEnds!.formatForUser()}'
                      : 'keine',
                  style: const TextStyle(
                      fontSize: 18.0, fontWeight: FontWeight.bold)),
            ],
          ),
          const Gap(10),
          const Row(
            children: [
              Text(
                'Deutsch - Sprachkompetenz',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Gap(10),
          const Row(
            children: [
              Text(
                'Kind:',
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 18.0),
              ),
            ],
          ),
          const Gap(10),
          InkWell(
            onTap: () => languageDialog(context, widget.pupil,
                'communication_pupil', widget.pupil.communicationPupil),
            onLongPress: () => locator<PupilManager>().patchPupil(
                widget.pupil.internalId, 'communication_pupil', null),
            child: widget.pupil.communicationPupil == null
                ? const Text(
                    'kein Eintrag',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: backgroundColor),
                  )
                : Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Gap(10),
                          InkWell(
                            child: Container(
                                child: communicationValues(
                                    widget.pupil.communicationPupil!)),
                          )
                        ],
                      ),
                    ),
                  ),
          ),
          const Gap(10),
          const Row(
            children: [
              Text(
                'Mutter / TutorIn 1:',
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 18.0),
              ),
            ],
          ),
          const Gap(10),
          InkWell(
            onTap: () => languageDialog(context, widget.pupil,
                'communication_tutor1', widget.pupil.communicationTutor1),
            onLongPress: () => locator<PupilManager>().patchPupil(
                widget.pupil.internalId, 'communication_tutor1', null),
            child: widget.pupil.communicationTutor1 == null
                ? const Text(
                    'kein Eintrag',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: backgroundColor),
                  )
                : Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Gap(10),
                          InkWell(
                            child: Container(
                                child: communicationValues(
                                    widget.pupil.communicationTutor1!)),
                          )
                        ],
                      ),
                    ),
                  ),
          ),
          const Gap(10),
          const Row(
            children: [
              Text(
                'Vater / TutorIn 2:',
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 18.0),
              ),
            ],
          ),
          const Gap(10),
          InkWell(
            onTap: () => languageDialog(context, widget.pupil,
                'communication_tutor2', widget.pupil.communicationTutor2),
            onLongPress: () => locator<PupilManager>().patchPupil(
                widget.pupil.internalId, 'communication_tutor2', null),
            child: widget.pupil.communicationTutor2 == null
                ? const Text(
                    'kein Eintrag',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: backgroundColor),
                  )
                : Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Gap(10),
                          InkWell(
                            child: Container(
                                child: communicationValues(
                                    widget.pupil.communicationTutor2!)),
                          )
                        ],
                      ),
                    ),
                  ),
          ),
          const Gap(10)
        ]),
      ),
    );
  }
}
