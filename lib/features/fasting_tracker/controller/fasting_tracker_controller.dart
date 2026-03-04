import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tracure/features/fasting_tracker/model/fasting_by_date_model.dart';
import 'package:tracure/features/fasting_tracker/model/fasting_stats_model.dart';
import 'package:tracure/features/fasting_tracker/model/fasting_summary_model.dart';
import 'package:uuid/uuid.dart';

import '../../../servies/api_service/dio_client.dart';
import '../../../servies/api_service/end_points.dart';
import '../../../servies/api_service/response_handler.dart';
import '../../../servies/hive_service.dart';
import '../../../utils/common_methods.dart';
import '../../../utils/common_widget.dart';
import '../../../utils/constant/string_constants.dart';
import '../../../utils/loading_overlay.dart';
import '../../homepage/controller/home_controller.dart';
import '../model/fasting_goal_model.dart';
import '../model/fasting_session_model.dart';
import '../model/fasting_summary_by_range_model.dart';

class FastingTrackerController extends GetxController {
  Rx<FastingSummaryModel?> fastingSummaryModel = Rx<FastingSummaryModel?>(null);
  Rx<FastingByDateModel?> fastingByDateModel = Rx<FastingByDateModel?>(null);
  Rx<FastingStatsModel?> fastingStatsModel = Rx<FastingStatsModel?>(null);
  Rx<FastingSummaryByRangeModel?> weeklyFastingSummary =
      Rx<FastingSummaryByRangeModel?>(null);
  Rx<FastingSummaryByRangeModel?> monthlyFastingSummary =
      Rx<FastingSummaryByRangeModel?>(null);
  Rx<FastingGoalModel?> fastingGoalModel = Rx<FastingGoalModel?>(null);

  // Hive keys
  static const _keyPlan = 'fasting_plan';
  static const _keyIsActive = 'fasting_is_active';
  static const _keyStartTime = 'fasting_start_time';
  static const _keySessions = 'fasting_sessions';

  // Observable state
  final selectedPlan = FastingPlan.sixteenEight.obs;
  final isFasting = false.obs;
  final fastingStartTime = Rx<DateTime?>(null);
  final elapsedSeconds = 0.obs;
  final fastingSessions = <FastingSession>[].obs;

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _loadFromHive();
    callFastingApis();
  }

  Future<void> callFastingApis() async {
    final todayFormatted = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await getSleepSummaryByDate(todayFormatted);
    await getFastingByDate(todayFormatted);
    await getFastingSettings();
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    final dateFormat = DateFormat('yyyy-MM-dd');
    await getFastingStats(
      dateFormat.format(weekStart),
      dateFormat.format(weekEnd),
    );
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  // --- Computed getters ---

  int get goalHours => selectedPlan.value.fastHours;

  Duration get elapsedDuration => Duration(seconds: elapsedSeconds.value);

  double get progressPercent {
    if (!isFasting.value || goalHours == 0) return 0.0;
    final progress = elapsedSeconds.value / (goalHours * 3600);
    return progress.clamp(0.0, 1.0);
  }

  int get totalFasts => fastingSessions.length;

  double get avgDurationHours {
    if (fastingSessions.isEmpty) return 0.0;
    final totalMinutes = fastingSessions.fold<int>(
      0,
      (sum, s) => sum + s.durationMinutes,
    );
    return totalMinutes / fastingSessions.length / 60;
  }

  double get successRate {
    if (fastingSessions.isEmpty) return 0.0;
    final successful = fastingSessions
        .where((s) => s.durationMinutes >= s.goalHours * 60)
        .length;
    return (successful / fastingSessions.length) * 100;
  }

  String get elapsedFormatted {
    final d = elapsedDuration;
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  // --- Actions ---

  void startFasting() {
    final now = DateTime.now();
    fastingStartTime.value = now;
    isFasting.value = true;
    elapsedSeconds.value = 0;
    _startTimer();
    _saveToHive();
  }

  void endFasting() {
    if (!isFasting.value || fastingStartTime.value == null) return;

    final session = FastingSession(
      id: const Uuid().v4(),
      startTime: fastingStartTime.value!,
      endTime: DateTime.now(),
      planType: selectedPlan.value,
      goalHours: goalHours,
    );

    fastingSessions.insert(0, session);
    _timer?.cancel();
    _timer = null;
    isFasting.value = false;
    fastingStartTime.value = null;
    elapsedSeconds.value = 0;
    _saveToHive();
    insertFasting(session);
  }

  Future<void> insertFasting(FastingSession session) async {
    try {
      showGlobalLoader();
      final deviceId = await getOrCreateDeviceId();
      final url = EndPoints.fastingInsert;
      final data = {
        "fasting": [
          {
            "uuid": session.id,
            "startTime": session.startTime.toIso8601String(),
            "endTime": session.endTime?.toIso8601String(),
            "durationMinutes": session.durationMinutes,
            "platform": Platform.isIOS ? "ios" : "android",
            "deviceId": deviceId,
            "sourceId": "app",
            "sourceName": "Tracure",
          }
        ]
      };
      final res = await DioClient().post(url, data);
      hideGlobalLoader();

      if (res is DioResponse) {
        final responseData = res.data as Map<String, dynamic>;
        final code = responseData['code'];
        final message = responseData['message'];
        if (code != 1) {
          CommonWidget.showToast(
            message ?? StringConstant.internalErrorExceptionMessage,
          );
          return;
        }
        CommonWidget.showToast(message ?? "Fasting session saved");
      }
      await callFastingApis();
      Get.find<HomeController>().getDashboardData(silent: true);
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }

  void changePlan(FastingPlan plan) {
    if (isFasting.value) return;
    selectedPlan.value = plan;
    _saveToHive();
  }

  // --- Timer ---

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (fastingStartTime.value != null) {
        elapsedSeconds.value = DateTime.now()
            .difference(fastingStartTime.value!)
            .inSeconds;
      }
    });
  }

  // --- Hive persistence ---

  void _loadFromHive() {
    try {
      final hive = HiveService.instance;

      // Load plan
      final planKey = hive.getString(_keyPlan);
      if (planKey != null) {
        selectedPlan.value = FastingPlan.fromKey(planKey);
      }

      // Load active fasting state
      final isActive = hive.getBool(_keyIsActive) ?? false;
      if (isActive) {
        final startTimeStr = hive.getString(_keyStartTime);
        if (startTimeStr != null) {
          final startTime = DateTime.tryParse(startTimeStr);
          if (startTime != null) {
            fastingStartTime.value = startTime;
            isFasting.value = true;
            elapsedSeconds.value = DateTime.now()
                .difference(startTime)
                .inSeconds;
            _startTimer();
          }
        }
      }

      // Load sessions
      final sessionsJson = hive.getString(_keySessions);
      if (sessionsJson != null) {
        final List<dynamic> decoded = jsonDecode(sessionsJson);
        fastingSessions.value = decoded
            .map((e) => FastingSession.fromJson(e))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading fasting data from Hive: $e');
    }
  }

  void _saveToHive() {
    try {
      final hive = HiveService.instance;
      hive.save(selectedPlan.value.key, _keyPlan);
      hive.save(isFasting.value, _keyIsActive);

      if (fastingStartTime.value != null) {
        hive.save(fastingStartTime.value!.toIso8601String(), _keyStartTime);
      } else {
        hive.delete(_keyStartTime);
      }

      final sessionsJson = jsonEncode(
        fastingSessions.map((e) => e.toJson()).toList(),
      );
      hive.save(sessionsJson, _keySessions);
    } catch (e) {
      debugPrint('Error saving fasting data to Hive: $e');
    }
  }

  Future<void> getSleepSummaryByDate(String date) async {
    try {
      showGlobalLoader();

      final param = {"date": date};
      final url = EndPoints.fastingByDate;
      final res = await DioClient().get(url, queryParam: param);
      hideGlobalLoader();
      fastingSummaryModel.value = jsonToObject(
        res,
        FastingSummaryModel.fromJson,
      );
      if (fastingSummaryModel.value?.code != 1) {
        CommonWidget.showToast(
          fastingSummaryModel.value?.message ??
              StringConstant.internalErrorExceptionMessage,
        );
        return;
      }
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }

  Future<void> getFastingByDate(String date) async {
    try {
      showGlobalLoader();

      final param = {"date": date};
      final url = EndPoints.fastingByDate;
      final res = await DioClient().get(url, queryParam: param);
      hideGlobalLoader();
      fastingByDateModel.value = jsonToObject(res, FastingByDateModel.fromJson);
      if (fastingByDateModel.value?.code != 1) {
        CommonWidget.showToast(
          fastingByDateModel.value?.message ??
              StringConstant.internalErrorExceptionMessage,
        );
        return;
      }
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }

  Future<void> getFastingStats(String startDate, String endDate) async {
    try {
      showGlobalLoader();

      final param = {"startDate": startDate, "endDate": endDate};
      final url = EndPoints.fastingStats;
      final res = await DioClient().get(url, queryParam: param);
      hideGlobalLoader();
      fastingStatsModel.value = jsonToObject(res, FastingStatsModel.fromJson);
      if (fastingStatsModel.value?.code != 1) {
        CommonWidget.showToast(
          fastingStatsModel.value?.message ??
              StringConstant.internalErrorExceptionMessage,
        );
        return;
      }
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }

  Future<void> getWeeklyFastingSummary(String startDate, String endDate) async {
    try {
      showGlobalLoader();

      final param = {"startDate": startDate, "endDate": endDate};
      final url = EndPoints.fastingSummaryByRange;
      final res = await DioClient().get(url, queryParam: param);
      hideGlobalLoader();
      weeklyFastingSummary.value = jsonToObject(
        res,
        FastingSummaryByRangeModel.fromJson,
      );
      if (weeklyFastingSummary.value?.code != 1) {
        CommonWidget.showToast(
          weeklyFastingSummary.value?.message ??
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
      final url = EndPoints.fastingSummaryByRange;
      final res = await DioClient().get(url, queryParam: param);
      hideGlobalLoader();
      monthlyFastingSummary.value = jsonToObject(
        res,
        FastingSummaryByRangeModel.fromJson,
      );
      if (monthlyFastingSummary.value?.code != 1) {
        CommonWidget.showToast(
          monthlyFastingSummary.value?.message ??
              StringConstant.internalErrorExceptionMessage,
        );
        return;
      }
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }

  Future<void> getFastingSettings() async {
    try {
      showGlobalLoader();
      final url = EndPoints.fastingGoals;
      final res = await DioClient().get(url);
      hideGlobalLoader();
      fastingGoalModel.value = jsonToObject(res, FastingGoalModel.fromJson);
      if (fastingGoalModel.value?.code != 1) {
        CommonWidget.showToast(
          fastingGoalModel.value?.message ??
              StringConstant.internalErrorExceptionMessage,
        );
        return;
      }
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }

  Future<bool> saveFastingSettings({
    required int targetDurationMinutes,
    required String fastingType,
  }) async {
    try {
      showGlobalLoader();
      final param = {
        "targetDurationMinutes": targetDurationMinutes,
        "fastingType": fastingType,
      };
      final url = EndPoints.fastingGoals;
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
        CommonWidget.showToast(message ?? "Fasting goal updated successfully");
        await getFastingSettings();
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
