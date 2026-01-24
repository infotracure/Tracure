// lib/api/interceptors/auth_interceptor.dart
import 'package:dio/dio.dart';
import 'package:tracure/features/loginpage/model/verify_otp_model.dart';
import 'package:tracure/servies/api_service/end_points.dart';
import 'package:tracure/servies/hive_service.dart';

import '../../utils/common_widget.dart';
import '../../utils/constant/string_constants.dart';
import '../../utils/loading_overlay.dart';

class AuthInterceptor extends Interceptor {
  bool _isRefreshing = false;
  final List<Function(RequestOptions)> _retryQueue = [];

  AuthInterceptor();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = HiveService.instance.getString(HiveService.loginToken);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshToken = HiveService.instance.getString(
        HiveService.refreshToken,
      );

      if (refreshToken == null) {
        CommonWidget.showToast(StringConstant.sessionExpired);
        await HiveService.instance.clear();
        return handler.reject(err);
      }
      if (_isRefreshing) {
        // ⏳ Queue until refresh is done
        final newToken = HiveService.instance.getString(HiveService.loginToken);
        _retryQueue.add((requestOptions) async {
          requestOptions.headers['Authorization'] = 'Bearer $newToken';
          return Dio().fetch(requestOptions);
        });
        return;
      } else {
        _isRefreshing = true;
        try {
          final newToken = await _refreshToken(refreshToken);
          // 🔄 Retry queued requests
          for (final retry in _retryQueue) {
            retry(err.requestOptions);
          }
          _retryQueue.clear();

          // Retry the original failed request
          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          final cloneReq = await Dio().fetch(err.requestOptions);
          return handler.resolve(cloneReq);
        } catch (e) {
          await HiveService.instance.clear();
          return handler.reject(err);
        } finally {
          _isRefreshing = false;
        }
      }
    }
    return handler.next(err);
  }

  Future<String?> _refreshToken(String refreshToken) async {
    try {
      showGlobalLoader();
      // Use plain Dio without interceptors to avoid infinite loop
      final dio = Dio(BaseOptions(
        baseUrl: EndPoints.baseUrl,
        connectTimeout: Duration(seconds: 60),
        receiveTimeout: Duration(seconds: 60),
      ));
      final response = await dio.post(
        EndPoints.refreshToken,
        data: {"refreshToken": refreshToken},
      );
      hideGlobalLoader();

      if (response.statusCode == 200 && response.data != null) {
        final verifyOTP = VerifyOtpModel.fromJson(response.data);
        if (verifyOTP.code == 1 && verifyOTP.data?.accessToken != null) {
          HiveService.instance.save(
            verifyOTP.data?.accessToken ?? '',
            HiveService.loginToken,
          );
          HiveService.instance.save(
            verifyOTP.data?.refreshToken ?? '',
            HiveService.refreshToken,
          );
          return verifyOTP.data?.accessToken ?? '';
        }
      }
      return null;
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
      return null;
    }
  }
}
