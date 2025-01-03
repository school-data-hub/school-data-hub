import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/theme/styles.dart';
import 'package:schuldaten_hub/common/widgets/themed_filter_chip.dart';
import 'package:schuldaten_hub/features/pupil/domain/filters/pupil_filter_enums.dart';
import 'package:schuldaten_hub/features/pupil/domain/filters/pupil_filter_manager.dart';
import 'package:watch_it/watch_it.dart';

class SchoolListPupilFiltersWidget extends WatchingWidget {
  const SchoolListPupilFiltersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    Map<PupilFilter, bool> activeFilters =
        watchValue((PupilFilterManager x) => x.pupilFilterState);
    bool valueYesResponse = activeFilters[PupilFilter.schoolListYesResponse]!;
    bool valueNoResponse = activeFilters[PupilFilter.schoolListNoResponse]!;
    bool valueNullResponse = activeFilters[PupilFilter.schoolListNullResponse]!;
    bool valueCommentResponse =
        activeFilters[PupilFilter.schoolListCommentResponse]!;
    final filterLocator = locator<PupilFilterManager>();
    return Column(
      children: [
        const Row(
          children: [
            Text(
              'Antwort:',
              style: AppStyles.subtitle,
            )
          ],
        ),
        const Gap(5),
        Wrap(
          spacing: 5,
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.center,
          children: [
            ThemedFilterChip(
              label: 'Ja',
              selected: valueYesResponse,
              onSelected: (val) {
                if (val) {
                  filterLocator.setPupilFilter(pupilFilterRecords: [
                    (
                      filter: PupilFilter.schoolListYesResponse,
                      value: true,
                    ),
                    (
                      filter: PupilFilter.schoolListNoResponse,
                      value: false,
                    ),
                    (filter: PupilFilter.schoolListNullResponse, value: false),
                  ]);
                  return;
                }
                filterLocator.setPupilFilter(pupilFilterRecords: [
                  (filter: PupilFilter.schoolListYesResponse, value: false),
                ]);
              },
            ),
            ThemedFilterChip(
              label: 'Nein',
              selected: valueNoResponse,
              onSelected: (val) {
                if (val) {
                  filterLocator.setPupilFilter(pupilFilterRecords: [
                    (
                      filter: PupilFilter.schoolListNoResponse,
                      value: true,
                    ),
                    (
                      filter: PupilFilter.schoolListYesResponse,
                      value: false,
                    ),
                    (filter: PupilFilter.schoolListNullResponse, value: false),
                  ]);
                  return;
                }
                filterLocator.setPupilFilter(pupilFilterRecords: [
                  (filter: PupilFilter.schoolListNoResponse, value: val)
                ]);
              },
            ),
            ThemedFilterChip(
              label: 'keine Antwort',
              selected: valueNullResponse,
              onSelected: (val) {
                if (val) {
                  filterLocator.setPupilFilter(pupilFilterRecords: [
                    (
                      filter: PupilFilter.schoolListNullResponse,
                      value: true,
                    ),
                    (
                      filter: PupilFilter.schoolListYesResponse,
                      value: false,
                    ),
                    (
                      filter: PupilFilter.schoolListNoResponse,
                      value: false,
                    ),
                  ]);
                  return;
                }
                filterLocator.setPupilFilter(pupilFilterRecords: [
                  (
                    filter: PupilFilter.schoolListNullResponse,
                    value: val,
                  )
                ]);
              },
            ),
            ThemedFilterChip(
              label: 'Kommentar',
              selected: valueCommentResponse,
              onSelected: (val) {
                filterLocator.setPupilFilter(pupilFilterRecords: [
                  (
                    filter: PupilFilter.schoolListCommentResponse,
                    value: val,
                  )
                ]);
              },
            ),
          ],
        ),
      ],
    );
  }
}
