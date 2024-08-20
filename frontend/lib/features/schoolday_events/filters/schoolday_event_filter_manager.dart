import 'package:flutter/foundation.dart';
import 'package:schuldaten_hub/common/constants/enums.dart';
import 'package:schuldaten_hub/common/utils/logger.dart';
import 'package:schuldaten_hub/features/schoolday_events/models/schoolday_event.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';
import 'package:schuldaten_hub/features/schoolday_events/models/schoolday_event_enums.dart';

class SchooldayEventFilterManager {
  ValueListenable<Map<SchooldayEventFilter, bool>>
      get schooldayEventsFilterState => _schooldayEventsFilterState;
  ValueListenable<bool> get schooldayEventsFiltersOn =>
      _schooldayEventsFiltersOn;
  // ValueListenable<int> get filteredSchooldayEventsCount =>
  //     _filteredSchooldayEventsCount;

  final _schooldayEventsFilterState =
      ValueNotifier<Map<SchooldayEventFilter, bool>>(
          initialSchooldayEventFilterValues);
  final _schooldayEventsFiltersOn = ValueNotifier<bool>(false);
  // final _filteredSchooldayEventsCount = ValueNotifier<int>(
  //     SchoolEventHelper.getSchooldayEventCount(
  //         locator<PupilsFilter>().filteredPupils.value));
  SchooldayEventFilterManager() {
    logger.i('SchooldayEventFilterManager constructor called!');
  }

  resetFilters() {
    _schooldayEventsFilterState.value = {...initialSchooldayEventFilterValues};
    _schooldayEventsFiltersOn.value = false;
  }

  void setFilter(SchooldayEventFilter filter, bool isActive) {
    _schooldayEventsFilterState.value = {
      ..._schooldayEventsFilterState.value,
      filter: isActive,
    };
  }

  List<SchooldayEvent> schooldayEventsInTheLastSevenDays(PupilProxy pupil) {
    DateTime sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    List<SchooldayEvent> schooldayEvents = [];
    if (pupil.schooldayEvents != null) {
      for (SchooldayEvent schooldayEvent in pupil.schooldayEvents!) {
        if (schooldayEvent.schooldayEventDate.isBefore(sevenDaysAgo)) {
          schooldayEvents.add(schooldayEvent);
        }
      }
    }
    return schooldayEvents;
  }

  List<SchooldayEvent> schooldayEventsNotProcessed(PupilProxy pupil) {
    List<SchooldayEvent> schooldayEvents = [];
    if (pupil.schooldayEvents != null) {
      for (SchooldayEvent schooldayEvent in pupil.schooldayEvents!) {
        if (schooldayEvent.processedBy == null) {
          schooldayEvents.add(schooldayEvent);
        }
      }
    }
    return schooldayEvents;
  }

  List<SchooldayEvent> schooldayEventsInTheLastFourteenDays(PupilProxy pupil) {
    DateTime fourteenDaysAgo =
        DateTime.now().subtract(const Duration(days: 14));
    List<SchooldayEvent> schooldayEvents = [];
    if (pupil.schooldayEvents != null) {
      for (SchooldayEvent schooldayEvent in pupil.schooldayEvents!) {
        if (schooldayEvent.schooldayEventDate.isBefore(fourteenDaysAgo)) {
          schooldayEvents.add(schooldayEvent);
        }
      }
    }
    return schooldayEvents;
  }

  List<SchooldayEvent> filteredSchooldayEvents(PupilProxy pupil) {
    List<SchooldayEvent> filteredSchooldayEvents = [];
    DateTime sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    if (pupil.schooldayEvents != null) {
      final activeFilters = _schooldayEventsFilterState.value;
      for (SchooldayEvent schooldayEvent in pupil.schooldayEvents!) {
        // we keep the last seven days
        if (activeFilters[SchooldayEventFilter.sevenDays]! &&
            schooldayEvent.schooldayEventDate.isBefore(sevenDaysAgo)) {
          _schooldayEventsFiltersOn.value = true;
          continue;
        }
        // we keep the not processed ones
        if (activeFilters[SchooldayEventFilter.processed]! &&
            schooldayEvent.processed == true) {
          _schooldayEventsFiltersOn.value = true;
          continue;
        }

        if (activeFilters[SchooldayEventFilter.admonition]! &&
            schooldayEvent.schooldayEventType !=
                SchooldayEventType.admonition.value) {
          _schooldayEventsFiltersOn.value = true;
          continue;
        }

        if (activeFilters[SchooldayEventFilter.afternoonCareAdmonition]! &&
            schooldayEvent.schooldayEventType !=
                SchooldayEventType.afternoonCareAdmonition.value) {
          _schooldayEventsFiltersOn.value = true;
          continue;
        }
        if (activeFilters[SchooldayEventFilter.admonitionAndBanned]! &&
            schooldayEvent.schooldayEventType !=
                SchooldayEventType.admonitionAndBanned.value) {
          _schooldayEventsFiltersOn.value = true;
          continue;
        }
        if (activeFilters[SchooldayEventFilter.otherEvent]! &&
            schooldayEvent.schooldayEventType !=
                SchooldayEventType.otherEvent.value) {
          _schooldayEventsFiltersOn.value = true;
          continue;
        }
        if (activeFilters[SchooldayEventFilter.parentsMeeting]! &&
            schooldayEvent.schooldayEventType !=
                SchooldayEventType.parentsMeeting.value) {
          _schooldayEventsFiltersOn.value = true;
          continue;
        }
        if (activeFilters[SchooldayEventFilter.violenceAgainstPupils]! &&
            !schooldayEvent.schooldayEventReason
                .contains(SchooldayEventReason.violenceAgainstPupils.value)) {
          _schooldayEventsFiltersOn.value = true;
          continue;
        }
        if (activeFilters[SchooldayEventFilter.insultOthers]! &&
            !schooldayEvent.schooldayEventReason
                .contains(SchooldayEventReason.insultOthers.value)) {
          _schooldayEventsFiltersOn.value = true;
          continue;
        }

        filteredSchooldayEvents.add(schooldayEvent);
      }

      // sort schooldayEvents, latest first
      filteredSchooldayEvents
          .sort((a, b) => b.schooldayEventDate.compareTo(a.schooldayEventDate));

      return filteredSchooldayEvents;
    }
    return [];
  }
}
