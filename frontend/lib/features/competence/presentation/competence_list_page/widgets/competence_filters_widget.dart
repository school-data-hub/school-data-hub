import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/domain/models/enums.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/theme/styles.dart';
import 'package:schuldaten_hub/common/widgets/themed_filter_chip.dart';
import 'package:schuldaten_hub/features/competence/domain/filters/competence_filter_manager.dart';
import 'package:watch_it/watch_it.dart';

class CompetenceFilters extends WatchingWidget {
  const CompetenceFilters({super.key});

  @override
  Widget build(BuildContext context) {
    Map<CompetenceFilter, bool> activeFilters =
        watchValue((CompetenceFilterManager x) => x.filterState);
    bool valueE1 = activeFilters[CompetenceFilter.E1]!;
    bool valueE2 = activeFilters[CompetenceFilter.E2]!;
    bool valueS3 = activeFilters[CompetenceFilter.S3]!;
    bool valueS4 = activeFilters[CompetenceFilter.S4]!;
    final filterLocator = locator<CompetenceFilterManager>();
    return Column(
      children: [
        const Row(
          children: [
            Text(
              'Jahrgang',
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
              label: 'E1',
              selected: valueE1,
              onSelected: (val) {
                filterLocator.setFilter(CompetenceFilter.E1, val);
              },
            ),
            ThemedFilterChip(
              label: 'E2',
              selected: valueE2,
              onSelected: (val) {
                filterLocator.setFilter(CompetenceFilter.E2, val);
              },
            ),
            ThemedFilterChip(
              label: 'S3',
              selected: valueS3,
              onSelected: (val) {
                filterLocator.setFilter(CompetenceFilter.S3, val);
              },
            ),
            ThemedFilterChip(
              label: 'S4',
              selected: valueS4,
              onSelected: (val) {
                filterLocator.setFilter(CompetenceFilter.S4, val);
              },
            ),
          ],
        ),
      ],
    );
  }
}
