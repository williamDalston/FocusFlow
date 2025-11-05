import Foundation
import Intents
import IntentsUI

/// Agent 8: iOS Shortcuts integration for quick workout start
/// Allows users to start workouts via Siri and Shortcuts app
enum WorkoutShortcuts {
    
    // MARK: - Intent Definition
    
    /// Creates a workout intent for Siri Shortcuts
    static func createWorkoutIntent() -> INIntent {
        let intent = INStartWorkoutIntent()
        intent.workoutName = "Ritual7"
        intent.goalValue = nil
        intent.workoutGoalUnitType = .minute
        return intent
    }
    
    // MARK: - Shortcut Registration
    
    /// Registers the workout shortcut with the system
    static func registerWorkoutShortcut() {
        let intent = createWorkoutIntent()
        let shortcut = INShortcut(intent: intent)
        
        // Create a user activity for the shortcut
        let activity = NSUserActivity(activityType: "com.williamalston.SevenMinuteWorkout.startWorkout")
        activity.title = "Start Ritual7"
        activity.suggestedInvocationPhrase = "Start workout"
        activity.isEligibleForPrediction = true
        activity.isEligibleForSearch = true
        activity.persistentIdentifier = "workout.shortcut"
        
        // Make the activity available for shortcuts
        activity.becomeCurrent()
        
        // Donate the shortcut to Siri
        let interaction = INInteraction(intent: intent, response: nil)
        interaction.donate { error in
            if let error = error {
                print("Failed to donate shortcut: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Shortcut Handling
    
    /// Handles shortcut invocation
    static func handleShortcut(_ userActivity: NSUserActivity) -> Bool {
        guard userActivity.activityType == "com.williamalston.SevenMinuteWorkout.startWorkout" else {
            return false
        }
        
        // Post notification to start workout
        NotificationCenter.default.post(
            name: NSNotification.Name("StartWorkoutFromShortcut"),
            object: nil
        )
        
        return true
    }
    
    // MARK: - Voice Shortcuts
    
    /// Creates a voice shortcut phrase
    static func createVoiceShortcut(phrase: String) {
        let intent = createWorkoutIntent()
        let shortcut = INShortcut(intent: intent)
        
        // Note: Actual voice shortcut creation requires user interaction
        // This is just a helper method
    }
}

// MARK: - Shortcut Intent Handler

/// Handles Siri shortcut intents
@available(iOS 12.0, *)
class WorkoutIntentHandler: NSObject, INStartWorkoutIntentHandling {
    
    func handle(intent: INStartWorkoutIntent, completion: @escaping (INStartWorkoutIntentResponse) -> Void) {
        // Post notification to start workout
        NotificationCenter.default.post(
            name: NSNotification.Name("StartWorkoutFromShortcut"),
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

// MARK: - Custom Intent (for better Shortcuts integration)

/// Custom intent for starting a workout
@available(iOS 12.0, *)
class StartWorkoutIntent: INIntent {
    @NSManaged var workoutType: String
}

// MARK: - Shortcut Intent Response

@available(iOS 12.0, *)
class StartWorkoutIntentResponse: INIntentResponse {
    enum Code: Int {
        case success = 1
        case failure = 0
        case failureRequiringAppLaunch = 2
    }
    
    var code: Code = .success
}


