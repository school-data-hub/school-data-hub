import 'package:flutter/material.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/features/competence/domain/competence_manager.dart';
import 'package:schuldaten_hub/features/competence/domain/filters/competence_filter_manager.dart';
import 'package:schuldaten_hub/features/competence/domain/models/competence.dart';
import 'package:schuldaten_hub/features/competence/presentation/select_competence_page/select_competence_page.dart';
import 'package:watch_it/watch_it.dart';

class SelectCompetence extends WatchingStatefulWidget {
  const SelectCompetence({
    super.key,
  });

  @override
  SelectCompetenceViewModel createState() => SelectCompetenceViewModel();
}

class SelectCompetenceViewModel extends State<SelectCompetence> {
  int? selectedCompetenceId;
  Competence? selectedCompetence;
  List<Competence> competences = [];

  void selectCompetence(int id) {
    setState(() {
      selectedCompetenceId = id;
      selectedCompetence = locator<CompetenceManager>().findCompetenceById(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    competences =
        watchValue((CompetenceFilterManager x) => x.filteredCompetences);
    return SelectCompetencePage(this);
  }
}
