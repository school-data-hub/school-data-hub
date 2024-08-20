import 'package:flutter/material.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/constants/styles.dart';
import 'package:schuldaten_hub/features/competence/models/competence.dart';
import 'package:schuldaten_hub/features/competence/filters/competence_filter_manager.dart';
import 'package:schuldaten_hub/features/competence/services/competence_manager.dart';
import 'package:schuldaten_hub/common/services/locator.dart';

import 'package:schuldaten_hub/features/competence/pages/competence_list_page/widgets/competence_list_view_bottom_navbar.dart';
import 'package:schuldaten_hub/features/competence/pages/competence_list_page/widgets/competence_tree.dart';
import 'package:schuldaten_hub/features/competence/pages/new_competence_page/new_competence_view.dart';
import 'package:schuldaten_hub/features/competence/pages/patch_competence_page/patch_competence_view.dart';

import 'package:watch_it/watch_it.dart';

class CompetenceListPage extends WatchingWidget {
  const CompetenceListPage({super.key});

  @override
  Widget build(BuildContext context) {
    //TODO: functions in the build method don't feel right
    navigateToNewCompetenceview(int competenceId) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (ctx) => NewCompetenceView(
          parentCompetence: competenceId,
        ),
      ));
    }

    navigateToPatchCompetenceView(Competence competence) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (ctx) => PatchCompetenceView(
          competence: competence,
        ),
      ));
    }

    List<Competence> competences =
        watchValue((CompetenceFilterManager x) => x.filteredCompetences);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: backgroundColor,
        title: const Text(
          'Kompetenzen',
          style: appBarTextStyle,
        ),
      ),
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
                  ...buildCompetenceTree(
                      navigateToNewCompetenceView: navigateToNewCompetenceview,
                      navigateToPatchCompetenceView:
                          navigateToPatchCompetenceView,
                      parentId: null,
                      indentation: 0,
                      backgroundColor: null,
                      competences: competences),
                ]),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar:
          CompetenceListPageBottomNavBar(competences: competences),
    );
  }
}
