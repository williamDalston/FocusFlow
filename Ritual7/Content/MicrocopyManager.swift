import Foundation

/// Agent 30: Centralized microcopy manager for consistent, helpful messaging throughout the app
/// Provides personalized success messages, button labels, tooltips, and help text
class MicrocopyManager {
    static let shared = MicrocopyManager()
    
    private init() {}
    
    // MARK: - Success Messages
    
    /// Personalized workout completion messages based on user stats
    func completionMessage(for stats: WorkoutCompletionStats) -> String {
        if stats.isPersonalBest {
            return personalBestMessage()
        } else if stats.isStreakDay {
            return streakMessage(days: stats.currentStreak)
        } else if stats.unlockedAchievements.isEmpty == false {
            return achievementUnlockMessage()
        } else {
            return generalCompletionMessage()
        }
    }
    
    private func personalBestMessage() -> String {
        let messages = [
            "Personal best! You're getting stronger! 💪",
            "New record! You're crushing it! 🔥",
            "You beat your best time! Keep pushing! 🚀",
            "Personal record achieved! Amazing work! ⭐",
            "You're faster than ever! Incredible! 💯"
        ]
        return messages.randomElement() ?? messages[0]
    }
    
    private func streakMessage(days: Int) -> String {
        if days >= 30 {
            return "Day \(days) of your streak! You're unstoppable! 🌟"
        } else if days >= 14 {
            return "Day \(days) of your streak! You're building an amazing habit! 🔥"
        } else if days >= 7 {
            return "Day \(days) of your streak! Keep the momentum going! 💪"
        } else {
            return "Day \(days) of your streak! You're on fire! 🔥"
        }
    }
    
    private func achievementUnlockMessage() -> String {
        let messages = [
            "Achievement unlocked! You're leveling up! 🏆",
            "New badge earned! Keep going! ⭐",
            "You've unlocked a milestone! Amazing! 🎉"
        ]
        return messages.randomElement() ?? messages[0]
    }
    
    private func generalCompletionMessage() -> String {
        let messages = [
            "Great job completing your workout!",
            "You did it! Well done!",
            "Workout complete! You're awesome!",
            "Excellent work! You finished strong!",
            "You nailed it! Keep it up!"
        ]
        return messages.randomElement() ?? messages[0]
    }
    
    /// Milestone celebration messages for special achievements
    func milestoneMessage(for milestone: Milestone) -> String {
        switch milestone {
        case .firstWorkout:
            return "First workout complete! Welcome to your fitness journey! 🎉"
        case .weekStreak:
            return "7 days in a row! You're building a powerful habit! 🔥"
        case .monthStreak:
            return "30 days strong! You're unstoppable! 🌟"
        case .hundredWorkouts:
            return "100 workouts completed! You're a fitness champion! 🏆"
        case .fiveHundredWorkouts:
            return "500 workouts! You're a legend! ⭐"
        }
    }
    
    /// Suggestion messages for next workout
    func suggestionMessage(for stats: WorkoutCompletionStats) -> String {
        if stats.currentStreak >= 30 {
            return "You're on fire! Keep your incredible streak going tomorrow."
        } else if stats.currentStreak >= 14 {
            return "You're building an amazing habit! Work out again tomorrow to keep growing your streak."
        } else if stats.currentStreak >= 7 {
            return "Great momentum! Work out again tomorrow to reach your first week streak!"
        } else if stats.currentStreak > 0 {
            return "You're building a great habit! Work out again tomorrow to grow your streak."
        } else {
            return "Start a streak by working out again tomorrow! Every day counts."
        }
    }
    
    // MARK: - Button Labels
    // Note: ButtonLabel is defined as a top-level type below for easier access
    
    // MARK: - Tooltips & Help Text
    
    /// Helpful tooltips for icon-only buttons and complex features
    func tooltip(for feature: HelpFeature) -> String {
        switch feature {
        case .startWorkout:
            return "Begin your 7-minute workout. Press Enter key to start."
        case .customizeWorkout:
            return "Customize exercise duration, rest periods, and workout preferences."
        case .viewExercises:
            return "Browse all available exercises with descriptions and instructions."
        case .viewHistory:
            return "View your past workout sessions and track your progress."
        case .pauseWorkout:
            return "Pause the workout. You can resume anytime."
        case .resumeWorkout:
            return "Resume the paused workout."
        case .skipRest:
            return "Skip the rest period and move to the next exercise immediately."
        case .skipPrep:
            return "Skip the preparation countdown and start the workout immediately."
        case .stopWorkout:
            return "Stop the workout and return to the main screen."
        case .voiceCues:
            return "Toggle voice guidance during workouts. Turn off for silent workouts."
        case .gestureSwipe:
            return "Swipe right to pause, swipe left to skip rest. Try it!"
        case .shareWorkout:
            return "Share your workout completion with friends and family."
        case .settings:
            return "Configure app settings, appearance, and notifications."
        case .help:
            return "Get help and learn more about using the app."
        }
    }
    
    // MARK: - Empty State Messages
    
    /// Enhanced empty state messages with actionable guidance
    func emptyStateMessage(for type: EmptyStateType) -> (title: String, message: String, actionTitle: String?) {
        switch type {
        case .noWorkouts:
            let messages = [
                ("No Workouts Yet", "Your fitness journey starts with a single step. Begin your first workout to build momentum.", "Start Workout"),
                ("Ready to Begin?", "Ready to transform your routine? Start your first workout and unlock your potential.", "Start Workout"),
                ("Let's Get Started", "Every champion started somewhere. Begin your workout streak today.", "Start Workout")
            ]
            return messages.randomElement() ?? messages[0]
            
        case .noHistoryFound:
            return ("No Results Found", "We couldn't find any workouts matching your search. Try adjusting your filters or clearing your search to see all workouts.", "Clear Filters")
            
        case .noExercisesFound:
            return ("No Exercises Found", "No exercises match your current search or filters. Try different search terms or clear your filters to browse all exercises.", "Clear Filters")
            
        case .noAchievements:
            let messages: [(String, String, String?)] = [
                ("No Achievements Yet", "Complete workouts to unlock achievements and track your progress. Every workout counts!", nil),
                ("Start Unlocking", "Your achievements are waiting. Complete workouts to unlock badges and celebrate your progress.", nil),
                ("Build Your Collection", "Start building your achievement collection. Complete workouts to unlock rewards and track milestones.", nil)
            ]
            return messages.randomElement() ?? messages[0]
            
        case .noInsights:
            let messages: [(String, String, String?)] = [
                ("Complete More Workouts", "Complete more workouts to unlock personalized insights and discover your fitness patterns.", nil),
                ("Insights Coming Soon", "Your workout data creates valuable insights. Complete a few more workouts to see personalized trends and recommendations.", nil),
                ("Build Your Data", "Insights are generated from your workout history. Complete workouts to unlock personalized analytics and recommendations.", nil)
            ]
            return messages.randomElement() ?? messages[0]
            
        case .noGoals:
            let messages = [
                ("Set Your First Goal", "Set a fitness goal to stay motivated and track your progress. Goals help turn intentions into achievements.", "Create Goal"),
                ("Define Your Target", "Goals give your workouts purpose. Set a weekly or monthly goal to stay motivated and track your progress.", "Create Goal"),
                ("Start Achieving", "Turn your fitness intentions into reality. Set a goal to stay motivated and celebrate your achievements.", "Create Goal")
            ]
            return messages.randomElement() ?? messages[0]
        }
    }
    
    // MARK: - Contextual Help
    
    /// Contextual help text for complex features
    /// Note: HelpContext is defined in ContextualHelpManager.swift
    func contextualHelp(for context: HelpContext) -> String {
        switch context {
        case .workoutCustomization:
            return "Customize your workout by adjusting exercise duration, rest periods, and selecting specific exercises. Changes are saved automatically."
        case .workoutHistory:
            return "View all your past workouts, track your progress, and see your workout statistics. Swipe to delete or tap to view details."
        case .streakTracking:
            return "Your streak is the number of consecutive days you've completed a workout. Work out every day to keep it growing!"
        case .achievements:
            return "Achievements are unlocked by completing workouts and reaching milestones. Check back regularly to see your progress."
        case .settings:
            return "Configure app appearance, notifications, sound settings, and more. All changes are saved automatically."
        case .healthIntegration:
            return "Connect with Apple Health to sync your workouts automatically. Your health data is private and secure."
        case .gestureControls:
            return "Use swipe gestures to control your workout. Swipe right to pause or resume, swipe left to skip rest periods."
        }
    }
}

// MARK: - Supporting Types

/// Clear, action-oriented button labels
enum ButtonLabel {
    case startWorkout
    case customize
    case viewExercises
    case viewHistory
    case pause
    case resume
    case skipRest
    case skipPrep
    case stopWorkout
    case done
    case next
    case back
    case share
    case startNew
    case viewHelp
    
    var text: String {
        switch self {
        case .startWorkout:
            return "Start Workout"
        case .customize:
            return "Customize"
        case .viewExercises:
            return "View Exercises"
        case .viewHistory:
            return "View History"
        case .pause:
            return "Pause"
        case .resume:
            return "Resume"
        case .skipRest:
            return "Skip Rest"
        case .skipPrep:
            return "Skip Prep"
        case .stopWorkout:
            return "Stop Workout"
        case .done:
            return "Done"
        case .next:
            return "Next"
        case .back:
            return "Back"
        case .share:
            return "Share"
        case .startNew:
            return "Start New Workout"
        case .viewHelp:
            return "Help & Support"
        }
    }
}

enum Milestone {
    case firstWorkout
    case weekStreak
    case monthStreak
    case hundredWorkouts
    case fiveHundredWorkouts
}

enum HelpFeature {
    case startWorkout
    case customizeWorkout
    case viewExercises
    case viewHistory
    case pauseWorkout
    case resumeWorkout
    case skipRest
    case skipPrep
    case stopWorkout
    case voiceCues
    case gestureSwipe
    case shareWorkout
    case settings
    case help
}

enum EmptyStateType {
    case noWorkouts
    case noHistoryFound
    case noExercisesFound
    case noAchievements
    case noInsights
    case noGoals
}

// HelpContext enum is defined in ContextualHelpManager.swift

