import SwiftUI
import UIKit

/// Agent 12: Social Features & Sharing - Central manager for workout sharing functionality
/// Provides easy-to-use methods for sharing workouts, streaks, achievements, and progress
@MainActor
final class WorkoutShareManager {
    static let shared = WorkoutShareManager()
    
    private init() {}
    
    // MARK: - Share Workout Completion
    
    /// Share a completed workout with stats and visual
    func shareWorkoutCompletion(
        duration: TimeInterval,
        exercisesCompleted: Int,
        calories: Int? = nil,
        streak: Int = 0,
        date: Date = Date(),
        from viewController: UIViewController? = nil
    ) {
        let image = ShareImageGenerator.generateWorkoutCompletionImage(
            duration: duration,
            exercisesCompleted: exercisesCompleted,
            calories: calories,
            streak: streak,
            date: date
        )
        
        let text = shareTextForWorkoutCompletion(
            duration: duration,
            exercisesCompleted: exercisesCompleted,
            calories: calories,
            streak: streak
        )
        
        shareItems(items: [text, image], from: viewController)
    }
    
    /// Share workout completion from a WorkoutSession
    func shareWorkoutCompletion(
        session: WorkoutSession,
        streak: Int = 0,
        calories: Int? = nil,
        from viewController: UIViewController? = nil
    ) {
        shareWorkoutCompletion(
            duration: session.duration,
            exercisesCompleted: session.exercisesCompleted,
            calories: calories,
            streak: streak,
            date: session.date,
            from: viewController
        )
    }
    
    // MARK: - Share Streak
    
    /// Share current workout streak
    func shareStreak(
        streak: Int,
        totalWorkouts: Int = 0,
        from viewController: UIViewController? = nil
    ) {
        let image = ShareImageGenerator.generateStreakImage(
            streak: streak,
            totalWorkouts: totalWorkouts
        )
        
        let text = shareTextForStreak(streak: streak, totalWorkouts: totalWorkouts)
        
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
        weeklyData: [DailyWorkoutCount],
        monthlyData: [MonthlyWorkoutCount]? = nil,
        from viewController: UIViewController? = nil
    ) {
        let image = ShareImageGenerator.generateProgressChartImage(
            weeklyData: weeklyData,
            monthlyData: monthlyData
        )
        
        let text = shareTextForProgress(weeklyData: weeklyData)
        
        shareItems(items: [text, image], from: viewController)
    }
    
    // MARK: - Share Workout Summary
    
    /// Share a comprehensive workout summary with stats
    func shareWorkoutSummary(
        totalWorkouts: Int,
        streak: Int,
        totalMinutes: TimeInterval,
        estimatedCalories: Int,
        from viewController: UIViewController? = nil
    ) {
        let image = ShareImageGenerator.generateSummaryImage(
            totalWorkouts: totalWorkouts,
            streak: streak,
            totalMinutes: totalMinutes,
            estimatedCalories: estimatedCalories
        )
        
        let text = shareTextForSummary(
            totalWorkouts: totalWorkouts,
            streak: streak,
            totalMinutes: totalMinutes,
            estimatedCalories: estimatedCalories
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
    
    private func shareTextForWorkoutCompletion(
        duration: TimeInterval,
        exercisesCompleted: Int,
        calories: Int?,
        streak: Int
    ) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        var text = "Just completed a 7-minute workout! 💪\n\n"
        text += "⏱️ Time: \(minutes):\(String(format: "%02d", seconds))\n"
        text += "🏃 Exercises: \(exercisesCompleted)/12\n"
        
        if let calories = calories {
            text += "🔥 Calories: ~\(calories)\n"
        }
        
        if streak > 0 {
            text += "🔥 Streak: \(streak) days\n"
        }
        
        text += "\n#7MinuteWorkout #Fitness"
        return text
    }
    
    private func shareTextForStreak(streak: Int, totalWorkouts: Int) -> String {
        var text = "🔥 \(streak)-day workout streak! 🔥\n\n"
        
        if totalWorkouts > 0 {
            text += "Total workouts: \(totalWorkouts)\n"
        }
        
        text += "\nKeep the momentum going! 💪\n"
        text += "#7MinuteWorkout #Fitness #Streak"
        return text
    }
    
    private func shareTextForAchievement(title: String, description: String) -> String {
        return "🏆 Achievement Unlocked: \(title)\n\n\(description)\n\n#7MinuteWorkout #Achievement"
    }
    
    private func shareTextForProgress(weeklyData: [DailyWorkoutCount]) -> String {
        let total = weeklyData.reduce(0) { $0 + $1.count }
        return "📊 Workout Progress: \(total) workouts this week!\n\n#7MinuteWorkout #Progress"
    }
    
    private func shareTextForSummary(
        totalWorkouts: Int,
        streak: Int,
        totalMinutes: TimeInterval,
        estimatedCalories: Int
    ) -> String {
        let hours = Int(totalMinutes) / 60
        let minutes = Int(totalMinutes) % 60
        
        var text = "📊 My Workout Summary:\n\n"
        text += "🏃 Total Workouts: \(totalWorkouts)\n"
        text += "🔥 Current Streak: \(streak) days\n"
        text += "⏱️ Total Time: \(hours)h \(minutes)m\n"
        text += "🔥 Calories Burned: ~\(estimatedCalories)\n"
        text += "\n#7MinuteWorkout #Fitness"
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

