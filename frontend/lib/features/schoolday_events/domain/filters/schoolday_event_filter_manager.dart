import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:schuldaten_hub/common/domain/filters/filters_state_manager.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/features/pupil/domain/filters/pupils_filter.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_proxy.dart';
import 'package:schuldaten_hub/features/schoolday_events/domain/models/schoolday_event.dart';
import 'package:schuldaten_hub/features/schoolday_events/domain/models/schoolday_event_enums.dart';

typedef SchooldayEventFilterRecord = ({
  SchooldayEventFilter filter,
  bool value
});

class SchooldayEventFilterManager {
  ValueListenable<Map<SchooldayEventFilter, bool>>
      get schooldayEventsFilterState => _schooldayEventsFilterState;

  final _schooldayEventsFilterState =
      ValueNotifier<Map<SchooldayEventFilter, bool>>(
          initialSchooldayEventFilterValues);

  SchooldayEventFilterManager();
  final filtersStateManager = locator<FiltersStateManager>();
  resetFilters() {
    _schooldayEventsFilterState.value = {...initialSchooldayEventFilterValues};
  }

  void setFilter(
      {required List<SchooldayEventFilterRecord> schooldayEventFilters}) {
    for (SchooldayEventFilterRecord record in schooldayEventFilters) {
      _schooldayEventsFilterState.value = {
        ..._schooldayEventsFilterState.value,
        record.filter: record.value,
      };
    }

    final schooldayEventFiltesStateEqualsInitialValues = const MapEquality()
        .equals(_schooldayEventsFilterState.value,
            initialSchooldayEventFilterValues);

    filtersStateManager.setFilterState(
        filterState: FilterState.schooldayEvent,
        value: !schooldayEventFiltesStateEqualsInitialValues);

    locator<PupilsFilter>().refreshs();
  }

  List<SchooldayEvent> filteredSchooldayEvents(PupilProxy pupil) {
    List<SchooldayEvent> filteredSchooldayEvents = [];

    DateTime sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

    if (pupil.schooldayEvents != null) {
      final activeFilters = _schooldayEventsFilterState.value;

      bool filterIsActive = false;

      for (SchooldayEvent schooldayEvent in pupil.schooldayEvents!) {
        bool isMatched = true;

        bool complementaryFilter = false;

        //- we keep the last seven days
        //- because this is a hard filter we use continue

        if (activeFilters[SchooldayEventFilter.sevenDays]! &&
            schooldayEvent.schooldayEventDate.isBefore(sevenDaysAgo)) {
          continue;
        }

        //- we keep the not processed ones
        //- because this is a hard filter we use continue

        if (activeFilters[SchooldayEventFilter.processed]! &&
            schooldayEvent.processed == true) {
          continue;
        }

        //- these are complementary filters
        //- and should persist if one of them is active

        if (activeFilters[SchooldayEventFilter.admonition]!) {
          if (schooldayEvent.schooldayEventType ==
              SchooldayEventType.admonition.value) {
            isMatched = true;
            complementaryFilter = true;
          } else if (!complementaryFilter) {
            isMatched = false;
          }
        }

        if (activeFilters[SchooldayEventFilter.afternoonCareAdmonition]!) {
          if (schooldayEvent.schooldayEventType ==
              SchooldayEventType.afternoonCareAdmonition.value) {
            isMatched = true;
            complementaryFilter = true;
          } else if (!complementaryFilter) {
            isMatched = false;
          }
        }

        if (activeFilters[SchooldayEventFilter.admonitionAndBanned]!) {
          if (schooldayEvent.schooldayEventType ==
              SchooldayEventType.admonitionAndBanned.value) {
            isMatched = true;
            complementaryFilter = true;
          } else if (!complementaryFilter) {
            isMatched = false;
          }
        }

        if (activeFilters[SchooldayEventFilter.parentsMeeting]!) {
          if (schooldayEvent.schooldayEventType ==
              SchooldayEventType.parentsMeeting.value) {
            isMatched = true;
            complementaryFilter = true;
          } else if (!complementaryFilter) {
            isMatched = false;
          }
        }

        if (activeFilters[SchooldayEventFilter.otherEvent]!) {
          if (schooldayEvent.schooldayEventType ==
              SchooldayEventType.otherEvent.value) {
            isMatched = true;
            complementaryFilter = true;
          } else if (!complementaryFilter) {
            isMatched = false;
          }
        }

        //- The behavior of this first filter group should be
        //- excluding for the next filter group
        //- let's tidy up the list

        if (!isMatched) {
          filterIsActive = true;
          continue;
        }

        //- these filters are also complementary
        //- we reset the complementary value to process them

        complementaryFilter = false;

        if (activeFilters[SchooldayEventFilter.violenceAgainstPupils]!) {
          if (schooldayEvent.schooldayEventReason
              .contains(SchooldayEventReason.violenceAgainstPupils.value)) {
            isMatched = true;
            complementaryFilter = true;
          } else if (!complementaryFilter) {
            isMatched = false;
          }
        }

        if (activeFilters[SchooldayEventFilter.violenceAgainstAdults]!) {
          if (schooldayEvent.schooldayEventReason
              .contains(SchooldayEventReason.violenceAgainstTeachers.value)) {
            isMatched = true;
            complementaryFilter = true;
          } else if (!complementaryFilter) {
            isMatched = false;
          }
        }
        if (activeFilters[SchooldayEventFilter.violenceAgainstThings]!) {
          if (schooldayEvent.schooldayEventReason
              .contains(SchooldayEventReason.violenceAgainstThings.value)) {
            isMatched = true;
            complementaryFilter = true;
          } else if (!complementaryFilter) {
            isMatched = false;
          }
        }
        if (activeFilters[SchooldayEventFilter.insultOthers]!) {
          if (schooldayEvent.schooldayEventReason
              .contains(SchooldayEventReason.insultOthers.value)) {
            isMatched = true;
            complementaryFilter = true;
          } else if (!complementaryFilter) {
            isMatched = false;
          }
        }
        if (activeFilters[SchooldayEventFilter.annoy]!) {
          if (schooldayEvent.schooldayEventReason
              .contains(SchooldayEventReason.annoyOthers.value)) {
            isMatched = true;
            complementaryFilter = true;
          } else if (!complementaryFilter) {
            isMatched = false;
          }
        }
        if (activeFilters[SchooldayEventFilter.dangerousBehaviour]!) {
          if (schooldayEvent.schooldayEventReason
              .contains(SchooldayEventReason.dangerousBehaviour.value)) {
            isMatched = true;
            complementaryFilter = true;
          } else if (!complementaryFilter) {
            isMatched = false;
          }
        }
        if (activeFilters[SchooldayEventFilter.disturbLesson]!) {
          if (schooldayEvent.schooldayEventReason
              .contains(SchooldayEventReason.disturbLesson.value)) {
            isMatched = true;
            complementaryFilter = true;
          } else if (!complementaryFilter) {
            isMatched = false;
          }
        }
        if (activeFilters[SchooldayEventFilter.ignoreInstructions]!) {
          if (schooldayEvent.schooldayEventReason
              .contains(SchooldayEventReason.ignoreInstructions.value)) {
            isMatched = true;
            complementaryFilter = true;
          } else if (!complementaryFilter) {
            isMatched = false;
          }
        }
        if (activeFilters[SchooldayEventFilter.learningDevelopmentInfo]!) {
          if (schooldayEvent.schooldayEventReason
              .contains(SchooldayEventReason.learningDevelopmentInfo.value)) {
            isMatched = true;
            complementaryFilter = true;
          } else if (!complementaryFilter) {
            isMatched = false;
          }
        }
        if (activeFilters[SchooldayEventFilter.learningSupportInfo]!) {
          if (schooldayEvent.schooldayEventReason
              .contains(SchooldayEventReason.learningSupportInfo.value)) {
            isMatched = true;
            complementaryFilter = true;
          } else if (!complementaryFilter) {
            isMatched = false;
          }
        }
        if (activeFilters[SchooldayEventFilter.admonitionInfo]!) {
          if (schooldayEvent.schooldayEventReason
              .contains(SchooldayEventReason.admonitionInfo.value)) {
            isMatched = true;
            complementaryFilter = true;
          } else if (!complementaryFilter) {
            isMatched = false;
          }
        }
        if (activeFilters[SchooldayEventFilter.other]!) {
          if (schooldayEvent.schooldayEventReason
              .contains(SchooldayEventReason.other.value)) {
            isMatched = true;
            complementaryFilter = true;
          } else if (!complementaryFilter) {
            isMatched = false;
          }
        }

        if (!isMatched) {
          filterIsActive = true;
          continue;
        }
        filteredSchooldayEvents.add(schooldayEvent);
      }

      if (filterIsActive) {
        filtersStateManager.setFilterState(
            filterState: FilterState.schooldayEvent, value: true);
      }
      // sort schooldayEvents, latest first
      filteredSchooldayEvents
          .sort((a, b) => b.schooldayEventDate.compareTo(a.schooldayEventDate));

      return filteredSchooldayEvents;
    }
    return [];
  }

  bool filterBySevenDays(SchooldayEvent schooldayEvent) {
    DateTime sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return schooldayEvent.schooldayEventDate.isAfter(sevenDaysAgo);
  }

  bool filterByProcessed(SchooldayEvent schooldayEvent) {
    return schooldayEvent.processed == true;
  }

  bool filterByAdmonition(SchooldayEvent schooldayEvent) {
    return schooldayEvent.schooldayEventType ==
        SchooldayEventType.admonition.value;
  }

  bool filterByAfternoonCareAdmonition(SchooldayEvent schooldayEvent) {
    return schooldayEvent.schooldayEventType ==
        SchooldayEventType.afternoonCareAdmonition.value;
  }

  bool filterByAdmonitionAndBanned(SchooldayEvent schooldayEvent) {
    return schooldayEvent.schooldayEventType ==
        SchooldayEventType.admonitionAndBanned.value;
  }

  bool filterByOtherEvent(SchooldayEvent schooldayEvent) {
    return schooldayEvent.schooldayEventType ==
        SchooldayEventType.otherEvent.value;
  }

  bool filterByParentsMeeting(SchooldayEvent schooldayEvent) {
    return schooldayEvent.schooldayEventType ==
        SchooldayEventType.parentsMeeting.value;
  }
}
