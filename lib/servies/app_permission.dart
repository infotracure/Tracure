import 'dart:async';
import 'package:permission_handler/permission_handler.dart';

class AppPermission {
  /// Global lock — ensures only one permission dialog is shown at a time.
  static Future<void>? _current;

  /// Runs [request] only after any in-flight permission request finishes.
  static Future<T> _enqueue<T>(Future<T> Function() request) async {
    // Wait for previous request to finish
    while (_current != null) {
      await _current;
    }
    final completer = Completer<T>();
    _current = completer.future;
    try {
      final result = await request();
      completer.complete(result);
      return result;
    } catch (e) {
      completer.completeError(e);
      rethrow;
    } finally {
      _current = null;
    }
  }

  static Future<bool> requestNotificationPermission() => _enqueue(() async {
    final status = await Permission.notification.status;
    if (status.isGranted) return true;

    final result = await Permission.notification.request();
    if (result.isGranted) return true;
    if (result.isPermanentlyDenied) await openAppSettings();
    return false;
  });

  static Future<bool> requestMicrophonePermission() => _enqueue(() async {
    final status = await Permission.microphone.status;
    if (status.isGranted) return true;

    final result = await Permission.microphone.request();
    if (result.isGranted) return true;
    if (result.isPermanentlyDenied) await openAppSettings();
    return false;
  });

  static Future<bool> requestActivityPermission() => _enqueue(() async {
    final status = await Permission.activityRecognition.status;
    if (status.isGranted) return true;

    final result = await Permission.activityRecognition.request();
    if (result.isGranted) return true;
    if (result.isPermanentlyDenied) await openAppSettings();
    return false;
  });

  static Future<bool> requestBatteryUnrestricted() => _enqueue(() async {
    final status = await Permission.ignoreBatteryOptimizations.status;
    if (status.isGranted) return true;

    final result = await Permission.ignoreBatteryOptimizations.request();
    return result.isGranted;
  });
}
