import 'package:flutter/material.dart';
import 'package:schuldaten_hub/features/competence/presentation/select_competece_page/select_common_competence_page.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_proxy.dart';

class SelectCompetence extends StatefulWidget {
  final PupilProxy pupil;
  final String elementType;
  const SelectCompetence({
    required this.pupil,
    required this.elementType,
    super.key,
  });

  @override
  SelectCompetenceController createState() => SelectCompetenceController();
}

class SelectCompetenceController extends State<SelectCompetence> {
  int? selectedCategoryId;

  void selectCcompetence(int id) {
    setState(() {
      selectedCategoryId = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SelectCompetencePage(this);
  }
}
