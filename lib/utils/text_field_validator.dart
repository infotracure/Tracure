class TextfieldValidator {
  static String? validateMobile(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter mobile number";
    }
    if (value.length < 10) {
      return "Please enter a valid mobile number";
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter email address";
    }

    // Simple email regex
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegex.hasMatch(value)) {
      return "Please enter a valid email address";
    }

    return null;
  }

  static String? validateOTP(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter OTP";
    }
    if (value.length < 6) {
      return "Please enter a valid OTP";
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter name";
    }
    return null;
  }

  static String? validateGender(String? value) {
    if (value == null || value.isEmpty) {
      return "Please select gender";
    }
    return null;
  }

  static String? validateDob(String? value) {
    if (value == null || value.isEmpty) {
      return "Please select date of birth";
    }
    return null;
  }
}
