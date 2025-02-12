import 'package:flutter/material.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/widgets/list_view_components/generic_app_bar.dart';
import 'package:schuldaten_hub/features/competence/domain/competence_manager.dart';
import 'package:schuldaten_hub/features/competence/domain/filters/competence_filter_manager.dart';
import 'package:schuldaten_hub/features/competence/domain/models/competence.dart';
import 'package:schuldaten_hub/features/competence/presentation/competence_list_page/widgets/competence_list_view_bottom_navbar.dart';
import 'package:schuldaten_hub/features/competence/presentation/competence_list_page/widgets/competence_tree.dart';
import 'package:schuldaten_hub/features/competence/presentation/post_or_patch_competence_page/post_or_patch_competence_page.dart';
import 'package:watch_it/watch_it.dart';

class CompetenceListPage extends WatchingWidget {
  const CompetenceListPage({super.key});

  @override
  Widget build(BuildContext context) {
    navigateToNewOrPatchCompetencePage(
        {int? competenceId, Competence? competence}) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (ctx) => PostOrPatchCompetencePage(
          parentCompetence: competenceId,
          competence: competence,
        ),
      ));
    }

    List<Competence> competences =
        watchValue((CompetenceFilterManager x) => x.filteredCompetences);
    return Scaffold(
      appBar: const GenericAppBar(
          iconData: Icons.lightbulb_rounded, title: 'Kompetenzen'),
      body: RefreshIndicator(
        onRefresh: () async => locator<CompetenceManager>().fetchCompetences(),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.only(
                top: 8.0, left: 10, right: 10, bottom: 10),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 800,
                ),
                child: Column(children: [
                  ...buildCommonCompetenceTree(
                      navigateToNewOrPatchCompetencePage:
                          navigateToNewOrPatchCompetencePage,
                      parentId: null,
                      indentation: 0,
                      backgroundColor: null,
                      competences: competences,
                      context: context),
                ]),
              ),
              // child: Column(children: [
              //   ...buildCommonCompetenceTree(
              //       navigateToNewOrPatchCompetencePage:
              //           navigateToNewOrPatchCompetencePage,
              //       parentId: null,
              //       indentation: 0,
              //       backgroundColor: null,
              //       competences: competences,
              //       context: context),
              // ]),
            ),
          ),
        ),
      ),
      bottomNavigationBar:
          CompetenceListPageBottomNavBar(competences: competences),
    );
  }
}
