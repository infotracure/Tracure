import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tracure/features/sleep_tracker/model/sleep_goal_model.dart';
import 'package:tracure/features/sleep_tracker/model/sleep_stats_model.dart';
import 'package:tracure/features/sleep_tracker/model/sleep_summary_by_range_model.dart';
import 'package:tracure/features/sleep_tracker/model/sleep_trend_model.dart';
import 'package:tracure/servies/sleep_service.dart';

import '../../../servies/api_service/dio_client.dart';
import '../../../servies/api_service/end_points.dart';
import '../../../servies/api_service/response_handler.dart';
import '../../../utils/common_widget.dart';
import '../../../utils/constant/string_constants.dart';
import '../../../utils/loading_overlay.dart';
import '../model/sleep_summary_model.dart';

class SleepTrackerController extends GetxController {
  Rx<SleepSummaryModel?> sleepSummaryModel = Rx<SleepSummaryModel?>(null);
  Rx<SleepTrendModel?> sleepTrendModel = Rx<SleepTrendModel?>(null);
  Rx<SleepStatsModel?> sleepStatsModel = Rx<SleepStatsModel?>(null);
  Rx<SleepSummaryByRangeModel?> weeklySleepSummary =
      Rx<SleepSummaryByRangeModel?>(null);
  Rx<SleepSummaryByRangeModel?> monthlySleepSummary =
      Rx<SleepSummaryByRangeModel?>(null);
  Rx<SleepGoalModel?> sleepGoalModel = Rx<SleepGoalModel?>(null);

  // Noise data from local sleep sessions
  var avgNoise = ''.obs;
  var maxNoise = ''.obs;
  var minNoise = ''.obs;

  @override
  void onInit() async {
    super.onInit();
    final now = DateTime.now().subtract(Duration(days: 1));
    var todayFormatted = DateFormat('yyyy-MM-dd').format(now);
    await getSleepSummaryByDate(todayFormatted);
    await getSleepTrend(todayFormatted);
    await fetchNoiseData(todayFormatted);

    // Calculate current week's start (Monday) and end (Sunday)

    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    final dateFormat = DateFormat('yyyy-MM-dd');

    // await getWeeklySleepSummary(
    //   dateFormat.format(weekStart),
    //   dateFormat.format(weekEnd),
    // );
  }

  Future<void> fetchNoiseData(String date) async {
    try {
      final sessions = await SleepService.getSleepDataForDate(date);
      if (sessions.isEmpty) {
        avgNoise.value = '';
        maxNoise.value = '';
        minNoise.value = '';
        return;
      }

      double sumAvg = 0;
      double overallMax = 0;
      double overallMin = double.infinity;
      int count = 0;

      for (final session in sessions) {
        final avg = session['avgNoise'];
        final max = session['maxNoise'];
        final min = session['minNoise'];

        // Skip sessions with no noise data (empty string or 0)
        if (avg is! num || avg == 0) continue;

        sumAvg += avg.toDouble();
        if (max is num && max > overallMax) overallMax = max.toDouble();
        if (min is num && min < overallMin) overallMin = min.toDouble();
        count++;
      }

      if (count == 0) {
        avgNoise.value = '';
        maxNoise.value = '';
        minNoise.value = '';
        return;
      }

      avgNoise.value = '${(sumAvg / count).toStringAsFixed(1)} dB';
      maxNoise.value = '${overallMax.toStringAsFixed(1)} dB';
      minNoise.value = '${overallMin.toStringAsFixed(1)} dB';
    } catch (e) {
      debugPrint('Error fetching noise data: $e');
      avgNoise.value = '';
      maxNoise.value = '';
      minNoise.value = '';
    }
  }

  Future<void> getSleepSummaryByDate(String date) async {
    try {
      showGlobalLoader();

      final param = {"date": date};
      final url = EndPoints.sleepSummary;
      final res = await DioClient().get(url, queryParam: param);
      hideGlobalLoader();
      sleepSummaryModel.value = jsonToObject(res, SleepSummaryModel.fromJson);
      if (sleepSummaryModel.value?.code != 1) {
        CommonWidget.showToast(
          sleepSummaryModel.value?.message ??
              StringConstant.internalErrorExceptionMessage,
        );
        return;
      }
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }

  Future<void> getSleepTrend(String date) async {
    try {
      showGlobalLoader();

      final param = {"date": date};
      final url = EndPoints.sleepTrend;
      final res = await DioClient().get(url, queryParam: param);
      hideGlobalLoader();
      sleepTrendModel.value = jsonToObject(res, SleepTrendModel.fromJson);
      if (sleepTrendModel.value?.code != 1) {
        CommonWidget.showToast(
          sleepTrendModel.value?.message ??
              StringConstant.internalErrorExceptionMessage,
        );
        return;
      }
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }

  Future<void> getSleepStats(String startDate, String endDate) async {
    try {
      showGlobalLoader();

      final param = {"startDate": startDate, "endDate": endDate};
      final url = EndPoints.sleepStats;
      final res = await DioClient().get(url, queryParam: param);
      hideGlobalLoader();
      sleepTrendModel.value = jsonToObject(res, SleepTrendModel.fromJson);
      if (sleepTrendModel.value?.code != 1) {
        CommonWidget.showToast(
          sleepTrendModel.value?.message ??
              StringConstant.internalErrorExceptionMessage,
        );
        return;
      }
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }

  Future<void> getWeeklySleepSummary(String startDate, String endDate) async {
    try {
      showGlobalLoader();

      final param = {"startDate": startDate, "endDate": endDate};
      final url = EndPoints.sleepSummaryByRange;
      final res = await DioClient().get(url, queryParam: param);
      hideGlobalLoader();
      weeklySleepSummary.value = jsonToObject(
        res,
        SleepSummaryByRangeModel.fromJson,
      );
      if (weeklySleepSummary.value?.code != 1) {
        CommonWidget.showToast(
          weeklySleepSummary.value?.message ??
              StringConstant.internalErrorExceptionMessage,
        );
        return;
      }
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }

  Future<void> getMonthlySleepSummary(DateTime month) async {
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
      final url = EndPoints.sleepSummaryByRange;
      final res = await DioClient().get(url, queryParam: param);
      hideGlobalLoader();
      monthlySleepSummary.value = jsonToObject(
        res,
        SleepSummaryByRangeModel.fromJson,
      );
      if (monthlySleepSummary.value?.code != 1) {
        CommonWidget.showToast(
          monthlySleepSummary.value?.message ??
              StringConstant.internalErrorExceptionMessage,
        );
        return;
      }
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }

  Future<void> getSleepSettings() async {
    try {
      showGlobalLoader();
      final url = EndPoints.sleepGoals;
      final res = await DioClient().get(url);
      hideGlobalLoader();
      sleepGoalModel.value = jsonToObject(res, SleepGoalModel.fromJson);
      if (sleepGoalModel.value?.code != 1) {
        CommonWidget.showToast(
          sleepGoalModel.value?.message ??
              StringConstant.internalErrorExceptionMessage,
        );
        return;
      }
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }

  Future<bool> saveSleepSettings({
    required String preferredBedtime,
    required String preferredWaketime,
    required int targetDurationMinutes,
    bool? automaticDetection,
    bool? bedtimeReminder,
    int? smartAlarmWindow,
    bool? gradualWakeup,
  }) async {
    try {
      showGlobalLoader();
      final param = {
        "preferredBedtime": preferredBedtime,
        "preferredWaketime": preferredWaketime,
        "targetDurationMinutes": targetDurationMinutes,
      };
      final url = EndPoints.sleepGoals;
      final res = await DioClient().post(url, param);
      hideGlobalLoader();

      if (res is DioResponse) {
        final responseData = res.data as Map<String, dynamic>;
        final code = responseData['code'];
        final message = responseData['message'];

        if (code != 1) {
          CommonWidget.showToast(
            message ?? StringConstant.internalErrorExceptionMessage,
          );
          return false;
        }
        CommonWidget.showToast(message ?? "Sleep Goal updated successfully");
        return true;
      }
      return false;
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
      return false;
    }
  }
}
