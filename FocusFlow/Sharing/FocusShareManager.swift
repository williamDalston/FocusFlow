import SwiftUI
import UIKit

/// Agent 23: Social Features & Sharing - Central manager for focus session sharing functionality
/// Provides easy-to-use methods for sharing focus sessions, streaks, achievements, and progress
@MainActor
final class FocusShareManager {
    static let shared = FocusShareManager()
    
    private init() {}
    
    // MARK: - Share Focus Session Completion
    
    /// Share a completed focus session with stats and visual
    func shareFocusSession(
        session: FocusSession,
        streak: Int = 0,
        from viewController: UIViewController? = nil
    ) {
        let image = ShareImageGenerator.generateFocusCompletionImage(
            session: session,
            streak: streak
        )
        
        let text = shareTextForFocusSession(
            session: session,
            streak: streak
        )
        
        shareItems(items: [text, image], from: viewController)
    }
    
    /// Share focus session completion with individual parameters
    func shareFocusSession(
        duration: TimeInterval,
        phaseType: FocusSession.PhaseType,
        streak: Int = 0,
        date: Date = Date(),
        from viewController: UIViewController? = nil
    ) {
        let session = FocusSession(
            date: date,
            duration: duration,
            phaseType: phaseType,
            completed: true
        )
        shareFocusSession(session: session, streak: streak, from: viewController)
    }
    
    // MARK: - Share Streak
    
    /// Share current focus streak
    func shareStreak(
        streak: Int,
        totalSessions: Int = 0,
        from viewController: UIViewController? = nil
    ) {
        let image = ShareImageGenerator.generateStreakImage(
            streak: streak,
            totalSessions: totalSessions
        )
        
        let text = shareTextForStreak(streak: streak, totalSessions: totalSessions)
        
        shareItems(items: [text, image], from: viewController)
    }
    
    // MARK: - Share Achievement
    
    /// Share an unlocked achievement
    func shareAchievement(
        title: String,
        description: String,
        icon: String = "trophy.fill",
        from viewController: UIViewController? = nil
    ) {
        let image = ShareImageGenerator.generateAchievementImage(
            title: title,
            description: description,
            icon: icon
        )
        
        let text = shareTextForAchievement(title: title, description: description)
        
        shareItems(items: [text, image], from: viewController)
    }
    
    // MARK: - Share Progress Chart
    
    /// Share a progress chart visualization
    func shareProgressChart(
        weeklyData: [DailyFocusCount],
        monthlyData: [MonthlyFocusCount]? = nil,
        from viewController: UIViewController? = nil
    ) {
        let image = ShareImageGenerator.generateProgressChartImage(
            weeklyData: weeklyData,
            monthlyData: monthlyData
        )
        
        let text = shareTextForProgress(weeklyData: weeklyData)
        
        shareItems(items: [text, image], from: viewController)
    }
    
    // MARK: - Share Focus Summary
    
    /// Share a comprehensive focus summary with stats
    func shareFocusSummary(
        totalSessions: Int,
        streak: Int,
        totalMinutes: TimeInterval,
        from viewController: UIViewController? = nil
    ) {
        let image = ShareImageGenerator.generateSummaryImage(
            totalSessions: totalSessions,
            streak: streak,
            totalMinutes: totalMinutes
        )
        
        let text = shareTextForSummary(
            totalSessions: totalSessions,
            streak: streak,
            totalMinutes: totalMinutes
        )
        
        shareItems(items: [text, image], from: viewController)
    }
    
    // MARK: - Share Custom Message
    
    /// Share a custom motivational message with poster
    func shareCustomMessage(
        message: String,
        date: Date = Date(),
        streak: Int = 0,
        from viewController: UIViewController? = nil
    ) {
        let image = PosterExporter.image(
            text: message,
            date: date,
            streak: streak
        )
        
        shareItems(items: [message, image], from: viewController)
    }
    
    // MARK: - Private Helpers
    
    private func shareItems(items: [Any], from viewController: UIViewController?) {
        let activityViewController = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        
        // Configure for iPad
        if let popover = activityViewController.popoverPresentationController {
            if let viewController = viewController {
                popover.sourceView = viewController.view
                popover.sourceRect = CGRect(x: viewController.view.bounds.midX, 
                                          y: viewController.view.bounds.midY, 
                                          width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
        }
        
        // Exclude some activity types if needed
        activityViewController.excludedActivityTypes = [
            .assignToContact,
            .addToReadingList
        ]
        
        // Present from key window if no view controller provided
        if let viewController = viewController {
            viewController.present(activityViewController, animated: true)
        } else if let window = UIApplication.shared.firstKeyWindow,
                  let rootViewController = window.rootViewController {
            rootViewController.present(activityViewController, animated: true)
        }
        
        Haptics.success()
    }
    
    private func shareTextForFocusSession(
        session: FocusSession,
        streak: Int
    ) -> String {
        let minutes = Int(session.duration) / 60
        let seconds = Int(session.duration) % 60
        var text = "Just completed a FocusFlow session! 🎯\n\n"
        text += "⏱️ Time: \(minutes):\(String(format: "%02d", seconds))\n"
        text += "🎯 Phase: \(session.phaseType.displayName)\n"
        
        if streak > 0 {
            text += "🔥 Streak: \(streak) days\n"
        }
        
        text += "\n#FocusFlow #Pomodoro #Productivity"
        return text
    }
    
    private func shareTextForStreak(streak: Int, totalSessions: Int) -> String {
        var text = "🔥 \(streak)-day focus streak! 🔥\n\n"
        
        if totalSessions > 0 {
            text += "Total focus sessions: \(totalSessions)\n"
        }
        
        text += "\nKeep the momentum going! 💪\n"
        text += "#FocusFlow #Pomodoro #Streak"
        return text
    }
    
    private func shareTextForAchievement(title: String, description: String) -> String {
        return "🏆 Achievement Unlocked: \(title)\n\n\(description)\n\n#FocusFlow #Achievement"
    }
    
    private func shareTextForProgress(weeklyData: [DailyFocusCount]) -> String {
        let total = weeklyData.reduce(0) { $0 + $1.count }
        return "📊 Focus Progress: \(total) sessions this week!\n\n#FocusFlow #Progress"
    }
    
    private func shareTextForSummary(
        totalSessions: Int,
        streak: Int,
        totalMinutes: TimeInterval
    ) -> String {
        let hours = Int(totalMinutes) / 3600
        let minutes = Int(totalMinutes) / 60 % 60
        
        var text = "📊 My Focus Summary:\n\n"
        text += "🎯 Total Sessions: \(totalSessions)\n"
        text += "🔥 Current Streak: \(streak) days\n"
        
        if hours > 0 {
            text += "⏱️ Total Time: \(hours)h \(minutes)m\n"
        } else {
            text += "⏱️ Total Time: \(minutes)m\n"
        }
        
        text += "\n#FocusFlow #Pomodoro #Productivity"
        return text
    }
}

// MARK: - SwiftUI Share Button Helper

extension View {
    /// Add a share button that presents the share sheet
    func shareButton(
        items: [Any],
        isPresented: Binding<Bool>
    ) -> some View {
        self.sheet(isPresented: isPresented) {
            ShareSheet(activityItems: items)
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        
        // Configure for iPad
        if let popover = controller.popoverPresentationController {
            popover.sourceView = UIView()
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Supporting Types
// Note: DailyFocusCount and MonthlyFocusCount are defined in FocusAnalytics.swift

