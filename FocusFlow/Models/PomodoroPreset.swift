import Foundation

/// Agent 2: Pomodoro Preset - Predefined Pomodoro timer configurations
/// Agent 14: Enhanced with validation and helper methods
/// Replaces WorkoutPreset for Pomodoro Timer app
enum PomodoroPreset: String, Codable, CaseIterable, Identifiable {
    case classic = "classic"
    case deepWork = "deepWork"
    case shortSprints = "shortSprints"
    
    var id: String { rawValue }
    
    // MARK: - Agent 14: Validation
    
    /// Whether this preset is valid
    var isValid: Bool {
        focusDuration >= 60 && focusDuration <= 7200 && // 1 min to 2 hours
        shortBreakDuration >= 0 && shortBreakDuration <= 3600 && // 0 to 1 hour
        longBreakDuration >= 0 && longBreakDuration <= 7200 && // 0 to 2 hours
        cycleLength >= 1 && cycleLength <= 20 // 1 to 20 sessions
    }
    
    var displayName: String {
        switch self {
        case .classic: return "Classic Pomodoro"
        case .deepWork: return "Deep Work"
        case .shortSprints: return "Short Sprints"
        }
    }
    
    var description: String {
        switch self {
        case .classic:
            return "The classic Pomodoro Technique: 25 minutes of focused work, 5-minute breaks, 15-minute long break."
        case .deepWork:
            return "Extended focus sessions for deep work: 45 minutes of focus, 15-minute breaks, 30-minute long break."
        case .shortSprints:
            return "Quick focus bursts: 15 minutes of focus, 3-minute breaks, 15-minute long break."
        }
    }
    
    var icon: String {
        switch self {
        case .classic: return "timer"
        case .deepWork: return "brain.head.profile"
        case .shortSprints: return "bolt.fill"
        }
    }
    
    /// Focus duration in seconds
    var focusDuration: TimeInterval {
        switch self {
        case .classic: return 25 * 60 // 25 minutes
        case .deepWork: return 45 * 60 // 45 minutes
        case .shortSprints: return 15 * 60 // 15 minutes
        }
    }
    
    /// Short break duration in seconds
    var shortBreakDuration: TimeInterval {
        switch self {
        case .classic: return 5 * 60 // 5 minutes
        case .deepWork: return 15 * 60 // 15 minutes
        case .shortSprints: return 3 * 60 // 3 minutes
        }
    }
    
    /// Long break duration in seconds
    var longBreakDuration: TimeInterval {
        switch self {
        case .classic: return 15 * 60 // 15 minutes
        case .deepWork: return 30 * 60 // 30 minutes
        case .shortSprints: return 15 * 60 // 15 minutes
        }
    }
    
    /// Number of focus sessions before a long break (default is 4)
    var cycleLength: Int {
        return 4
    }
    
    /// Focus duration in minutes (for display)
    var focusDurationMinutes: Int {
        Int(focusDuration / 60)
    }
    
    /// Short break duration in minutes (for display)
    var shortBreakDurationMinutes: Int {
        Int(shortBreakDuration / 60)
    }
    
    /// Long break duration in minutes (for display)
    var longBreakDurationMinutes: Int {
        Int(longBreakDuration / 60)
    }
    
    // MARK: - Agent 14: Helper Methods
    
    /// Get total cycle duration (all focus sessions + breaks)
    func totalCycleDuration() -> TimeInterval {
        let focusTime = TimeInterval(cycleLength) * focusDuration
        let shortBreakTime = TimeInterval(cycleLength - 1) * shortBreakDuration
        let longBreakTime = longBreakDuration
        return focusTime + shortBreakTime + longBreakTime
    }
    
    /// Get total cycle duration in minutes (for display)
    var totalCycleDurationMinutes: Int {
        Int(totalCycleDuration() / 60)
    }
    
    /// Get estimated completion time for a full cycle
    func estimatedCycleCompletionTime() -> TimeInterval {
        totalCycleDuration()
    }
    
    /// Compare with another preset
    func isSimilar(to other: PomodoroPreset) -> Bool {
        abs(focusDuration - other.focusDuration) < 60 && // Within 1 minute
        abs(shortBreakDuration - other.shortBreakDuration) < 60 &&
        abs(longBreakDuration - other.longBreakDuration) < 300 // Within 5 minutes
    }
}

