import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tracure/features/homepage/controller/home_controller.dart';

class SleepDataFetcher {
  static const platform = MethodChannel('com.tracure.main');

  static Future<List<Map<String, dynamic>>> fetchSleepData(
    DateTime date,
  ) async {
    try {
      final result = await platform.invokeMethod('fetchSleepData', {
        'date': date.toIso8601String(),
      });

      return (result as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (e) {
      print('Error fetching sleep data: $e');
      return [];
    }
  }

  static Future<void> setSleepSettings({
    required String lSStartTime,
    required String lSHardStopTime,
    required String lSEndTime,
    required int sleepInterval,
  }) async {
    const platform = MethodChannel('com.tracure.main');
    try {
      await platform.invokeMethod('setSleepSettings', {
        'lSStartTime': lSStartTime,
        'lSHardStopTime': lSHardStopTime,
        'lSEndTime': lSEndTime,
        'sleepInterval': sleepInterval,
      });
    } catch (e) {
      print('Failed to send sleep settings: $e');
    }
  }
}

Future<void> setSleepSettings() async {
  await SleepDataFetcher.setSleepSettings(
    lSStartTime: "21:00",
    lSHardStopTime: "10:00",
    lSEndTime: "21:05",
    sleepInterval: 1800,
  );
}

Future<void> getSleep() async {
  await setSleepSettings();
  DateTime date = DateTime.now()
      .subtract(Duration(days: 1))
      .toUtc(); // Or any selected date
  List<Map<String, dynamic>> sleepData = await SleepDataFetcher.fetchSleepData(
    date,
  );

  print("Sleep Data: $sleepData");
}

class SleepService {
  static const MethodChannel _channel = MethodChannel('sleep_service');

  /// Starts sleep tracking via WorkManager (periodic sensor sampling + receivers).
  static Future<void> startTracking({
    required String lSStartTime,
    required String lSEndTime,
    required String lSHardStopTime,
    required int sleepInterval,
  }) async {
    await _channel.invokeMethod('startSleepTracking', {
      'lSStartTime': lSStartTime,
      'lSEndTime': lSEndTime,
      'lSHardStopTime': lSHardStopTime,
      'sleepInterval': sleepInterval,
    });
  }

  /// Stops all sleep tracking (WorkManager + receivers).
  static Future<void> stopTracking() async {
    await _channel.invokeMethod('stopSleepTracking');
  }

  /// Get sleep session data for a specific date.
  static Future<List<Map<String, dynamic>>> getSleepDataForDate(
    String date,
  ) async {
    final List<dynamic> result = await _channel.invokeMethod(
      "getSleepDataForDate",
      {"date": date},
    );

    final List<Map<String, dynamic>> castedList = result.map((item) {
      return Map<String, dynamic>.from(item as Map);
    }).toList();

    debugPrint(castedList.toString());
    return castedList;
  }

  /// Schedule sleep tracking with WorkManager + AlarmManager backup.
  static Future<void> scheduleSleepTracking() async {
    try {
      await _channel.invokeMethod('scheduleSleepTracking', {
        'lSStartTime': startTime,
        'lSEndTime': endTime,
        'lSHardStopTime': hardStop,
        'lSInterval': 1800,
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Trigger sleep inference immediately (for when user opens the app).
  static Future<void> runInferenceNow() async {
    try {
      await _channel.invokeMethod('runInferenceNow');
    } catch (e) {
      debugPrint('Error running inference: $e');
    }
  }

  /// Get sleep quality data including confidence scores.
  static Future<List<Map<String, dynamic>>> getSleepQuality(String date) async {
    try {
      final List<dynamic> result = await _channel.invokeMethod(
        'getSleepQuality',
        {'date': date},
      );
      return result.map((item) {
        return Map<String, dynamic>.from(item as Map);
      }).toList();
    } catch (e) {
      debugPrint('Error getting sleep quality: $e');
      return [];
    }
  }

  /// Request battery optimization exemption for reliable background work.
  static Future<bool> requestBatteryExemption() async {
    try {
      final result = await _channel.invokeMethod('requestBatteryExemption');
      return result == true;
    } catch (e) {
      debugPrint('Error requesting battery exemption: $e');
      return false;
    }
  }

  static Future<bool> requestAlarmPermission() async {
    var isGranted = await _channel.invokeMethod('checkExactAlarmPermission');
    return isGranted == true;
  }

  static Future<bool> checkAlarmPermission() async {
    var isGranted = await _channel.invokeMethod('checkExactAlarmPermission');
    return isGranted == true;
  }

  /// Debug: check which alarms are currently scheduled.
  static Future<Map<String, dynamic>> debugCheckAlarms() async {
    try {
      final result = await _channel.invokeMethod('debugCheckAlarms');
      final map = Map<String, dynamic>.from(result as Map);

      debugPrint('=== ALARM STATUS ===');
      debugPrint('Start alarm scheduled: ${map['startAlarm']}');
      debugPrint('Stop alarm scheduled: ${map['stopAlarm']}');
      debugPrint('Service running: ${map['serviceRunning']}');
      debugPrint('Scheduled window: ${map['scheduledStart']} - ${map['scheduledEnd']}');

      final watchdogs = List<bool>.from(map['watchdogAlarms'] as List);
      final activeCount = watchdogs.where((w) => w).length;
      debugPrint('Watchdog alarms active: $activeCount / ${watchdogs.length}');
      for (int i = 0; i < watchdogs.length; i++) {
        if (watchdogs[i]) {
          debugPrint('  Watchdog #$i (rc=${200 + i}): SCHEDULED');
        }
      }
      debugPrint('====================');

      return map;
    } catch (e) {
      debugPrint('Error checking alarms: $e');
      return {};
    }
  }

  /// If current time is within the sleep window and the service isn't running, start it.
  static Future<String> startTrackingIfNeeded() async {
    try {
      final result = await _channel.invokeMethod('startIfInSleepWindow');
      debugPrint('startTrackingIfNeeded: $result');
      return result as String;
    } catch (e) {
      debugPrint('Error in startTrackingIfNeeded: $e');
      return 'error';
    }
  }
}
