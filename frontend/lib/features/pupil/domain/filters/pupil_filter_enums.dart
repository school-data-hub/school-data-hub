enum PupilFilter {
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

Map<PupilFilter, bool> initialPupilFilterValues = {
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
