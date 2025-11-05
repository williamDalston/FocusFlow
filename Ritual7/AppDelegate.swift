import UIKit
import GoogleMobileAds
import StoreKit
import AVFoundation
import UserNotifications

final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    static let quickAction = Notification.Name("StartWorkoutQuickAction")

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {

        // Configure audio session for background playback
        configureAudioSession()
        
        // Configure notification delegate for actionable notifications
        UNUserNotificationCenter.current().delegate = self

        // Start Google Mobile Ads (App ID must be in Info.plist under GADApplicationIdentifier)
        MobileAds.shared.start()

        // If you ever need to test on a PHYSICAL device only during development,
        // you can temporarily uncomment and add your device's IDFA hash here under DEBUG.
        // #if DEBUG
        // MobileAds.shared.requestConfiguration.testDeviceIdentifiers = ["YOUR_DEVICE_ID_HASH"]
        // #endif

        return true
    }
    
    // MARK: - Audio Configuration
    
    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }

    // Home-screen quick action: "Start Workout"
    func application(
        _ application: UIApplication,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        if shortcutItem.type == "com.williamalston.Ritual7.startworkout" {
            NotificationCenter.default.post(name: AppDelegate.quickAction, object: nil)
            completionHandler(true)
        } else {
            completionHandler(false)
        }
    }
    
    // Handle notification actions
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let actionIdentifier = response.actionIdentifier
        
        if actionIdentifier == "START_WORKOUT" {
            // Start workout from notification
            NotificationCenter.default.post(name: AppDelegate.quickAction, object: nil)
        } else if actionIdentifier == "VIEW_PROGRESS" {
            // Navigate to progress view
            NotificationCenter.default.post(
                name: NSNotification.Name("ViewProgressFromNotification"),
                object: nil
            )
        }
        
        completionHandler()
    }
}
