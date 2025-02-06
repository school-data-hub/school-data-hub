import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:schuldaten_hub/common/domain/session_manager.dart';
import 'package:schuldaten_hub/common/services/api/api_settings.dart';
import 'package:schuldaten_hub/common/services/locator.dart';

enum Token {
  hub,
  matrix,
  corporal,
}

class ApiClient {
  // dio instance
  late final Dio _dio;

  // injecting dio instance
  ApiClient(this._dio) {
    _dio
      //..options.baseUrl = baseUrl
      ..options.connectTimeout = ApiSettings.connectionTimeout
      //..options.headers['content-Type'] = 'application/json'
      ..options.validateStatus = (status) {
        return status! < 500;
      }
      ..options.receiveTimeout = ApiSettings.receiveTimeout;
    //..options.responseType = ResponseType.json
    // ..interceptors.add(DioInterceptor())
    // ..interceptors.add(LogInterceptor(
    //   request: true,
    //   requestHeader: true,
    //   requestBody: true,
    //   responseHeader: true,
    //   responseBody: true,
    // ));
    log('ApiClient initialized');
  }

  Options _hubOptions = Options();
  Options get hubOptions => _hubOptions;
  Options _matrixOptions = Options();
  Options get matrixOptions => _matrixOptions;

  Options _corporalOptions = Options();
  Options get corporalOptions => _corporalOptions;

  void setApiOptions({required Token tokenKey, required String token}) {
    switch (tokenKey) {
      case Token.hub:
        _hubOptions = Options(headers: {});
        _hubOptions.headers!['x-access-token'] = token;
        _hubOptions.responseType = ResponseType.json;

        break;
      case Token.matrix:
        _matrixOptions = Options(headers: {});
        _matrixOptions.headers!['Authorization'] = token;
        _matrixOptions.responseType = ResponseType.json;

        break;
      case Token.corporal:
        _corporalOptions = Options(headers: {});
        _corporalOptions.headers!['Authorization'] = token;
        _corporalOptions.responseType = ResponseType.json;

        break;
    }
  }

  Options apiOptions({
    required Token tokenKey,
    bool? isFile,
  }) {
    Options options;
    switch (tokenKey) {
      case Token.hub:
        options = _hubOptions;
        break;
      case Token.matrix:
        options = _matrixOptions;
        break;
      case Token.corporal:
        options = _corporalOptions;
        break;
    }
    if (isFile != null) {
      options.contentType = isFile ? 'multipart/form-data' : 'application/json';
    }

    return options;
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
    if (response.statusCode == 401) {
      locator<SessionManager>().logout();
    }

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
    if (response.statusCode == 401) {
      if (response.data['message'] == 'Token nicht (mehr) gültig!') {
        locator<SessionManager>().logout();
      }
    }

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
    log(
      "Response[POST] ${response.statusCode} => PATH: $uri",
    );
    if (response.statusCode == 401) {
      if (response.data['message'] == 'Token nicht (mehr) gültig!') {
        locator<SessionManager>().logout();
      }
    }

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
    log(
      "Response[PUT] ${response.statusCode} => PATH: $uri",
    );
    if (response.statusCode == 401) {
      if (response.data['message'] == 'Token nicht (mehr) gültig!') {
        locator<SessionManager>().logout();
      }
    }
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
    if (response.statusCode == 401) {
      if (response.data['message'] == 'Token nicht (mehr) gültig!') {
        locator<SessionManager>().logout();
      }
    }
    return response;
  }
}
