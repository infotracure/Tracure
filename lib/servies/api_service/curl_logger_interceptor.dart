import 'package:dio/dio.dart';
import 'package:tracure/utils/common_methods.dart';

class CurlLoggerInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final method = options.method.toUpperCase();
    final buffer = StringBuffer();

    buffer.write('curl -X $method \'${options.uri}\'');

    // Headers
    options.headers.forEach((k, v) {
      buffer.write(' -H "$k: $v"');
    });

    // Body
    if (options.data != null) {
      if (options.data is FormData) {
        buffer.write(" --data '<form-data>'");
      } else {
        buffer.write(" --data '${options.data.toString()}'");
      }
    }

    devLog('===== CURL REQUEST =====');
    devLog(buffer.toString());
    devLog('========================');

    handler.next(options); // ✅ safe
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    devLog('===== RESPONSE (${response.statusCode}) =====');
    devLog(response.data);
    devLog('================================');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    devLog('===== ERROR (${err.response?.statusCode}) =====');
    devLog(err.message ?? 'Unknown error');
    if (err.response != null) {
      devLog(err.response?.data);
    }
    devLog('================================');
    handler.next(err);
  }
}
