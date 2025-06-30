import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

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
    lSStartTime: "22:00",
    lSHardStopTime: "10:00",
    lSEndTime: "07:00",
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

  /// Starts the Android native sleep tracking service.
  static Future<void> startTracking({
    required String lSStartTime, // e.g., "22:00"
    required String lSEndTime, // e.g., "07:00"
    required String lSHardStopTime, // e.g., "10:00"
    required int sleepInterval, // e.g., 1800 (seconds)
    required String sleepDate, // e.g., "2025-06-23"
  }) async {
    await _channel.invokeMethod('startSleepTracking', {
      'lSStartTime': lSStartTime,
      'lSEndTime': lSEndTime,
      'lSHardStopTime': lSHardStopTime,
      'sleepInterval': sleepInterval,
      'sleepDate': sleepDate,
    });
  }

  /// Stops the Android native sleep tracking service.
  static Future<void> stopTracking() async {
    await _channel.invokeMethod('stopSleepTracking');
  }

  static Future<List<Map<String, dynamic>>> getSleepDataForDate(
    String date,
  ) async {
    final List<dynamic> result = await _channel.invokeMethod(
      "getSleepDataForDate",
      {"date": date},
    );
    debugPrint(result.toString());
    return result.cast<Map<String, dynamic>>();
  }

  static scheduleSleepTracking() async {
    await _channel.invokeMethod('scheduleSleepTracking', {
      'lSStartTime': '09:48',
      'lSEndTime': '12:00',
    });
  }
}
