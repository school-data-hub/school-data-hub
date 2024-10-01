import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/constants/paddings.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';
import 'package:schuldaten_hub/features/schoolday_events/pages/schoolday_event_list_page/schoolday_event_list_page.dart';
import 'package:schuldaten_hub/features/schoolday_events/pages/schoolday_event_list_page/widgets/pupil_schoolday_event_content_list.dart';

import '../../../../../../../common/services/base_state.dart';
import '../../../../../../../common/services/locator.dart';
import '../../../../../filters/pupils_filter.dart';

class PupilSchooldayEventsContent extends StatefulWidget {
  final PupilProxy pupil;

  const PupilSchooldayEventsContent({required this.pupil, super.key});

  @override
  State<PupilSchooldayEventsContent> createState() =>
      _PupilSchooldayEventsContentState();
}

class _PupilSchooldayEventsContentState
    extends BaseState<PupilSchooldayEventsContent> {
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
        child: Column(children: [
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Color.fromARGB(255, 239, 66, 66),
              size: 24,
            ),
            const Gap(5),
            InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (ctx) => const SchooldayEventListPage(),
                ));
              },
              child: const Text('Ereignisse',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: backgroundColor,
                  )),
            )
          ]),
          const Gap(15),
          SchooldayEventsContentList(pupil: widget.pupil),
        ]),
      ),
    );
  }
}
