import 'package:flutter/material.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/widgets/generic_app_bar.dart';
import 'package:schuldaten_hub/features/competence/filters/competence_filter_manager.dart';
import 'package:schuldaten_hub/features/competence/models/competence.dart';
import 'package:schuldaten_hub/features/competence/pages/competence_list_page/widgets/competence_list_view_bottom_navbar.dart';
import 'package:schuldaten_hub/features/competence/pages/competence_list_page/widgets/competence_tree.dart';
import 'package:schuldaten_hub/features/competence/pages/post_or_patch_competence_page/post_or_patch_competence_page.dart';
import 'package:schuldaten_hub/features/competence/services/competence_manager.dart';
import 'package:watch_it/watch_it.dart';

import '../../../../common/constants/colors.dart';
import '../../../../common/services/base_state.dart';
import '../../../../common/widgets/generic_app_bar.dart';

class CompetenceListPage extends WatchingStatefulWidget {
  const CompetenceListPage({super.key});

  @override
  State<CompetenceListPage> createState() => _CompetenceListPageState();
}

class _CompetenceListPageState extends BaseState<CompetenceListPage> {
  get competence => null;

  @override
  Future<void> onInitialize() async {
    await locator.isReady<CompetenceFilterManager>();
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      return const Scaffold(
        backgroundColor: canvasColor,
        appBar:
            GenericAppBar(iconData: Icons.rule_rounded, title: 'Kompetenzen'),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    //TODO: functions in the build method don't feel right
     navigateToNewOrPatchCompetencePage(
        {int? competenceId, Competence? competence}) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (ctx) => PostOrPatchCompetencePage(
          parentCompetence: competenceId,
          competence: competence,
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
