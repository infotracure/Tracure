import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      let controller = window?.rootViewController as! FlutterViewController
      configureMethodChannels(controller: controller)
      
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    private func configureMethodChannels(controller: FlutterViewController) {
        let sleepChannel = FlutterMethodChannel(
             name: "sleep_service",
             binaryMessenger: controller.binaryMessenger
           )

           sleepChannel.setMethodCallHandler { call, result in
             switch call.method {
             case "getSleepDataForDate":
                 guard let args = call.arguments as? [String: Any],
                       let dateString = args["date"] as? String,
                       let givenDate = DateUtils.parseISO8601DateTrimmingMicroseconds(from: dateString) else {
                     result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid or missing date", details: nil))
                     return
                 }

               SleepAnalyzer.fetchSleepData(for: givenDate) { sleepArray in
                 result(sleepArray)
               }

             case "setSleepSettings":
               guard let args = call.arguments as? [String: Any] else {
                 result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing settings data", details: nil))
                 return
               }

               SleepAnalyzer.setDataFromSettings(settingsData: args)
               result("Settings updated")

             default:
               result(FlutterMethodNotImplemented)
             }
           }
      }
    }
