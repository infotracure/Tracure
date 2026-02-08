import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tracure/features/homepage/controller/home_controller.dart';
import 'package:tracure/features/water_intake/model/water_stats_model.dart';
import 'package:tracure/features/water_intake/model/water_summary_by_range.dart';

import '../../../servies/api_service/dio_client.dart';
import '../../../servies/api_service/end_points.dart';
import '../../../servies/api_service/response_handler.dart';
import '../../../utils/common_methods.dart';
import '../../../utils/common_widget.dart';
import '../../../utils/constant/string_constants.dart';
import '../../../utils/loading_overlay.dart';
import '../model/blood_pressuer_goal_model.dart';
import '../model/blood_pressure_stats_model.dart';
import '../model/blood_pressure_summary_model.dart';
import '../model/blood_pressure_trend_model.dart';

class BloodPressureController extends GetxController {
  // Add your methods and properties here
  Rx<BloodPressureSummaryModel?> bloodPressureSummary =
      Rx<BloodPressureSummaryModel?>(null);
  Rx<BloodPressureTrendModel?> bloodPressureTrend =
      Rx<BloodPressureTrendModel?>(null);
  Rx<BloodPressureStatsModel?> bloodPressureStats =
      Rx<BloodPressureStatsModel?>(null);
  Rx<BloodPressureGoalModel?> bloodPressureGoal = Rx<BloodPressureGoalModel?>(
    null,
  );
  Rx<BloodPressureTrendModel?> monthlyBloodPressureSummary =
      Rx<BloodPressureTrendModel?>(null);
  Rx<BloodPressureTrendModel?> weeklyBloodPressureSummary =
      Rx<BloodPressureTrendModel?>(null);

  @override
  void onInit() {
    super.onInit();
    callBloodPressureApis();
  }

  Future<Map<String, Object>> convertToBloodPressureJson({
    required int systolic,
    required int diastolic,
    required int pulse,
  }) async {
    return {
      "uuid": generateBloodPressureRecordId(DateTime.now().toIso8601String()),
      "measurementTime": DateTime.now().toIso8601String(),
      "systolic": systolic,
      "diastolic": diastolic,
      "pulse": pulse,
      "platform": Platform.isIOS ? "ios" : "android",
      "deviceId": await getOrCreateDeviceId(),
      "sourceId": "app",
      "sourceName": "Tracure",
    };
  }

  String generateBloodPressureRecordId(String startTime) {
    final bytes = utf8.encode(startTime);
    final hash = sha1.convert(bytes).toString().substring(0, 8);
    return 'bp-$hash';
  }

  Future<void> callBloodPressureApis() async {
    var todayFormatted = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await getBloodPressureSummaryByDate(todayFormatted);
    await getBloodPressureTrendByDate(todayFormatted);
    // Calculate current week's start (Monday) and end (Sunday)
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    final dateFormat = DateFormat('yyyy-MM-dd');
    await getBloodPressureStatsByDate(
      dateFormat.format(weekStart),
      dateFormat.format(weekEnd),
    );
  }

  Future<void> getBloodPressureSummaryByDate(String date) async {
    try {
      showGlobalLoader();

      final param = {"date": date};
      final url = EndPoints.bloodPressureSummry;
      final res = await DioClient().get(url, queryParam: param);
      hideGlobalLoader();
      bloodPressureSummary.value = jsonToObject(
        res,
        BloodPressureSummaryModel.fromJson,
      );
      if (bloodPressureSummary.value?.code != 1) {
        CommonWidget.showToast(
          bloodPressureSummary.value?.message ??
              StringConstant.internalErrorExceptionMessage,
        );
        return;
      }
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }

  Future<void> getBloodPressureTrendByDate(String date) async {
    try {
      showGlobalLoader();
      final param = {"startDate": date, "endDate": date};
      final url = EndPoints.bloodPressureTrend;
      final res = await DioClient().get(url, queryParam: param);
      hideGlobalLoader();
      bloodPressureTrend.value = jsonToObject(
        res,
        BloodPressureTrendModel.fromJson,
      );
      if (bloodPressureTrend.value?.code != 1) {
        CommonWidget.showToast(
          bloodPressureTrend.value?.message ??
              StringConstant.internalErrorExceptionMessage,
        );
        return;
      }
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }

  Future<void> getBloodPressureStatsByDate(
    String startDate,
    String endDate,
  ) async {
    try {
      showGlobalLoader();
      final param = {"startDate": startDate, "endDate": endDate};
      final url = EndPoints.bloodPressureStats;
      final res = await DioClient().get(url, queryParam: param);
      hideGlobalLoader();
      bloodPressureStats.value = jsonToObject(
        res,
        BloodPressureStatsModel.fromJson,
      );
      if (bloodPressureStats.value?.code != 1) {
        CommonWidget.showToast(
          bloodPressureStats.value?.message ??
              StringConstant.internalErrorExceptionMessage,
        );
        return;
      }
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }

  // Future<void> getBloodPressureSummaryByRange(String startDate, String endDate) async {
  //   try {
  //     showGlobalLoader();
  //     final param = {"startDate": startDate, "endDate": endDate};
  //     final url = EndPoints.waterSummaryByRange;
  //     final res = await DioClient().get(url, queryParam: param);
  //     hideGlobalLoader();
  //     monthlyWaterSummary.value = jsonToObject(
  //       res,
  //       WaterSummaryByRangeModel.fromJson,
  //     );
  //     if (monthlyWaterSummary.value?.code != 1) {
  //       CommonWidget.showToast(
  //         monthlyWaterSummary.value?.message ??
  //             StringConstant.internalErrorExceptionMessage,
  //       );
  //       return;
  //     }
  //   } catch (e) {
  //     hideGlobalLoader();
  //     CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
  //   }
  // }

  Future<void> getMonthlyBloodPressureSummary(DateTime month) async {
    try {
      showGlobalLoader();

      // Calculate first and last day of the month
      final firstDay = DateTime(month.year, month.month, 1);
      final lastDay = DateTime(month.year, month.month + 1, 0);
      final dateFormat = DateFormat('yyyy-MM-dd');

      final param = {
        "startDate": dateFormat.format(firstDay),
        "endDate": dateFormat.format(lastDay),
      };
      final url = EndPoints.bloodPressureTrend;
      final res = await DioClient().get(url, queryParam: param);
      hideGlobalLoader();
      monthlyBloodPressureSummary.value = jsonToObject(
        res,
        BloodPressureTrendModel.fromJson,
      );
      if (monthlyBloodPressureSummary.value?.code != 1) {
        CommonWidget.showToast(
          monthlyBloodPressureSummary.value?.message ??
              StringConstant.internalErrorExceptionMessage,
        );
        return;
      }
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }

  Future<void> getWeeklyBloodPressureSummary(
    String startDate,
    String endDate,
  ) async {
    try {
      showGlobalLoader();

      final param = {"startDate": startDate, "endDate": endDate};
      final url = EndPoints.bloodPressureTrend;
      final res = await DioClient().get(url, queryParam: param);
      hideGlobalLoader();
      weeklyBloodPressureSummary.value = jsonToObject(
        res,
        BloodPressureTrendModel.fromJson,
      );
      if (weeklyBloodPressureSummary.value?.code != 1) {
        CommonWidget.showToast(
          weeklyBloodPressureSummary.value?.message ??
              StringConstant.internalErrorExceptionMessage,
        );
        return;
      }
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }

  Future<void> getBloodPressureGoal() async {
    try {
      showGlobalLoader();
      final url = EndPoints.bloodPressureGoals;
      final res = await DioClient().get(url);
      hideGlobalLoader();
      bloodPressureGoal.value = jsonToObject(
        res,
        BloodPressureGoalModel.fromJson,
      );
      if (bloodPressureGoal.value?.code != 1) {
        CommonWidget.showToast(
          bloodPressureGoal.value?.message ??
              StringConstant.internalErrorExceptionMessage,
        );
        return;
      }
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }

  Future<void> setBloodPressureGoal({
    int? targetSystolic,
    int? targetDiastolic,
    int? reminderIntervalMinutes,
  }) async {
    try {
      showGlobalLoader();
      final url = EndPoints.bloodPressureGoals;
      final res = await DioClient().post(url, {
        "targetSystolicMin": 90,
        "targetSystolicMax": targetSystolic,
        "targetDiastolicMin": 60,
        "targetDiastolicMax": targetDiastolic,
        "reminderIntervalMinutes": reminderIntervalMinutes,
      });
      hideGlobalLoader();
      bloodPressureGoal.value = jsonToObject(
        res,
        BloodPressureGoalModel.fromJson,
      );
      if (bloodPressureGoal.value?.code != 1) {
        CommonWidget.showToast(
          bloodPressureGoal.value?.message ??
              StringConstant.internalErrorExceptionMessage,
        );
        return;
      }
      CommonWidget.showToast("Goal updated successfully");
      var todayFormatted = DateFormat('yyyy-MM-dd').format(DateTime.now());
      getBloodPressureSummaryByDate(todayFormatted);
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }

  Future<void> addBloodPressure({
    List<Map<String, dynamic>>? bloodPressureData,
  }) async {
    try {
      showGlobalLoader();
      final url = EndPoints.bloodPressureInsert;
      final res = await DioClient().post(url, {
        "bloodPressure": bloodPressureData,
      });
      hideGlobalLoader();
      bloodPressureGoal.value = jsonToObject(
        res,
        BloodPressureGoalModel.fromJson,
      );
      if (bloodPressureGoal.value?.code != 1) {
        CommonWidget.showToast(
          bloodPressureGoal.value?.message ??
              StringConstant.internalErrorExceptionMessage,
        );
        return;
      }
      await callBloodPressureApis();
      Get.find<HomeController>().getDashboardData(silent: true);
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }
}
