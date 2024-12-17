export '../../../features/attendance/data/attendance_repository.dart';
export '../../../features/authorizations/data/authorization_repository.dart';
export '../../../features/competence/data/competence_repository.dart';
export '../../../features/learning_support/data/learning_support_repository.dart';
export '../../../features/pupil/data/pupil_data_repository.dart';
export '../../../features/school_lists/data/school_list_repository.dart';
export '../../../features/schoolday_events/data/schoolday_event_repository.dart';
export '../../../features/schooldays/data/schoolday_repository.dart';
export '../../../features/users/data/user_repository.dart';
export '../../../features/workbooks/data/pupil_workbook_repository.dart';
export '../../../features/workbooks/data/workbook_repository.dart';

class ApiSettings {
  // dev environment urls:
  //static const baseUrl = 'http://10.0.2.2:5000/api'; // android VM
  //static const baseUrl = 'http://127.0.0.1:5000/api'; //windows

  // receiveTimeout
  static const Duration receiveTimeout = Duration(milliseconds: 15000);

  // connectTimeout
  static const Duration connectionTimeout = Duration(milliseconds: 30000);
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, int? statusCode) : statusCode = statusCode ?? 0;
}
