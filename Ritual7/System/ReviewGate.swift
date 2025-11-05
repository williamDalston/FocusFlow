import StoreKit
import UIKit
import Foundation

/// ASO-Optimized Review Prompt System
/// Prompts at optimal times for maximum positive reviews:
/// - After 3rd completed workout
/// - After unlocking first achievement
/// - After reaching 7-day streak
/// 
/// Follows Apple's guidelines: max 3 prompts per year, only at positive moments
enum ReviewGate {
    // MARK: - ASO-Optimized Milestones
    
    /// Optimal ASO prompting times (based on research)
    private static let workoutCountMilestone = 3  // After 3rd workout
    private static let streakMilestone = 7         // After 7-day streak
    private static let achievementMilestone = 1   // After first achievement
    
    // MARK: - Tracking Keys
    
    private static let lastPromptDateKey = "reviewGate.lastPromptDate"
    private static let promptCountThisYearKey = "reviewGate.promptCountThisYear"
    private static let lastPromptYearKey = "reviewGate.lastPromptYear"
    private static let lastWorkoutCountKey = "reviewGate.lastWorkoutCount"
    private static let lastStreakKey = "reviewGate.lastStreak"
    private static let lastAchievementCountKey = "reviewGate.lastAchievementCount"
    private static let hasPromptedForWorkoutKey = "reviewGate.hasPromptedForWorkout"
    private static let hasPromptedForAchievementKey = "reviewGate.hasPromptedForAchievement"
    private static let hasPromptedForStreakKey = "reviewGate.hasPromptedForStreak"
    
    // MARK: - Apple Guidelines
    
    /// Maximum prompts per year (Apple's recommendation)
    private static let maxPromptsPerYear = 3
    
    /// Minimum time between prompts (365 days / 3 = ~4 months minimum)
    private static let minDaysBetweenPrompts = 120
    
    // MARK: - Public API
    
    /// ASO-optimized: Prompt after workout completion
    /// Should be called when a workout is completed
    @MainActor
    static func considerPromptAfterWorkout(totalWorkouts: Int) {
        // Check if we've already prompted for this milestone
        guard !UserDefaults.standard.bool(forKey: hasPromptedForWorkoutKey) else { return }
        
        // Check if we've reached the milestone
        guard totalWorkouts >= workoutCountMilestone else { return }
        
        // Check if we can prompt (rate limiting)
        guard canPrompt() else { return }
        
        // Track that we've prompted for this milestone
        UserDefaults.standard.set(true, forKey: hasPromptedForWorkoutKey)
        UserDefaults.standard.set(totalWorkouts, forKey: lastWorkoutCountKey)
        
        // Show the prompt
        promptForReview(reason: "workout_milestone")
        
        // Track ASO analytics
        ASOAnalytics.shared.trackReviewPrompt(trigger: "workout_\(totalWorkouts)", success: true)
    }
    
    /// ASO-optimized: Prompt after achievement unlock
    /// Should be called when an achievement is unlocked
    @MainActor
    static func considerPromptAfterAchievement(achievementCount: Int) {
        // Only prompt for first achievement (best moment)
        guard achievementCount >= achievementMilestone else { return }
        
        // Check if we've already prompted for this milestone
        guard !UserDefaults.standard.bool(forKey: hasPromptedForAchievementKey) else { return }
        
        // Check if we can prompt (rate limiting)
        guard canPrompt() else { return }
        
        // Track that we've prompted for this milestone
        UserDefaults.standard.set(true, forKey: hasPromptedForAchievementKey)
        UserDefaults.standard.set(achievementCount, forKey: lastAchievementCountKey)
        
        // Show the prompt
        promptForReview(reason: "achievement_unlock")
        
        // Track ASO analytics
        ASOAnalytics.shared.trackReviewPrompt(trigger: "achievement_first", success: true)
    }
    
    /// ASO-optimized: Prompt after reaching streak milestone
    /// Should be called when streak reaches 7 days
    @MainActor
    static func considerPromptAfterStreak(streak: Int) {
        // Check if we've reached the milestone
        guard streak >= streakMilestone else { return }
        
        // Check if we've already prompted for this milestone
        guard !UserDefaults.standard.bool(forKey: hasPromptedForStreakKey) else { return }
        
        // Check if we can prompt (rate limiting)
        guard canPrompt() else { return }
        
        // Track that we've prompted for this milestone
        UserDefaults.standard.set(true, forKey: hasPromptedForStreakKey)
        UserDefaults.standard.set(streak, forKey: lastStreakKey)
        
        // Show the prompt
        promptForReview(reason: "streak_milestone")
        
        // Track ASO analytics
        ASOAnalytics.shared.trackReviewPrompt(trigger: "streak_\(streak)", success: true)
    }
    
    /// Legacy method for backward compatibility
    /// Still works but uses new ASO-optimized logic
    @MainActor
    static func considerPrompt(totalSaves: Int) {
        considerPromptAfterWorkout(totalWorkouts: totalSaves)
    }
    
    // MARK: - Internal Implementation
    
    /// Check if we can prompt (rate limiting and Apple guidelines)
    private static func canPrompt() -> Bool {
        let defaults = UserDefaults.standard
        let calendar = Calendar.current
        let now = Date()
        
        // Get last prompt date
        guard let lastPromptDate = defaults.object(forKey: lastPromptDateKey) as? Date else {
            // Never prompted before - allow
            return true
        }
        
        // Check minimum time between prompts
        if let daysSinceLastPrompt = calendar.dateComponents([.day], from: lastPromptDate, to: now).day,
           daysSinceLastPrompt < minDaysBetweenPrompts {
            return false
        }
        
        // Check prompts per year
        let currentYear = calendar.component(.year, from: now)
        let lastPromptYear = defaults.integer(forKey: lastPromptYearKey)
        
        if currentYear == lastPromptYear {
            // Same year - check count
            let promptCount = defaults.integer(forKey: promptCountThisYearKey)
            if promptCount >= maxPromptsPerYear {
                return false
            }
        } else {
            // New year - reset count
            defaults.set(0, forKey: promptCountThisYearKey)
        }
        
        return true
    }
    
    /// Show the review prompt
    @MainActor
    private static func promptForReview(reason: String) {
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive })
        else {
            // Track that we tried but couldn't show
            ASOAnalytics.shared.trackReviewPrompt(trigger: reason, success: false)
            return
        }
        
        // Update tracking
        let defaults = UserDefaults.standard
        let now = Date()
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: now)
        
        defaults.set(now, forKey: lastPromptDateKey)
        defaults.set(currentYear, forKey: lastPromptYearKey)
        
        let currentCount = defaults.integer(forKey: promptCountThisYearKey)
        defaults.set(currentCount + 1, forKey: promptCountThisYearKey)
        
        // Show the prompt
        if #available(iOS 18.0, *) {
            // New API on iOS 18
            AppStore.requestReview(in: scene)
        } else {
            // Older iOS
            SKStoreReviewController.requestReview(in: scene)
        }
    }
    
    // MARK: - Reset (for testing)
    
    /// Reset all review prompt tracking (for testing or user reset)
    static func reset() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: lastPromptDateKey)
        defaults.removeObject(forKey: promptCountThisYearKey)
        defaults.removeObject(forKey: lastPromptYearKey)
        defaults.removeObject(forKey: lastWorkoutCountKey)
        defaults.removeObject(forKey: lastStreakKey)
        defaults.removeObject(forKey: lastAchievementCountKey)
        defaults.removeObject(forKey: hasPromptedForWorkoutKey)
        defaults.removeObject(forKey: hasPromptedForAchievementKey)
        defaults.removeObject(forKey: hasPromptedForStreakKey)
    }
}
