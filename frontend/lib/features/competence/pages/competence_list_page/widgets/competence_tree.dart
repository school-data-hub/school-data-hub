import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/features/competence/models/competence.dart';
import 'package:schuldaten_hub/features/competence/services/competence_helper.dart';

List<Widget> buildCompetenceTree(
    {required Function(int) navigateToNewCompetenceView,
    required Function(Competence) navigateToPatchCompetenceView,
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
      final children = buildCompetenceTree(
          navigateToNewCompetenceView: navigateToNewCompetenceView,
          navigateToPatchCompetenceView: navigateToPatchCompetenceView,
          parentId: competence.competenceId,
          indentation: indentation + 1,
          backgroundColor: competenceBackgroundColor,
          competences: competences);

      competenceWidgets.add(
        children.isNotEmpty
            ? Padding(
                padding: EdgeInsets.only(top: 8, left: 5.0 * indentation),
                child: Wrap(
                  children: [
                    Card(
                      color: competenceBackgroundColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      clipBehavior: Clip.antiAlias,
                      margin: EdgeInsets.zero,
                      child: ExpansionTile(
                        iconColor: Colors.white,
                        collapsedTextColor: Colors.white,
                        collapsedIconColor: Colors.white,
                        textColor: Colors.white,
                        maintainState: true,
                        backgroundColor: competenceBackgroundColor,
                        childrenPadding:
                            const EdgeInsets.symmetric(vertical: 5),
                        title: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: InkWell(
                                      onTap: () =>
                                          navigateToPatchCompetenceView(
                                              competence),
                                      onLongPress: () =>
                                          navigateToNewCompetenceView(
                                              competence.competenceId),
                                      child: Text(
                                        competence.competenceName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        collapsedBackgroundColor: competenceBackgroundColor,
                        children: children,
                      ),
                    ),
                  ],
                ),
              )
            : Padding(
                padding: EdgeInsets.only(left: 5.0 * indentation, bottom: 5.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: InkWell(
                                  onTap: () =>
                                      navigateToPatchCompetenceView(competence),
                                  onLongPress: () =>
                                      navigateToNewCompetenceView(
                                          competence.competenceId),
                                  child: Text(
                                    competence.competenceName,
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          competence.indicators != null
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Indikatoren:',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontStyle: FontStyle.italic),
                                    ),
                                    const Gap(10),
                                    Flexible(
                                      child: Text(
                                        competence.indicators!,
                                        textAlign: TextAlign.start,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : const SizedBox.shrink(),
                          competence.competenceLevel != null
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                      top: 4.0, bottom: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          competence.competenceLevel!,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox.shrink()
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      );
    }
  }
  return competenceWidgets;
}
