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

    /// Schedule daily focus reminder with actionable buttons
    static func scheduleDailyReminder(at components: DateComponents, identifier: String = "daily.workout") {
        let center = UNUserNotificationCenter.current()
        // Remove existing with same id for idempotency
        center.removePendingNotificationRequests(withIdentifiers: [identifier])

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let content = UNMutableNotificationContent()
        content.title = "Time for Your FocusFlow"
        content.categoryIdentifier = "WORKOUT_REMINDER"
        
        // Use motivational message manager for personalized messages
        // Access MainActor-isolated property and method in a Task
        Task { @MainActor in
            let messageManager = MotivationalMessageManager.shared
            content.body = messageManager.getTimeBasedReminderMessage()
            content.sound = .default
            
            // Add actionable buttons
            let startAction = UNNotificationAction(
                identifier: "START_WORKOUT",
                title: "Start Focus",
                options: [.foreground]
            )
            let viewProgressAction = UNNotificationAction(
                identifier: "VIEW_PROGRESS",
                title: "View Progress",
                options: [.foreground]
            )
            let category = UNNotificationCategory(
                identifier: "WORKOUT_REMINDER",
                actions: [startAction, viewProgressAction],
                intentIdentifiers: [],
                options: []
            )
            center.setNotificationCategories([category])

            let req = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            Task {
                do {
                    try await center.add(req)
                } catch {
                    print("Notif schedule error:", error)
                }
            }
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
        content.body = "You're on a \(streak)-day streak! Complete a focus session to keep it going."
        content.sound = .default
        content.categoryIdentifier = "WORKOUT_REMINDER"
        
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
        content.title = "Remember Your Focus Session"
        
        // Access MainActor-isolated property and method in a Task
        Task { @MainActor in
            let messageManager = MotivationalMessageManager.shared
            content.body = messageManager.getNoWorkoutTodayMessage()
            content.sound = .default
            
            let req = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            Task {
                do {
                    try await center.add(req)
                } catch {
                    print("No workout nudge schedule error:", error)
                }
            }
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
        content.body = "Check out your focus stats for the week!"
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
    
    /// Cancel all focus-related notifications
    static func cancelAllWorkoutNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["daily.workout", "streak.reminder", "no.workout.nudge", "weekly.summary"]
        )
    }
    
    // MARK: - Agent 6: Focus Session Notifications
    
    /// Schedule daily focus reminder with actionable buttons
    static func scheduleDailyFocusReminder(at components: DateComponents, identifier: String = "daily.focus") {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let content = UNMutableNotificationContent()
        content.title = "Time for Your Focus Session"
        content.categoryIdentifier = "FOCUS_REMINDER"
        content.body = "Ready to start your Pomodoro? Let's get focused!"
        content.sound = .default
        
        // Add actionable buttons
        let startAction = UNNotificationAction(
            identifier: "START_FOCUS",
            title: "Start Focus",
            options: [.foreground]
        )
        let viewProgressAction = UNNotificationAction(
            identifier: "VIEW_PROGRESS",
            title: "View Progress",
            options: [.foreground]
        )
        let category = UNNotificationCategory(
            identifier: "FOCUS_REMINDER",
            actions: [startAction, viewProgressAction],
            intentIdentifiers: [],
            options: []
        )
        center.setNotificationCategories([category])
        
        let req = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        Task {
            do {
                try await center.add(req)
            } catch {
                print("Focus reminder schedule error:", error)
            }
        }
    }
    
    /// Schedule break reminder notification
    static func scheduleBreakReminder(at components: DateComponents) {
        let center = UNUserNotificationCenter.current()
        let identifier = "break.reminder"
        
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let content = UNMutableNotificationContent()
        content.title = "⏰ Break Time!"
        content.body = "Your focus session is complete. Take a well-deserved break."
        content.sound = .default
        content.categoryIdentifier = "FOCUS_REMINDER"
        
        let req = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        center.add(req) { err in
            if let err = err { print("Break reminder schedule error:", err) }
        }
    }
    
    /// Schedule streak maintenance reminder for focus sessions
    static func scheduleFocusStreakReminder(at components: DateComponents, streak: Int) {
        let center = UNUserNotificationCenter.current()
        let identifier = "focus.streak.reminder"
        
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        
        guard streak > 0 else { return }
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let content = UNMutableNotificationContent()
        content.title = "🔥 Don't Break Your Focus Streak!"
        content.body = "You're on a \(streak)-day focus streak! Complete a session today to keep it going."
        content.sound = .default
        content.categoryIdentifier = "FOCUS_REMINDER"
        
        let req = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        center.add(req) { err in
            if let err = err { print("Focus streak reminder schedule error:", err) }
        }
    }
    
    /// Schedule focus session completion notification
    static func scheduleFocusSessionComplete() {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "🎉 Focus Session Complete!"
        content.body = "Great job staying focused! Time for a break."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "focus.session.complete",
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error = error {
                print("Failed to schedule focus completion notification: \(error)")
            }
        }
    }
    
    static func cancelDailyFocusReminder(identifier: String = "daily.focus") {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    static func cancelBreakReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["break.reminder"])
    }
    
    static func cancelFocusStreakReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["focus.streak.reminder"])
    }
    
    /// Cancel all focus-related notifications
    static func cancelAllFocusNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["daily.focus", "break.reminder", "focus.streak.reminder", "focus.session.complete"]
        )
    }
}
