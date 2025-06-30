import 'package:get/get.dart';
import 'package:tracure/servies/health_service.dart';
import 'package:tracure/servies/sleep_service.dart';

class HomeController extends GetxController {
  var todayStep = "".obs;
  var todayCalories = "".obs;
  var todaySleep = "".obs;
  @override
  void onInit() async {
    super.onInit();
    await PermissionManager.requestActivityPermission();
    todayStep.value = (await printTodaySteps()).toString();
    await startSleepTracking();
    await getSleepData();
  }

  Future<void> getSleepData() async {
    await SleepService.scheduleSleepTracking();
  }

  Future<void> startSleepTracking() async {
    await SleepService.startTracking(
      lSStartTime: '09:00',
      lSEndTime: '07:00',
      lSHardStopTime: '10:00',
      sleepInterval: 60,
      sleepDate: '2025-06-26',
    );
  }
}
