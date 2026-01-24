import 'package:get/get.dart';
import 'package:health/health.dart';
import 'package:intl/intl.dart';
import 'package:tracure/features/homepage/model/feature_mapper_model.dart';
import 'package:tracure/features/loginpage/model/user_config_model.dart';
import 'package:tracure/servies/app_permission.dart';
import 'package:tracure/servies/health_service.dart';
import 'package:tracure/servies/sleep_service.dart';

import '../../../servies/api_service/dio_client.dart';
import '../../../servies/api_service/end_points.dart';
import '../../../servies/api_service/response_handler.dart';
import '../../../utils/common_widget.dart';
import '../../../utils/constant/string_constants.dart';
import '../../../utils/loading_overlay.dart';
import '../../loginpage/model/verify_otp_model.dart';

var startTime = '22:00';
var endTime = '07:00';

class HomeController extends GetxController {
  var todayStep = "".obs;
  var todayCalories = "".obs;
  var todaySleep = "".obs;
  FeatureMapperModel? featureMapperModel;

  @override
  void onInit() async {
    super.onInit();

    todayStep.value = (await printTodaySteps()).toString();
    todaySleep.value = await getTotalDuration();
    // await startSleepTracking();
    await scheduleSleep();
    await getUserConfiguration();
    await getFeatureList();
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

  Future<void> getFeatureList() async {
    try {
      showGlobalLoader();
      final url = EndPoints.featureListing;
      final res = await DioClient().get(url);
      hideGlobalLoader();
      final featureMapper = jsonToObject(res, FeatureMapperModel.fromJson);
      if (featureMapper?.code != 1) {
        CommonWidget.showToast(
          featureMapper?.message ??
              StringConstant.internalErrorExceptionMessage,
        );
        return;
      }
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }

  Future<void> getUserConfiguration() async {
    try {
      showGlobalLoader();
      final url = EndPoints.userConfiguration;
      final res = await DioClient().get(url);
      hideGlobalLoader();
      final userConfig = jsonToObject(res, UserConfigurationModel.fromJson);
      if (userConfig?.code != 1) {
        CommonWidget.showToast(
          userConfig?.message ?? StringConstant.internalErrorExceptionMessage,
        );
        return;
      }
      checkForLastPushedData(userConfig);
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }

  Future<void> pushStepsData(List<HealthDataPoint> data) async {
    try {
      showGlobalLoader();
      final url = EndPoints.pushSteps;
      var jsonStepList = data.map((e) => e.toJson()).toList();
      final param = {"steps": jsonStepList};

      final res = await DioClient().post(url, param);
      hideGlobalLoader();
      final userConfig = jsonToObject(res, UserConfigurationModel.fromJson);
      if (userConfig?.code != 1) {
        CommonWidget.showToast(
          userConfig?.message ?? StringConstant.internalErrorExceptionMessage,
        );
        return;
      }
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }

  void checkForLastPushedData(UserConfigurationModel? userConfig) async {
    if (userConfig?.data?.lastSyncTimeSteps?.isEmpty ?? true) return;

    HealthDataService().getStepsDataFrom(
      DateTime.now().subtract(Duration(days: 7)),
    );
  }
}
