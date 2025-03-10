export '../../../features/attendance/data/attendance_api_service.dart';
export '../../../features/authorizations/data/authorization_api_service.dart';
export '../../../features/books/data/book_api_service.dart';
export '../../../features/competence/data/competence_api_service.dart';
export '../../../features/learning_support/data/learning_support_api_service.dart';
export '../../../features/pupil/data/pupil_data_api_service.dart';
export '../../../features/school_lists/data/school_list_api_service.dart';
export '../../../features/schoolday_events/data/schoolday_event_api_service.dart';
export '../../../features/schooldays/data/schoolday_api_service.dart';
export '../../../features/users/data/user_api_service.dart';
export '../../../features/workbooks/data/pupil_workbook_api_service.dart';
export '../../../features/workbooks/data/workbook_api_service.dart';

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
