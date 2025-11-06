import Foundation

/// Watch-specific constants for Pomodoro timer
/// These constants mirror AppConstants.TimingConstants for the Watch app
enum WatchConstants {
    // MARK: - Timing Constants
    
    enum TimingConstants {
        // Pomodoro Timer Constants
        static let defaultFocusDuration: TimeInterval = 1500.0 // 25 minutes
        static let defaultShortBreakDuration: TimeInterval = 300.0 // 5 minutes
        static let defaultLongBreakDuration: TimeInterval = 900.0 // 15 minutes
        static let defaultPomodoroCycleLength: Int = 4 // 4 sessions = long break
    }
}

/// Represents the current phase of a Pomodoro session
/// This enum is used by the Watch app for Pomodoro timer state
enum PomodoroPhase: Equatable {
    case idle
    case focus
    case shortBreak
    case longBreak
    case completed
}

