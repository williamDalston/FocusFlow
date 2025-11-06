import Foundation
import ActivityKit
import WidgetKit

/// Live Activity manager for showing workout progress on lock screen (iOS 16.2+)
@available(iOS 16.2, *)
@MainActor
class LiveActivityManager {
    static let shared = LiveActivityManager()
    
    private var activity: Activity<WorkoutAttributes>?
    
    private init() {}
    
    // MARK: - Live Activity Management
    
    /// Starts a Live Activity for the workout
    func startWorkoutActivity(
        exerciseName: String,
        currentExercise: Int,
        totalExercises: Int,
        timeRemaining: TimeInterval,
        phase: String
    ) {
        // Check if Live Activities are available
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities are not enabled")
            return
        }
        
        let attributes = WorkoutAttributes(
            exerciseName: exerciseName,
            totalExercises: totalExercises
        )
        
        let contentState = WorkoutAttributes.ContentState(
            currentExercise: currentExercise,
            timeRemaining: timeRemaining,
            phase: phase,
            progress: Double(currentExercise) / Double(totalExercises)
        )
        
        let activityContent = ActivityContent(state: contentState, staleDate: nil)
        
        do {
            activity = try Activity<WorkoutAttributes>.request(
                attributes: attributes,
                content: activityContent,
                pushType: nil
            )
        } catch {
            print("Failed to start Live Activity: \(error)")
        }
    }
    
    /// Updates the Live Activity with current workout state
    func updateWorkoutActivity(
        exerciseName: String,
        currentExercise: Int,
        timeRemaining: TimeInterval,
        phase: String
    ) {
        guard let activity = activity else { return }
        
        let contentState = WorkoutAttributes.ContentState(
            currentExercise: currentExercise,
            timeRemaining: timeRemaining,
            phase: phase,
            progress: Double(currentExercise) / Double(activity.attributes.totalExercises)
        )
        
        let activityContent = ActivityContent(state: contentState, staleDate: nil)
        
        Task {
            await activity.update(activityContent)
        }
    }
    
    /// Ends the Live Activity when workout completes
    func endWorkoutActivity(isCompleted: Bool = true) {
        guard let activity = activity else { return }
        
        let finalState = WorkoutAttributes.ContentState(
            currentExercise: activity.attributes.totalExercises,
            timeRemaining: 0,
            phase: isCompleted ? "Complete" : "Stopped",
            progress: 1.0
        )
        
        let finalContent = ActivityContent(state: finalState, staleDate: nil)
        
        Task {
            await activity.end(finalContent, dismissalPolicy: .immediate)
        }
        
        self.activity = nil
    }
    
    /// Stops the Live Activity (for when workout is stopped)
    func stopWorkoutActivity() {
        endWorkoutActivity(isCompleted: false)
    }
}

// MARK: - Workout Attributes

/// Attributes for the workout Live Activity
@available(iOS 16.2, *)
struct WorkoutAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var currentExercise: Int
        var timeRemaining: TimeInterval
        var phase: String // "Exercise", "Rest", "Preparing", "Complete"
        var progress: Double
    }
    
    var exerciseName: String
    var totalExercises: Int
}

