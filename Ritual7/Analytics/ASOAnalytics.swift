import Foundation
import os.log

/// ASO Analytics Tracker
/// Tracks App Store Optimization metrics to measure effectiveness
/// 
/// Tracks:
/// - Review prompt triggers and success rates
/// - User engagement metrics
/// - Conversion funnel events
/// - Workout completion rates
@MainActor
final class ASOAnalytics {
    static let shared = ASOAnalytics()
    
    private let logger = Logger(subsystem: "com.ritual7.app", category: "ASO")
    
    // MARK: - Tracking Keys
    
    private let reviewPromptsKey = "aso.reviewPrompts"
    private let reviewPromptSuccessKey = "aso.reviewPromptSuccess"
    private let reviewPromptFailuresKey = "aso.reviewPromptFailures"
    private let userEngagementKey = "aso.userEngagement"
    
    private init() {}
    
    // MARK: - Review Prompt Tracking
    
    /// Track when a review prompt is shown
    /// - Parameters:
    ///   - trigger: What triggered the prompt (e.g., "workout_3", "achievement_first", "streak_7")
    ///   - success: Whether the prompt was successfully shown
    func trackReviewPrompt(trigger: String, success: Bool) {
        logger.info("📊 ASO: Review prompt - trigger: \(trigger), success: \(success)")
        
        let defaults = UserDefaults.standard
        
        // Track total prompts
        var prompts = defaults.dictionary(forKey: reviewPromptsKey) as? [String: Int] ?? [:]
        prompts[trigger] = (prompts[trigger] ?? 0) + 1
        defaults.set(prompts, forKey: reviewPromptsKey)
        
        // Track success/failure
        if success {
            var successes = defaults.dictionary(forKey: reviewPromptSuccessKey) as? [String: Int] ?? [:]
            successes[trigger] = (successes[trigger] ?? 0) + 1
            defaults.set(successes, forKey: reviewPromptSuccessKey)
        } else {
            var failures = defaults.dictionary(forKey: reviewPromptFailuresKey) as? [String: Int] ?? [:]
            failures[trigger] = (failures[trigger] ?? 0) + 1
            defaults.set(failures, forKey: reviewPromptFailuresKey)
        }
        
        // Log to console for debugging
        if success {
            logger.info("✅ ASO: Review prompt shown successfully for trigger: \(trigger)")
        } else {
            logger.warning("⚠️ ASO: Review prompt failed for trigger: \(trigger)")
        }
    }
    
    /// Get review prompt statistics
    func getReviewPromptStats() -> (total: Int, successes: Int, failures: Int, byTrigger: [String: (total: Int, success: Int, failure: Int)]) {
        let defaults = UserDefaults.standard
        
        let prompts = defaults.dictionary(forKey: reviewPromptsKey) as? [String: Int] ?? [:]
        let successes = defaults.dictionary(forKey: reviewPromptSuccessKey) as? [String: Int] ?? [:]
        let failures = defaults.dictionary(forKey: reviewPromptFailuresKey) as? [String: Int] ?? [:]
        
        let total = prompts.values.reduce(0, +)
        let totalSuccesses = successes.values.reduce(0, +)
        let totalFailures = failures.values.reduce(0, +)
        
        var byTrigger: [String: (total: Int, success: Int, failure: Int)] = [:]
        for (trigger, totalCount) in prompts {
            byTrigger[trigger] = (
                total: totalCount,
                success: successes[trigger] ?? 0,
                failure: failures[trigger] ?? 0
            )
        }
        
        return (total, totalSuccesses, totalFailures, byTrigger)
    }
    
    // MARK: - User Engagement Tracking
    
    /// Track user engagement event
    /// - Parameters:
    ///   - event: Event name (e.g., "workout_completed", "achievement_unlocked")
    ///   - value: Optional value (e.g., workout count, streak length)
    func trackEngagement(event: String, value: Int? = nil) {
        logger.info("📊 ASO: Engagement - event: \(event), value: \(value ?? 0)")
        
        let defaults = UserDefaults.standard
        var engagement = defaults.dictionary(forKey: userEngagementKey) as? [String: Any] ?? [:]
        
        // Track event count
        let countKey = "\(event)_count"
        let currentCount = engagement[countKey] as? Int ?? 0
        engagement[countKey] = currentCount + 1
        
        // Track latest value if provided
        if let value = value {
            engagement["\(event)_latest"] = value
        }
        
        // Track last occurrence
        engagement["\(event)_last"] = Date().timeIntervalSince1970
        
        defaults.set(engagement, forKey: userEngagementKey)
    }
    
    /// Get engagement statistics
    func getEngagementStats() -> [String: Any] {
        let defaults = UserDefaults.standard
        return defaults.dictionary(forKey: userEngagementKey) as? [String: Any] ?? [:]
    }
    
    // MARK: - Conversion Funnel Tracking
    
    /// Track conversion funnel event
    /// - Parameter stage: Funnel stage (e.g., "app_install", "first_launch", "first_workout", "workout_3", "achievement_unlock")
    func trackConversionFunnel(stage: String) {
        logger.info("📊 ASO: Conversion funnel - stage: \(stage)")
        
        let defaults = UserDefaults.standard
        var funnel = defaults.array(forKey: "aso.conversionFunnel") as? [String] ?? []
        
        // Only track if this is a new stage (avoid duplicates)
        if !funnel.contains(stage) {
            funnel.append(stage)
            defaults.set(funnel, forKey: "aso.conversionFunnel")
            
            // Track timestamp
            var timestamps = defaults.dictionary(forKey: "aso.conversionFunnelTimestamps") as? [String: TimeInterval] ?? [:]
            timestamps[stage] = Date().timeIntervalSince1970
            defaults.set(timestamps, forKey: "aso.conversionFunnelTimestamps")
        }
    }
    
    /// Get conversion funnel progress
    func getConversionFunnel() -> [String] {
        let defaults = UserDefaults.standard
        return defaults.array(forKey: "aso.conversionFunnel") as? [String] ?? []
    }
    
    // MARK: - Analytics Summary
    
    /// Get comprehensive ASO analytics summary
    func getSummary() -> ASOAnalyticsSummary {
        let reviewStats = getReviewPromptStats()
        let engagement = getEngagementStats()
        let funnel = getConversionFunnel()
        
        return ASOAnalyticsSummary(
            reviewPrompts: reviewStats,
            engagement: engagement,
            conversionFunnel: funnel
        )
    }
    
    // MARK: - Reset (for testing)
    
    /// Reset all ASO analytics (for testing)
    func reset() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: reviewPromptsKey)
        defaults.removeObject(forKey: reviewPromptSuccessKey)
        defaults.removeObject(forKey: reviewPromptFailuresKey)
        defaults.removeObject(forKey: userEngagementKey)
        defaults.removeObject(forKey: "aso.conversionFunnel")
        defaults.removeObject(forKey: "aso.conversionFunnelTimestamps")
        
        logger.info("🔄 ASO: Analytics reset")
    }
}

// MARK: - Analytics Summary Model

struct ASOAnalyticsSummary {
    let reviewPrompts: (total: Int, successes: Int, failures: Int, byTrigger: [String: (total: Int, success: Int, failure: Int)])
    let engagement: [String: Any]
    let conversionFunnel: [String]
    
    var successRate: Double {
        guard reviewPrompts.total > 0 else { return 0 }
        return Double(reviewPrompts.successes) / Double(reviewPrompts.total) * 100
    }
    
    var conversionRate: Double {
        // Calculate conversion rate based on funnel stages
        // This is a simplified calculation - can be enhanced
        let totalStages = conversionFunnel.count
        guard totalStages > 0 else { return 0 }
        
        // Weight stages differently (later stages are more valuable)
        let weightedScore = conversionFunnel.enumerated().reduce(0) { sum, item in
            sum + (item.offset + 1) // Weight by position
        }
        
        // Maximum possible score (if all stages completed)
        let maxScore = (1...totalStages).reduce(0, +)
        guard maxScore > 0 else { return 0 }
        
        return Double(weightedScore) / Double(maxScore) * 100
    }
}

