import 'package:flutter/material.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/theme/app_colors.dart';
import 'package:schuldaten_hub/common/widgets/list_view_components/generic_app_bar.dart';
import 'package:schuldaten_hub/common/widgets/list_view_components/generic_sliver_list.dart';
import 'package:schuldaten_hub/common/widgets/list_view_components/generic_sliver_search_app_bar.dart';
import 'package:schuldaten_hub/features/competence/domain/competence_helper.dart';
import 'package:schuldaten_hub/features/competence/presentation/multi_pupil_competence_check_page/multi_pupil_competence_check_view_model.dart';
import 'package:schuldaten_hub/features/competence/presentation/multi_pupil_competence_check_page/widgets/competence_parents_names_widget.dart';
import 'package:schuldaten_hub/features/competence/presentation/multi_pupil_competence_check_page/widgets/multi_pupil_competence_check_card.dart';
import 'package:schuldaten_hub/features/competence/presentation/multi_pupil_competence_check_page/widgets/multi_pupil_competence_check_page_bottom_navbar.dart';
import 'package:schuldaten_hub/features/pupil/presentation/credit/credit_list_page/widgets/credit_list_searchbar.dart';
import 'package:schuldaten_hub/features/pupil/domain/pupil_manager.dart';

class MultiPupilCompetenceCheckPage extends StatelessWidget {
  final MultiPupilCompetenceCheckViewModel viewModel;
  const MultiPupilCompetenceCheckPage({required this.viewModel, super.key});

  @override
  Widget build(BuildContext context) {
    final competence = viewModel.widget.competence;
    final filteredPupils = viewModel.competenceFilteredPupils;
    return Scaffold(
      backgroundColor: AppColors.canvasColor,
      appBar: const GenericAppBar(
        title: 'Kompetenz dokumentieren',
        iconData: Icons.group_add_rounded,
      ),
      body: RefreshIndicator(
        onRefresh: () async => locator<PupilManager>().fetchAllPupils(),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: CompetenceHelper.getCompetenceColor(
                          competence.competenceId),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                ...competenceTreeAncestorsNames(
                                  competenceId: competence.competenceId,
                                  categoryColor:
                                      CompetenceHelper.getCompetenceColor(
                                          competence.competenceId),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      // const SliverGap(5),
                      GenericSliverSearchAppBar(
                        height: 110,
                        title: CreditListSearchBar(pupils: filteredPupils),
                      ),
                      GenericSliverListWithEmptyListCheck(
                          items: filteredPupils,
                          itemBuilder: (_, pupil) =>
                              MultiPupilCompetenceCheckCard(
                                passedPupil: pupil,
                                groupId: viewModel.groupId,
                                competenceId: competence.competenceId,
                              )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const MultiPupilCompetenceCheckPageBottomNavBar(),
    );
  }
}
