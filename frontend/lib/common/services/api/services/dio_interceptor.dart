import 'dart:developer';

import 'package:dio/dio.dart';

class DioInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    log("Request[${options.method}] => PATH: ${options.path}");
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.statusCode == 401) {
      // locator<SessionManager>().logout();
      return;
    }

    //log("Response Status Code: [${response.statusCode}]");
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    log("\x1B[31mError[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}\x1B[31m");
    if (err.response!.statusCode == 401) {
      log("AUTH ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}");
      log('BASEURL: ${err.requestOptions.baseUrl} HEADERS: ${err.requestOptions.headers} ');
      //  locator<SessionManager>().logout();
      //handler.next(err);
    }
    super.onError(err, handler);
  }
}
