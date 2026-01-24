import 'package:dio/dio.dart';
import 'package:tracure/servies/api_service/auth_interceptor.dart';
import 'package:tracure/servies/api_service/curl_logger_interceptor.dart';

import 'end_points.dart';
import 'response_handler.dart';

class DioClient {
  final Dio _dio = Dio();

  DioClient({String? baseUrl}) {
    _dio
      ..options.baseUrl = baseUrl ?? EndPoints.baseUrl
      ..options.responseType = ResponseType.json
      ..options.connectTimeout = Duration(seconds: 60)
      ..interceptors.add(AuthInterceptor())
      ..interceptors.add(CurlLoggerInterceptor())
      ..options.receiveTimeout = Duration(seconds: 60);
  }

  Future<ApiResponse> get(
    String url, {
    Map<String, dynamic>? queryParam,
    ProgressCallback? onResponse,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        url,
        queryParameters: queryParam,
        options: options,
        cancelToken: cancelToken,
      );

      return DioResponse(response);
    } catch (e) {
      // debugPrint("$e");
      var dioError = DioExceptions.fromDioError(e as DioException);
      return dioError;
    }
  }

  Future<ApiResponse> post(
    String url,
    data, {
    Map<String, dynamic>? queryParam,
    ProgressCallback? onResponse,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {


      final response = await _dio.post(
        url,
        data: data,
        queryParameters: queryParam,
        options: options,
        cancelToken: cancelToken,
      );


      return DioResponse(response);
    } catch (e) {
      // debugPrint(e.toString());
      var dioError = DioExceptions.fromDioError(e as DioException);
      return dioError;
    }
  }
}
