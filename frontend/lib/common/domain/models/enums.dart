// ignore_for_file: constant_identifier_names

enum SearchType { pupil, room, matrixUser, list, authorization, workbook }

enum NotificationType { success, error, warning, info, infoDialog }

enum CompetenceFilter { E1, E2, S3, S4 }

Map<CompetenceFilter, bool> initialCompetenceFilterValues = {
  CompetenceFilter.E1: false,
  CompetenceFilter.E2: false,
  CompetenceFilter.S3: false,
  CompetenceFilter.S4: false
};

enum SchooldayEventFilter {
  sevenDays,
  admonition,
  afternoonCareAdmonition,
  admonitionAndBanned,
  parentsMeeting,
  otherEvent,
  violenceAgainstThings,
  violenceAgainstPupils,
  insultOthers,
  annoy,
  ignoreInstructions,
  disturbLesson,
  other,
  processed,
}

Map<SchooldayEventFilter, bool> initialSchooldayEventFilterValues = {
  SchooldayEventFilter.sevenDays: false,
  SchooldayEventFilter.admonition: false,
  SchooldayEventFilter.afternoonCareAdmonition: false,
  SchooldayEventFilter.admonitionAndBanned: false,
  SchooldayEventFilter.parentsMeeting: false,
  SchooldayEventFilter.otherEvent: false,
  SchooldayEventFilter.violenceAgainstThings: false,
  SchooldayEventFilter.violenceAgainstPupils: false,
  SchooldayEventFilter.insultOthers: false,
  SchooldayEventFilter.annoy: false,
  SchooldayEventFilter.ignoreInstructions: false,
  SchooldayEventFilter.disturbLesson: false,
  SchooldayEventFilter.other: false,
  SchooldayEventFilter.processed: false,
};

enum PupilSortMode {
  sortByName,
  sortByMissedExcused,
  sortByMissedUnexcused,
  sortByContacted,
  sortByLate,
  sortByCredit,
  sortByCreditEarned,
  sortByGoneHome,
  sortBySchooldayEvents,
  sortByLastSchooldayEvent,
  sortByLastNonProcessedSchooldayEvent,
}

Map<PupilSortMode, bool> initialSortModeValues = {
  PupilSortMode.sortByName: true,
  PupilSortMode.sortByMissedExcused: false,
  PupilSortMode.sortByMissedUnexcused: false,
  PupilSortMode.sortByContacted: false,
  PupilSortMode.sortByLate: false,
  PupilSortMode.sortByCredit: false,
  PupilSortMode.sortByCreditEarned: false,
  PupilSortMode.sortByGoneHome: false,
  PupilSortMode.sortBySchooldayEvents: false,
  PupilSortMode.sortByLastSchooldayEvent: false,
  PupilSortMode.sortByLastNonProcessedSchooldayEvent: false
};

enum SupportLevel {
  supportLevel1,
  supportLevel2,
  supportLevel3,
  supportLevel4,
  specialNeeds,
  migrationSupport,
}

Map<SupportLevel, bool> initialSupportLevelFilterValues = {
  SupportLevel.supportLevel1: false,
  SupportLevel.supportLevel2: false,
  SupportLevel.supportLevel3: false,
  SupportLevel.supportLevel4: false,
  SupportLevel.specialNeeds: false,
  SupportLevel.migrationSupport: false,
};

enum SupportArea {
  motorics(1),
  language(2),
  math(3),
  german(4),
  emotions(5),
  learning(6);

  static const intToValue = {
    1: SupportArea.motorics,
    2: SupportArea.language,
    3: SupportArea.math,
    4: SupportArea.german,
    5: SupportArea.emotions,
    6: SupportArea.learning,
  };

  final int value;
  const SupportArea(this.value);
}

Map<SupportArea, bool> initialSupportAreaFilterValues = {
  SupportArea.motorics: false,
  SupportArea.language: false,
  SupportArea.math: false,
  SupportArea.german: false,
  SupportArea.emotions: false,
  SupportArea.learning: false,
};
