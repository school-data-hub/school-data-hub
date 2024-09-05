import 'package:flutter/material.dart';
import 'package:schuldaten_hub/common/constants/styles.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/features/competence/models/competence.dart';
import 'package:schuldaten_hub/features/competence/services/competence_manager.dart';

class CompetencePupilsCheckListPage extends StatelessWidget {
  final Competence competence;
  const CompetencePupilsCheckListPage({required this.competence, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: locator<CompetenceManager>()
            .getCompetenceColor(competence.competenceId),
        title: Text(
          competence.competenceName,
          style: appBarTextStyle,
        ),
      ),
      body: const Center(
        child: Text('Pupils Check List'),
      ),
    );
  }
}
