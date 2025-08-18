import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:tracure/utils/common_widget.dart';

class ApiResponse {}

class DioResponse extends Response implements ApiResponse {
  DioResponse(Response response)
    : super(
        data: response.data,
        requestOptions: response.requestOptions,
        statusCode: response.statusCode,
        statusMessage: response.statusMessage,
      );
}

T? jsonToObject<T>(
  ApiResponse res,
  T Function(String) fromJson, {
  bool showToast = true,
}) {
  try {
    if (res is DioExceptions) {
      CommonWidget.showToast(res.toString());
      return null;
    } else if (res is DioResponse) {
      return fromJson(res.data);
    }
  } catch (e) {
    debugPrint(e.toString());
  }
  return null;
}

class DioExceptions extends ApiResponse implements Exception {
  late String message;

  DioExceptions.fromDioError(DioException dioError) {
    switch (dioError.type) {
      case DioExceptionType.cancel:
        message = "Request to API server was cancelled";
        break;
      case DioExceptionType.connectionTimeout:
        message = "Connection timeout with API server";
        break;
      case DioExceptionType.receiveTimeout:
        message = "Receive timeout in connection with API server";
        break;
      case DioExceptionType.badResponse:
        message = _handleError(
          dioError.response?.statusCode,
          dioError.response?.data,
        );
        break;
      case DioExceptionType.sendTimeout:
        message = "Send timeout in connection with API server";
        break;
      case DioExceptionType.unknown:
        if (dioError.error != null &&
            dioError.error.toString().contains("SocketException")) {
          message = "No Internet";
        } else {
          message = "Unexpected error occurred";
        }
        break;
      default:
        message = "Something went wrong";
        break;
    }
  }

  String _handleError(int? statusCode, dynamic error) {
    switch (statusCode) {
      case 400:
        debugPrint('400:Bad request');
        break;
      case 401:
        debugPrint('401:Unauthorized');
        return 'Invalid login credentails or user not registered';
      case 403:
        debugPrint('403:Forbidden');
        break;
      case 404:
        debugPrint("404:Not Found");
        break;
      case 500:
        debugPrint('500:Internal server error');
        break;
      case 502:
        debugPrint('502:Bad gateway');
        break;

      default:
        debugPrint('Oops something went wrong');
    }
    return 'Oops something went wrong';
  }

  @override
  String toString() => message;
}
