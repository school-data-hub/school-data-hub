import 'package:flutter/material.dart';
import 'package:schuldaten_hub/common/constants/enums.dart';
import 'package:schuldaten_hub/common/constants/styles.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/widgets/themed_filter_chip.dart';
import 'package:schuldaten_hub/features/pupil/filters/pupil_filter_manager.dart';
import 'package:watch_it/watch_it.dart';

class AttendanceFilters extends WatchingWidget {
  const AttendanceFilters({super.key});

  @override
  Widget build(BuildContext context) {
    Map<PupilFilter, bool> activeFilters =
        watchValue((PupilFilterManager x) => x.pupilFilterState);
    bool valuePresent = activeFilters[PupilFilter.present]!;
    bool valueNotPresent = activeFilters[PupilFilter.notPresent]!;
    bool valueUnexcused = activeFilters[PupilFilter.unexcused]!;
    bool valueOgs = activeFilters[PupilFilter.ogs]!;
    bool valueNotOgs = activeFilters[PupilFilter.notOgs]!;
    final filterLocator = locator<PupilFilterManager>();
    return Column(
      children: [
        const Row(
          children: [
            Text(
              'Anwesenheit',
              style: subtitle,
            )
          ],
        ),
        Wrap(
          spacing: 5,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ThemedFilterChip(
              label: 'anwesend',
              selected: valuePresent,
              onSelected: (val) {
                filterLocator.setPupilFilter(PupilFilter.present, val);

                valuePresent =
                    filterLocator.pupilFilterState.value[PupilFilter.present]!;
                if (valuePresent == true) {
                  //_valueNotPresent = false;
                  filterLocator.setPupilFilter(PupilFilter.notPresent, false);
                  filterLocator.setPupilFilter(PupilFilter.unexcused, false);
                }
              },
            ),
            ThemedFilterChip(
              label: 'nicht da',
              selected: valueNotPresent,
              onSelected: (val) {
                filterLocator.setPupilFilter(PupilFilter.notPresent, val);
                valueNotPresent = filterLocator
                    .pupilFilterState.value[PupilFilter.notPresent]!;
                if (valueNotPresent == true) {
                  //_valuePresent = false;
                  filterLocator.setPupilFilter(PupilFilter.present, false);
                }
              },
            ),
            ThemedFilterChip(
              label: 'nicht da unent.',
              selected: valueUnexcused,
              onSelected: (val) {
                filterLocator.setPupilFilter(PupilFilter.unexcused, val);
                valueUnexcused = filterLocator
                    .pupilFilterState.value[PupilFilter.unexcused]!;
                if (valueUnexcused == true) {
                  filterLocator.setPupilFilter(PupilFilter.present, false);
                }
              },
            ),
            ThemedFilterChip(
              label: 'OGS',
              selected: valueOgs,
              onSelected: (val) {
                if (val == true) {
                  filterLocator.setPupilFilter(PupilFilter.notOgs, false);
                  filterLocator.setPupilFilter(PupilFilter.ogs, val);
                } else {
                  filterLocator.setPupilFilter(PupilFilter.ogs, val);
                }
              },
            ),
            ThemedFilterChip(
              label: 'nicht OGS',
              selected: valueNotOgs,
              onSelected: (val) {
                if (val == true) {
                  filterLocator.setPupilFilter(PupilFilter.ogs, false);
                  filterLocator.setPupilFilter(PupilFilter.notOgs, val);
                } else {
                  filterLocator.setPupilFilter(PupilFilter.notOgs, val);
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}
