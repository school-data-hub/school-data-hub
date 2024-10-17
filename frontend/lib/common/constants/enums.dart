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

enum PupilFilter {
  late,
  missed,
  home,
  unexcused,
  contacted,
  goneHome,
  present,
  notPresent,

  ogs,
  notOgs,
  specialInfo,
  migrationSupport,
  preSchoolRevision0,
  preSchoolRevision1,
  preSchoolRevision2,
  preSchoolRevision3,

  fiveYears,
  communicationPupil,
  communicationTutor1,
  communicationTutor2,
  onlyGirls,
  onlyBoys,
  schoolListYesResponse,
  schoolListNoResponse,
  schoolListNullResponse,
  schoolListCommentResponse,
  authorizationYesResponse,
  authorizationNoResponse,
  authorizationNullResponse,
  authorizationCommentResponse,
  authorizationFileResponse,
}

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

enum SupportAreaFilter {
  motorics,
  language,
  math,
  german,
  emotions,
  learning,
}

Map<SupportAreaFilter, bool> initialSupportAreaFilterValues = {
  SupportAreaFilter.motorics: false,
  SupportAreaFilter.language: false,
  SupportAreaFilter.math: false,
  SupportAreaFilter.german: false,
  SupportAreaFilter.emotions: false,
  SupportAreaFilter.learning: false,
};

Map<PupilFilter, bool> initialPupilFilterValues = {
  PupilFilter.late: false,
  PupilFilter.missed: false,
  PupilFilter.home: false,
  PupilFilter.unexcused: false,
  PupilFilter.contacted: false,
  PupilFilter.goneHome: false,
  PupilFilter.present: false,
  PupilFilter.notPresent: false,
  PupilFilter.ogs: false,
  PupilFilter.notOgs: false,
  PupilFilter.specialInfo: false,
  PupilFilter.migrationSupport: false,
  PupilFilter.preSchoolRevision0: false,
  PupilFilter.preSchoolRevision1: false,
  PupilFilter.preSchoolRevision2: false,
  PupilFilter.preSchoolRevision3: false,
  PupilFilter.fiveYears: false,
  PupilFilter.communicationPupil: false,
  PupilFilter.communicationTutor1: false,
  PupilFilter.communicationTutor2: false,
  PupilFilter.onlyBoys: false,
  PupilFilter.onlyGirls: false,
  PupilFilter.schoolListYesResponse: false,
  PupilFilter.schoolListNoResponse: false,
  PupilFilter.schoolListNullResponse: false,
  PupilFilter.schoolListCommentResponse: false,
  PupilFilter.authorizationYesResponse: false,
  PupilFilter.authorizationNoResponse: false,
  PupilFilter.authorizationNullResponse: false,
  PupilFilter.authorizationCommentResponse: false,
  PupilFilter.authorizationFileResponse: false,
};
