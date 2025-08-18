import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../main.dart';
import 'end_points.dart';
import 'response_handler.dart';

class DioClient {
  final Dio _dio = Dio();

  DioClient({String? baseUrl}) {
    _dio
      ..options.baseUrl = baseUrl ?? EndPoints.baseUrl
      ..options.responseType = ResponseType.json
      ..options.connectTimeout = Duration(seconds: 60)
      ..options.responseType = ResponseType.plain
      // ..interceptors.add(alice.)
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
      debugPrint("url :${_dio.options.baseUrl}$url ");
      debugPrint("Param: $queryParam");
      final response = await _dio.get(
        url,
        queryParameters: queryParam,
        options: options,
        cancelToken: cancelToken,
      );
      debugPrint('res: ${response.data}');
      return DioResponse(response);
    } catch (e) {
      // debugPrint("$e");
      var dioError = DioExceptions.fromDioError(e as DioError);
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
      debugPrint("url :${_dio.options.baseUrl}$url \n req: $data");
      debugPrint("Param: $queryParam");

      final response = await _dio.post(
        url,
        data: data,
        queryParameters: queryParam,
        options: options,
        cancelToken: cancelToken,
      );

      debugPrint('res: ${response.data}');

      return DioResponse(response);
    } catch (e) {
      // debugPrint(e.toString());
      var dioError = DioExceptions.fromDioError(e as DioError);
      return dioError;
    }
  }
}
