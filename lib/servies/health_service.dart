import 'dart:developer';

import 'package:permission_handler/permission_handler.dart';
import 'package:health/health.dart';

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

  final List<HealthDataType> _dataTypes = [HealthDataType.STEPS];
  final List<HealthDataAccess> _permissions = [HealthDataAccess.READ];

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

  Future<List<Map<String, dynamic>>> getWeeklySteps() async {
    if (!await _authorize()) return [];

    final now = DateTime.now();
    List<Map<String, dynamic>> stepsData = [];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final steps = await _fetchStepsForDay(date);
      stepsData.add({'date': date, 'steps': steps});
    }

    return stepsData;
  }

  Future<List<Map<String, dynamic>>> getMonthlySteps() async {
    if (!await _authorize()) return [];

    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final today = DateTime(now.year, now.month, now.day);
    final days = today.difference(firstDay).inDays + 1;

    List<Map<String, dynamic>> stepsData = [];

    for (int i = 0; i < days; i++) {
      final date = firstDay.add(Duration(days: i));
      final steps = await _fetchStepsForDay(date);
      stepsData.add({'date': date, 'steps': steps});
    }

    return stepsData;
  }
}

void printTodaySteps() async {
  final service = HealthDataService();
  final todayStep = await service.getTodaySteps();
  log(todayStep.toString());
}

void printWeeklySteps() async {
  final service = HealthDataService();
  final weekData = await service.getWeeklySteps();
  for (var day in weekData) {
    log("${day['date']}: ${day['steps']} steps");
  }
}

void printMonthlySteps() async {
  final service = HealthDataService();
  final monthData = await service.getMonthlySteps();
  for (var day in monthData) {
    log("${day['date']}: ${day['steps']} steps");
  }
}
