import Foundation
import SwiftUI

/// Agent 2 & 4: Achievement Manager - Tracks and manages focus achievements
/// Agent 28: Enhanced with VoiceOver announcements for achievement unlocks
/// Agent 4: Refactored for Pomodoro focus sessions
@MainActor
final class AchievementManager: ObservableObject {
    private let store: FocusStore
    
    @Published private(set) var unlockedAchievements: Set<Achievement> = []
    @Published private(set) var recentUnlocks: [Achievement] = []
    
    private let unlockedKey = "achievements.unlocked"
    private let recentUnlocksKey = "achievements.recent"
    
    init(store: FocusStore) {
        self.store = store
        load()
        checkAchievements()
    }
    
    // MARK: - Achievement Checking
    
    func checkAchievements() {
        var newlyUnlocked: [Achievement] = []
        
        // First focus session
        let focusSessions = store.sessions.filter { $0.phaseType == .focus && $0.completed }
        if focusSessions.count >= 1 && !unlockedAchievements.contains(.firstFocusSession) {
            newlyUnlocked.append(.firstFocusSession)
        }
        
        // 7-day streak
        if store.streak >= 7 && !unlockedAchievements.contains(.sevenDayStreak) {
            newlyUnlocked.append(.sevenDayStreak)
        }
        
        // 30-day streak
        if store.streak >= 30 && !unlockedAchievements.contains(.thirtyDayStreak) {
            newlyUnlocked.append(.thirtyDayStreak)
        }
        
        // 100 focus sessions
        if focusSessions.count >= 100 && !unlockedAchievements.contains(.hundredSessions) {
            newlyUnlocked.append(.hundredSessions)
        }
        
        // Perfect week (daily focus sessions)
        if store.sessionsThisWeek >= 7 && !unlockedAchievements.contains(.perfectWeek) {
            newlyUnlocked.append(.perfectWeek)
        }
        
        // Early bird (morning focus sessions)
        let morningFocus = countMorningFocusSessions()
        if morningFocus >= 10 && !unlockedAchievements.contains(.earlyBird) {
            newlyUnlocked.append(.earlyBird)
        }
        
        // Night owl (evening focus sessions)
        let eveningFocus = countEveningFocusSessions()
        if eveningFocus >= 10 && !unlockedAchievements.contains(.nightOwl) {
            newlyUnlocked.append(.nightOwl)
        }
        
        // Deep Focus (completed 4-session cycle = 1 full Pomodoro cycle)
        let cyclesCompleted = focusSessions.count / 4
        if cyclesCompleted >= 1 && !unlockedAchievements.contains(.deepFocus) {
            newlyUnlocked.append(.deepFocus)
        }
        
        // Unlock new achievements
        for achievement in newlyUnlocked {
            unlock(achievement)
        }
    }
    
    private func unlock(_ achievement: Achievement) {
        unlockedAchievements.insert(achievement)
        recentUnlocks.append(achievement)
        
        // Keep only last 5 recent unlocks
        if recentUnlocks.count > 5 {
            if !recentUnlocks.isEmpty {
                recentUnlocks.removeFirst()
            }
        }
        
        save()
        
        // Agent 28: Announce achievement unlock via VoiceOver
        AccessibilityAnnouncer.announceAchievementUnlocked(achievement.title)
        
        // ASO: Consider review prompt after achievement unlock
        Task { @MainActor in
            let achievementCount = unlockedAchievements.count
            ReviewGate.considerPromptAfterAchievement(achievementCount: achievementCount)
            
            // ASO: Track engagement
            ASOAnalytics.shared.trackEngagement(event: "achievement_unlocked", value: achievementCount)
            
            // ASO: Track conversion funnel for first achievement
            if achievementCount == 1 {
                ASOAnalytics.shared.trackConversionFunnel(stage: "achievement_unlock")
            }
        }
    }
    
    // MARK: - Helpers
    
    private func countMorningFocusSessions() -> Int {
        let calendar = Calendar.current
        return store.sessions.filter { session in
            session.phaseType == .focus && session.completed &&
            calendar.component(.hour, from: session.date) >= 5 &&
            calendar.component(.hour, from: session.date) < 12
        }.count
    }
    
    private func countEveningFocusSessions() -> Int {
        let calendar = Calendar.current
        return store.sessions.filter { session in
            session.phaseType == .focus && session.completed &&
            calendar.component(.hour, from: session.date) >= 17 &&
            calendar.component(.hour, from: session.date) < 22
        }.count
    }
    
    // MARK: - Persistence
    
    private func load() {
        let d = UserDefaults.standard
        
        // Load unlocked achievements
        if let data = d.data(forKey: unlockedKey),
           let decoded = try? JSONDecoder().decode([String].self, from: data) {
            unlockedAchievements = Set(decoded.compactMap { Achievement(rawValue: $0) })
        }
        
        // Load recent unlocks
        if let data = d.data(forKey: recentUnlocksKey),
           let decoded = try? JSONDecoder().decode([String].self, from: data) {
            recentUnlocks = decoded.compactMap { Achievement(rawValue: $0) }
        }
    }
    
    private func save() {
        let d = UserDefaults.standard
        
        let unlockedStrings = unlockedAchievements.map { $0.rawValue }
        if let data = try? JSONEncoder().encode(unlockedStrings) {
            d.set(data, forKey: unlockedKey)
        }
        
        let recentStrings = recentUnlocks.map { $0.rawValue }
        if let data = try? JSONEncoder().encode(recentStrings) {
            d.set(data, forKey: recentUnlocksKey)
        }
    }
    
    // MARK: - Progress Tracking
    
    func progressForAchievement(_ achievement: Achievement) -> Double {
        let focusSessions = store.sessions.filter { $0.phaseType == .focus && $0.completed }
        switch achievement {
        case .firstFocusSession:
            return min(1.0, Double(focusSessions.count) / 1.0)
        case .sevenDayStreak:
            return min(1.0, Double(store.streak) / 7.0)
        case .thirtyDayStreak:
            return min(1.0, Double(store.streak) / 30.0)
        case .hundredSessions:
            return min(1.0, Double(focusSessions.count) / 100.0)
        case .perfectWeek:
            return min(1.0, Double(store.sessionsThisWeek) / 7.0)
        case .earlyBird:
            let count = countMorningFocusSessions()
            return min(1.0, Double(count) / 10.0)
        case .nightOwl:
            let count = countEveningFocusSessions()
            return min(1.0, Double(count) / 10.0)
        case .deepFocus:
            let cycles = focusSessions.count / 4
            return min(1.0, Double(cycles) / 1.0)
        }
    }
    
    // MARK: - Agent 21: Next Achievement Helpers
    
    /// Get the next closest unlocked achievement
    func nextAchievement() -> (achievement: Achievement, remaining: Int, progressText: String)? {
        let lockedAchievements = Achievement.allCases.filter { !unlockedAchievements.contains($0) }
        
        // Find the closest achievement based on progress
        var closest: (achievement: Achievement, remaining: Int, progress: Double)?
        
        for achievement in lockedAchievements {
            let progress = progressForAchievement(achievement)
            let remaining = calculateRemaining(for: achievement)
            
            if progress > 0 {
                if let currentClosest = closest {
                    if progress > currentClosest.progress {
                        closest = (achievement, remaining, progress)
                    }
                } else {
                    closest = (achievement, remaining, progress)
                }
            }
        }
        
        guard let closestAchievement = closest else { return nil }
        
        let progressText = generateProgressText(for: closestAchievement.achievement, remaining: closestAchievement.remaining)
        
        return (closestAchievement.achievement, closestAchievement.remaining, progressText)
    }
    
    /// Get up to 3 closest achievements for preview
    func closestAchievements(limit: Int = 3) -> [(achievement: Achievement, remaining: Int, progress: Double, progressText: String)] {
        let lockedAchievements = Achievement.allCases.filter { !unlockedAchievements.contains($0) }
        
        var candidates: [(achievement: Achievement, remaining: Int, progress: Double, progressText: String)] = []
        
        for achievement in lockedAchievements {
            let progress = progressForAchievement(achievement)
            if progress > 0 {
                let remaining = calculateRemaining(for: achievement)
                let progressText = generateProgressText(for: achievement, remaining: remaining)
                candidates.append((achievement, remaining, progress, progressText))
            }
        }
        
        // Sort by progress (descending) and take top N
        return candidates.sorted { $0.progress > $1.progress }.prefix(limit).map { $0 }
    }
    
    /// Calculate remaining focus sessions/actions needed for an achievement
    private func calculateRemaining(for achievement: Achievement) -> Int {
        let focusSessions = store.sessions.filter { $0.phaseType == .focus && $0.completed }
        switch achievement {
        case .firstFocusSession:
            return max(0, 1 - focusSessions.count)
        case .sevenDayStreak:
            return max(0, 7 - store.streak)
        case .thirtyDayStreak:
            return max(0, 30 - store.streak)
        case .hundredSessions:
            return max(0, 100 - focusSessions.count)
        case .perfectWeek:
            return max(0, 7 - store.sessionsThisWeek)
        case .earlyBird:
            let count = countMorningFocusSessions()
            return max(0, 10 - count)
        case .nightOwl:
            let count = countEveningFocusSessions()
            return max(0, 10 - count)
        case .deepFocus:
            let cycles = focusSessions.count / 4
            return max(0, 1 - cycles)
        }
    }
    
    /// Generate progress text for an achievement
    private func generateProgressText(for achievement: Achievement, remaining: Int) -> String {
        switch achievement {
        case .firstFocusSession:
            return remaining == 1 ? "Complete your first focus session!" : "\(remaining) sessions until \(achievement.title)"
        case .sevenDayStreak:
            return remaining == 1 ? "1 day until \(achievement.title)!" : "\(remaining) days until \(achievement.title)"
        case .thirtyDayStreak:
            return remaining == 1 ? "1 day until \(achievement.title)!" : "\(remaining) days until \(achievement.title)"
        case .perfectWeek:
            return remaining == 1 ? "1 session until \(achievement.title)!" : "\(remaining) sessions until \(achievement.title)"
        case .earlyBird:
            return remaining == 1 ? "1 morning focus session until \(achievement.title)!" : "\(remaining) morning focus sessions until \(achievement.title)"
        case .nightOwl:
            return remaining == 1 ? "1 evening focus session until \(achievement.title)!" : "\(remaining) evening focus sessions until \(achievement.title)"
        case .hundredSessions:
            return remaining == 1 ? "1 session until \(achievement.title)!" : "\(remaining) sessions until \(achievement.title)"
        case .deepFocus:
            return remaining == 1 ? "Complete 1 more Pomodoro cycle!" : "Complete \(remaining) more Pomodoro cycle\(remaining == 1 ? "" : "s")!"
        }
    }
    
    /// Get current value for an achievement (for display)
    func currentValue(for achievement: Achievement) -> Int {
        let focusSessions = store.sessions.filter { $0.phaseType == .focus && $0.completed }
        switch achievement {
        case .firstFocusSession:
            return focusSessions.count
        case .sevenDayStreak, .thirtyDayStreak:
            return store.streak
        case .hundredSessions:
            return focusSessions.count
        case .perfectWeek:
            return store.sessionsThisWeek
        case .earlyBird:
            return countMorningFocusSessions()
        case .nightOwl:
            return countEveningFocusSessions()
        case .deepFocus:
            return focusSessions.count / 4
        }
    }
    
    /// Get target value for an achievement
    func targetValue(for achievement: Achievement) -> Int {
        switch achievement {
        case .firstFocusSession: return 1
        case .sevenDayStreak: return 7
        case .thirtyDayStreak: return 30
        case .hundredSessions: return 100
        case .perfectWeek: return 7
        case .earlyBird: return 10
        case .nightOwl: return 10
        case .deepFocus: return 1
        }
    }
}

// MARK: - Achievement Model

enum Achievement: String, CaseIterable, Codable, Identifiable {
    case firstFocusSession = "first_focus_session"
    case sevenDayStreak = "seven_day_streak"
    case thirtyDayStreak = "thirty_day_streak"
    case hundredSessions = "hundred_sessions"
    case perfectWeek = "perfect_week"
    case earlyBird = "early_bird"
    case nightOwl = "night_owl"
    case deepFocus = "deep_focus"
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .firstFocusSession: return "First Focus"
        case .sevenDayStreak: return "Week Warrior"
        case .thirtyDayStreak: return "Monthly Master"
        case .hundredSessions: return "Century Club"
        case .perfectWeek: return "Perfect Week"
        case .earlyBird: return "Early Bird"
        case .nightOwl: return "Night Owl"
        case .deepFocus: return "Deep Focus"
        }
    }
    
    var description: String {
        switch self {
        case .firstFocusSession: return "Complete your first focus session"
        case .sevenDayStreak: return "Maintain a 7-day focus streak"
        case .thirtyDayStreak: return "Maintain a 30-day focus streak"
        case .hundredSessions: return "Complete 100 focus sessions"
        case .perfectWeek: return "Complete 7 focus sessions in 7 days"
        case .earlyBird: return "Complete 10 morning focus sessions"
        case .nightOwl: return "Complete 10 evening focus sessions"
        case .deepFocus: return "Complete a full Pomodoro cycle (4 sessions)"
        }
    }
    
    var icon: String {
        switch self {
        case .firstFocusSession: return "star.fill"
        case .sevenDayStreak: return "flame.fill"
        case .thirtyDayStreak: return "flame.fill"
        case .hundredSessions: return "trophy.fill"
        case .perfectWeek: return "checkmark.circle.fill"
        case .earlyBird: return "sunrise.fill"
        case .nightOwl: return "moon.stars.fill"
        case .deepFocus: return "infinity"
        }
    }
    
    var color: Color {
        switch self {
        case .firstFocusSession: return .yellow
        case .sevenDayStreak: return .orange
        case .thirtyDayStreak: return .red
        case .hundredSessions: return .purple
        case .perfectWeek: return .green
        case .earlyBird: return .yellow
        case .nightOwl: return .indigo
        case .deepFocus: return .blue
        }
    }
    
    var rarity: Rarity {
        switch self {
        case .firstFocusSession: return .common
        case .sevenDayStreak: return .uncommon
        case .thirtyDayStreak: return .rare
        case .hundredSessions: return .epic
        case .perfectWeek: return .uncommon
        case .earlyBird: return .common
        case .nightOwl: return .common
        case .deepFocus: return .uncommon
        }
    }
    
    enum Rarity {
        case common
        case uncommon
        case rare
        case epic
        case legendary
    }
}

