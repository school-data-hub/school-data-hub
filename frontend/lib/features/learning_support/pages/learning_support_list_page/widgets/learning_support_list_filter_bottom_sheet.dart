import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/constants/enums.dart';
import 'package:schuldaten_hub/common/constants/styles.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/widgets/common_pupil_filters.dart';
import 'package:schuldaten_hub/features/pupil/filters/pupil_filter_manager.dart';
import 'package:watch_it/watch_it.dart';

class LearningSupportFilterBottomSheet extends WatchingWidget {
  const LearningSupportFilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    Map<SupportLevelFilter, bool> supportLevelFilters =
        watchValue((PupilFilterManager x) => x.supportLevelFilterState);
    Map<SupportAreaFilter, bool> supportAreaFilters =
        watchValue((PupilFilterManager x) => x.supportAreaFilterState);
    bool valueSpecialNeeds =
        supportLevelFilters[SupportLevelFilter.specialNeeds]!;
    bool valueSupportLevel1 =
        supportLevelFilters[SupportLevelFilter.supportLevel1]!;
    bool valueSupportLevel2 =
        supportLevelFilters[SupportLevelFilter.supportLevel2]!;
    bool valueSupportLevel3 =
        supportLevelFilters[SupportLevelFilter.supportLevel3]!;
    bool valueSupportLevel4 =
        supportLevelFilters[SupportLevelFilter.supportLevel4]!;
    bool valueMigrationSupport =
        supportLevelFilters[SupportLevelFilter.migrationSupport]!;
    bool valueSupportAreaMotorics =
        supportAreaFilters[SupportAreaFilter.motorics]!;
    bool valueSupportAreaEmotions =
        supportAreaFilters[SupportAreaFilter.emotions]!;
    bool valueSupportAreaMath = supportAreaFilters[SupportAreaFilter.math]!;
    bool valueSupportAreaLearning =
        supportAreaFilters[SupportAreaFilter.learning]!;
    bool valueSupportAreaGerman = supportAreaFilters[SupportAreaFilter.german]!;
    bool valueSupportAreaLanguage =
        supportAreaFilters[SupportAreaFilter.language]!;
    final filterLocator = locator<PupilFilterManager>();
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20, top: 8),
      child: Column(
        children: [
          const FilterHeading(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(children: [
                const CommonPupilFiltersWidget(),
                const Row(
                  children: [
                    Text(
                      'Förderebene',
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
                      selectedColor: filterChipSelectedColor,
                      avatar: const SizedBox(
                        width: 10,
                      ),
                      checkmarkColor: filterChipSelectedCheckColor,
                      backgroundColor: filterChipUnselectedColor,
                      label: const Text(
                        'Ebene 1',
                        style: filterItemsTextStyle,
                      ),
                      selected: valueSupportLevel1,
                      onSelected: (val) {
                        filterLocator.setSupportLevelFilter(
                            SupportLevelFilter.supportLevel1, val);

                        valueSupportLevel1 = filterLocator
                            .supportLevelFilterState
                            .value[SupportLevelFilter.supportLevel1]!;
                      },
                    ),
                    FilterChip(
                      padding: filterChipPadding,
                      labelPadding: filterChipLabelPadding,
                      shape: filterChipShape,
                      selectedColor: filterChipSelectedColor,
                      avatar: const SizedBox(
                        width: 10,
                      ),
                      checkmarkColor: filterChipSelectedCheckColor,
                      backgroundColor: filterChipUnselectedColor,
                      label: const Text(
                        'Ebene 2',
                        style: filterItemsTextStyle,
                      ),
                      selected: valueSupportLevel2,
                      onSelected: (val) {
                        filterLocator.setSupportLevelFilter(
                            SupportLevelFilter.supportLevel2, val);

                        valueSupportLevel2 = filterLocator
                            .supportLevelFilterState
                            .value[SupportLevelFilter.supportLevel2]!;
                      },
                    ),
                    FilterChip(
                      padding: filterChipPadding,
                      labelPadding: filterChipLabelPadding,
                      shape: filterChipShape,
                      selectedColor: filterChipSelectedColor,
                      avatar: const SizedBox(
                        width: 10,
                      ),
                      checkmarkColor: filterChipSelectedCheckColor,
                      backgroundColor: filterChipUnselectedColor,
                      label: const Text(
                        'Ebene 3',
                        style: filterItemsTextStyle,
                      ),
                      selected: valueSupportLevel3,
                      onSelected: (val) {
                        filterLocator.setSupportLevelFilter(
                            SupportLevelFilter.supportLevel3, val);

                        valueSupportLevel3 = filterLocator
                            .supportLevelFilterState
                            .value[SupportLevelFilter.supportLevel3]!;
                      },
                    ),
                    FilterChip(
                      padding: filterChipPadding,
                      labelPadding: filterChipLabelPadding,
                      shape: filterChipShape,
                      selectedColor: filterChipSelectedColor,
                      avatar: const SizedBox(
                        width: 10,
                      ),
                      checkmarkColor: filterChipSelectedCheckColor,
                      backgroundColor: filterChipUnselectedColor,
                      label: const Text(
                        'Regenbogen',
                        style: filterItemsTextStyle,
                      ),
                      selected: valueSupportLevel4,
                      onSelected: (val) {
                        filterLocator.setSupportLevelFilter(
                            SupportLevelFilter.supportLevel4, val);

                        valueSupportLevel4 = filterLocator
                            .supportLevelFilterState
                            .value[SupportLevelFilter.supportLevel4]!;
                      },
                    ),
                    FilterChip(
                      padding: filterChipPadding,
                      labelPadding: filterChipLabelPadding,
                      shape: filterChipShape,
                      selectedColor: filterChipSelectedColor,
                      avatar: const SizedBox(
                        width: 10,
                      ),
                      checkmarkColor: filterChipSelectedCheckColor,
                      backgroundColor: filterChipUnselectedColor,
                      label: const Text(
                        'AO-SF',
                        style: filterItemsTextStyle,
                      ),
                      selected: valueSpecialNeeds,
                      onSelected: (val) {
                        filterLocator.setSupportLevelFilter(
                            SupportLevelFilter.specialNeeds, val);

                        valueSpecialNeeds = filterLocator
                            .supportLevelFilterState
                            .value[SupportLevelFilter.specialNeeds]!;
                      },
                    ),
                  ],
                ),
                const Row(
                  children: [
                    Text(
                      'Förderbereich',
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
                      selectedColor: filterChipSelectedColor,
                      avatar: const SizedBox(
                        width: 10,
                      ),
                      checkmarkColor: filterChipSelectedCheckColor,
                      backgroundColor: filterChipUnselectedColor,
                      label: const Text(
                        'Motorik',
                        style: filterItemsTextStyle,
                      ),
                      selected: valueSupportAreaMotorics,
                      onSelected: (val) {
                        filterLocator.setSupportAreaFilter(
                            SupportAreaFilter.motorics, val);

                        valueSupportAreaMotorics = filterLocator
                            .supportAreaFilterState
                            .value[SupportAreaFilter.motorics]!;
                      },
                    ),
                    FilterChip(
                      padding: filterChipPadding,
                      labelPadding: filterChipLabelPadding,
                      shape: filterChipShape,
                      selectedColor: filterChipSelectedColor,
                      avatar: const SizedBox(
                        width: 10,
                      ),
                      checkmarkColor: filterChipSelectedCheckColor,
                      backgroundColor: filterChipUnselectedColor,
                      label: const Text(
                        'ES',
                        style: filterItemsTextStyle,
                      ),
                      selected: valueSupportAreaEmotions,
                      onSelected: (val) {
                        filterLocator.setSupportAreaFilter(
                            SupportAreaFilter.emotions, val);

                        valueSupportAreaEmotions = filterLocator
                            .supportAreaFilterState
                            .value[SupportAreaFilter.emotions]!;
                      },
                    ),
                    FilterChip(
                      padding: filterChipPadding,
                      labelPadding: filterChipLabelPadding,
                      shape: filterChipShape,
                      selectedColor: filterChipSelectedColor,
                      avatar: const SizedBox(
                        width: 10,
                      ),
                      checkmarkColor: filterChipSelectedCheckColor,
                      backgroundColor: filterChipUnselectedColor,
                      label: const Text(
                        'Mathe',
                        style: filterItemsTextStyle,
                      ),
                      selected: valueSupportAreaMath,
                      onSelected: (val) {
                        filterLocator.setSupportAreaFilter(
                            SupportAreaFilter.math, val);

                        valueSupportAreaMath = filterLocator
                            .supportAreaFilterState
                            .value[SupportAreaFilter.math]!;
                      },
                    ),
                    FilterChip(
                      padding: filterChipPadding,
                      labelPadding: filterChipLabelPadding,
                      shape: filterChipShape,
                      selectedColor: filterChipSelectedColor,
                      avatar: const SizedBox(
                        width: 10,
                      ),
                      checkmarkColor: filterChipSelectedCheckColor,
                      backgroundColor: filterChipUnselectedColor,
                      label: const Text(
                        'Lernen',
                        style: filterItemsTextStyle,
                      ),
                      selected: valueSupportAreaLearning,
                      onSelected: (val) {
                        filterLocator.setSupportAreaFilter(
                            SupportAreaFilter.learning, val);

                        valueSupportAreaLearning = filterLocator
                            .supportAreaFilterState
                            .value[SupportAreaFilter.learning]!;
                      },
                    ),
                    FilterChip(
                      padding: filterChipPadding,
                      labelPadding: filterChipLabelPadding,
                      shape: filterChipShape,
                      selectedColor: filterChipSelectedColor,
                      avatar: const SizedBox(
                        width: 10,
                      ),
                      checkmarkColor: filterChipSelectedCheckColor,
                      backgroundColor: filterChipUnselectedColor,
                      label: const Text(
                        'Deutsch',
                        style: filterItemsTextStyle,
                      ),
                      selected: valueSupportAreaGerman,
                      onSelected: (val) {
                        filterLocator.setSupportAreaFilter(
                            SupportAreaFilter.german, val);

                        valueSupportAreaGerman = filterLocator
                            .supportAreaFilterState
                            .value[SupportAreaFilter.german]!;
                      },
                    ),
                    FilterChip(
                      padding: filterChipPadding,
                      labelPadding: filterChipLabelPadding,
                      shape: filterChipShape,
                      selectedColor: filterChipSelectedColor,
                      avatar: const SizedBox(
                        width: 10,
                      ),
                      checkmarkColor: filterChipSelectedCheckColor,
                      backgroundColor: filterChipUnselectedColor,
                      label: const Text(
                        'Sprache',
                        style: filterItemsTextStyle,
                      ),
                      selected: valueSupportAreaLanguage,
                      onSelected: (val) {
                        filterLocator.setSupportAreaFilter(
                            SupportAreaFilter.language, val);

                        valueSupportAreaLanguage = filterLocator
                            .supportAreaFilterState
                            .value[SupportAreaFilter.language]!;
                      },
                    ),
                    FilterChip(
                      padding: filterChipPadding,
                      labelPadding: filterChipLabelPadding,
                      shape: filterChipShape,
                      selectedColor: filterChipSelectedColor,
                      avatar: const SizedBox(
                        width: 10,
                      ),
                      checkmarkColor: filterChipSelectedCheckColor,
                      backgroundColor: filterChipUnselectedColor,
                      label: const Text(
                        'EF',
                        style: filterItemsTextStyle,
                      ),
                      selected: valueMigrationSupport,
                      onSelected: (val) {
                        filterLocator.setPupilFilter(
                            PupilFilter.migrationSupport, val);

                        valueMigrationSupport = filterLocator.pupilFilterState
                            .value[PupilFilter.migrationSupport]!;
                      },
                    ),
                  ],
                ),
                const Gap(20),
              ]),
            ),
          )
        ],
      ),
    );
  }
}

showLearningSupportFilterBottomSheet(BuildContext context) {
  return showModalBottomSheet(
    constraints: const BoxConstraints(maxWidth: 800),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.0),
    ),
    context: context,
    builder: (_) => const LearningSupportFilterBottomSheet(),
  );
}
