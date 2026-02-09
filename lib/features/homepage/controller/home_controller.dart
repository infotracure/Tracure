import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:health/health.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';
import 'package:tracure/features/homepage/model/feature_mapper_model.dart';
import 'package:tracure/features/homepage/model/gym_check_in_model.dart';
import 'package:tracure/features/homepage/model/sync_status_model.dart';
import 'package:tracure/features/loginpage/model/user_config_model.dart';
import 'package:tracure/servies/app_permission.dart';
import 'package:tracure/servies/health_service.dart';
import 'package:tracure/servies/sleep_service.dart';
import 'package:tracure/utils/common_methods.dart';
import 'package:uuid/uuid.dart';

import '../../../servies/api_service/dio_client.dart';
import '../../../servies/api_service/end_points.dart';
import '../../../servies/api_service/response_handler.dart';
import '../../../servies/hive_service.dart';
import '../../../utils/common_widget.dart';
import '../../../utils/constant/string_constants.dart';
import '../../../utils/loading_overlay.dart';
import '../../loginpage/model/verify_otp_model.dart';
import '../model/dashboard_activity_model.dart';

var startTime = '22:00';
var endTime = '07:00';

class HomeController extends GetxController {
  final GlobalKey<ScaffoldState> mainScaffoldKey = GlobalKey<ScaffoldState>();

  var todayStep = "".obs;
  var todayCalories = "".obs;
  var todaySleep = "".obs;
  FeatureMapperModel? featureMapperModel;
  Rx<SyncStatusModel?>? syncStatusModel = Rx<SyncStatusModel?>(null);
  Rx<GymCheckInModel?>? gymCheckInModel = Rx<GymCheckInModel?>(null);
  Rx<DashboardActivityModel?>? dashboardActivityModel =
      Rx<DashboardActivityModel?>(null);

  @override
  void onInit() async {
    super.onInit();
    await getUserSyncStatus();
    todayStep.value = (await printTodaySteps()).toString();
    todaySleep.value = await getTotalDuration();
    // await startSleepTracking();
    await scheduleSleep();
    await getDashboardData();
    checkForLastStepPushedData(silent: true);
    checkForLastSleepPushedData(silent: true);
    // await getUserConfiguration();
    await getFeatureList();
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    final dateFormat = DateFormat('yyyy-MM-dd');
    await getGymCheckIn(
      startDate: dateFormat.format(weekStart),
      endDate: dateFormat.format(weekEnd),
    );
  }

  void setStepValue() async {
    todayStep.value = (await printTodaySteps()).toString();
  }

  void setSleepValue() async {
    todaySleep.value = await getTotalDuration();
  }

  /// Called when returning to Homepage from another page
  Future<void> refreshOnReturn() async {
    setStepValue();
    setSleepValue();
    await getDashboardData(silent: true);
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

    // If no sessions found, trigger inference and retry
    if (sessions.isEmpty) {
      await SleepService.runInferenceNow();
      // Give inference a moment to complete
      await Future.delayed(const Duration(seconds: 2));
      sessions = await SleepService.getSleepDataForDate(date);
    }

    var convertedSessions = convertSleepRawToObject(sessions);
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
      // checkForLastPushedData(userConfig);
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }

  Future<void> getUserSyncStatus() async {
    try {
      showGlobalLoader();
      final url = EndPoints.syncStatus;
      final res = await DioClient().get(url);
      hideGlobalLoader();
      syncStatusModel?.value = jsonToObject(res, SyncStatusModel.fromJson);
      if (syncStatusModel?.value?.code != 1) {
        CommonWidget.showToast(
          syncStatusModel?.value?.message ??
              StringConstant.internalErrorExceptionMessage,
        );
        return;
      }
      checkForLastStepPushedData();
      checkForLastSleepPushedData();
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }

  Future<void> getDashboardData({bool silent = false}) async {
    try {
      if (!silent) showGlobalLoader();
      final url = EndPoints.dashboard;
      final arg = {"date": DateFormat('yyyy-MM-dd').format(DateTime.now())};
      final res = await DioClient().get(url, queryParam: arg);
      if (!silent) hideGlobalLoader();
      dashboardActivityModel?.value = jsonToObject(
        res,
        DashboardActivityModel.fromJson,
      );
      if (dashboardActivityModel?.value?.code != 1) {
        CommonWidget.showToast(
          dashboardActivityModel?.value?.message ??
              StringConstant.internalErrorExceptionMessage,
        );
        return;
      }
      // checkForLastStepPushedData(silent: silent);
      // checkForLastSleepPushedData(silent: silent);
    } catch (e) {
      if (!silent) {
        hideGlobalLoader();
        CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
      }
    }
  }

  Future<void> getGymCheckIn({String? startDate, String? endDate}) async {
    try {
      showGlobalLoader();
      final param = {"startDate": startDate, "endDate": endDate};
      final url = EndPoints.gymCheckIn;
      final res = await DioClient().get(url, queryParam: param);
      hideGlobalLoader();
      gymCheckInModel?.value = jsonToObject(res, GymCheckInModel.fromJson);
      if (gymCheckInModel?.value?.code != 1) {
        CommonWidget.showToast(
          gymCheckInModel?.value?.message ??
              StringConstant.internalErrorExceptionMessage,
        );
        return;
      }
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }

  Future<void> setGymCheckIn({String? date}) async {
    try {
      showGlobalLoader();
      final param = {"checkinDate": date, "checkedIn": true, "notes": ""};
      final url = EndPoints.gymCheckInInsert;
      final res = await DioClient().post(url, param);
      hideGlobalLoader();

      if (res is DioResponse) {
        final responseData = res.data as Map<String, dynamic>;
        final code = responseData['code'];
        final innerData = responseData['data'] as Map<String, dynamic>?;
        final message = responseData['message'] ?? innerData?['Message'];

        if (code != 1) {
          CommonWidget.showToast(
            message ?? StringConstant.internalErrorExceptionMessage,
          );

          return;
        }
        final now = DateTime.now();
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6));
        final dateFormat = DateFormat('yyyy-MM-dd');
        await getGymCheckIn(
          startDate: dateFormat.format(weekStart),
          endDate: dateFormat.format(weekEnd),
        );
      }
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }

  Future<void> pushStepsData(
    List<HealthDataPoint> data, {
    bool silent = false,
  }) async {
    try {
      if (!silent) showGlobalLoader();
      final url = EndPoints.pushSteps;
      var jsonStepList = data.map((e) => _healthDataPointToJson(e)).toList();
      final param = {"steps": jsonStepList};

      final res = await DioClient().post(url, param);
      if (!silent) hideGlobalLoader();

      if (res is DioResponse) {
        final responseData = res.data as Map<String, dynamic>;
        final code = responseData['code'];
        final innerData = responseData['data'] as Map<String, dynamic>?;
        final dataCode = innerData?['Code'];
        final message = responseData['message'] ?? innerData?['Message'];

        if (code != 1 || dataCode != 200) {
          if (!silent) {
            CommonWidget.showToast(
              message ?? StringConstant.internalErrorExceptionMessage,
            );
          }
          return;
        }
        getDashboardData(silent: true);
      }
    } catch (e) {
      if (!silent) {
        hideGlobalLoader();
        CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
      } else {
        debugPrint('Silent push error: $e');
      }
    }
  }

  Future<void> pushSleepData(
    List<Map<String, dynamic>> data, {
    bool silent = false,
  }) async {
    try {
      if (!silent) showGlobalLoader();
      final url = EndPoints.sleepInsert;
      final param = {"sleep": data};
      log(param.toString());
      final res = await DioClient().post(url, param);
      if (!silent) hideGlobalLoader();

      if (res is DioResponse) {
        final responseData = res.data as Map<String, dynamic>;
        final code = responseData['code'];
        final innerData = responseData['data'] as Map<String, dynamic>?;
        final dataCode = innerData?['Code'];
        final message = responseData['message'] ?? innerData?['Message'];

        if (code != 1 || dataCode != 200) {
          if (!silent) {
            CommonWidget.showToast(
              message ?? StringConstant.internalErrorExceptionMessage,
            );
          }
          return;
        }
        getDashboardData(silent: true);
      }
    } catch (e) {
      if (!silent) {
        hideGlobalLoader();
        CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
      } else {
        debugPrint('Silent push error: $e');
      }
    }
  }

  Map<String, dynamic> _healthDataPointToJson(HealthDataPoint point) {
    // Get the base JSON from the health package
    final json = point.toJson();

    // Extract numeric value from HealthValue
    num value = 0;
    if (point.value is NumericHealthValue) {
      value = (point.value as NumericHealthValue).numericValue;
    }

    // Override the value field with numeric value
    json['value'] = value.toInt();

    return json;
  }

  Future<void> checkForLastStepPushedData({bool silent = false}) async {
    final lastSyncTime = syncStatusModel?.value?.data?.steps?.lastSyncTime;
    if (lastSyncTime == null) return;

    var data = await HealthDataService().getStepsDataFrom(lastSyncTime);
    if (data.isNotEmpty) {
      await pushStepsData(data, silent: silent);
    }
  }

  Future<void> checkForLastSleepPushedData({bool silent = false}) async {
    final lastSyncTime = syncStatusModel?.value?.data?.sleep?.lastSyncTime;
    if (lastSyncTime == null /*|| isToday(lastSyncTime)*/ ) return;

    final fetchDate = getDateToFetchSleep();
    final date = DateFormat('yyyy-MM-dd').format(fetchDate);
    var sessions = await SleepService.getSleepDataForDate(date);
    print("SleepService.getSleepDataForDate");
    var convertedSessions = await convertSleepRawToObject(sessions);
    print("SleepService.getSleepDataForDate : $convertedSessions");
    if (convertedSessions.isNotEmpty) {
      await pushSleepData(convertedSessions, silent: silent);
    }
  }

  Future<List<Map<String, dynamic>>> convertSleepRawToObject(
    List<Map<String, dynamic>> sessions,
  ) async {
    List<Map<String, dynamic>> convertedSessions = [];
    for (var data in sessions) {
      final startTime = data['startTime']?.toString();
      final endTime = data['endTime']?.toString();
      final sleepDate = data['date']?.toString();

      if (startTime == null || endTime == null || sleepDate == null) continue;

      final startDateTime = DateTime.parse(startTime);
      final endDateTime = DateTime.parse(endTime);
      final sleepDateTime = DateTime.parse(sleepDate);

      final startTimeFormatted = startDateTime.toIso8601String();
      final endTimeFormatted = endDateTime.toIso8601String();
      final sleepDateFormatted = sleepDateTime.toIso8601String();

      var rawValue = {
        "uuid": generateSleepRecordId(startTimeFormatted),
        "sleepDate": sleepDateFormatted,
        "startTime": startTimeFormatted,
        "endTime": endTimeFormatted,
        "sleepStage": "DEEP",
        "platform": Platform.isIOS ? "iOS" : "Android",
        "deviceId": await getOrCreateDeviceId(),
        "sourceId": Platform.isIOS ? "apple-health" : "health-connect",
        "sourceName": Platform.isIOS ? "Apple Health" : "Health Connect",
        "metadata": null,
      };
      convertedSessions.add(rawValue);
    }
    return convertedSessions;
  }

  String generateSleepRecordId(String startTime) {
    final bytes = utf8.encode(startTime);
    final hash = sha1.convert(bytes).toString().substring(0, 8);
    return 'sleep-record-$hash';
  }
}
