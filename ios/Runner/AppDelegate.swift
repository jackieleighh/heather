import Flutter
import UIKit
import CoreLocation
import FirebaseCore
import FirebaseMessaging
import workmanager_apple

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }

    application.registerForRemoteNotifications()

    // WorkManager: register plugin callback for background isolate
    WorkmanagerPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }

    // Write a native flag when cold-launched from the home widget URL scheme
    if let launchUrl = launchOptions?[.url] as? URL,
       launchUrl.scheme == "heather" {
        UserDefaults(suiteName: "group.com.totms.heather")?.set(true, forKey: "widget_cold_launch")
    }

    // Start significant location monitoring (handles re-launch from location event)
    // This is safe even if "Always" permission hasn't been granted yet — it checks first.
    SignificantLocationManager.shared.startMonitoringIfAuthorized()

    // If re-launched by a significant location change, iOS delivers the location
    // via the delegate automatically — no additional handling needed here.

    GeneratedPluginRegistrant.register(with: self)

    // Set up Flutter method channel for Dart to control location monitoring
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: "com.totms.heather/location",
        binaryMessenger: controller.binaryMessenger
      )
      channel.setMethodCallHandler { [weak self] (call, result) in
        self?.handleLocationMethodCall(call, result: result)
      }
    }

    // WorkManager: register BGTask identifier
    WorkmanagerPlugin.registerPeriodicTask(withIdentifier: "com.totms.heather.alertCheck", frequency: nil)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    Messaging.messaging().apnsToken = deviceToken
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  // MARK: - Location Method Channel

  private func handleLocationMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "startMonitoring":
      SignificantLocationManager.shared.startMonitoring()
      result(nil)
    case "stopMonitoring":
      SignificantLocationManager.shared.stopMonitoring()
      result(nil)
    case "hasAlwaysPermission":
      let status = CLLocationManager().authorizationStatus
      result(status == .authorizedAlways)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
