// ignore_for_file: unreachable_switch_default

import 'dart:io';
import 'package:dio/dio.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    final message = _getErrorMessage(err);

    final resolvedException = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: err.error,
      stackTrace: err.stackTrace,
      message: message,
    );

    handler.next(resolvedException);
  }

  String _getErrorMessage(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timed out. Please check your internet connection.';

      case DioExceptionType.sendTimeout:
        return 'Request timed out while sending data. Please try again.';

      case DioExceptionType.receiveTimeout:
        return 'The server is taking too long to respond.';

      case DioExceptionType.badCertificate:
        return 'Secure connection failed. Invalid certificate.';

      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network.';

      case DioExceptionType.cancel:
        return 'Request was cancelled.';

      case DioExceptionType.badResponse:
        return _handleStatusCode(err.response);

      case DioExceptionType.unknown:
        if (err.error is SocketException) {
          return 'No internet connection. Please check your network.';
        }

        return 'Something went wrong. Please try again.';

      default:
        return 'Unexpected error occurred.';
    }
  }

  String _handleStatusCode(Response? response) {
    final statusCode = response?.statusCode;

    // Try to read backend message first
    final data = response?.data;

    if (data is Map<String, dynamic>) {
      final serverMessage =
          data['message'] ??
          data['error'] ??
          data['detail'];

      if (serverMessage != null &&
          serverMessage.toString().trim().isNotEmpty) {
        return serverMessage.toString();
      }
    }

    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';

      case 401:
        return 'Session expired. Please login again.';

      case 403:
        return 'You do not have permission to perform this action.';

      case 404:
        return 'Requested resource was not found.';

      case 408:
        return 'Request timed out. Please try again.';

      case 409:
        return 'This resource already exists.';

      case 422:
        return 'Validation failed. Please check your input.';

      case 429:
        return 'Too many requests. Please try again later.';

      case 500:
        return 'Something went wrong on our server.';

      case 502:
        return 'Bad gateway. Please try again later.';

      case 503:
        return 'Service temporarily unavailable.';

      case 504:
        return 'Server took too long to respond.';

      default:
        return 'Server error (${statusCode ?? 'Unknown'}).';
    }
  }
}