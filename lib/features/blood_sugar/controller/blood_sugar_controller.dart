import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tracure/features/blood_sugar/model/blood_sugar_day_log.dart';
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
import '../model/blood_sugar_goal.dart';
import '../model/blood_sugar_stats.dart';
import '../model/blood_sugar_summary.dart';
import '../model/blood_sugar_trend.dart';

class BloodSugarController extends GetxController {
  // Add your methods and properties here
  Rx<BloodSugarSummaryModel?> bloodSugarSummary = Rx<BloodSugarSummaryModel?>(
    null,
  );
  Rx<BloodSugarDayLogModel?> bloodSugarTrend = Rx<BloodSugarDayLogModel?>(null);
  Rx<BloodSugarStatsModel?> bloodSugarStats = Rx<BloodSugarStatsModel?>(null);
  Rx<BloodSugarGoalModel?> bloodSugarGoal = Rx<BloodSugarGoalModel?>(null);
  Rx<BloodSugarTrendModel?> monthlyBloodSugarSummary =
      Rx<BloodSugarTrendModel?>(null);
  Rx<BloodSugarTrendModel?> weeklyBloodSugarSummary = Rx<BloodSugarTrendModel?>(
    null,
  );

  @override
  void onInit() {
    super.onInit();
    callBloodSugarApis();
  }

  Future<Map<String, Object>> convertToBloodSugarJson({
    required int value,
    required String measurementContext,
    required String notes,
  }) async {
    return {
      "uuid": generateBloodSugarRecordId(DateTime.now().toIso8601String()),
      "measurementTime": DateTime.now().toIso8601String(),
      "platform": Platform.isIOS ? "ios" : "android",
      "deviceId": await getOrCreateDeviceId(),
      "sourceId": "app",
      "sourceName": "Tracure",
      "value": value,
      "unit": "MGDL",
      "measurementContext": measurementContext,
      "notes": notes,
    };
  }

  String generateBloodSugarRecordId(String startTime) {
    final bytes = utf8.encode(startTime);
    final hash = sha1.convert(bytes).toString().substring(0, 8);
    return 'bs-$hash';
  }

  Future<void> callBloodSugarApis() async {
    var todayFormatted = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await getBloodSugarSummaryByDate(todayFormatted);
    await getBloodSugarTrendByDate(todayFormatted);
    // Calculate current week's start (Monday) and end (Sunday)
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    final dateFormat = DateFormat('yyyy-MM-dd');
    await getBloodSugarStatsByDate(
      dateFormat.format(weekStart),
      dateFormat.format(weekEnd),
    );
  }

  Future<void> getBloodSugarSummaryByDate(String date) async {
    try {
      showGlobalLoader();

      final param = {"date": date};
      final url = EndPoints.bloodSugarSummry;
      final res = await DioClient().get(url, queryParam: param);
      hideGlobalLoader();
      bloodSugarSummary.value = jsonToObject(
        res,
        BloodSugarSummaryModel.fromJson,
      );
      if (bloodSugarSummary.value?.code != 1) {
        CommonWidget.showToast(
          bloodSugarSummary.value?.message ??
              StringConstant.internalErrorExceptionMessage,
        );
        return;
      }
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }

  Future<void> getBloodSugarTrendByDate(String date) async {
    try {
      showGlobalLoader();
      final param = {"date": date};
      final url = EndPoints.bloodSugarReadings;
      final res = await DioClient().get(url, queryParam: param);
      hideGlobalLoader();
      bloodSugarTrend.value = jsonToObject(res, BloodSugarDayLogModel.fromJson);
      if (bloodSugarTrend.value?.code != 1) {
        CommonWidget.showToast(
          bloodSugarTrend.value?.message ??
              StringConstant.internalErrorExceptionMessage,
        );
        return;
      }
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }

  Future<void> getBloodSugarStatsByDate(
    String startDate,
    String endDate,
  ) async {
    try {
      showGlobalLoader();
      final param = {"startDate": startDate, "endDate": endDate};
      final url = EndPoints.bloodSugarStats;
      final res = await DioClient().get(url, queryParam: param);
      hideGlobalLoader();
      bloodSugarStats.value = jsonToObject(res, BloodSugarStatsModel.fromJson);
      if (bloodSugarStats.value?.code != 1) {
        CommonWidget.showToast(
          bloodSugarStats.value?.message ??
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

  Future<void> getMonthlyBloodSugarSummary(DateTime month) async {
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
      final url = EndPoints.bloodSugarTrend;
      final res = await DioClient().get(url, queryParam: param);
      hideGlobalLoader();
      monthlyBloodSugarSummary.value = jsonToObject(
        res,
        BloodSugarTrendModel.fromJson,
      );
      if (monthlyBloodSugarSummary.value?.code != 1) {
        CommonWidget.showToast(
          monthlyBloodSugarSummary.value?.message ??
              StringConstant.internalErrorExceptionMessage,
        );
        return;
      }
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }

  Future<void> getWeeklyBloodSugarSummary(
    String startDate,
    String endDate,
  ) async {
    try {
      showGlobalLoader();

      final param = {"startDate": startDate, "endDate": endDate};
      final url = EndPoints.bloodSugarTrend;
      final res = await DioClient().get(url, queryParam: param);
      hideGlobalLoader();
      weeklyBloodSugarSummary.value = jsonToObject(
        res,
        BloodSugarTrendModel.fromJson,
      );
      if (weeklyBloodSugarSummary.value?.code != 1) {
        CommonWidget.showToast(
          weeklyBloodSugarSummary.value?.message ??
              StringConstant.internalErrorExceptionMessage,
        );
        return;
      }
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }

  Future<void> getBloodSugarGoal() async {
    try {
      showGlobalLoader();
      final url = EndPoints.bloodSugarGoals;
      final res = await DioClient().get(url);
      hideGlobalLoader();
      bloodSugarGoal.value = jsonToObject(res, BloodSugarGoalModel.fromJson);
      if (bloodSugarGoal.value?.code != 1) {
        CommonWidget.showToast(
          bloodSugarGoal.value?.message ??
              StringConstant.internalErrorExceptionMessage,
        );
        return;
      }
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }

  Future<void> setBloodSugarGoal({
    int? targetSystolic,
    int? targetDiastolic,
    int? reminderIntervalMinutes,
  }) async {
    try {
      showGlobalLoader();
      final url = EndPoints.bloodSugarGoals;
      final res = await DioClient().post(url, {
        "fastingMin": 70,
        "fastingMax": 100,
        "beforeMealMin": 70,
        "beforeMealMax": 130,
        "afterMealMin": 70,
        "afterMealMax": 180,
        "bedtimeMin": 90,
        "bedtimeMax": 150,
        "reminderIntervalMinutes": 240,
      });
      hideGlobalLoader();
      bloodSugarGoal.value = jsonToObject(res, BloodSugarGoalModel.fromJson);
      if (bloodSugarGoal.value?.code != 1) {
        CommonWidget.showToast(
          bloodSugarGoal.value?.message ??
              StringConstant.internalErrorExceptionMessage,
        );
        return;
      }
      CommonWidget.showToast("Goal updated successfully");
      var todayFormatted = DateFormat('yyyy-MM-dd').format(DateTime.now());
      getBloodSugarSummaryByDate(todayFormatted);
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }

  Future<void> addBloodSugar({
    List<Map<String, dynamic>>? bloodSugarData,
  }) async {
    try {
      showGlobalLoader();
      final url = EndPoints.bloodSugarInsert;
      final res = await DioClient().post(url, {"bloodSugar": bloodSugarData});
      hideGlobalLoader();
      bloodSugarGoal.value = jsonToObject(res, BloodSugarGoalModel.fromJson);
      if (bloodSugarGoal.value?.code != 1) {
        CommonWidget.showToast(
          bloodSugarGoal.value?.message ??
              StringConstant.internalErrorExceptionMessage,
        );
        return;
      }
      await callBloodSugarApis();
      Get.find<HomeController>().getDashboardData(silent: true);
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }
}
