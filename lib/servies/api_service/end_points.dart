//base url
class EndPoints {
  static const String baseUrl = "https://api.tracure.in";

  // receiveTimeout
  static const int receiveTimeout = 15000;
  // connectTimeout
  static const int connectionTimeout = 15000;
  //* Auth Endpoints */
  static const String generateOTP = "$baseUrl/auth/sendotp";
  static const String verifyOTP = "$baseUrl/auth/verifyotp";
  static const String refreshToken = "$baseUrl/auth/refreshtoken";
  static const String registerUser = "$baseUrl/user/register";
  static const String featureListing = "$baseUrl/feature/featurelisting";
  static const String userConfiguration = "$baseUrl/user/configuration";
  static const String syncStatus = "$baseUrl/configuration/sync-status";
  //* Step Tracker Endpoints */
  static const String pushSteps = "$baseUrl/steps";
  static const String stepsbydate = "$baseUrl/steps/stepsbydate";
  static const String stepsSummarybydate = "$baseUrl/steps/stepssummarybydate";
  static const String stepsSummarybyRange =
      "$baseUrl/steps/stepssummarybyrange";
  static const String stepsaverage = "$baseUrl/steps/stepsaverage";
  static const String stepsetting = "$baseUrl/steps/stepsetting";
  //* Sleep Tracker Endpoints */
  static const String sleepInsert = "$baseUrl/sleep";
  static const String sleepSummary = "$baseUrl/sleep/summary";
  static const String sleepTrend = "$baseUrl/sleep/trend";
  static const String sleepStats = "$baseUrl/sleep/stats";
  static const String sleepSummaryByRange = "$baseUrl/sleep/summarybyrange";
  static const String sleepGoals = "$baseUrl/sleep/goals";
  //* Water Intake Endpoints */
  static const String waterSummary = "$baseUrl/water/summary";
  static const String waterInsert = "$baseUrl/water";
  static const String waterTrend = "$baseUrl/water/trend";
  static const String waterStats = "$baseUrl/water/stats";
  static const String waterGoals = "$baseUrl/water/goals";
  static const String waterSummaryByRange = "$baseUrl/water/summarybyrange";
  //* Gym Chek-in Endpoints */
  static const String gymCheckIn = "$baseUrl/gym/checkins";
  static const String gymCheckInInsert = "$baseUrl/gym/checkin";
}
