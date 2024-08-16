export 'endpoints/schoolday_event_api_service.dart';
export 'endpoints/authorization_api_service.dart';
export 'endpoints/competence_api_service.dart';
export 'endpoints/learning_support_api_service.dart';
export 'endpoints/attendance_api_service.dart';
export 'endpoints/pupil_data_api_service.dart';
export 'endpoints/pupil_workbook_api_service.dart';
export 'endpoints/school_list_api_service.dart';
export 'endpoints/schoolday_api_service.dart';
export 'endpoints/user_api_service.dart';
export 'endpoints/workbook_api_service.dart';

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
