import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:tracure/features/homepage/view/main_navigation.dart';

import '../../../servies/api_service/dio_client.dart';
import '../../../servies/api_service/end_points.dart';
import '../../../servies/api_service/response_handler.dart';
import '../../../servies/hive_service.dart';
import '../../../utils/common_widget.dart';
import '../../../utils/constant/string_constants.dart';
import '../../../utils/loading_overlay.dart';

class RegisterController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final fnameController = TextEditingController();
  final lnameController = TextEditingController();
  final emailController = TextEditingController();
  final dobController = TextEditingController();
  final otpTFC = TextEditingController();
  var gender = ''.obs;

  Future<void> registerUser() async {
    try {
      showGlobalLoader();
      final url = EndPoints.registerUser;
      final data = {
        "firstName": fnameController.text,
        "lastName": lnameController.text,
        "gender": gender.value,
        "dateOfBirth": dobController.text,
        "email": emailController.text,
      };
      final res = await DioClient().post(url, data);
      hideGlobalLoader();
      if (res is DioResponse) {
        if (res.data["code"] == 1) {
          HiveService.instance.save(true, HiveService.isUserLoggedIn);
          Get.offAll(() => MainNavigation());
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

  void validateAndSubmit() {
    if (fnameController.text.isEmpty || lnameController.text.isEmpty) {
      CommonWidget.showToast("Please enter name");
      return;
    }
    if (gender.value.isEmpty) {
      CommonWidget.showToast("Please select gender");
      return;
    }
    if (dobController.text.isEmpty) {
      CommonWidget.showToast("Please select date of birth");
      return;
    }
    if (emailController.text.isEmpty) {
      CommonWidget.showToast("Please enter email");
      return;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(emailController.text)) {
      CommonWidget.showToast("Please enter a valid email address");
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    registerUser();
  }
}
