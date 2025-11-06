import Foundation

/// Completion statistics for focus sessions
struct FocusCompletionStats {
    let isPersonalBest: Bool
    let isStreakDay: Bool
    let currentStreak: Int
    let unlockedAchievements: [Achievement]
    let totalSessions: Int
    let thisWeekSessions: Int
}

