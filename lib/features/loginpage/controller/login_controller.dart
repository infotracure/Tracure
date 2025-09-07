import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tracure/features/loginpage/model/verify_otp_model.dart';
import 'package:tracure/features/loginpage/view/otp_verification_screen.dart';
import 'package:tracure/features/register_screen/view/register_screen.dart';
import 'package:tracure/servies/api_service/dio_client.dart';
import 'package:tracure/servies/api_service/end_points.dart';
import 'package:tracure/servies/hive_service.dart';
import 'package:tracure/utils/constant/string_constants.dart';

import '../../../servies/api_service/response_handler.dart';
import '../../../utils/common_widget.dart';
import '../../../utils/loading_overlay.dart';
import '../../homepage/view/homepage.dart';

class LoginController extends GetxController {
  final mobileTFC = TextEditingController();
  final otpTFC = TextEditingController();
  final formKeyMobile = GlobalKey<FormState>();
  final formKeyOTP = GlobalKey<FormState>();

  Future<void> validateAndSubmit() async {
    if (formKeyMobile.currentState!.validate()) {
      FocusManager.instance.primaryFocus?.unfocus();
      await generateOTP();
    }
  }

  Future<void> verifyOTPSubmit() async {
    if (formKeyOTP.currentState!.validate()) {
      FocusManager.instance.primaryFocus?.unfocus();
      await verifyOTP();
    }
  }

  Future<void> generateOTP() async {
    try {
      showGlobalLoader();
      final url = EndPoints.generateOTP;
      final data = {"mobileNumber": mobileTFC.text};
      final res = await DioClient().post(url, data);
      hideGlobalLoader();

      if (res is DioResponse) {
        if (res.data["code"] == 1) {
          HiveService.instance.save(jsonEncode(res.data), HiveService.loginKey);
          Get.to(() => OTPVerificationScreen());
          return;
        }
      } else if (res is DioResponse) {
        CommonWidget.showToast(res.toString());
      }
      throw Exception(StringConstant.internalErrorExceptionMessage);
    } catch (e) {
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }

  Future<void> verifyOTP() async {
    try {
      showGlobalLoader();
      final url = EndPoints.verifyOTP;
      final data = {"mobileNumber": mobileTFC.text, "otp": otpTFC.text};
      final res = await DioClient().post(url, data);
      hideGlobalLoader();
      final verifyOTP = jsonToObject(res, VerifyOtpModel.fromJson);
      if (verifyOTP?.code == 1) {
        saveTokenLocalStorage(verifyOTP);
        HiveService.instance.save(true, HiveService.isUserLoggedIn);
        Get.offAll(Homepage());
        return;
      } else if (verifyOTP?.code == 5) {
        saveTokenLocalStorage(verifyOTP);
        Get.to(() => RegisterScreen());
        return;
      }
      CommonWidget.showToast(
        verifyOTP?.message ?? StringConstant.internalErrorExceptionMessage,
      );
    } catch (e) {
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }

  void saveTokenLocalStorage(VerifyOtpModel? verifyOTP) {
    HiveService.instance.save(
      verifyOTP?.data?.accessToken ?? '',
      HiveService.loginToken,
    );
    HiveService.instance.save(
      verifyOTP?.data?.refreshToken ?? '',
      HiveService.refreshToken,
    );
    debugPrint(HiveService.instance.getString(HiveService.loginKey));
  }

  @override
  void onClose() {
    mobileTFC.dispose();
    super.onClose();
  }
}
