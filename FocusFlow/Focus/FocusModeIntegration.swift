import Foundation
import Intents
import IntentsUI

/// Agent 6: Focus Mode Integration - Integrates with iOS Focus Mode for distraction-free focus sessions
/// Handles Do Not Disturb and Focus Mode integration during Pomodoro sessions
@MainActor
final class FocusModeIntegration: ObservableObject {
    @Published var isFocusModeEnabled: Bool = false
    @Published var isDoNotDisturbEnabled: Bool = false
    
    private var focusModeIntent: INStartWorkoutIntent?
    
    init() {
        checkFocusModeStatus()
    }
    
    /// Check current Focus Mode status
    func checkFocusModeStatus() {
        // Note: iOS doesn't provide direct API to check Focus Mode status
        // This is a placeholder for future implementation
        // In iOS 15+, we can use INStartWorkoutIntent to suggest Focus Mode activation
        isFocusModeEnabled = false
        isDoNotDisturbEnabled = false
    }
    
    /// Request Focus Mode activation for focus session
    func requestFocusMode(for duration: TimeInterval) {
        // Create a workout intent that can trigger Focus Mode
        // iOS may suggest activating Focus Mode when starting a workout/focus session
        // Note: INStartWorkoutIntent properties are set via initializer
        let workoutName = INSpeakableString(spokenPhrase: "Focus Session")
        let intent = INStartWorkoutIntent(
            workoutName: workoutName,
            goalValue: duration,
            workoutLocationType: .indoor,
            isOpenEnded: false
        )
        
        self.focusModeIntent = intent
        
        // Note: Actual Focus Mode activation requires user interaction
        // This is a suggestion/request pattern
    }
    
    /// Enable Do Not Disturb mode (legacy, iOS 15+ uses Focus Mode)
    func enableDoNotDisturb() {
        // Note: Do Not Disturb is now part of Focus Mode in iOS 15+
        // This is a placeholder for backwards compatibility
        isDoNotDisturbEnabled = true
    }
    
    /// Disable Do Not Disturb mode
    func disableDoNotDisturb() {
        isDoNotDisturbEnabled = false
    }
    
    /// Get Focus Mode suggestion view controller (for iOS 15+)
    func getFocusModeSuggestionViewController() -> UIViewController? {
        guard let intent = focusModeIntent else { return nil }
        
        // Create an intent view controller for Focus Mode suggestion
        // Note: INUIAddVoiceShortcutViewController requires different initialization
        // For now, return nil as this is a placeholder implementation
        return nil
    }
    
    /// Show Focus Mode activation prompt
    func showFocusModePrompt() {
        // This would typically show a system prompt suggesting Focus Mode activation
        // Implementation depends on iOS version and availability
        requestFocusMode(for: 25 * 60) // Default 25 minutes
    }
}

/// Helper extension for Focus Mode integration utilities
extension FocusModeIntegration {
    /// Check if Focus Mode is available on this device
    static var isAvailable: Bool {
        // Focus Mode is available on iOS 15+
        if #available(iOS 15.0, *) {
            return true
        }
        return false
    }
    
    /// Get recommended Focus Mode configuration for Pomodoro
    static func getRecommendedFocusMode() -> String {
        return """
        Recommended Focus Mode settings for Pomodoro:
        - Allow: Timer apps, Music
        - Silence: Notifications, Calls (except favorites)
        - Enable: Do Not Disturb
        """
    }
}

