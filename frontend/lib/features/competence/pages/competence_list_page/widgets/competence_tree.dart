import 'package:flutter/material.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/features/competence/models/competence.dart';
import 'package:schuldaten_hub/features/competence/pages/competence_list_page/widgets/common_competence_card.dart';
import 'package:schuldaten_hub/features/competence/pages/competence_list_page/widgets/last_child_competence_card.dart';
import 'package:schuldaten_hub/features/competence/services/competence_helper.dart';
import 'package:schuldaten_hub/features/competence/services/competence_manager.dart';

List<Widget> buildCommonCompetenceTree(
    {required Function({int? competenceId, Competence? competence})
        navigateToNewOrPatchCompetencePage,
    required int? parentId,
    required int indentation,
    required Color? backgroundColor,
    required List<Competence> competences}) {
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
      final children = buildCommonCompetenceTree(
          navigateToNewOrPatchCompetencePage:
              navigateToNewOrPatchCompetencePage,
          parentId: competence.competenceId,
          indentation: indentation + 1,
          backgroundColor: competenceBackgroundColor,
          competences: competences);

      competenceWidgets.add(
        children.isNotEmpty
            ? Wrap(
                children: [
                  CommonCompetenceCard(
                      competence: competence,
                      competenceBackgroundColor: competenceBackgroundColor,
                      navigateToNewOrPatchCompetencePage:
                          navigateToNewOrPatchCompetencePage,
                      children: children)
                ],
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: InkWell(
                  onLongPress: () => locator<CompetenceManager>()
                      .deleteCompetence(competence.competenceId),
                  child: LastChildCompetenceCard(
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
