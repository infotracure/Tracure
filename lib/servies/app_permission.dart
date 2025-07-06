import 'package:permission_handler/permission_handler.dart';

class AppPermission {
 static Future<bool> requestNotificationPermission() async {
    // Check current status
    final status = await Permission.notification.status;

    if (status.isGranted) {
      return true;
    }

    // Request permission
    final result = await Permission.notification.request();

    if (result.isGranted) {
      return true;
    } else if (result.isPermanentlyDenied) {
      // Optional: Prompt user to open settings
      await openAppSettings();
    }

    return false;
  }
}
