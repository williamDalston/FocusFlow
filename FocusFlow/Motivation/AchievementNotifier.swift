import Foundation
import UserNotifications

/// Agent 7: Tracks achievements and sends notifications for milestones
@MainActor
final class AchievementNotifier {
    static let shared = AchievementNotifier()
    
    private let achievedMilestonesKey = "achievements.milestones"
    private var achievedMilestones: Set<String> = []
    
    private init() {
        loadAchievements()
    }
    
    // MARK: - Achievement Types
    
    enum Achievement: String, CaseIterable, Identifiable {
        var id: String { rawValue }
        case firstWorkout = "first_workout"
        case threeDayStreak = "three_day_streak"
        case sevenDayStreak = "seven_day_streak"
        case fourteenDayStreak = "fourteen_day_streak"
        case thirtyDayStreak = "thirty_day_streak"
        case fiftyDayStreak = "fifty_day_streak"
        case hundredDayStreak = "hundred_day_streak"
        case fiveWorkouts = "five_workouts"
        case tenWorkouts = "ten_workouts"
        case twentyFiveWorkouts = "twenty_five_workouts"
        case fiftyWorkouts = "fifty_workouts"
        case hundredWorkouts = "hundred_workouts"
        case perfectWeek = "perfect_week"
        case earlyBird = "early_bird"
        case nightOwl = "night_owl"
        
        var title: String {
            switch self {
            case .firstWorkout: return "First Steps"
            case .threeDayStreak: return "Getting Started"
            case .sevenDayStreak: return "Week Warrior"
            case .fourteenDayStreak: return "Two Weeks Strong"
            case .thirtyDayStreak: return "Month Master"
            case .fiftyDayStreak: return "Half Century"
            case .hundredDayStreak: return "Century Club"
            case .fiveWorkouts: return "Building Momentum"
            case .tenWorkouts: return "Double Digits"
            case .twentyFiveWorkouts: return "Quarter Century"
            case .fiftyWorkouts: return "Fifty Strong"
            case .hundredWorkouts: return "Century Champion"
            case .perfectWeek: return "Perfect Week"
            case .earlyBird: return "Early Bird"
            case .nightOwl: return "Night Owl"
            }
        }
        
        var message: String {
            switch self {
            case .firstWorkout: return "🎉 You've completed your first workout! The journey begins!"
            case .threeDayStreak: return "🔥 3-day streak! You're building a powerful habit!"
            case .sevenDayStreak: return "🌟 7-day streak! You're a week warrior!"
            case .fourteenDayStreak: return "💪 14 days strong! Two weeks of consistency!"
            case .thirtyDayStreak: return "🏆 30-day streak! You've completed a full month!"
            case .fiftyDayStreak: return "🎯 50 days! Half century achieved!"
            case .hundredDayStreak: return "🏅 100 days! You're in the century club!"
            case .fiveWorkouts: return "🔥 5 workouts complete! You're building momentum!"
            case .tenWorkouts: return "🌟 10 workouts done! Double digits achieved!"
            case .twentyFiveWorkouts: return "💪 25 workouts! Quarter century milestone!"
            case .fiftyWorkouts: return "🏆 50 workouts! You're unstoppable!"
            case .hundredWorkouts: return "🏅 100 workouts! You're a fitness champion!"
            case .perfectWeek: return "✨ Perfect week! 7 workouts in 7 days!"
            case .earlyBird: return "🌅 Early bird! You work out in the morning!"
            case .nightOwl: return "🌙 Night owl! You work out in the evening!"
            }
        }
        
        var icon: String {
            switch self {
            case .firstWorkout: return "star.fill"
            case .threeDayStreak: return "flame.fill"
            case .sevenDayStreak: return "flame.fill"
            case .fourteenDayStreak: return "flame.fill"
            case .thirtyDayStreak: return "trophy.fill"
            case .fiftyDayStreak: return "trophy.fill"
            case .hundredDayStreak: return "crown.fill"
            case .fiveWorkouts: return "chart.line.uptrend.xyaxis"
            case .tenWorkouts: return "chart.line.uptrend.xyaxis"
            case .twentyFiveWorkouts: return "chart.line.uptrend.xyaxis"
            case .fiftyWorkouts: return "trophy.fill"
            case .hundredWorkouts: return "crown.fill"
            case .perfectWeek: return "sparkles"
            case .earlyBird: return "sunrise.fill"
            case .nightOwl: return "moon.fill"
            }
        }
    }
    
    // MARK: - Achievement Checking
    
    /// Check for new achievements based on current stats
    func checkAchievements(
        streak: Int,
        totalWorkouts: Int,
        workoutsThisWeek: Int,
        workoutTime: Date? = nil
    ) -> [Achievement] {
        var newAchievements: [Achievement] = []
        
        // Streak achievements
        if streak >= 3 && !achievedMilestones.contains(Achievement.threeDayStreak.rawValue) {
            newAchievements.append(.threeDayStreak)
        }
        if streak >= 7 && !achievedMilestones.contains(Achievement.sevenDayStreak.rawValue) {
            newAchievements.append(.sevenDayStreak)
        }
        if streak >= 14 && !achievedMilestones.contains(Achievement.fourteenDayStreak.rawValue) {
            newAchievements.append(.fourteenDayStreak)
        }
        if streak >= 30 && !achievedMilestones.contains(Achievement.thirtyDayStreak.rawValue) {
            newAchievements.append(.thirtyDayStreak)
        }
        if streak >= 50 && !achievedMilestones.contains(Achievement.fiftyDayStreak.rawValue) {
            newAchievements.append(.fiftyDayStreak)
        }
        if streak >= 100 && !achievedMilestones.contains(Achievement.hundredDayStreak.rawValue) {
            newAchievements.append(.hundredDayStreak)
        }
        
        // Total workout achievements
        if totalWorkouts >= 5 && !achievedMilestones.contains(Achievement.fiveWorkouts.rawValue) {
            newAchievements.append(.fiveWorkouts)
        }
        if totalWorkouts >= 10 && !achievedMilestones.contains(Achievement.tenWorkouts.rawValue) {
            newAchievements.append(.tenWorkouts)
        }
        if totalWorkouts >= 25 && !achievedMilestones.contains(Achievement.twentyFiveWorkouts.rawValue) {
            newAchievements.append(.twentyFiveWorkouts)
        }
        if totalWorkouts >= 50 && !achievedMilestones.contains(Achievement.fiftyWorkouts.rawValue) {
            newAchievements.append(.fiftyWorkouts)
        }
        if totalWorkouts >= 100 && !achievedMilestones.contains(Achievement.hundredWorkouts.rawValue) {
            newAchievements.append(.hundredWorkouts)
        }
        
        // Perfect week achievement
        if workoutsThisWeek >= 7 && !achievedMilestones.contains(Achievement.perfectWeek.rawValue) {
            newAchievements.append(.perfectWeek)
        }
        
        // Time-based achievements (if workout time provided)
        if let workoutTime = workoutTime {
            let hour = Calendar.current.component(.hour, from: workoutTime)
            if hour >= 5 && hour < 10 && !achievedMilestones.contains(Achievement.earlyBird.rawValue) {
                newAchievements.append(.earlyBird)
            }
            if hour >= 20 && hour < 24 && !achievedMilestones.contains(Achievement.nightOwl.rawValue) {
                newAchievements.append(.nightOwl)
            }
        }
        
        // Mark achievements as earned
        for achievement in newAchievements {
            achievedMilestones.insert(achievement.rawValue)
        }
        
        if !newAchievements.isEmpty {
            saveAchievements()
        }
        
        return newAchievements
    }
    
    /// Check for first workout achievement
    func checkFirstWorkout(totalWorkouts: Int) -> Achievement? {
        if totalWorkouts == 1 && !achievedMilestones.contains(Achievement.firstWorkout.rawValue) {
            achievedMilestones.insert(Achievement.firstWorkout.rawValue)
            saveAchievements()
            return .firstWorkout
        }
        return nil
    }
    
    /// Get all earned achievements
    func getEarnedAchievements() -> [Achievement] {
        return Achievement.allCases.filter { achievedMilestones.contains($0.rawValue) }
    }
    
    /// Check if an achievement has been earned
    func hasEarned(_ achievement: Achievement) -> Bool {
        return achievedMilestones.contains(achievement.rawValue)
    }
    
    // MARK: - Notification Scheduling
    
    /// Schedule achievement notification
    func scheduleAchievementNotification(_ achievement: Achievement) {
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "🏆 Achievement Unlocked!"
        content.body = "\(achievement.title): \(achievement.message)"
        content.sound = .default
        content.badge = 1
        
        // Schedule immediately (show in 1 second)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "achievement.\(achievement.rawValue)",
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error = error {
                print("Failed to schedule achievement notification: \(error)")
            }
        }
    }
    
    // MARK: - Persistence
    
    private func loadAchievements() {
        if let data = UserDefaults.standard.data(forKey: achievedMilestonesKey),
           let decoded = try? JSONDecoder().decode(Set<String>.self, from: data) {
            achievedMilestones = decoded
        } else {
            achievedMilestones = []
        }
    }
    
    private func saveAchievements() {
        if let data = try? JSONEncoder().encode(achievedMilestones) {
            UserDefaults.standard.set(data, forKey: achievedMilestonesKey)
        }
    }
    
    /// Reset all achievements (for testing or user reset)
    func resetAchievements() {
        achievedMilestones.removeAll()
        saveAchievements()
    }
}

