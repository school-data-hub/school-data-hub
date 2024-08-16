import 'package:dio/dio.dart';
import 'package:schuldaten_hub/api/api.dart';
import 'package:schuldaten_hub/api/dio/dio_interceptor.dart';
import 'package:schuldaten_hub/common/services/env_manager.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/session_manager.dart';

class DioClient {
  // dio instance
  late final Dio _dio;
  String baseUrl;

  // injecting dio instance
  DioClient(this._dio, this.baseUrl) {
    _dio
      ..options.baseUrl = baseUrl
      ..options.connectTimeout = ApiSettings.connectionTimeout
      //..options.headers['content-Type'] = 'application/json'

      ..options.receiveTimeout = ApiSettings.receiveTimeout
      ..options.responseType = ResponseType.json
      ..interceptors.add(DioInterceptor())
      ..interceptors.add(LogInterceptor(
        request: true,
        requestHeader: true,
        // requestBody: true,
        // responseHeader: true,
        // responseBody: true,
      ));
  }

  setCustomDioClientOptions(
      {String? baseUrl, String? tokenKey, String? token, bool? isFile}) {
    if (baseUrl != null) _dio.options.baseUrl = baseUrl;
    if (tokenKey != null && token != null) {
      _dio.options.headers[tokenKey] = token;
    }
    if (isFile != null) {
      _dio.options.contentType =
          isFile ? 'multipart/form-data' : 'application/json';
    }
  }

  setDefaultDioClientOptions() {
    _dio.options.baseUrl = locator<EnvManager>().env.value.serverUrl!;
    _dio.options.headers.clear();
    _dio.options.headers['x-access-token'] =
        locator<SessionManager>().credentials.value.jwt!;
  }

  setHeaders({required String tokenKey, required String token}) {
    _dio.options.headers[tokenKey] = token;
  }

  setBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }

  //- GET:-----------------------------------------------------------------------

  Future<Response> get(
    String uri, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    final Response response = await _dio.get(
      uri,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );

    return response;
  }

//- PATCH:-----------------------------------------------------------------------

  Future<Response> patch(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    final Response response = await _dio.patch(
      uri,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
    return response;
  }

  //- POST:----------------------------------------------------------------------

  Future<Response> post(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final Response response = await _dio.post(
      uri,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    return response;
  }

  //- PUT:-----------------------------------------------------------------------

  Future<Response> put(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final Response response = await _dio.put(
      uri,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
    return response;
  }

  //- DELETE:--------------------------------------------------------------------

  Future<Response> delete(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final Response response = await _dio.delete(
      uri,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
    return response;
  }
}
