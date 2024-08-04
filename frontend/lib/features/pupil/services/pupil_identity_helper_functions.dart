import 'package:schuldaten_hub/features/pupil/models/pupil_identity.dart';

class PupilIdentityHelper {
  static PupilIdentity pupilIdentityFromString(String pupilIdentityAsString) {
    List<String> pupilIdentityValues = pupilIdentityAsString.split(',');
    //-TODO implement enum for the schoolyear
    final schoolyear = pupilIdentityValues[4] == '03'
        ? 'S3'
        : pupilIdentityValues[4] == '04'
            ? 'S4'
            : pupilIdentityValues[4];
    final newPupilIdentity = PupilIdentity(
      id: int.parse(pupilIdentityValues[0]),
      firstName: pupilIdentityValues[1],
      lastName: pupilIdentityValues[2],
      group: pupilIdentityValues[3],
      schoolGrade: schoolyear,
      specialNeeds: pupilIdentityValues[5] == ''
          ? null
          : '${pupilIdentityValues[5]}${pupilIdentityValues[6]}',
      gender: pupilIdentityValues[7],
      language: pupilIdentityValues[8],
      family: pupilIdentityValues[9] == '' ? null : pupilIdentityValues[9],
      birthday: DateTime.tryParse(pupilIdentityValues[10])!,
      migrationSupportEnds: pupilIdentityValues[11] == ''
          ? null
          : DateTime.tryParse(pupilIdentityValues[11])!,
      pupilSince: DateTime.tryParse(pupilIdentityValues[12])!,
    );
    return newPupilIdentity;
  }
}
