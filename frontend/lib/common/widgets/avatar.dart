import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schuldaten_hub/common/services/api/api_settings.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/theme/colors.dart';
import 'package:schuldaten_hub/common/widgets/download_or_cached_and_decrypt_image.dart';
import 'package:schuldaten_hub/features/attendance/domain/attendance_helper_functions.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_proxy.dart';
import 'package:schuldaten_hub/features/pupil/domain/pupil_helper_functions.dart';
import 'package:schuldaten_hub/features/pupil/domain/pupil_manager.dart';
import 'package:schuldaten_hub/features/pupil/presentation/pupil_profile_page/widgets/pupil_set_avatar.dart';
import 'package:schuldaten_hub/features/schoolday_events/domain/schoolday_event_helper_functions.dart';
import 'package:watch_it/watch_it.dart';
import 'package:widget_zoom/widget_zoom.dart';

class AvatarData {
  final String? avatarId;
  final int internalId;
  final double size;

  AvatarData(
      {required this.avatarId, required this.internalId, required this.size});
}

class AvatarImage extends StatelessWidget {
  const AvatarImage({super.key, Key? customKey});

  @override
  Widget build(BuildContext context) {
    final avatarId = Provider.of<AvatarData>(context).avatarId;
    final internalId = Provider.of<AvatarData>(context).internalId;
    final size = Provider.of<AvatarData>(context).size;
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: avatarId != null
            ? WidgetZoom(
                heroAnimationTag: internalId,
                zoomWidget: FutureBuilder<Widget>(
                  future: cachedOrDownloadAndDecryptImage(
                    imageUrl: PupilDataApiService.getPupilAvatar(internalId),
                    cacheKey: avatarId,
                  ),
                  builder: (context, snapshot) {
                    Widget child;
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // Display a loading indicator while the future is not complete
                      child = const CircularProgressIndicator(
                        strokeWidth: 8,
                        color: AppColors.backgroundColor,
                      );
                    } else if (snapshot.hasError) {
                      // Display an error message if the future encounters an error
                      child = Text('Error: ${snapshot.error}');
                    } else {
                      child = snapshot.data!;
                    }
                    return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(size / 2),
                            child: child));
                  },
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(size / 2),
                child: Image.asset(
                  'assets/dummy-profile-pic.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
      ),
    );
  }
}

class AvatarWithBadges extends WatchingWidget {
  final PupilProxy pupil;
  final double size;
  const AvatarWithBadges({required this.pupil, required this.size, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Stack(
        children: [
          GestureDetector(
            onLongPressStart: (details) {
              final offset = details.globalPosition;
              final position = RelativeRect.fromLTRB(
                  offset.dx, offset.dy, offset.dx, offset.dy);
              showMenu(
                context: context,
                position: position,
                items: [
                  PopupMenuItem(
                    child: pupil.avatarId == null
                        ? const Text('Foto hochladen')
                        : const Text('Foto ersetzen'),
                    onTap: () => setAvatar(context, pupil),
                  ),
                  if (pupil.avatarId != null)
                    PopupMenuItem(
                      child: const Text('Foto löschen'),
                      onTap: () async {
                        await locator<PupilManager>().deleteAvatarImage(
                            pupil.internalId, pupil.internalId.toString());
                      },
                    ),
                ],
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Provider<AvatarData>.value(
                  updateShouldNotify: (oldValue, newValue) =>
                      oldValue.avatarId != newValue.avatarId,
                  value: AvatarData(
                      avatarId: pupil.avatarId,
                      internalId: pupil.internalId,
                      size: size),
                  child: const AvatarImage()),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: 30.0,
              height: 30.0,
              decoration: BoxDecoration(
                color: AttendanceHelper.pupilIsMissedToday(pupil)
                    ? AppColors.warningButtonColor
                    : AppColors.groupColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  pupil.group,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 30.0,
              height: 30.0,
              decoration: BoxDecoration(
                color: SchoolDayEventHelper.pupilIsAdmonishedToday(pupil)
                    ? Colors.red
                    : AppColors.schoolyearColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  pupil.schoolyear,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          if (pupil.ogs == true)
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: 30.0,
                height: 30.0,
                decoration: const BoxDecoration(
                  color: AppColors.ogsColor,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'OGS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          if (pupil.migrationSupportEnds != null)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 30.0,
                height: 30.0,
                decoration: BoxDecoration(
                  color: hasLanguageSupport(pupil.migrationSupportEnds)
                      ? Colors.green
                      : Colors.grey,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.language_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
