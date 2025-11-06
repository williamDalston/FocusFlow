import UIKit
import GoogleMobileAds
import StoreKit
import AVFoundation
import UserNotifications

final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, AudioVideoManagerDelegate {
    static let quickAction = Notification.Name("StartWorkoutQuickAction")

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {

        // Configure audio session for background playback (lightweight, keep synchronous)
        configureAudioSession()
        
        // Configure notification delegate for actionable notifications (lightweight, keep synchronous)
        UNUserNotificationCenter.current().delegate = self

        // Defer Google Mobile Ads initialization to improve launch time
        // Start after UI is visible to avoid blocking initial render
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            MobileAds.shared.start()
            // Configure audio video manager for proper ad audio handling
            self.configureAdAudioManager()
        }

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
    
    // MARK: - Ad Audio Configuration
    
    /// Configure Google AdMob audio video manager for proper audio handling
    /// Best practice: App manages its own audio session, so we set audioSessionIsApplicationManaged = true
    private func configureAdAudioManager() {
        let audioVideoManager = MobileAds.shared.audioVideoManager
        // Tell AdMob that the app manages its own audio session
        // This prevents AdMob from changing the audio session category
        audioVideoManager.isAudioSessionApplicationManaged = true
        // Set delegate to handle ad audio events
        audioVideoManager.delegate = self
    }
    
    // MARK: - AudioVideoManagerDelegate
    
    /// Called when an ad will start playing audio
    /// Best practice: Pause app audio to allow ad audio to play clearly
    func audioVideoManagerWillPlayAudio(_ audioVideoManager: AudioVideoManager) {
        Task { @MainActor in
            // Pause app audio when ad audio starts
            SoundManager.shared.pauseAudioForAd()
            // Notify MeditationEngine instances to pause audio
            NotificationCenter.default.post(name: NSNotification.Name("AdAudioWillPlay"), object: nil)
        }
    }
    
    /// Called when all ad audio has stopped playing
    /// Best practice: Resume app audio after ad audio finishes
    func audioVideoManagerDidStopPlayingAudio(_ audioVideoManager: AudioVideoManager) {
        Task { @MainActor in
            // Resume app audio when ad audio stops
            SoundManager.shared.resumeAudioAfterAd()
            // Notify MeditationEngine instances to resume audio
            NotificationCenter.default.post(name: NSNotification.Name("AdAudioDidStop"), object: nil)
        }
    }
    
    /// Called when an ad will start playing video
    /// Optional: Can be used for additional video-specific handling
    func audioVideoManagerWillPlayVideo(_ audioVideoManager: AudioVideoManager) {
        // Video ads may also play audio, so we rely on audioVideoManagerWillPlayAudio
    }
    
    /// Called when all ad videos have paused/stopped
    /// Best practice: Ensure audio session is properly managed
    func audioVideoManagerDidPauseAllVideo(_ audioVideoManager: AudioVideoManager) {
        // All video ads have stopped, audio should already be handled by audioVideoManagerDidStopPlayingAudio
    }

    // Home-screen quick action: "Start Workout"
    func application(
        _ application: UIApplication,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        if shortcutItem.type == "com.williamalston.FocusFlow.startworkout" {
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
