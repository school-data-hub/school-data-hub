import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/constants/paddings.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/utils/extensions.dart';
import 'package:schuldaten_hub/common/widgets/avatar.dart';
import 'package:schuldaten_hub/common/widgets/dialogues/confirmation_dialog.dart';
import 'package:schuldaten_hub/common/widgets/dialogues/long_textfield_dialog.dart';
import 'package:schuldaten_hub/features/matrix/services/matrix_policy_helper_functions.dart';

import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';
import 'package:schuldaten_hub/features/pupil/services/pupil_manager.dart';
import 'package:schuldaten_hub/features/pupil/pages/pupil_profile_page/pupil_profile_page.dart';

import '../../../../../../../common/services/base_state.dart';
import '../../../../../../../common/widgets/generic_app_bar.dart';
import '../../../../../filters/pupils_filter.dart';

class PupilInfosContent extends StatefulWidget {
  final PupilProxy pupil;

  const PupilInfosContent({required this.pupil, super.key});

  @override
  State<PupilInfosContent> createState() => _PupilInfosContentState();
}

class _PupilInfosContentState extends BaseState<PupilInfosContent> {
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
    List<PupilProxy> pupilSiblings =
        locator<PupilManager>().siblings(widget.pupil);
    return Card(
      color: pupilProfileCardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: pupilProfileCardPadding,
        child: Column(
          children: [
            const Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_rounded,
                  color: backgroundColor,
                  size: 24,
                ),
                Gap(5),
                Text(
                  'Infos',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: backgroundColor),
                ),
              ],
            ),
            const Gap(15),
            const Row(
              children: [
                Text('Besondere Infos:', style: TextStyle(fontSize: 18.0)),
                Gap(5),
              ],
            ),
            const Gap(5),
            InkWell(
              onTap: () async {
                final String? specialInformation = await longTextFieldDialog(
                    'Besondere Infos',
                    widget.pupil.specialInformation,
                    context);
                if (specialInformation == null) return;
                await locator<PupilManager>().patchPupil(
                    widget.pupil.internalId,
                    'special_information',
                    specialInformation);
              },
              onLongPress: () async {
                if (widget.pupil.specialInformation == null) return;
                final bool? confirm = await confirmationDialog(
                    context: context,
                    title: 'Besondere Infos löschen',
                    message:
                        'Besondere Informationen für dieses Kind löschen?');
                if (confirm == false || confirm == null) return;
                await locator<PupilManager>().patchPupil(
                    widget.pupil.internalId, 'special_information', null);
              },
              child: Row(
                children: [
                  Flexible(
                    child: widget.pupil.specialInformation != null
                        ? Text(widget.pupil.specialInformation!,
                            softWrap: true,
                            style: const TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: backgroundColor))
                        : const Text(
                            'keine Informationen',
                            style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: interactiveColor),
                          ),
                  ),
                ],
              ),
            ),
            const Gap(10),
            Row(
              children: [
                const Text('Geschlecht:', style: TextStyle(fontSize: 18.0)),
                const Gap(10),
                Text(widget.pupil.gender == 'm' ? 'männlich' : 'weiblich',
                    style: const TextStyle(
                        fontSize: 18.0, fontWeight: FontWeight.bold))
              ],
            ),
            const Gap(10),
            Row(
              children: [
                const Text('Geburtsdatum:', style: TextStyle(fontSize: 18.0)),
                const Gap(10),
                Text(widget.pupil.birthday.formatForUser(),
                    style: const TextStyle(
                        fontSize: 18.0, fontWeight: FontWeight.bold))
              ],
            ),
            const Gap(10),
            Row(
              children: [
                const Text('Kontakt:', style: TextStyle(fontSize: 18.0)),
                const Gap(10),
                InkWell(
                  onTap: () {
                    if (widget.pupil.contact != null &&
                        widget.pupil.contact!.isNotEmpty) {
                      launchMatrixUrl(context, widget.pupil.contact!);
                    }
                  },
                  onLongPress: () async {
                    final String? contact = await longTextFieldDialog(
                        'Kontakt', widget.pupil.contact, context);
                    if (contact == null) return;
                    await locator<PupilManager>().patchPupil(
                        widget.pupil.internalId, 'contact', contact);
                  },
                  child: Text(
                      widget.pupil.contact?.isNotEmpty == true
                          ? widget.pupil.contact!
                          : 'keine Angabe',
                      style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: interactiveColor)),
                )
              ],
            ),
            const Gap(10),
            Row(
              children: [
                const Text('Kontakt Familie:',
                    style: TextStyle(fontSize: 18.0)),
                const Gap(10),
                InkWell(
                  // onTap: () {
                  //   if (pupil.parentsContact != null) {
                  //     launchMatrixUrl(context, pupil.parentsContact!);
                  //   }
                  // },
                  onLongPress: () async {
                    final String? family = await longTextFieldDialog(
                        'Kontakt Familie',
                        widget.pupil.parentsContact ?? 'keine Angabe',
                        context);
                    if (family == null) return;
                    await locator<PupilManager>().patchPupil(
                        widget.pupil.internalId, 'parents_contact', family);
                  },
                  child: Text(widget.pupil.parentsContact ?? 'keine Angabe',
                      style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: interactiveColor)),
                )
              ],
            ),
            const Gap(10),
            Row(
              children: [
                const Text('Aufnahmedatum:', style: TextStyle(fontSize: 18.0)),
                const Gap(10),
                Text(widget.pupil.pupilSince.formatForUser(),
                    style: const TextStyle(
                        fontSize: 18.0, fontWeight: FontWeight.bold))
              ],
            ),
            const Gap(10),
            pupilSiblings.isNotEmpty
                ? const Row(
                    children: [
                      Text(
                        'Geschwister:',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
            pupilSiblings.isNotEmpty
                ? ListView.builder(
                    padding: const EdgeInsets.only(top: 5, bottom: 15),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: pupilSiblings.length,
                    itemBuilder: (context, int index) {
                      PupilProxy sibling = pupilSiblings[index];
                      return Column(
                        children: [
                          const Gap(5),
                          InkWell(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (ctx) => PupilProfilePage(
                                  pupil: sibling,
                                ),
                              ));
                            },
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Row(
                                  children: [
                                    Provider.value(
                                      value: AvatarData(
                                          avatarId: sibling.avatarId,
                                          internalId: sibling.internalId,
                                          size: 50),
                                      child: const AvatarImage(),
                                    ),
                                    const Gap(10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          sibling.firstName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                        Text(
                                          sibling.lastName,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    const Gap(20),
                                    Text(
                                      sibling.group,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: groupColor,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const Gap(20),
                                    Text(
                                      sibling.schoolyear,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: schoolyearColor,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    })
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
