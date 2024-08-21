import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/widgets/avatar.dart';
import 'package:schuldaten_hub/common/widgets/dialogues/confirmation_dialog.dart';
import 'package:schuldaten_hub/common/widgets/dialogues/long_textfield_dialog.dart';
import 'package:schuldaten_hub/features/authorizations/services/authorization_manager.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';
import 'package:schuldaten_hub/features/pupil/services/pupil_manager.dart';
import 'package:watch_it/watch_it.dart';

class PupilsContactList extends WatchingWidget {
  const PupilsContactList({super.key});

  @override
  Widget build(BuildContext context) {
    List<PupilProxy> pupils = watch(locator<PupilManager>()).allPupils;
    pupils.sort((a, b) => a.firstName.compareTo(b.firstName));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kontakte'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView.builder(
            itemCount: pupils.length,
            itemBuilder: (context, index) {
              final pupil = pupils[index];
              return Card(
                  child: Column(
                children: [
                  Row(
                    children: [
                      AvatarWithBadges(pupil: pupil, size: 60),
                      const Gap(10),
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              '${pupils[index].firstName} ${pupils[index].lastName}',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          Row(
                            children: [
                              const Text('Kontakt: '),
                              InkWell(
                                onTap: () async {
                                  final String? contact =
                                      await longTextFieldDialog(
                                          'Kontakt', pupil.contact, context);
                                  if (contact == null) return;
                                  await locator<PupilManager>().patchPupil(
                                      pupil.internalId, 'contact', '@$contact');
                                },
                                child: Text(
                                    pupils[index].contact ??
                                        'nicht eingetragen',
                                    style: TextStyle(
                                        color: pupils[index].contact == null
                                            ? Colors.black
                                            : backgroundColor,
                                        fontWeight:
                                            pupils[index].contact == null
                                                ? FontWeight.normal
                                                : FontWeight.bold)),
                              ),
                              const Gap(10),
                              IconButton(
                                icon: const Icon(Icons.copy),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(
                                      text: pupils[index].contact!));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Copied to clipboard')),
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
                                    final String? contact =
                                        await longTextFieldDialog(
                                            'Elternkontakt',
                                            pupil.parentsContact,
                                            context);
                                    if (contact == null) return;
                                    await locator<PupilManager>().patchPupil(
                                        pupil.internalId,
                                        'parents_contact',
                                        '@$contact');
                                  },
                                  child: Text(
                                      pupils[index].parentsContact ??
                                          'nicht eingetragen',
                                      style: TextStyle(
                                          color: pupils[index].parentsContact ==
                                                  null
                                              ? Colors.black
                                              : backgroundColor,
                                          fontWeight:
                                              pupils[index].parentsContact ==
                                                      null
                                                  ? FontWeight.normal
                                                  : FontWeight.bold))),
                            ],
                          ),
                          const Gap(10),
                        ],
                      ))
                    ],
                  ),
                ],
              ));
            },
          ),
        ),
      ),
    );
  }
}
