import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:schuldaten_hub/common/domain/env_manager.dart';
import 'package:schuldaten_hub/common/domain/session_manager.dart';
import 'package:schuldaten_hub/common/services/api/api_settings.dart';
import 'package:schuldaten_hub/common/services/locator.dart';

class ApiClient {
  // dio instance
  late final Dio _dio;
  String baseUrl;

  // injecting dio instance
  ApiClient(this._dio, {required this.baseUrl}) {
    _dio
      ..options.baseUrl = baseUrl
      ..options.connectTimeout = ApiSettings.connectionTimeout
      //..options.headers['content-Type'] = 'application/json'
      ..options.validateStatus = (status) {
        return status! < 500;
      }
      ..options.receiveTimeout = ApiSettings.receiveTimeout
      ..options.responseType = ResponseType.json;
    //   ..interceptors.add(DioInterceptor());
    // ..interceptors.add(LogInterceptor(
    //   request: true,
    //   requestHeader: true,
    //   requestBody: true,
    //   responseHeader: true,
    //   responseBody: true,
    // ));
    log('ApiClient initialized');
  }

  setCustomDioClientOptions(
      {String? baseUrl, String? tokenKey, String? token, bool? isFile}) {
    if (baseUrl != null) _dio.options.baseUrl = baseUrl;
    if (tokenKey != null && token != null) {
      _dio.options.headers.clear();
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
    log('Base URL set to: $baseUrl');
  }

  //- GET:

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
    log("Response[GET] ${response.statusCode} => PATH: $uri");
    return response;
  }

//- PATCH:

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
    log("Response[PATCH] ${response.statusCode} => PATH: $uri");
    return response;
  }

  //- POST:

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
    log("Response[POST] ${response.statusCode} => PATH: $uri");
    return response;
  }

  //- PUT:

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

  //- DELETE:

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
    log("Response[DELETE] ${response.statusCode} => PATH: $uri");
    return response;
  }
}
