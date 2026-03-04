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
  static const String dashboard = "$baseUrl/dashboard";
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
  //* Blood Pressure Endpoints */
  static const String bloodPressureSummry = "$baseUrl/blood-pressure/summary";
  static const String bloodPressureInsert = "$baseUrl/blood-pressure";
  static const String bloodPressureGoals = "$baseUrl/blood-pressure/goals";
  static const String bloodPressureTrend = "$baseUrl/blood-pressure/trend";
  static const String bloodPressureStats = "$baseUrl/blood-pressure/stats"; 
  static const String bloodPressureReadings = "$baseUrl/blood-pressure/readings"; 
  //* Blood Sugar Endpoints */
  static const String bloodSugarSummry = "$baseUrl/blood-sugar/summary";
  static const String bloodSugarInsert = "$baseUrl/blood-sugar";
  static const String bloodSugarGoals = "$baseUrl/blood-sugar/goals";
  static const String bloodSugarTrend = "$baseUrl/blood-sugar/trend";
  static const String bloodSugarStats = "$baseUrl/blood-sugar/stats";
  static const String bloodSugarReadings = "$baseUrl/blood-sugar/readings";
  //* Profile Endpoints */
  static const String getProfile = "$baseUrl/user/profile";
  static const String updateProfile = "$baseUrl/user/profile";
}
