import Foundation
import Intents
import IntentsUI
import os.log

/// Agent 9: iOS Shortcuts integration for quick focus session start
/// Allows users to start focus sessions via Siri and Shortcuts app
enum FocusShortcuts {
    
    // MARK: - Intent Definition
    
    /// Creates a focus intent for Siri Shortcuts
    static func createFocusIntent() -> INIntent {
        let intent = INStartWorkoutIntent()
        // Note: INStartWorkoutIntent properties are read-only
        // The intent will be configured by the system based on user interaction
        return intent
    }
    
    // MARK: - Shortcut Registration
    
    /// Registers all focus shortcuts with the system
    static func registerAllShortcuts() {
        registerStartFocusShortcut()
        registerDeepWorkShortcut()
        registerQuickFocusShortcut()
        registerShowStatsShortcut()
    }
    
    /// Registers the main focus session shortcut
    static func registerStartFocusShortcut() {
        let activity = NSUserActivity(activityType: AppConstants.ActivityTypes.startFocus)
        activity.title = "Start Focus Session"
        activity.suggestedInvocationPhrase = "Start focus session"
        activity.isEligibleForPrediction = true
        activity.isEligibleForSearch = true
        activity.persistentIdentifier = "focus.shortcut.start"
        
        // Make the activity available for shortcuts
        activity.becomeCurrent()
        
        // Donate the shortcut to Siri
        let intent = createFocusIntent()
        let interaction = INInteraction(intent: intent, response: nil)
        interaction.donate { error in
            if let error = error {
                os_log("Failed to donate focus shortcut: %{public}@", log: .default, type: .error, error.localizedDescription)
            }
        }
    }
    
    /// Registers the deep work (45-minute) shortcut
    static func registerDeepWorkShortcut() {
        let activity = NSUserActivity(activityType: AppConstants.ActivityTypes.startDeepWork)
        activity.title = "Start Deep Work"
        activity.suggestedInvocationPhrase = "Start deep work"
        activity.isEligibleForPrediction = true
        activity.isEligibleForSearch = true
        activity.persistentIdentifier = "focus.shortcut.deepwork"
        
        // Add user info to identify the preset
        activity.userInfo = ["preset": "deepWork"]
        
        activity.becomeCurrent()
        
        let intent = createFocusIntent()
        let interaction = INInteraction(intent: intent, response: nil)
        interaction.donate { error in
            if let error = error {
                os_log("Failed to donate deep work shortcut: %{public}@", log: .default, type: .error, error.localizedDescription)
            }
        }
    }
    
    /// Registers the quick focus (15-minute) shortcut
    static func registerQuickFocusShortcut() {
        let activity = NSUserActivity(activityType: AppConstants.ActivityTypes.startQuickFocus)
        activity.title = "Start Quick Focus"
        activity.suggestedInvocationPhrase = "Start quick focus"
        activity.isEligibleForPrediction = true
        activity.isEligibleForSearch = true
        activity.persistentIdentifier = "focus.shortcut.quick"
        
        // Add user info to identify the preset
        activity.userInfo = ["preset": "quickFocus"]
        
        activity.becomeCurrent()
        
        let intent = createFocusIntent()
        let interaction = INInteraction(intent: intent, response: nil)
        interaction.donate { error in
            if let error = error {
                os_log("Failed to donate quick focus shortcut: %{public}@", log: .default, type: .error, error.localizedDescription)
            }
        }
    }
    
    /// Registers the show stats shortcut
    static func registerShowStatsShortcut() {
        let activity = NSUserActivity(activityType: AppConstants.ActivityTypes.showFocusStats)
        activity.title = "Show Focus Stats"
        activity.suggestedInvocationPhrase = "Show focus stats"
        activity.isEligibleForPrediction = true
        activity.isEligibleForSearch = true
        activity.persistentIdentifier = "focus.shortcut.stats"
        
        activity.becomeCurrent()
        
        let intent = createFocusIntent()
        let interaction = INInteraction(intent: intent, response: nil)
        interaction.donate { error in
            if let error = error {
                os_log("Failed to donate stats shortcut: %{public}@", log: .default, type: .error, error.localizedDescription)
            }
        }
    }
    
    // MARK: - Shortcut Handling
    
    /// Handles shortcut invocation
    static func handleShortcut(_ userActivity: NSUserActivity) -> Bool {
        let activityType = userActivity.activityType
        
        switch activityType {
        case AppConstants.ActivityTypes.startFocus:
            // Start current preset
            NotificationCenter.default.post(
                name: NSNotification.Name(AppConstants.NotificationNames.startFocusFromShortcut),
                object: nil,
                userInfo: ["preset": "current"]
            )
            return true
            
        case AppConstants.ActivityTypes.startDeepWork:
            // Start 45-minute deep work session
            NotificationCenter.default.post(
                name: NSNotification.Name(AppConstants.NotificationNames.startFocusFromShortcut),
                object: nil,
                userInfo: ["preset": "deepWork"]
            )
            return true
            
        case AppConstants.ActivityTypes.startQuickFocus:
            // Start 15-minute quick focus session
            NotificationCenter.default.post(
                name: NSNotification.Name(AppConstants.NotificationNames.startFocusFromShortcut),
                object: nil,
                userInfo: ["preset": "quickFocus"]
            )
            return true
            
        case AppConstants.ActivityTypes.showFocusStats:
            // Show today's focus stats
            NotificationCenter.default.post(
                name: NSNotification.Name("ShowFocusStats"),
                object: nil
            )
            return true
            
        default:
            return false
        }
    }
    
    // MARK: - Voice Shortcuts
    
    /// Creates a voice shortcut phrase
    static func createVoiceShortcut(phrase: String) {
        let intent = createFocusIntent()
        _ = INShortcut(intent: intent)
        
        // Note: Actual voice shortcut creation requires user interaction
        // This is just a helper method
    }
}

// MARK: - Shortcut Intent Handler

/// Handles Siri shortcut intents for focus sessions
@available(iOS 12.0, *)
class FocusIntentHandler: NSObject, INStartWorkoutIntentHandling {
    
    func handle(intent: INStartWorkoutIntent, completion: @escaping (INStartWorkoutIntentResponse) -> Void) {
        // Post notification to start focus session
        NotificationCenter.default.post(
            name: NSNotification.Name(AppConstants.NotificationNames.startFocusFromShortcut),
            object: nil
        )
        
        let response = INStartWorkoutIntentResponse(code: .success, userActivity: nil)
        completion(response)
    }
    
    func confirm(intent: INStartWorkoutIntent, completion: @escaping (INStartWorkoutIntentResponse) -> Void) {
        let response = INStartWorkoutIntentResponse(code: .ready, userActivity: nil)
        completion(response)
    }
}

