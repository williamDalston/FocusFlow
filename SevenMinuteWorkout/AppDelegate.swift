import UIKit
import GoogleMobileAds
import StoreKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    static let quickAction = Notification.Name("StartWorkoutQuickAction")

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {

        // Start Google Mobile Ads (App ID must be in Info.plist under GADApplicationIdentifier)
        MobileAds.shared.start()

        // If you ever need to test on a PHYSICAL device only during development,
        // you can temporarily uncomment and add your device's IDFA hash here under DEBUG.
        // #if DEBUG
        // MobileAds.shared.requestConfiguration.testDeviceIdentifiers = ["YOUR_DEVICE_ID_HASH"]
        // #endif

        return true
    }

    // Home-screen quick action: "Start Workout"
    func application(
        _ application: UIApplication,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        if shortcutItem.type == "com.williamalston.SevenMinuteWorkout.startworkout" {
            NotificationCenter.default.post(name: AppDelegate.quickAction, object: nil)
            completionHandler(true)
        } else {
            completionHandler(false)
        }
    }
}
