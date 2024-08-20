export '../../../features/schoolday_events/services/schoolday_event_api_service.dart';
export '../../../features/authorizations/services/authorization_api_service.dart';
export '../../../features/competence/services/competence_api_service.dart';
export '../../../features/learning_support/services/learning_support_api_service.dart';
export '../../../features/attendance/services/attendance_api_service.dart';
export '../../../features/pupil/services/pupil_data_api_service.dart';
export '../../../features/workbooks/services/pupil_workbook_api_service.dart';
export '../../../features/school_lists/services/school_list_api_service.dart';
export '../../../features/schooldays/services/schoolday_api_service.dart';
export '../../../features/users/services/user_api_service.dart';
export '../../../features/workbooks/services/workbook_api_service.dart';

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
