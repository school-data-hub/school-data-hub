import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/theme/app_colors.dart';
import 'package:schuldaten_hub/common/widgets/bottom_nav_bar_layouts.dart';
import 'package:schuldaten_hub/common/widgets/list_view_components/generic_filter_bottom_sheet.dart';
import 'package:schuldaten_hub/features/competence/domain/filters/competence_filter_manager.dart';
import 'package:schuldaten_hub/features/competence/domain/models/competence.dart';
import 'package:schuldaten_hub/features/competence/presentation/competence_list_page/widgets/competence_filters_widget.dart';

class CompetenceListPageBottomNavBar extends StatelessWidget {
  final List<Competence> competences;
  const CompetenceListPageBottomNavBar({required this.competences, super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavBarLayout(
      bottomNavBar: BottomAppBar(
        height: 60,
        padding: const EdgeInsets.all(10),
        shape: null,
        color: AppColors.backgroundColor,
        child: IconTheme(
          data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
          child: Row(
            children: [
              const Spacer(),
              IconButton(
                tooltip: 'zurück',
                icon: const Icon(
                  Icons.arrow_back,
                  size: 30,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const Gap(30),
              IconButton(
                tooltip: 'aktualisieren',
                icon: const Icon(Icons.update_rounded),
                onPressed: () {
                  locator<CompetenceFilterManager>()
                      .refreshFilteredCompetences(competences);
                },
              ),
              const Gap(30),
              IconButton(
                tooltip: 'Filter',
                icon: const Icon(Icons.filter_list_rounded),
                onPressed: () => showGenericFilterBottomSheet(
                    context: context, filterList: [const CompetenceFilters()]),
              ),
              const Gap(10)
            ],
          ),
        ),
      ),
    );
  }
}
