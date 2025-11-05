import Foundation
import UserNotifications

/// Agent 7: Enhanced notification manager with smart notifications
enum NotificationManager {
    static func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            print("Notif auth error:", error)
            return false
        }
    }

    /// Schedule daily workout reminder
    static func scheduleDailyReminder(at components: DateComponents, identifier: String = "daily.workout") {
        let center = UNUserNotificationCenter.current()
        // Remove existing with same id for idempotency
        center.removePendingNotificationRequests(withIdentifiers: [identifier])

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let content = UNMutableNotificationContent()
        content.title = "Time for Your Ritual7"
        
        // Use motivational message manager for personalized messages
        let messageManager = MotivationalMessageManager.shared
        content.body = messageManager.getTimeBasedReminderMessage()
        content.sound = .default

        let req = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        center.add(req) { err in
            if let err = err { print("Notif schedule error:", err) }
        }
    }
    
    /// Schedule streak maintenance reminder (if user hasn't worked out yet today)
    static func scheduleStreakReminder(at components: DateComponents, streak: Int) {
        let center = UNUserNotificationCenter.current()
        let identifier = "streak.reminder"
        
        // Remove existing
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        
        // Only schedule if user has an active streak
        guard streak > 0 else { return }
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let content = UNMutableNotificationContent()
        content.title = "🔥 Don't Break Your Streak!"
        content.body = "You're on a \(streak)-day streak! Complete your workout to keep it going."
        content.sound = .default
        
        let req = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        center.add(req) { err in
            if let err = err { print("Streak reminder schedule error:", err) }
        }
    }
    
    /// Schedule "you haven't worked out today" gentle nudge
    static func scheduleNoWorkoutNudge(at components: DateComponents) {
        let center = UNUserNotificationCenter.current()
        let identifier = "no.workout.nudge"
        
        // Remove existing
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let content = UNMutableNotificationContent()
        content.title = "Remember Your Workout"
        
        let messageManager = MotivationalMessageManager.shared
        content.body = messageManager.getNoWorkoutTodayMessage()
        content.sound = .default
        
        let req = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        center.add(req) { err in
            if let err = err { print("No workout nudge schedule error:", err) }
        }
    }
    
    /// Schedule weekly progress summary
    static func scheduleWeeklySummary(on weekday: Int, hour: Int = 20, minute: Int = 0) {
        let center = UNUserNotificationCenter.current()
        let identifier = "weekly.summary"
        
        // Remove existing
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        
        var components = DateComponents()
        components.weekday = weekday // 1 = Sunday, 2 = Monday, etc.
        components.hour = hour
        components.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let content = UNMutableNotificationContent()
        content.title = "📊 Your Weekly Progress"
        content.body = "Check out your workout stats for the week!"
        content.sound = .default
        
        let req = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        center.add(req) { err in
            if let err = err { print("Weekly summary schedule error:", err) }
        }
    }
    
    /// Schedule achievement notification (immediate)
    static func scheduleAchievementNotification(_ achievement: AchievementNotifier.Achievement) {
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

    static func cancelDailyReminder(identifier: String = "daily.workout") {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    static func cancelStreakReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["streak.reminder"])
    }
    
    static func cancelNoWorkoutNudge() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["no.workout.nudge"])
    }
    
    static func cancelWeeklySummary() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["weekly.summary"])
    }
    
    /// Cancel all workout-related notifications
    static func cancelAllWorkoutNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["daily.workout", "streak.reminder", "no.workout.nudge", "weekly.summary"]
        )
    }
}
