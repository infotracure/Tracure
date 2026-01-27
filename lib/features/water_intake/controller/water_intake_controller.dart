import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tracure/features/water_intake/model/water_stats_model.dart';
import 'package:tracure/features/water_intake/model/water_summary_by_range.dart';

import '../../../servies/api_service/dio_client.dart';
import '../../../servies/api_service/end_points.dart';
import '../../../servies/api_service/response_handler.dart';
import '../../../utils/common_widget.dart';
import '../../../utils/constant/string_constants.dart';
import '../../../utils/loading_overlay.dart';
import '../model/water_goal_model.dart';
import '../model/water_summary_model.dart';
import '../model/water_trend_model.dart';

class WaterIntakeController extends GetxController {
  // Add your methods and properties here
  Rx<WaterSummaryModel?> waterSummary = Rx<WaterSummaryModel?>(null);
  Rx<WaterTrendModel?> waterTrend = Rx<WaterTrendModel?>(null);
  Rx<WaterStatsModel?> waterStats = Rx<WaterStatsModel?>(null);
  Rx<WaterGoalModel?> waterGoal = Rx<WaterGoalModel?>(null);
  Rx<WaterSummaryByRangeModel?> monthlyWaterSummary =
      Rx<WaterSummaryByRangeModel?>(null);
  Rx<WaterSummaryByRangeModel?> weeklyWaterSummary =
      Rx<WaterSummaryByRangeModel?>(null);

  void onInit() async {
    super.onInit();
    await callWaterApis();
    // await getWaterGoal();
  }

  Future<void> callWaterApis() async {
    var todayFormatted = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await getWaterSummaryByDate(todayFormatted);
    await getWaterTrendByDate(todayFormatted);
    // Calculate current week's start (Monday) and end (Sunday)
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    final dateFormat = DateFormat('yyyy-MM-dd');
    await getWaterStatsByDate(
      dateFormat.format(weekStart),
      dateFormat.format(weekEnd),
    );
  }

  Future<void> getWaterSummaryByDate(String date) async {
    try {
      showGlobalLoader();

      final param = {"date": date};
      final url = EndPoints.waterSummary;
      final res = await DioClient().get(url, queryParam: param);
      hideGlobalLoader();
      waterSummary.value = jsonToObject(res, WaterSummaryModel.fromJson);
      if (waterSummary.value?.code != 1) {
        CommonWidget.showToast(
          waterSummary.value?.message ??
              StringConstant.internalErrorExceptionMessage,
        );
        return;
      }
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }

  Future<void> getWaterTrendByDate(String date) async {
    try {
      showGlobalLoader();
      final param = {"date": date};
      final url = EndPoints.waterTrend;
      final res = await DioClient().get(url, queryParam: param);
      hideGlobalLoader();
      waterTrend.value = jsonToObject(res, WaterTrendModel.fromJson);
      if (waterTrend.value?.code != 1) {
        CommonWidget.showToast(
          waterTrend.value?.message ??
              StringConstant.internalErrorExceptionMessage,
        );
        return;
      }
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }

  Future<void> getWaterStatsByDate(String startDate, String endDate) async {
    try {
      showGlobalLoader();
      final param = {"startDate": startDate, "endDate": endDate};
      final url = EndPoints.waterStats;
      final res = await DioClient().get(url, queryParam: param);
      hideGlobalLoader();
      waterStats.value = jsonToObject(res, WaterStatsModel.fromJson);
      if (waterStats.value?.code != 1) {
        CommonWidget.showToast(
          waterStats.value?.message ??
              StringConstant.internalErrorExceptionMessage,
        );
        return;
      }
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }

  Future<void> getWaterSummaryByRange(String startDate, String endDate) async {
    try {
      showGlobalLoader();
      final param = {"startDate": startDate, "endDate": endDate};
      final url = EndPoints.waterSummaryByRange;
      final res = await DioClient().get(url, queryParam: param);
      hideGlobalLoader();
      monthlyWaterSummary.value = jsonToObject(
        res,
        WaterSummaryByRangeModel.fromJson,
      );
      if (monthlyWaterSummary.value?.code != 1) {
        CommonWidget.showToast(
          monthlyWaterSummary.value?.message ??
              StringConstant.internalErrorExceptionMessage,
        );
        return;
      }
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }

  Future<void> getMonthlyWaterSummary(DateTime month) async {
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
      final url = EndPoints.waterSummaryByRange;
      final res = await DioClient().get(url, queryParam: param);
      hideGlobalLoader();
      monthlyWaterSummary.value = jsonToObject(
        res,
        WaterSummaryByRangeModel.fromJson,
      );
      if (monthlyWaterSummary.value?.code != 1) {
        CommonWidget.showToast(
          monthlyWaterSummary.value?.message ??
              StringConstant.internalErrorExceptionMessage,
        );
        return;
      }
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }

  Future<void> getWeeklyWaterSummary(String startDate, String endDate) async {
    try {
      showGlobalLoader();

      final param = {"startDate": startDate, "endDate": endDate};
      final url = EndPoints.waterSummaryByRange;
      final res = await DioClient().get(url, queryParam: param);
      hideGlobalLoader();
      weeklyWaterSummary.value = jsonToObject(
        res,
        WaterSummaryByRangeModel.fromJson,
      );
      if (weeklyWaterSummary.value?.code != 1) {
        CommonWidget.showToast(
          weeklyWaterSummary.value?.message ??
              StringConstant.internalErrorExceptionMessage,
        );
        return;
      }
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }

  Future<void> getWaterGoal() async {
    try {
      showGlobalLoader();
      final url = EndPoints.waterGoals;
      final res = await DioClient().get(url);
      hideGlobalLoader();
      waterGoal.value = jsonToObject(res, WaterGoalModel.fromJson);
      if (waterGoal.value?.code != 1) {
        CommonWidget.showToast(
          waterGoal.value?.message ??
              StringConstant.internalErrorExceptionMessage,
        );
        return;
      }
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }

  Future<void> setWaterGoal({
    int? dailyTargetMl,
    int? reminderIntervalMinutes,
  }) async {
    try {
      showGlobalLoader();
      final url = EndPoints.waterGoals;
      final res = await DioClient().post(url, {
        "dailyTargetMl": dailyTargetMl,
        "reminderIntervalMinutes": reminderIntervalMinutes,
      });
      hideGlobalLoader();
      waterGoal.value = jsonToObject(res, WaterGoalModel.fromJson);
      if (waterGoal.value?.code != 1) {
        CommonWidget.showToast(
          waterGoal.value?.message ??
              StringConstant.internalErrorExceptionMessage,
        );
        return;
      }
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }

  Future<void> addWater({List<Map<String, dynamic>>? waterData}) async {
    try {
      showGlobalLoader();
      final url = EndPoints.waterInsert;
      final res = await DioClient().post(url, {"water": waterData});
      hideGlobalLoader();
      waterGoal.value = jsonToObject(res, WaterGoalModel.fromJson);
      if (waterGoal.value?.code != 1) {
        CommonWidget.showToast(
          waterGoal.value?.message ??
              StringConstant.internalErrorExceptionMessage,
        );
        return;
      }
      await callWaterApis();
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }
}
