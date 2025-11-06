import Foundation
import SwiftUI

/// Agent 4: Focus Insights Manager - Provides productivity insights and recommendations
/// Generates personalized insights based on focus patterns and productivity best practices
@MainActor
final class FocusInsightsManager: ObservableObject {
    let analytics: FocusAnalytics
    
    init(analytics: FocusAnalytics) {
        self.analytics = analytics
    }
    
    // MARK: - Productivity Insights
    
    /// Generate comprehensive productivity insights
    func generateProductivityInsights() -> [ProductivityInsight] {
        var insights: [ProductivityInsight] = []
        
        // Best focus time insight
        if let optimalTime = analytics.getOptimalFocusTime() {
            insights.append(.init(
                type: .optimalTime,
                title: "Peak Performance Time",
                message: "You focus best at \(optimalTime.timeDescription). Schedule important tasks during this time!",
                icon: "clock.fill",
                color: .blue,
                priority: .high
            ))
        }
        
        // Consistency insight
        let consistency = analytics.getConsistencyTrend()
        if consistency.level == .veryConsistent {
            insights.append(.init(
                type: .consistency,
                title: "Consistency Champion",
                message: "Your focus routine is very consistent. Keep up the great work!",
                icon: "checkmark.circle.fill",
                color: .green,
                priority: .medium
            ))
        } else if consistency.level == .inconsistent {
            insights.append(.init(
                type: .consistency,
                title: "Build a Routine",
                message: "Try to focus at the same time each day to build a stronger habit.",
                icon: "calendar.badge.clock",
                color: .orange,
                priority: .high
            ))
        }
        
        // Streak insight
        if analytics.store.streak >= 7 {
            insights.append(.init(
                type: .streak,
                title: "On Fire!",
                message: "You're on a \(analytics.store.streak)-day streak! Momentum is building.",
                icon: "flame.fill",
                color: .orange,
                priority: .high
            ))
        }
        
        // Progress insight
        let progress7 = analytics.progress7Days
        if progress7.change > 20 {
            insights.append(.init(
                type: .progress,
                title: "Rising Star",
                message: "You've increased focus sessions by \(Int(progress7.change))% this week!",
                icon: "chart.line.uptrend.xyaxis",
                color: .green,
                priority: .medium
            ))
        }
        
        // Cycle completion insight
        let cycles = analytics.totalCycles
        if cycles >= 1 {
            insights.append(.init(
                type: .achievement,
                title: "Deep Focus Achieved",
                message: "You've completed \(cycles) full Pomodoro cycle\(cycles == 1 ? "" : "s")!",
                icon: "infinity",
                color: .purple,
                priority: .medium
            ))
        }
        
        // Time of day pattern insight
        switch analytics.bestFocusTime {
        case .morning:
            insights.append(.init(
                type: .pattern,
                title: "Morning Person",
                message: "You focus best in the morning. Use this time for your most important work!",
                icon: "sunrise.fill",
                color: .yellow,
                priority: .medium
            ))
        case .evening:
            insights.append(.init(
                type: .pattern,
                title: "Night Owl",
                message: "Evening focus works well for you. Plan your deep work sessions accordingly!",
                icon: "moon.stars.fill",
                color: .indigo,
                priority: .medium
            ))
        default:
            break
        }
        
        return insights.sorted { $0.priority.rawValue > $1.priority.rawValue }
    }
    
    // MARK: - Productivity Tips
    
    /// Get productivity tips based on current patterns
    func getProductivityTips() -> [String] {
        var tips: [String] = []
        
        // Time-based tips
        if let optimalTime = analytics.getOptimalFocusTime() {
            let hour = optimalTime.hour
            if hour >= 5 && hour < 12 {
                tips.append("Schedule your most important tasks in the morning when you're most focused.")
            } else if hour >= 17 && hour < 22 {
                tips.append("Evening sessions work well for you. Plan your deep work accordingly.")
            }
        }
        
        // Consistency tips
        let consistency = analytics.getConsistencyTrend()
        if consistency.level == .inconsistent {
            tips.append("Try focusing at the same time each day to build a stronger habit.")
        }
        
        // Session duration tips
        let avgDuration = analytics.averageDuration
        if avgDuration > 0 {
            let minutes = Int(avgDuration / 60)
            if minutes < 20 {
                tips.append("Consider trying longer focus sessions (25-45 minutes) for deeper work.")
            } else if minutes >= 45 {
                tips.append("Great job with longer focus sessions! Remember to take breaks between sessions.")
            }
        }
        
        // Streak tips
        if analytics.store.streak > 0 && analytics.store.streak < 7 {
            tips.append("Keep your streak going! Consistency is key to building lasting habits.")
        }
        
        // Cycle tips
        let cycles = analytics.totalCycles
        if cycles >= 1 {
            tips.append("You've completed full Pomodoro cycles! Try completing multiple cycles in one day for deep work.")
        }
        
        // Default tips if no specific patterns
        if tips.isEmpty {
            tips.append("Start with shorter focus sessions (15-25 minutes) and gradually increase duration.")
            tips.append("Take regular breaks between focus sessions to maintain productivity.")
            tips.append("Eliminate distractions during focus sessions for better results.")
        }
        
        return tips
    }
    
    // MARK: - Recommendations
    
    /// Get personalized recommendations
    func getRecommendations() -> [ProductivityRecommendation] {
        var recommendations: [ProductivityRecommendation] = []
        
        // Optimal time recommendation
        if let optimalTime = analytics.getOptimalFocusTime() {
            recommendations.append(.init(
                type: .optimalTime,
                title: "Schedule Focus Sessions",
                message: "Focus at \(optimalTime.timeDescription) for best results",
                action: "Set Reminder",
                icon: "bell.fill"
            ))
        }
        
        // Consistency recommendation
        let consistency = analytics.getConsistencyTrend()
        if consistency.level == .inconsistent {
            recommendations.append(.init(
                type: .consistency,
                title: "Build a Routine",
                message: "Try focusing at the same time each day",
                action: "Set Daily Goal",
                icon: "calendar.badge.clock"
            ))
        }
        
        // Session frequency recommendation
        let frequencyTrend = analytics.getFrequencyTrend()
        if frequencyTrend.direction == .declining {
            recommendations.append(.init(
                type: .frequency,
                title: "Increase Frequency",
                message: "Try to focus more regularly this week",
                action: "Set Weekly Goal",
                icon: "target"
            ))
        }
        
        return recommendations
    }
}

// MARK: - Supporting Types

struct ProductivityInsight: Identifiable {
    let id = UUID()
    let type: InsightType
    let title: String
    let message: String
    let icon: String
    let color: Color
    let priority: Priority
    
    enum InsightType {
        case optimalTime
        case consistency
        case streak
        case progress
        case achievement
        case pattern
    }
    
    enum Priority: Int {
        case low = 1
        case medium = 2
        case high = 3
    }
}

struct ProductivityRecommendation: Identifiable {
    let id = UUID()
    let type: RecommendationType
    let title: String
    let message: String
    let action: String
    let icon: String
    
    enum RecommendationType {
        case optimalTime
        case consistency
        case frequency
        case duration
    }
}

