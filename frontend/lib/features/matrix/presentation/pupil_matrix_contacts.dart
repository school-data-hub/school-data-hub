import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/theme/colors.dart';
import 'package:schuldaten_hub/common/widgets/avatar.dart';
import 'package:schuldaten_hub/common/widgets/dialogs/confirmation_dialog.dart';
import 'package:schuldaten_hub/common/widgets/dialogs/long_textfield_dialog.dart';
import 'package:schuldaten_hub/common/widgets/generic_sliver_list.dart';
import 'package:schuldaten_hub/common/widgets/sliver_search_app_bar.dart';
import 'package:schuldaten_hub/features/credit/credit_list_page/widgets/credit_list_searchbar.dart';
import 'package:schuldaten_hub/features/matrix/domain/matrix_policy_helper_functions.dart';
import 'package:schuldaten_hub/features/pupil/domain/filters/pupils_filter.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_proxy.dart';
import 'package:schuldaten_hub/features/pupil/domain/pupil_manager.dart';
import 'package:schuldaten_hub/features/pupil/presentation/pupil_profile_page/pupil_profile_page.dart';
import 'package:watch_it/watch_it.dart';

class PupilsContactList extends WatchingWidget {
  const PupilsContactList({super.key});

  @override
  Widget build(BuildContext context) {
    List<PupilProxy> pupils = watchValue((PupilsFilter x) => x.filteredPupils);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kontakte'),
      ),
      body: Center(
        child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: CustomScrollView(
              slivers: [
                const SliverGap(5),
                SliverSearchAppBar(
                  title: CreditListSearchBar(pupils: pupils),
                  height: 110,
                ),
                GenericSliverListWithEmptyListCheck(
                    items: pupils,
                    itemBuilder: (_, pupil) => Card(
                        color: pupil.contact == null ||
                                pupil.parentsContact == null
                            ? Colors.orange
                            : Colors.white,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Gap(5),
                                AvatarWithBadges(pupil: pupil, size: 80),
                                const Gap(10),
                                Expanded(
                                    child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Gap(10),
                                    Row(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            Navigator.of(context)
                                                .push(MaterialPageRoute(
                                              builder: (ctx) =>
                                                  PupilProfilePage(
                                                pupil: pupil,
                                              ),
                                            ));
                                          },
                                          child: Text(
                                              '${pupil.firstName} ${pupil.lastName}',
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        if (pupil.family != null)
                                          const Row(
                                            children: [
                                              Gap(10),
                                              Icon(Icons.group,
                                                  size: 25,
                                                  color: AppColors
                                                      .backgroundColor),
                                            ],
                                          )
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Text('Kontakt: '),
                                        InkWell(
                                          onTap: () async {
                                            final confirm =
                                                await confirmationDialog(
                                                    context: context,
                                                    title: 'Messenger öffnen',
                                                    message:
                                                        'Nachricht an ${pupil.firstName} schicken?');
                                            if (confirm == true &&
                                                context.mounted) {
                                              MatrixHelper.launchMatrixUrl(
                                                  context, pupil.contact!);
                                            }
                                          },
                                          onLongPress: () async {
                                            final String? contact =
                                                await longTextFieldDialog(
                                                    title: 'Kontakt',
                                                    labelText: 'Kontakt',
                                                    textinField: pupil.contact,
                                                    parentContext: context);
                                            if (contact == null) return;
                                            await locator<PupilManager>()
                                                .patchPupil(pupil.internalId,
                                                    'contact', '@$contact');
                                          },
                                          child: Text(
                                              pupil.contact ??
                                                  'nicht eingetragen',
                                              style: TextStyle(
                                                  color: pupil.contact == null
                                                      ? Colors.black
                                                      : AppColors
                                                          .backgroundColor,
                                                  fontWeight:
                                                      pupil.contact == null
                                                          ? FontWeight.normal
                                                          : FontWeight.bold)),
                                        ),
                                        const Gap(10),
                                        IconButton(
                                          icon: const Icon(Icons.copy),
                                          onPressed: () {
                                            Clipboard.setData(ClipboardData(
                                                text: pupil.contact!));
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      'Copied to clipboard')),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    const Gap(10),
                                    Row(
                                      children: [
                                        const Text('Elternkontakt: '),
                                        InkWell(
                                            onTap: () async {
                                              final confirm =
                                                  await confirmationDialog(
                                                      context: context,
                                                      title: 'Messenger öffnen',
                                                      message:
                                                          'Nachricht an ${pupil.firstName}s Erziehungsberechtigte schicken?');
                                              if (confirm == true &&
                                                  context.mounted) {
                                                MatrixHelper.launchMatrixUrl(
                                                    context,
                                                    pupil.parentsContact!);
                                              }
                                            },
                                            onLongPress: () async {
                                              final String? contact =
                                                  await longTextFieldDialog(
                                                      title: 'Elternkontakt',
                                                      labelText:
                                                          'Elternkontakt',
                                                      textinField:
                                                          pupil.parentsContact,
                                                      parentContext: context);
                                              if (contact == null) return;
                                              await locator<PupilManager>()
                                                  .patchPupil(
                                                      pupil.internalId,
                                                      'parents_contact',
                                                      '@$contact');
                                            },
                                            child: Text(
                                                pupil.parentsContact ??
                                                    'nicht eingetragen',
                                                style: TextStyle(
                                                    color:
                                                        pupil.parentsContact ==
                                                                null
                                                            ? Colors.black
                                                            : AppColors
                                                                .backgroundColor,
                                                    fontWeight:
                                                        pupil.parentsContact ==
                                                                null
                                                            ? FontWeight.normal
                                                            : FontWeight
                                                                .bold))),
                                      ],
                                    ),
                                    const Gap(10),
                                  ],
                                ))
                              ],
                            ),
                          ],
                        ))),
              ],
            )),
      ),
    );
  }
}
