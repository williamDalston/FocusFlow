import Foundation
import SwiftUI

/// Agent 2: Achievement Manager - Tracks and manages workout achievements
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
            recentUnlocks.removeFirst()
        }
        
        save()
        
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

