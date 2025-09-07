import 'dart:developer';

import 'package:permission_handler/permission_handler.dart';
import 'package:health/health.dart';
import 'package:tracure/utils/common_methods.dart';

class PermissionManager {
  static Future<void> requestActivityPermission() async {
    if (await Permission.activityRecognition.isDenied) {
      await Permission.activityRecognition.request();
    }

    if (await Permission.activityRecognition.isPermanentlyDenied) {
      openAppSettings();
    }
  }
}

class HealthDataService {
  static final HealthDataService _instance = HealthDataService._internal();
  factory HealthDataService() => _instance;
  HealthDataService._internal();

  final Health _health = Health();

  bool _isAuthorized = false;
  bool _isRequesting = false;

  final List<HealthDataType> _dataTypes = [
    HealthDataType.STEPS,
    // HealthDataType.SLEEP_ASLEEP,
    // HealthDataType.SLEEP_IN_BED,
  ];
  final List<HealthDataAccess> _permissions = [
    HealthDataAccess.READ,
    // HealthDataAccess.READ,
    // HealthDataAccess.READ,
  ];

  Future<bool> _authorize() async {
    if (_isAuthorized || _isRequesting) return _isAuthorized;

    _isRequesting = true;

    try {
      _isAuthorized = await _health.requestAuthorization(
        _dataTypes,
        permissions: _permissions,
      );
    } catch (e) {
      print("Authorization error: $e");
      _isAuthorized = false;
    } finally {
      _isRequesting = false;
    }

    return _isAuthorized;
  }

  Future<int> _fetchStepsForDay(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(Duration(days: 1));

    final data = await _health.getHealthDataFromTypes(
      startTime: start,
      endTime: end,
      types: _dataTypes,
    );

    final clean = _health.removeDuplicates(data);

    return clean.fold<int>(0, (sum, d) {
      if (d.type == HealthDataType.STEPS && d.value is NumericHealthValue) {
        return sum + (d.value as NumericHealthValue).numericValue.toInt();
      }
      return sum;
    });
  }

  Future<int> getTodaySteps() async {
    if (!await _authorize()) return 0;
    return await _fetchStepsForDay(DateTime.now());
  }

  Future<List<HealthDataPoint>> getWeeklySteps(DateTime week) async {
    if (!await _authorize()) return [];

    final startOfWeek = week.subtract(
      Duration(days: week.weekday - 1),
    ); // Monday
    final endOfWeek = startOfWeek.add(const Duration(days: 6)); // Sunday

    // Fetch all step data for the week in a single query
    final data = await _health.getHealthDataFromTypes(
      startTime: startOfWeek,
      endTime: endOfWeek,
      types: _dataTypes,
    );

    final clean = _health.removeDuplicates(data);
    return clean;
  }

  Future<List<HealthDataPoint>> getMonthlySteps(DateTime month) async {
    if (!await _authorize()) return [];

    final start = DateTime(month.year, month.month, 1);
    final end = getLastDayOfMonth(start);

    final data = await _health.getHealthDataFromTypes(
      startTime: start,
      endTime: end,
      types: _dataTypes,
    );

    final clean = _health.removeDuplicates(data);
    return clean;
  }

  Future<List<HealthDataPoint>> getStepsDataFrom(DateTime from) async {
    if (!await _authorize()) return [];
    final data = await _health.getHealthDataFromTypes(
      startTime: from,
      endTime: DateTime.now(),
      types: _dataTypes,
    );

    final clean = _health.removeDuplicates(data);
    return clean;
  }

  Future<void> fetchSleepData() async {
    if (!await _authorize()) return;

    final types = [HealthDataType.SLEEP_IN_BED, HealthDataType.SLEEP_ASLEEP];

    final now = DateTime.now();
    final yesterday = now.subtract(Duration(days: 1));

    var sleepData = await _health.getHealthDataFromTypes(
      types: types,
      startTime: yesterday,
      endTime: now,
    );
    sleepData = _health.removeDuplicates(sleepData);
    for (var data in sleepData) {
      print(
        "Type: ${data.type}, Value: ${data.value}, Start: ${data.dateFrom}, End: ${data.dateTo}",
      );
    }
  }
}

Future<int> printTodaySteps() async {
  final service = HealthDataService();
  final todayStep = await service.getTodaySteps();
  log(todayStep.toString());
  return todayStep;
}

void printWeeklySteps() async {
  final service = HealthDataService();
  final weekData = await service.getWeeklySteps(DateTime.now());
}

void printMonthlySteps() async {
  final service = HealthDataService();
  final monthData = await service.getMonthlySteps(DateTime.now());
}

DateTime getLastDayOfMonth(DateTime date) {
  // Move to the next month, then go back one day
  DateTime firstDayNextMonth = (date.month == 12)
      ? DateTime(date.year + 1, 1, 1)
      : DateTime(date.year, date.month + 1, 1);

  return firstDayNextMonth.subtract(const Duration(days: 1));
}
