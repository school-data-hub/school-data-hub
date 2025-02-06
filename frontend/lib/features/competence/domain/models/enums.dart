enum RootCompetenceType {
  science('Sachunterricht'),
  english('Englisch'),
  math('Mathematik'),
  music('Musik'),
  art('Kunst'),
  religion('Religion'),
  sport('Sport'),
  workBehavior('Arbeitsverhalten'),
  socialBehavior('Sozialverhalten'),
  german('Deutsch');

  final String value;

  static const stringToValue = {
    'Sachunterricht': RootCompetenceType.science,
    'Englisch': RootCompetenceType.english,
    'Mathematik': RootCompetenceType.math,
    'Musik': RootCompetenceType.music,
    'Kunst': RootCompetenceType.art,
    'Religion': RootCompetenceType.religion,
    'Sport': RootCompetenceType.sport,
    'Arbeitsverhalten': RootCompetenceType.workBehavior,
    'Sozialverhalten': RootCompetenceType.socialBehavior,
    'Deutsch': RootCompetenceType.german,
  };

  const RootCompetenceType(this.value);
}
