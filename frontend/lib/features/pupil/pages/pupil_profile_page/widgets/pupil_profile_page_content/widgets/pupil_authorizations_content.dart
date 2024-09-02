import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/constants/paddings.dart';
import 'package:schuldaten_hub/features/authorizations/pages/authorizations_list_page/authorizations_list_page.dart';
import 'package:schuldaten_hub/features/authorizations/pages/authorization_pupils_page/widgets/pupil_authorizations_content_list.dart';
import 'package:schuldaten_hub/features/authorizations/services/authorization_manager.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';

import '../../../../../../../common/services/base_state.dart';
import '../../../../../../../common/services/locator.dart';
import '../../../../../filters/pupils_filter.dart';

class PupilAuthorizationsContent extends StatefulWidget {
  final PupilProxy pupil;

  const PupilAuthorizationsContent({required this.pupil, super.key});

  @override
  State<PupilAuthorizationsContent> createState() =>
      _PupilAuthorizationsContentState();
}

class _PupilAuthorizationsContentState
    extends BaseState<PupilAuthorizationsContent> {
  @override
  Future<void> onInitialize() async {
    await locator.isReady<PupilsFilter>();
    await locator.isReady<AuthorizationManager>();
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
              Icons.fact_check_rounded,
              color: backgroundColor,
              size: 24,
            ),
            const Gap(5),
            InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (ctx) => const AuthorizationsListPage(),
                ));
              },
              child: const Text('Einwilligungen',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: backgroundColor,
                  )),
            )
          ]),
          const Gap(15),
          PupilAuthorizationsContentList(pupil: widget.pupil),
        ]),
      ),
    );
  }
}
