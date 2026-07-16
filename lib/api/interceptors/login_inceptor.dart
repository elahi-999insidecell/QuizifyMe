import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    if (kDebugMode) {
      debugPrint(
          '================ NETWORK REQUEST ================');
      debugPrint(
          'HTTP Method : ${options.method.toUpperCase()}');
      debugPrint('URL         : ${options.uri}');
      debugPrint('Headers     : ${options.headers}');

      if (options.queryParameters.isNotEmpty) {
        debugPrint(
            'Query Params: ${options.queryParameters}');
      }

      if (options.data != null) {
        debugPrint('Request Body: ${options.data}');
      }

      debugPrint(
          '================================================');
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    if (kDebugMode) {
      debugPrint(
          '================ NETWORK RESPONSE ================');
      debugPrint(
          'Status Code : ${response.statusCode}');
      debugPrint(
          'HTTP Method : ${response.requestOptions.method.toUpperCase()}');
      debugPrint(
          'URL         : ${response.requestOptions.uri}');

      if (response.data != null) {
        debugPrint('Response Body: ${response.data}');
      }

      debugPrint(
          '=================================================');
    }

    super.onResponse(response, handler);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    if (kDebugMode) {
      debugPrint(
          '================ NETWORK ERROR =================');
      debugPrint('Error Message: ${err.message}');
      debugPrint(
          'Status Code : ${err.response?.statusCode}');
      debugPrint(
          'HTTP Method : ${err.requestOptions.method.toUpperCase()}');
      debugPrint('URL         : ${err.requestOptions.uri}');

      if (err.response?.data != null) {
        debugPrint(
            'Response Body: ${err.response?.data}');
      }

      debugPrint(
          '================================================');
    }

    super.onError(err, handler);
  }
}