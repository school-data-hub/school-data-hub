import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/domain/session_manager.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/theme/colors.dart';
import 'package:schuldaten_hub/common/widgets/avatar.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_proxy.dart';
import 'package:watch_it/watch_it.dart';

class PupilProfileHeadWidget extends WatchingWidget {
  final PupilProxy passedPupil;
  const PupilProfileHeadWidget({required this.passedPupil, super.key});

  @override
  Widget build(BuildContext context) {
    final pupil = watch<PupilProxy>(passedPupil);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            AvatarWithBadges(pupil: pupil, size: 100),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Gap(10),
              Row(
                children: [
                  Align(
                    child: Text(
                      pupil.firstName,
                      //textAlign: TextAlign.left,
                      style: const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${pupil.lastName} ',
                    style: const TextStyle(
                      fontSize: 20.0,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    'FE  ${pupil.supportLevel}',
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0),
                  ),
                  const Gap(15),
                  pupil.specialNeeds != null
                      ? Text(
                          pupil.schoolyear,
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                              color: AppColors.schoolyearColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0),
                        )
                      : const SizedBox.shrink(),
                  const Gap(15),
                  if (pupil.specialInformation != null)
                    const Icon(
                      Icons.warning_rounded,
                      color: Colors.red,
                    ),
                  if (locator<SessionManager>().isAdmin.value ==
                      true) ...<Widget>[
                    const Gap(10),
                    Text(
                      '${pupil.internalId}',
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0),
                    )
                  ]
                ],
              ),
              const Gap(2),
            ],
          ),
        )
      ],
    );
  }
}
