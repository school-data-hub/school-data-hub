import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/constants/enums.dart';
import 'package:schuldaten_hub/common/constants/styles.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/features/pupil/pages/widgets/common_pupil_filters.dart';
import 'package:schuldaten_hub/features/pupil/filters/pupil_filter_manager.dart';
import 'package:watch_it/watch_it.dart';

class SchoolListFilterBottomSheet extends WatchingWidget {
  const SchoolListFilterBottomSheet({super.key});

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
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20, top: 8),
      child: Column(
        children: [
          const FilterHeading(),
          const CommonPupilFiltersWidget(),
          const Row(
            children: [
              Text(
                'Antwort:',
                style: subtitle,
              )
            ],
          ),
          const Gap(5),
          Wrap(
            spacing: 5,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilterChip(
                padding: filterChipPadding,
                labelPadding: filterChipLabelPadding,
                shape: filterChipShape,
                avatar: const SizedBox(
                  width: 10,
                ),
                selectedColor: filterChipSelectedColor,
                checkmarkColor: filterChipSelectedCheckColor,
                backgroundColor: filterChipUnselectedColor,
                label: const Text(
                  'Ja',
                  style: filterItemsTextStyle,
                ),
                selected: valueYesResponse,
                onSelected: (val) {
                  filterLocator.setPupilFilter(
                      PupilFilter.schoolListYesResponse, val);

                  if (val) {
                    filterLocator.setPupilFilter(
                        PupilFilter.schoolListNoResponse, false);
                    filterLocator.setPupilFilter(
                        PupilFilter.schoolListNullResponse, false);
                    filterLocator.setPupilFilter(
                        PupilFilter.schoolListCommentResponse, false);
                  }
                },
              ),
              FilterChip(
                padding: filterChipPadding,
                labelPadding: filterChipLabelPadding,
                shape: filterChipShape,
                avatar: const SizedBox(
                  width: 10,
                ),
                selectedColor: filterChipSelectedColor,
                checkmarkColor: filterChipSelectedCheckColor,
                backgroundColor: filterChipUnselectedColor,
                label: const Text(
                  'Nein',
                  style: filterItemsTextStyle,
                ),
                selected: valueNoResponse,
                onSelected: (val) {
                  filterLocator.setPupilFilter(
                      PupilFilter.schoolListNoResponse, val);

                  if (val) {
                    filterLocator.setPupilFilter(
                        PupilFilter.schoolListYesResponse, false);
                    filterLocator.setPupilFilter(
                        PupilFilter.schoolListNullResponse, false);
                    filterLocator.setPupilFilter(
                        PupilFilter.schoolListCommentResponse, false);
                  }
                },
              ),
              FilterChip(
                padding: filterChipPadding,
                labelPadding: filterChipLabelPadding,
                shape: filterChipShape,
                avatar: const SizedBox(
                  width: 10,
                ),
                selectedColor: filterChipSelectedColor,
                checkmarkColor: filterChipSelectedCheckColor,
                backgroundColor: filterChipUnselectedColor,
                label: const Text(
                  'keine Antwort',
                  style: filterItemsTextStyle,
                ),
                selected: valueNullResponse,
                onSelected: (val) {
                  filterLocator.setPupilFilter(
                      PupilFilter.schoolListNullResponse, val);

                  if (val) {
                    filterLocator.setPupilFilter(
                        PupilFilter.schoolListYesResponse, false);
                    filterLocator.setPupilFilter(
                        PupilFilter.schoolListNoResponse, false);
                    filterLocator.setPupilFilter(
                        PupilFilter.schoolListCommentResponse, false);
                  }
                },
              ),
              FilterChip(
                padding: filterChipPadding,
                labelPadding: filterChipLabelPadding,
                shape: filterChipShape,
                avatar: const SizedBox(
                  width: 10,
                ),
                selectedColor: filterChipSelectedColor,
                checkmarkColor: filterChipSelectedCheckColor,
                backgroundColor: filterChipUnselectedColor,
                label: const Text(
                  'Kommentar',
                  style: filterItemsTextStyle,
                ),
                selected: valueCommentResponse,
                onSelected: (val) {
                  filterLocator.setPupilFilter(
                      PupilFilter.schoolListCommentResponse, val);

                  if (val) {
                    filterLocator.setPupilFilter(
                        PupilFilter.schoolListYesResponse, false);
                    filterLocator.setPupilFilter(
                        PupilFilter.schoolListNoResponse, false);
                    filterLocator.setPupilFilter(
                        PupilFilter.schoolListNullResponse, false);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<dynamic> showPupilListFilterBottomSheet(BuildContext context) {
  return showModalBottomSheet(
    constraints: const BoxConstraints(maxWidth: 800),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20.0),
        topRight: Radius.circular(20.0),
      ),
    ),
    context: context,
    builder: (_) => const SchoolListFilterBottomSheet(),
  );
}
