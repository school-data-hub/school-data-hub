import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/constants/paddings.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/utils/extensions.dart';
import 'package:schuldaten_hub/common/widgets/avatar.dart';
import 'package:schuldaten_hub/common/widgets/dialogues/confirmation_dialog.dart';
import 'package:schuldaten_hub/common/widgets/dialogues/information_dialog.dart';
import 'package:schuldaten_hub/common/widgets/dialogues/long_textfield_dialog.dart';

import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';
import 'package:schuldaten_hub/features/pupil/services/pupil_manager.dart';
import 'package:schuldaten_hub/features/pupil/pages/pupil_profile_page/pupil_profile_page.dart';
import 'package:url_launcher/url_launcher.dart';

class PupilInfosContent extends StatelessWidget {
  final PupilProxy pupil;
  const PupilInfosContent({required this.pupil, super.key});

  Future<void> launchMatrixUrl(BuildContext context, String contact) async {
    final Uri matrixUrl = Uri.parse('https://matrix.to/#/$contact');
    bool canLaunchThis = await canLaunchUrl(matrixUrl);
    if (!canLaunchThis) {
      if (context.mounted) {
        informationDialog(context, 'Verbindung nicht möglich',
            'Es konnte keine Verbindung mit dem Messenger hergestellt werden.');
      }
    }
    try {
      final bool launched = await launchUrl(
        matrixUrl,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        print('Failed to launch $matrixUrl');
      }
    } catch (e) {
      print('An error occurred while launching $matrixUrl: $e');
    }

    return;
  }

  @override
  Widget build(BuildContext context) {
    List<PupilProxy> pupilSiblings = locator<PupilManager>().siblings(pupil);
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
                    'Besondere Infos', pupil.specialInformation, context);
                if (specialInformation == null) return;
                await locator<PupilManager>().patchPupil(pupil.internalId,
                    'special_information', specialInformation);
              },
              onLongPress: () async {
                if (pupil.specialInformation == null) return;
                final bool? confirm = await confirmationDialog(
                    context: context,
                    title: 'Besondere Infos löschen',
                    message:
                        'Besondere Informationen für dieses Kind löschen?');
                if (confirm == false || confirm == null) return;
                await locator<PupilManager>()
                    .patchPupil(pupil.internalId, 'special_information', null);
              },
              child: Row(
                children: [
                  Flexible(
                    child: pupil.specialInformation != null
                        ? Text(pupil.specialInformation!,
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
                Text(pupil.gender == 'm' ? 'männlich' : 'weiblich',
                    style: const TextStyle(
                        fontSize: 18.0, fontWeight: FontWeight.bold))
              ],
            ),
            const Gap(10),
            Row(
              children: [
                const Text('Geburtsdatum:', style: TextStyle(fontSize: 18.0)),
                const Gap(10),
                Text(pupil.birthday.formatForUser(),
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
                    if (pupil.contact != null && pupil.contact!.isNotEmpty) {
                      launchMatrixUrl(context, pupil.contact!);
                    }
                  },
                  onLongPress: () async {
                    final String? contact = await longTextFieldDialog(
                        'Kontakt', pupil.contact, context);
                    if (contact == null) return;
                    await locator<PupilManager>()
                        .patchPupil(pupil.internalId, 'contact', contact);
                  },
                  child: Text(
                      pupil.contact?.isNotEmpty == true
                          ? pupil.contact!
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
                        pupil.parentsContact ?? 'keine Angabe',
                        context);
                    if (family == null) return;
                    await locator<PupilManager>().patchPupil(
                        pupil.internalId, 'parents_contact', family);
                  },
                  child: Text(pupil.parentsContact ?? 'keine Angabe',
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
                Text(pupil.pupilSince.formatForUser(),
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
