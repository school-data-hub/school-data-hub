import 'package:flutter/material.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/widgets/dialogs/confirmation_dialog.dart';
import 'package:schuldaten_hub/features/competence/domain/competence_helper.dart';
import 'package:schuldaten_hub/features/competence/domain/competence_manager.dart';
import 'package:schuldaten_hub/features/competence/domain/models/competence.dart';
import 'package:schuldaten_hub/features/competence/presentation/competence_list_sortable_page/widgets/common_competence_card_sortable.dart';
import 'package:schuldaten_hub/features/competence/presentation/competence_list_sortable_page/widgets/last_child_competence_card_sortable.dart';

List<Widget> buildCommonCompetenceTreeSortable({
  required Function({int? competenceId, Competence? competence})
      navigateToNewOrPatchCompetencePage,
  required int? parentId,
  required int indentation,
  required Color? backgroundColor,
  required List<Competence> competences,
  required BuildContext context,
}) {
  // // Separate competences into two lists: one for those without a parent competence and one for those with a parent competence
  // List<Competence> rootCompetences = [];
  // List<Competence> childCompetences = [];

  // for (var competence in competences) {
  //   if (competence.parentCompetence == null) {
  //     rootCompetences.add(competence);
  //   } else {
  //     childCompetences.add(competence);
  //   }
  // }

  // // Sort the child competences list based on parentCompetence and order values
  // childCompetences.sort((a, b) {
  //   if (a.parentCompetence == b.parentCompetence) {
  //     if (a.order == null && b.order == null) return 0;
  //     if (a.order == null) return 1;
  //     if (b.order == null) return -1;
  //     return a.order!.compareTo(b.order!);
  //   }
  //   return (a.parentCompetence ?? 0).compareTo(b.parentCompetence ?? 0);
  // });

  // // Combine the root competences and sorted child competences
  // List<Competence> sortedCompetences = [
  //   ...rootCompetences,
  //   ...childCompetences
  // ];

  List<Widget> competenceWidgets = [];

  late Color competenceBackgroundColor;
  for (var competence in competences) {
    if (backgroundColor == null) {
      competenceBackgroundColor =
          CompetenceHelper.getCompetenceColor(competence.competenceId);
    } else {
      competenceBackgroundColor = backgroundColor;
    }
    if (competence.parentCompetence == parentId) {
      final children = buildCommonCompetenceTreeSortable(
          navigateToNewOrPatchCompetencePage:
              navigateToNewOrPatchCompetencePage,
          parentId: competence.competenceId,
          indentation: indentation + 1,
          backgroundColor: competenceBackgroundColor,
          competences: competences,
          context: context);

      competenceWidgets.add(
        children.isNotEmpty
            ? Wrap(
                key: ValueKey(competence.competenceId),
                children: [
                  CommonCompetenceCardSortable(
                      competence: competence,
                      competenceBackgroundColor: competenceBackgroundColor,
                      navigateToNewOrPatchCompetencePage:
                          navigateToNewOrPatchCompetencePage,
                      children: children)
                ],
              )
            : Padding(
                key: ValueKey(competence.competenceId),
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: InkWell(
                  onLongPress: () async {
                    final confirm = await confirmationDialog(
                        context: context,
                        title: 'Kompetenz löschen',
                        message: 'Sind Sie sicher?');
                    if (confirm!) {
                      locator<CompetenceManager>()
                          .deleteCompetence(competence.competenceId);
                    }
                  },
                  child: LastChildCompetenceCardSortable(
                    key: ValueKey(competence.competenceId),
                    competence: competence,
                    navigateToNewOrPatchCompetencePage:
                        navigateToNewOrPatchCompetencePage,
                  ),
                ),
              ),
      );
    }
  }
  return competenceWidgets;
}
