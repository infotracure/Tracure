import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:tracure/main.dart';

class CurlLoggerInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final method = options.method.toUpperCase();
    final buffer = StringBuffer();

    buffer.write('curl -X $method \'${options.uri}\'');

    // Headers
    options.headers.forEach((k, v) {
      buffer.write(' \\\n  -H "$k: $v"');
    });

    // Body
    if (options.data != null) {
      if (options.data is FormData) {
        buffer.write(" \\\n  --data '<form-data>'");
      } else {
        buffer.write(" \\\n  --data '${options.data.toString()}'");
      }
    }

    talker.info('📤 CURL REQUEST\n${buffer.toString()}');

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    String responseBody;
    try {
      responseBody = const JsonEncoder.withIndent('  ').convert(response.data);
    } catch (_) {
      responseBody = response.data.toString();
    }

    talker.info(
      '📥 RESPONSE [${response.statusCode}] ${response.requestOptions.uri}\n$responseBody',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String errorBody = '';
    if (err.response?.data != null) {
      try {
        errorBody = const JsonEncoder.withIndent('  ').convert(err.response?.data);
      } catch (_) {
        errorBody = err.response?.data.toString() ?? '';
      }
    }

    talker.error(
      '❌ ERROR [${err.response?.statusCode}] ${err.requestOptions.uri}\n${err.message ?? 'Unknown error'}\n$errorBody',
    );
    handler.next(err);
  }
}
