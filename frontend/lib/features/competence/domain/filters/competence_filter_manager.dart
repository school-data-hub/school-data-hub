import 'package:flutter/foundation.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/utils/logger.dart';
import 'package:schuldaten_hub/features/competence/domain/competence_manager.dart';
import 'package:schuldaten_hub/features/competence/domain/filters/enums.dart';
import 'package:schuldaten_hub/features/competence/domain/models/competence.dart';

class CompetenceFilterManager {
  final _filterState =
      ValueNotifier<Map<CompetenceFilter, bool>>(initialCompetenceFilterValues);
  ValueListenable<Map<CompetenceFilter, bool>> get filterState => _filterState;

  final _filteredCompetences = ValueNotifier<List<Competence>>(
      locator<CompetenceManager>().competences.value);
  ValueListenable<List<Competence>> get filteredCompetences =>
      _filteredCompetences;

  final _filtersOn = ValueNotifier<bool>(false);
  ValueListenable<bool> get filtersOn => _filtersOn;

  CompetenceFilterManager();

  refreshFilteredCompetences(List<Competence> competences) {
    _filteredCompetences.value = competences;
    logger.i('refreshed filtered competences');
  }

  resetFilters() {
    _filteredCompetences.value = locator<CompetenceManager>().competences.value;

    _filterState.value = {...initialCompetenceFilterValues};

    _filtersOn.value = false;
  }

  void setFilter(CompetenceFilter filter, bool isActive) {
    _filterState.value = {
      ..._filterState.value,
      filter: isActive,
    };

    filterCompetences();
  }

  void filterCompetences() {
    List<Competence> competences =
        locator<CompetenceManager>().competences.value;

    List<Competence> filteredCompetences = [];

    final activeFilters = _filterState.value;

    for (Competence competence in competences) {
      if (competence.competenceLevel != null) {
        if ((activeFilters[CompetenceFilter.E1]! &&
                !competence.competenceLevel!.contains('E1')) ||
            (activeFilters[CompetenceFilter.E2]! &&
                !competence.competenceLevel!.contains('E2')) ||
            (activeFilters[CompetenceFilter.S3]! &&
                !competence.competenceLevel!.contains('S3')) ||
            (activeFilters[CompetenceFilter.S4]! &&
                !competence.competenceLevel!.contains('S4'))) {
          continue;
        }
      }

      filteredCompetences.add(competence);

      _filteredCompetences.value = filteredCompetences;
    }
  }
}
