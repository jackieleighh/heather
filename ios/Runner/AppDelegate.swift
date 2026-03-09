import Flutter
import UIKit
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

    GeneratedPluginRegistrant.register(with: self)

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
}
