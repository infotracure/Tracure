import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tracure/servies/app_permission.dart';
import 'package:tracure/servies/health_service.dart';
import 'package:tracure/servies/sleep_service.dart';

var startTime = '22:00';
var endTime = '07:00';

class HomeController extends GetxController {
  var todayStep = "".obs;
  var todayCalories = "".obs;
  var todaySleep = "".obs;

  @override
  void onInit() async {
    super.onInit();
    
    todayStep.value = (await printTodaySteps()).toString();
    todaySleep.value = await getTotalDuration();
    await startSleepTracking();
    scheduleSleep();
    
  }

  void setStepValue() async {
    todayStep.value = (await printTodaySteps()).toString();
  }

  void setSleepValue() async {
      todaySleep.value = await getTotalDuration();
  }

  Future<void> scheduleSleep() async {
    await SleepService.scheduleSleepTracking();
  }

  Future<void> startSleepTracking() async {
    await SleepService.startTracking(
      lSStartTime: startTime,
      lSEndTime: endTime,
      lSHardStopTime: '10:00',
      sleepInterval: 1800,
    );
  }

  Future<String> getTotalDuration() async {
    final fetchDate = getDateToFetchSleep();
    final date = DateFormat('yyyy-MM-dd').format(fetchDate);
    var sessions = await SleepService.getSleepDataForDate(date);

    final format = DateFormat("yyyy-MM-dd HH:mm:ss");
    Duration totalDuration = Duration();

    for (var session in sessions) {
      try {
        final rawStart = session['startTime']!.replaceAll(' ', '');
        final rawEnd = session['endTime']!.replaceAll(' ', '');

        final start = format.parse(
          rawStart.replaceFirstMapped(
            RegExp(r'^(\d{4}-\d{2}-\d{2})(\d{2}:\d{2}:\d{2})$'),
            (m) => '${m[1]} ${m[2]}',
          ),
        );

        final end = format.parse(
          rawEnd.replaceFirstMapped(
            RegExp(r'^(\d{4}-\d{2}-\d{2})(\d{2}:\d{2}:\d{2})$'),
            (m) => '${m[1]} ${m[2]}',
          ),
        );

        totalDuration += end.difference(start);
      } catch (e) {
        print('Error parsing times: $e');
      }
    }

    final hours = totalDuration.inHours;
    final minutes = totalDuration.inMinutes.remainder(60);
    return "${hours}h ${minutes}min";
  }

  DateTime getDateToFetchSleep() {
    final now = DateTime.now();
    final boundaryTime = DateTime(
      now.year,
      now.month,
      now.day,
      22,
    ); // today at 22:00

    if (now.isBefore(boundaryTime)) {
      return now.subtract(const Duration(days: 1)); // return yesterday
    } else {
      return now; // return today
    }
  }
}
