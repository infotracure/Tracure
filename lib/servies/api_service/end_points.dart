//base url
class EndPoints {
  static const String baseUrl = "https://api.tracure.in";

  // receiveTimeout
  static const int receiveTimeout = 15000;

  // connectTimeout
  static const int connectionTimeout = 15000;

  static const String generateOTP = "$baseUrl/auth/sendotp";
  static const String verifyOTP = "$baseUrl/auth/verifyotp";
  static const String refreshToken = "$baseUrl/auth/refreshtoken";
  static const String registerUser = "$baseUrl/user/register";
  static const String featureListing = "$baseUrl/feature/featurelisting";
  static const String userConfiguration = "$baseUrl/user/configuration";
  static const String pushSteps = "$baseUrl/steps";
  static const String stepsbydate = "$baseUrl/stepsbydate";
  static const String stepssummarybydate = "$baseUrl/steps/stepssummarybydate";
  static const String stepsaverage = "$baseUrl/stepsaverage";
  static const String stepsetting = "$baseUrl/stepsetting";
}
