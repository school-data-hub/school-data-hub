import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/theme/colors.dart';
import 'package:schuldaten_hub/common/theme/paddings.dart';
import 'package:schuldaten_hub/common/utils/extensions.dart';
import 'package:schuldaten_hub/common/widgets/avatar.dart';
import 'package:schuldaten_hub/common/widgets/dialogues/confirmation_dialog.dart';
import 'package:schuldaten_hub/common/widgets/dialogues/long_textfield_dialog.dart';
import 'package:schuldaten_hub/common/widgets/dialogues/short_textfield_dialog.dart';
import 'package:schuldaten_hub/features/matrix/domain/matrix_policy_helper_functions.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_proxy.dart';
import 'package:schuldaten_hub/features/pupil/domain/pupil_manager.dart';
import 'package:schuldaten_hub/features/pupil/presentation/pupil_profile_page/pupil_profile_page.dart';

class PupilInfosContent extends StatelessWidget {
  final PupilProxy pupil;
  const PupilInfosContent({required this.pupil, super.key});

  @override
  Widget build(BuildContext context) {
    List<PupilProxy> pupilSiblings = locator<PupilManager>().siblings(pupil);
    return Card(
      color: AppColors.pupilProfileCardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: AppPaddings.pupilProfileCardPadding,
        child: Column(
          children: [
            const Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_rounded,
                  color: AppColors.backgroundColor,
                  size: 24,
                ),
                Gap(5),
                Text(
                  'Infos',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.backgroundColor),
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
                  title: 'Besondere Infos',
                  labelText: 'Besondere Infos',
                  textinField: pupil.specialInformation ?? '',
                  parentContext: context,
                );
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
                                color: AppColors.backgroundColor))
                        : const Text(
                            'keine Informationen',
                            style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: AppColors.interactiveColor),
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
                      MatrixHelperFunctions.launchMatrixUrl(
                          context, pupil.contact!);
                    }
                  },
                  onLongPress: () async {
                    final String? contact = await shortTextfieldDialog(
                      title: 'Kontakt',
                      hintText: 'Kontakt des Schülers/der Schülerin',
                      labelText: 'Kontakt',
                      textinField: pupil.contact ?? '',
                      context: context,
                    );
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
                          color: AppColors.interactiveColor)),
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
                  onTap: () {
                    if (pupil.parentsContact != null &&
                        pupil.parentsContact!.isNotEmpty) {
                      MatrixHelperFunctions.launchMatrixUrl(
                          context, pupil.parentsContact!);
                    }
                  },
                  // onTap: () {
                  //   if (pupil.parentsContact != null) {
                  //     launchMatrixUrl(context, pupil.parentsContact!);
                  //   }
                  // },
                  onLongPress: () async {
                    final String? family = await shortTextfieldDialog(
                        title: 'Kontakt Familie',
                        hintText: 'Kontakt der Familie',
                        labelText: 'Kontakt Familie',
                        textinField: pupil.parentsContact ?? 'keine Angabe',
                        context: context);
                    if (family == null) return;
                    await locator<PupilManager>().patchPupil(
                        pupil.internalId, 'parents_contact', family);
                  },
                  child: Text(pupil.parentsContact ?? 'keine Angabe',
                      style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.interactiveColor)),
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
                                    AvatarWithBadges(pupil: sibling, size: 80),
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
                                        color: AppColors.groupColor,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const Gap(20),
                                    Text(
                                      sibling.schoolyear,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.schoolyearColor,
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
