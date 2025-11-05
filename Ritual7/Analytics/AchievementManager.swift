import Foundation
import SwiftUI

/// Agent 2: Achievement Manager - Tracks and manages workout achievements
/// Agent 28: Enhanced with VoiceOver announcements for achievement unlocks
@MainActor
final class AchievementManager: ObservableObject {
    private let store: WorkoutStore
    
    @Published private(set) var unlockedAchievements: Set<Achievement> = []
    @Published private(set) var recentUnlocks: [Achievement] = []
    
    private let unlockedKey = "achievements.unlocked"
    private let recentUnlocksKey = "achievements.recent"
    
    init(store: WorkoutStore) {
        self.store = store
        load()
        checkAchievements()
    }
    
    // MARK: - Achievement Checking
    
    func checkAchievements() {
        var newlyUnlocked: [Achievement] = []
        
        // First workout
        if store.totalWorkouts >= 1 && !unlockedAchievements.contains(.firstWorkout) {
            newlyUnlocked.append(.firstWorkout)
        }
        
        // 7-day streak
        if store.streak >= 7 && !unlockedAchievements.contains(.sevenDayStreak) {
            newlyUnlocked.append(.sevenDayStreak)
        }
        
        // 30-day streak
        if store.streak >= 30 && !unlockedAchievements.contains(.thirtyDayStreak) {
            newlyUnlocked.append(.thirtyDayStreak)
        }
        
        // 100 workouts
        if store.totalWorkouts >= 100 && !unlockedAchievements.contains(.hundredWorkouts) {
            newlyUnlocked.append(.hundredWorkouts)
        }
        
        // Perfect week (7 workouts in 7 days)
        if store.workoutsThisWeek >= 7 && !unlockedAchievements.contains(.perfectWeek) {
            newlyUnlocked.append(.perfectWeek)
        }
        
        // Monthly consistency (20+ workouts in a month)
        if store.workoutsThisMonth >= 20 && !unlockedAchievements.contains(.monthlyConsistency) {
            newlyUnlocked.append(.monthlyConsistency)
        }
        
        // Early bird (morning workouts)
        let morningWorkouts = countMorningWorkouts()
        if morningWorkouts >= 10 && !unlockedAchievements.contains(.earlyBird) {
            newlyUnlocked.append(.earlyBird)
        }
        
        // Night owl (evening workouts)
        let eveningWorkouts = countEveningWorkouts()
        if eveningWorkouts >= 10 && !unlockedAchievements.contains(.nightOwl) {
            newlyUnlocked.append(.nightOwl)
        }
        
        // 50 workouts
        if store.totalWorkouts >= 50 && !unlockedAchievements.contains(.fiftyWorkouts) {
            newlyUnlocked.append(.fiftyWorkouts)
        }
        
        // 200 workouts
        if store.totalWorkouts >= 200 && !unlockedAchievements.contains(.twoHundredWorkouts) {
            newlyUnlocked.append(.twoHundredWorkouts)
        }
        
        // 500 workouts
        if store.totalWorkouts >= 500 && !unlockedAchievements.contains(.fiveHundredWorkouts) {
            newlyUnlocked.append(.fiveHundredWorkouts)
        }
        
        // 1000 workouts
        if store.totalWorkouts >= 1000 && !unlockedAchievements.contains(.thousandWorkouts) {
            newlyUnlocked.append(.thousandWorkouts)
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
    
    private func countMorningWorkouts() -> Int {
        let calendar = Calendar.current
        return store.sessions.filter { session in
            let hour = calendar.component(.hour, from: session.date)
            return hour >= 5 && hour < 12
        }.count
    }
    
    private func countEveningWorkouts() -> Int {
        let calendar = Calendar.current
        return store.sessions.filter { session in
            let hour = calendar.component(.hour, from: session.date)
            return hour >= 17 && hour < 22
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
        switch achievement {
        case .firstWorkout:
            return min(1.0, Double(store.totalWorkouts) / 1.0)
        case .sevenDayStreak:
            return min(1.0, Double(store.streak) / 7.0)
        case .thirtyDayStreak:
            return min(1.0, Double(store.streak) / 30.0)
        case .hundredWorkouts:
            return min(1.0, Double(store.totalWorkouts) / 100.0)
        case .perfectWeek:
            return min(1.0, Double(store.workoutsThisWeek) / 7.0)
        case .monthlyConsistency:
            return min(1.0, Double(store.workoutsThisMonth) / 20.0)
        case .earlyBird:
            let count = countMorningWorkouts()
            return min(1.0, Double(count) / 10.0)
        case .nightOwl:
            let count = countEveningWorkouts()
            return min(1.0, Double(count) / 10.0)
        case .fiftyWorkouts:
            return min(1.0, Double(store.totalWorkouts) / 50.0)
        case .twoHundredWorkouts:
            return min(1.0, Double(store.totalWorkouts) / 200.0)
        case .fiveHundredWorkouts:
            return min(1.0, Double(store.totalWorkouts) / 500.0)
        case .thousandWorkouts:
            return min(1.0, Double(store.totalWorkouts) / 1000.0)
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
    
    /// Calculate remaining workouts/actions needed for an achievement
    private func calculateRemaining(for achievement: Achievement) -> Int {
        switch achievement {
        case .firstWorkout:
            return max(0, 1 - store.totalWorkouts)
        case .sevenDayStreak:
            return max(0, 7 - store.streak)
        case .thirtyDayStreak:
            return max(0, 30 - store.streak)
        case .hundredWorkouts:
            return max(0, 100 - store.totalWorkouts)
        case .perfectWeek:
            return max(0, 7 - store.workoutsThisWeek)
        case .monthlyConsistency:
            return max(0, 20 - store.workoutsThisMonth)
        case .earlyBird:
            let count = countMorningWorkouts()
            return max(0, 10 - count)
        case .nightOwl:
            let count = countEveningWorkouts()
            return max(0, 10 - count)
        case .fiftyWorkouts:
            return max(0, 50 - store.totalWorkouts)
        case .twoHundredWorkouts:
            return max(0, 200 - store.totalWorkouts)
        case .fiveHundredWorkouts:
            return max(0, 500 - store.totalWorkouts)
        case .thousandWorkouts:
            return max(0, 1000 - store.totalWorkouts)
        }
    }
    
    /// Generate progress text for an achievement
    private func generateProgressText(for achievement: Achievement, remaining: Int) -> String {
        switch achievement {
        case .firstWorkout:
            return remaining == 1 ? "Complete your first workout!" : "\(remaining) workouts until \(achievement.title)"
        case .sevenDayStreak:
            return remaining == 1 ? "1 day until \(achievement.title)!" : "\(remaining) days until \(achievement.title)"
        case .thirtyDayStreak:
            return remaining == 1 ? "1 day until \(achievement.title)!" : "\(remaining) days until \(achievement.title)"
        case .perfectWeek:
            return remaining == 1 ? "1 workout until \(achievement.title)!" : "\(remaining) workouts until \(achievement.title)"
        case .monthlyConsistency:
            return remaining == 1 ? "1 workout until \(achievement.title)!" : "\(remaining) workouts until \(achievement.title)"
        case .earlyBird:
            return remaining == 1 ? "1 morning workout until \(achievement.title)!" : "\(remaining) morning workouts until \(achievement.title)"
        case .nightOwl:
            return remaining == 1 ? "1 evening workout until \(achievement.title)!" : "\(remaining) evening workouts until \(achievement.title)"
        default:
            return remaining == 1 ? "1 workout until \(achievement.title)!" : "\(remaining) workouts until \(achievement.title)"
        }
    }
    
    /// Get current value for an achievement (for display)
    func currentValue(for achievement: Achievement) -> Int {
        switch achievement {
        case .firstWorkout:
            return store.totalWorkouts
        case .sevenDayStreak, .thirtyDayStreak:
            return store.streak
        case .hundredWorkouts, .fiftyWorkouts, .twoHundredWorkouts, .fiveHundredWorkouts, .thousandWorkouts:
            return store.totalWorkouts
        case .perfectWeek:
            return store.workoutsThisWeek
        case .monthlyConsistency:
            return store.workoutsThisMonth
        case .earlyBird:
            return countMorningWorkouts()
        case .nightOwl:
            return countEveningWorkouts()
        }
    }
    
    /// Get target value for an achievement
    func targetValue(for achievement: Achievement) -> Int {
        switch achievement {
        case .firstWorkout: return 1
        case .sevenDayStreak: return 7
        case .thirtyDayStreak: return 30
        case .hundredWorkouts: return 100
        case .perfectWeek: return 7
        case .monthlyConsistency: return 20
        case .earlyBird: return 10
        case .nightOwl: return 10
        case .fiftyWorkouts: return 50
        case .twoHundredWorkouts: return 200
        case .fiveHundredWorkouts: return 500
        case .thousandWorkouts: return 1000
        }
    }
}

// MARK: - Achievement Model

enum Achievement: String, CaseIterable, Codable, Identifiable {
    case firstWorkout = "first_workout"
    case sevenDayStreak = "seven_day_streak"
    case thirtyDayStreak = "thirty_day_streak"
    case hundredWorkouts = "hundred_workouts"
    case perfectWeek = "perfect_week"
    case monthlyConsistency = "monthly_consistency"
    case earlyBird = "early_bird"
    case nightOwl = "night_owl"
    case fiftyWorkouts = "fifty_workouts"
    case twoHundredWorkouts = "two_hundred_workouts"
    case fiveHundredWorkouts = "five_hundred_workouts"
    case thousandWorkouts = "thousand_workouts"
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .firstWorkout: return "First Step"
        case .sevenDayStreak: return "Week Warrior"
        case .thirtyDayStreak: return "Monthly Master"
        case .hundredWorkouts: return "Century Club"
        case .perfectWeek: return "Perfect Week"
        case .monthlyConsistency: return "Monthly Champion"
        case .earlyBird: return "Early Bird"
        case .nightOwl: return "Night Owl"
        case .fiftyWorkouts: return "Half Century"
        case .twoHundredWorkouts: return "Double Century"
        case .fiveHundredWorkouts: return "Five Hundred"
        case .thousandWorkouts: return "Thousand Club"
        }
    }
    
    var description: String {
        switch self {
        case .firstWorkout: return "Complete your first workout"
        case .sevenDayStreak: return "Maintain a 7-day workout streak"
        case .thirtyDayStreak: return "Maintain a 30-day workout streak"
        case .hundredWorkouts: return "Complete 100 workouts"
        case .perfectWeek: return "Complete 7 workouts in 7 days"
        case .monthlyConsistency: return "Complete 20 workouts in a month"
        case .earlyBird: return "Complete 10 morning workouts"
        case .nightOwl: return "Complete 10 evening workouts"
        case .fiftyWorkouts: return "Complete 50 workouts"
        case .twoHundredWorkouts: return "Complete 200 workouts"
        case .fiveHundredWorkouts: return "Complete 500 workouts"
        case .thousandWorkouts: return "Complete 1000 workouts"
        }
    }
    
    var icon: String {
        switch self {
        case .firstWorkout: return "star.fill"
        case .sevenDayStreak: return "flame.fill"
        case .thirtyDayStreak: return "flame.fill"
        case .hundredWorkouts: return "trophy.fill"
        case .perfectWeek: return "checkmark.circle.fill"
        case .monthlyConsistency: return "calendar"
        case .earlyBird: return "sunrise.fill"
        case .nightOwl: return "moon.stars.fill"
        case .fiftyWorkouts: return "medal.fill"
        case .twoHundredWorkouts: return "trophy.fill"
        case .fiveHundredWorkouts: return "trophy.fill"
        case .thousandWorkouts: return "crown.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .firstWorkout: return .yellow
        case .sevenDayStreak: return .orange
        case .thirtyDayStreak: return .red
        case .hundredWorkouts: return .purple
        case .perfectWeek: return .green
        case .monthlyConsistency: return .blue
        case .earlyBird: return .yellow
        case .nightOwl: return .indigo
        case .fiftyWorkouts: return .blue
        case .twoHundredWorkouts: return .purple
        case .fiveHundredWorkouts: return .orange
        case .thousandWorkouts: return .yellow
        }
    }
    
    var rarity: Rarity {
        switch self {
        case .firstWorkout: return .common
        case .sevenDayStreak: return .uncommon
        case .thirtyDayStreak: return .rare
        case .hundredWorkouts: return .epic
        case .perfectWeek: return .uncommon
        case .monthlyConsistency: return .rare
        case .earlyBird: return .common
        case .nightOwl: return .common
        case .fiftyWorkouts: return .uncommon
        case .twoHundredWorkouts: return .epic
        case .fiveHundredWorkouts: return .legendary
        case .thousandWorkouts: return .legendary
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

