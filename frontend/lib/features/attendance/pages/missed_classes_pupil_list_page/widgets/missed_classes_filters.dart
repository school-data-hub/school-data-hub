import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/constants/enums.dart';
import 'package:schuldaten_hub/common/constants/styles.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/widgets/themed_filter_chip.dart';
import 'package:schuldaten_hub/features/pupil/filters/pupils_filter.dart';
import 'package:watch_it/watch_it.dart';

class MissedClassFilters extends WatchingWidget {
  const MissedClassFilters({super.key});

  @override
  Widget build(BuildContext context) {
    PupilSortMode sortMode = watchValue((PupilsFilter x) => x.sortMode);
    return Column(
      children: [
        const Row(
          children: [
            Text(
              'Sortieren',
              style: subtitle,
            )
          ],
        ),
        const Gap(5),
        Wrap(
          spacing: 5,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ThemedFilterChip(
              label: 'A-Z',
              selected: sortMode == PupilSortMode.sortByName,
              onSelected: (val) {
                // if the filter is already selected, do nothing
                if (locator<PupilsFilter>().sortMode.value ==
                    PupilSortMode.sortByName) {
                  return;
                }
                // set the filter
                locator<PupilsFilter>().setSortMode(PupilSortMode.sortByName);
              },
            ),
            ThemedFilterChip(
              label: 'entschuldigt',
              selected: sortMode == PupilSortMode.sortByMissedExcused,
              onSelected: (val) {
                // if the filter is already selected, do nothing
                if (locator<PupilsFilter>().sortMode.value ==
                    PupilSortMode.sortByMissedExcused) {
                  return;
                }
                // set the filter
                locator<PupilsFilter>()
                    .setSortMode(PupilSortMode.sortByMissedExcused);
              },
            ),
            ThemedFilterChip(
              label: 'unentschuldigt',
              selected: sortMode == PupilSortMode.sortByMissedUnexcused,
              onSelected: (val) {
                // if the filter is already selected, do nothing
                if (locator<PupilsFilter>().sortMode.value ==
                    PupilSortMode.sortByMissedUnexcused) {
                  return;
                }
                // set the filter
                locator<PupilsFilter>()
                    .setSortMode(PupilSortMode.sortByMissedUnexcused);
              },
            ),
            ThemedFilterChip(
              label: 'verspätet',
              selected: sortMode == PupilSortMode.sortByLate,
              onSelected: (val) {
                // if the filter is already selected, do nothing
                if (locator<PupilsFilter>().sortMode.value ==
                    PupilSortMode.sortByLate) {
                  return;
                }
                // set the filter
                locator<PupilsFilter>().setSortMode(PupilSortMode.sortByLate);
              },
            ),
            ThemedFilterChip(
              label: 'kontaktiert',
              selected: sortMode == PupilSortMode.sortByContacted,
              onSelected: (val) {
                // if the filter is already selected, do nothing
                if (locator<PupilsFilter>().sortMode.value ==
                    PupilSortMode.sortByContacted) {
                  return;
                }
                // set the filter
                locator<PupilsFilter>()
                    .setSortMode(PupilSortMode.sortByContacted);
              },
            ),
          ],
        ),
        const Gap(20),
      ],
    );
  }
}