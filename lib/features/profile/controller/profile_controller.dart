import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../servies/api_service/dio_client.dart';
import '../../../servies/api_service/end_points.dart';
import '../../../servies/api_service/response_handler.dart';
import '../../../utils/common_widget.dart';
import '../../../utils/constant/string_constants.dart';
import '../../../utils/loading_overlay.dart';
import '../model/profile_model.dart';

class ProfileController extends GetxController {
  Rx<ProfileModel?> profileModel = Rx<ProfileModel?>(null);
  var isEditing = false.obs;

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final dobController = TextEditingController();
  var selectedGender = ''.obs;

  @override
  void onInit() {
    super.onInit();
    getProfile();
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    dobController.dispose();
    super.onClose();
  }

  void enterEditMode() {
    final data = profileModel.value?.data;
    firstNameController.text = data?.firstName ?? '';
    lastNameController.text = data?.lastName ?? '';
    emailController.text = data?.email ?? '';
    dobController.text = _formatDobForEdit(data?.dateOfBirth ?? '');
    selectedGender.value = data?.gender ?? '';
    isEditing.value = true;
  }

  void cancelEdit() {
    isEditing.value = false;
  }

  String _formatDobForEdit(String dob) {
    if (dob.isEmpty) return '';
    try {
      final date = DateTime.parse(dob);
      return DateFormat('dd-MM-yyyy').format(date);
    } catch (_) {
      return dob;
    }
  }

  String _formatDobForApi(String dob) {
    if (dob.isEmpty) return '';
    try {
      final date = DateFormat('dd-MM-yyyy').parse(dob);
      return DateFormat('yyyy-MM-dd').format(date);
    } catch (_) {
      return dob;
    }
  }

  String get fullName {
    final data = profileModel.value?.data;
    final first = data?.firstName ?? '';
    final last = data?.lastName ?? '';
    if (first.isEmpty && last.isEmpty) return 'User';
    return '$first $last'.trim();
  }

  String get memberSince {
    return profileModel.value?.data?.memberSince ?? '';
  }

  String get mobileNumber {
    return profileModel.value?.data?.mobileNumber ?? '';
  }

  int get age {
    final dob = profileModel.value?.data?.dateOfBirth;
    if (dob == null || dob.isEmpty) return 0;
    try {
      final birthDate = DateTime.parse(dob);
      final now = DateTime.now();
      int age = now.year - birthDate.year;
      if (now.month < birthDate.month ||
          (now.month == birthDate.month && now.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (_) {
      return 0;
    }
  }

  String get displayDob {
    final dob = profileModel.value?.data?.dateOfBirth;
    if (dob == null || dob.isEmpty) return '';
    try {
      final date = DateTime.parse(dob);
      return DateFormat('MMMM d, yyyy').format(date);
    } catch (_) {
      return dob;
    }
  }

  Future<void> getProfile() async {
    try {
      showGlobalLoader();
      final url = EndPoints.getProfile;
      final res = await DioClient().get(url);
      hideGlobalLoader();
      profileModel.value = jsonToObject(res, ProfileModel.fromJson);
      if (profileModel.value?.code != 1) {
        CommonWidget.showToast(
          profileModel.value?.message ??
              StringConstant.internalErrorExceptionMessage,
        );
      }
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }

  Future<void> updateProfile() async {
    if (firstNameController.text.trim().isEmpty ||
        lastNameController.text.trim().isEmpty) {
      CommonWidget.showToast("Please enter your name");
      return;
    }
    if (selectedGender.value.isEmpty) {
      CommonWidget.showToast("Please select gender");
      return;
    }
    if (dobController.text.trim().isEmpty) {
      CommonWidget.showToast("Please select date of birth");
      return;
    }
    if (emailController.text.trim().isEmpty) {
      CommonWidget.showToast("Please enter email");
      return;
    }

    try {
      showGlobalLoader();
      final data = {
        "firstName": firstNameController.text.trim(),
        "lastName": lastNameController.text.trim(),
        "gender": selectedGender.value,
        "dateOfBirth": _formatDobForApi(dobController.text),
        "email": emailController.text.trim(),
      };
      final url = EndPoints.updateProfile;
      final res = await DioClient().post(url, data);
      hideGlobalLoader();

      if (res is DioResponse) {
        final responseData = res.data as Map<String, dynamic>;
        final code = responseData['code'];
        final message = responseData['message'];

        if (code == 1) {
          CommonWidget.showToast(message ?? "Profile updated successfully");
          isEditing.value = false;
          await getProfile();
          return;
        }
        CommonWidget.showToast(
          message ?? StringConstant.internalErrorExceptionMessage,
        );
      }
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }
}
