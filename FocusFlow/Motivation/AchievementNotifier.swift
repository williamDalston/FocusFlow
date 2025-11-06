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
        case firstSession = "first_session"
        case threeDayStreak = "three_day_streak"
        case sevenDayStreak = "seven_day_streak"
        case fourteenDayStreak = "fourteen_day_streak"
        case thirtyDayStreak = "thirty_day_streak"
        case fiftyDayStreak = "fifty_day_streak"
        case hundredDayStreak = "hundred_day_streak"
        case fiveSessions = "five_sessions"
        case tenSessions = "ten_sessions"
        case twentyFiveSessions = "twenty_five_sessions"
        case fiftySessions = "fifty_sessions"
        case hundredSessions = "hundred_sessions"
        case perfectWeek = "perfect_week"
        case earlyBird = "early_bird"
        case nightOwl = "night_owl"
        
        var title: String {
            switch self {
            case .firstSession: return "First Steps"
            case .threeDayStreak: return "Getting Started"
            case .sevenDayStreak: return "Week Warrior"
            case .fourteenDayStreak: return "Two Weeks Strong"
            case .thirtyDayStreak: return "Month Master"
            case .fiftyDayStreak: return "Half Century"
            case .hundredDayStreak: return "Century Club"
            case .fiveSessions: return "Building Momentum"
            case .tenSessions: return "Double Digits"
            case .twentyFiveSessions: return "Quarter Century"
            case .fiftySessions: return "Fifty Strong"
            case .hundredSessions: return "Century Champion"
            case .perfectWeek: return "Perfect Week"
            case .earlyBird: return "Early Bird"
            case .nightOwl: return "Night Owl"
            }
        }
        
        var message: String {
            switch self {
            case .firstSession: return "🎉 You've completed your first focus session! The journey begins!"
            case .threeDayStreak: return "🔥 3-day streak! You're building a powerful habit!"
            case .sevenDayStreak: return "🌟 7-day streak! You're a week warrior!"
            case .fourteenDayStreak: return "💪 14 days strong! Two weeks of consistency!"
            case .thirtyDayStreak: return "🏆 30-day streak! You've completed a full month!"
            case .fiftyDayStreak: return "🎯 50 days! Half century achieved!"
            case .hundredDayStreak: return "🏅 100 days! You're in the century club!"
            case .fiveSessions: return "🔥 5 focus sessions complete! You're building momentum!"
            case .tenSessions: return "🌟 10 focus sessions done! Double digits achieved!"
            case .twentyFiveSessions: return "💪 25 focus sessions! Quarter century milestone!"
            case .fiftySessions: return "🏆 50 focus sessions! You're unstoppable!"
            case .hundredSessions: return "🏅 100 focus sessions! You're a focus champion!"
            case .perfectWeek: return "✨ Perfect week! 7 focus sessions in 7 days!"
            case .earlyBird: return "🌅 Early bird! You focus in the morning!"
            case .nightOwl: return "🌙 Night owl! You focus in the evening!"
            }
        }
        
        var icon: String {
            switch self {
            case .firstSession: return "star.fill"
            case .threeDayStreak: return "flame.fill"
            case .sevenDayStreak: return "flame.fill"
            case .fourteenDayStreak: return "flame.fill"
            case .thirtyDayStreak: return "trophy.fill"
            case .fiftyDayStreak: return "trophy.fill"
            case .hundredDayStreak: return "crown.fill"
            case .fiveSessions: return "chart.line.uptrend.xyaxis"
            case .tenSessions: return "chart.line.uptrend.xyaxis"
            case .twentyFiveSessions: return "chart.line.uptrend.xyaxis"
            case .fiftySessions: return "trophy.fill"
            case .hundredSessions: return "crown.fill"
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
        totalSessions: Int,
        sessionsThisWeek: Int,
        sessionTime: Date? = nil
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
        
        // Total session achievements
        if totalSessions >= 5 && !achievedMilestones.contains(Achievement.fiveSessions.rawValue) {
            newAchievements.append(.fiveSessions)
        }
        if totalSessions >= 10 && !achievedMilestones.contains(Achievement.tenSessions.rawValue) {
            newAchievements.append(.tenSessions)
        }
        if totalSessions >= 25 && !achievedMilestones.contains(Achievement.twentyFiveSessions.rawValue) {
            newAchievements.append(.twentyFiveSessions)
        }
        if totalSessions >= 50 && !achievedMilestones.contains(Achievement.fiftySessions.rawValue) {
            newAchievements.append(.fiftySessions)
        }
        if totalSessions >= 100 && !achievedMilestones.contains(Achievement.hundredSessions.rawValue) {
            newAchievements.append(.hundredSessions)
        }
        
        // Perfect week achievement
        if sessionsThisWeek >= 7 && !achievedMilestones.contains(Achievement.perfectWeek.rawValue) {
            newAchievements.append(.perfectWeek)
        }
        
        // Time-based achievements (if session time provided)
        if let sessionTime = sessionTime {
            let hour = Calendar.current.component(.hour, from: sessionTime)
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
    
    /// Check for first session achievement
    func checkFirstSession(totalSessions: Int) -> Achievement? {
        if totalSessions == 1 && !achievedMilestones.contains(Achievement.firstSession.rawValue) {
            achievedMilestones.insert(Achievement.firstSession.rawValue)
            saveAchievements()
            return .firstSession
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

