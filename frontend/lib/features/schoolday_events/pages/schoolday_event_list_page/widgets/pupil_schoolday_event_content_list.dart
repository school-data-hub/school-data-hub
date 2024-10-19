import 'package:flutter/material.dart';
import 'package:schuldaten_hub/common/constants/enums.dart';
import 'package:schuldaten_hub/common/constants/styles.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_manager.dart';
import 'package:schuldaten_hub/common/widgets/dialogues/confirmation_dialog.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';
import 'package:schuldaten_hub/features/schoolday_events/filters/schoolday_event_filter_manager.dart';
import 'package:schuldaten_hub/features/schoolday_events/models/schoolday_event.dart';
import 'package:schuldaten_hub/features/schoolday_events/pages/new_schoolday_event_page/new_schoolday_event_page.dart';
import 'package:schuldaten_hub/features/schoolday_events/pages/schoolday_event_list_page/widgets/pupil_schoolday_event_card.dart';
import 'package:schuldaten_hub/features/schoolday_events/services/schoolday_event_manager.dart';
import 'package:watch_it/watch_it.dart';

class SchooldayEventsContentList extends WatchingWidget {
  final PupilProxy pupil;
  const SchooldayEventsContentList({super.key, required this.pupil});

  @override
  Widget build(BuildContext context) {
    final pupil = watch(this.pupil);
    final List<SchooldayEvent> filteredSchooldayEvents =
        locator<SchooldayEventFilterManager>().filteredSchooldayEvents(pupil);
    return Column(children: [
      Padding(
        padding: const EdgeInsets.only(top: 10.0, bottom: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          //margin: const EdgeInsets.only(bottom: 16),
          width: double.infinity,
          child: ElevatedButton(
            style: actionButtonStyle,
            onPressed: () async {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (ctx) => NewSchooldayEventPage(
                  pupilId: pupil.internalId,
                ),
              ));
            },
            child: const Text(
              "NEUES EREIGNIS",
              style: TextStyle(
                  fontSize: 17.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      ListView.builder(
        padding: const EdgeInsets.only(top: 5, bottom: 5),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: filteredSchooldayEvents.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: GestureDetector(
              onTap: () {
                //- TO-DO: change schooldayEvent
              },
              onLongPress: () async {
                if (filteredSchooldayEvents[index].processed) {
                  locator<NotificationManager>().showSnackBar(
                      NotificationType.error,
                      'Ereignis wurde bereits bearbeitet!');

                  return;
                }
                bool? confirm = await confirmationDialog(
                    context: context,
                    title: 'Ereignis löschen',
                    message: 'Das Ereignis löschen?');
                if (confirm! == false) return;
                await locator<SchooldayEventManager>().deleteSchooldayEvent(
                    filteredSchooldayEvents[index].schooldayEventId);
                locator<NotificationManager>().showSnackBar(
                    NotificationType.success, 'Das Ereignis wurde gelöscht!');
              },
              child: PupilSchooldayEventCard(
                schooldayEvent: filteredSchooldayEvents[index],
              ),
            ),
          );
        },
      ),
    ]);
  }
}
