import Foundation
import SwiftUI

/// Agent 4: Analytics Engine - Comprehensive focus session analytics and insights
/// Refactored from WorkoutAnalytics for Pomodoro Timer app
@MainActor
final class FocusAnalytics: ObservableObject {
    let store: FocusStore
    
    // Agent 10: Advanced analytics components
    lazy var predictiveAnalytics = PredictiveFocusAnalytics(store: store)
    lazy var trendAnalyzer = FocusTrendAnalyzer(store: store)
    
    init(store: FocusStore) {
        self.store = store
    }
    
    // MARK: - Enhanced Statistics
    
    /// Weekly focus session trends
    var weeklyTrend: [DailyFocusCount] {
        let calendar = Calendar.current
        let today = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        
        return (0..<7).compactMap { dayOffset in
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek) else { return nil }
            let count = store.sessions.filter { calendar.isDate($0.date, inSameDayAs: date) }.count
            return DailyFocusCount(date: date, count: count)
        }
    }
    
    /// Monthly focus session trends (last 30 days)
    var monthlyTrend: [DailyFocusCount] {
        let calendar = Calendar.current
        let today = Date()
        let startDate = calendar.date(byAdding: .day, value: -30, to: today) ?? today
        
        var trend: [DailyFocusCount] = []
        var currentDate = startDate
        
        while currentDate <= today {
            let count = store.sessions.filter { calendar.isDate($0.date, inSameDayAs: currentDate) }.count
            trend.append(DailyFocusCount(date: currentDate, count: count))
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }
        
        return trend
    }
    
    /// Yearly focus session trends (last 12 months)
    var yearlyTrend: [MonthlyFocusCount] {
        let calendar = Calendar.current
        let today = Date()
        
        return (0..<12).compactMap { monthOffset in
            guard let monthDate = calendar.date(byAdding: .month, value: -monthOffset, to: today) else { return nil }
            let count = store.sessions.filter { calendar.isDate($0.date, equalTo: monthDate, toGranularity: .month) }.count
            return MonthlyFocusCount(month: monthDate, count: count)
        }.reversed()
    }
    
    /// Average focus session completion rate (percentage of sessions completed)
    var averageCompletionRate: Double {
        guard !store.sessions.isEmpty else { return 0 }
        let completedCount = store.sessions.filter { $0.completed }.count
        return Double(completedCount) / Double(store.sessions.count) * 100
    }
    
    /// Best focus time of day
    var bestFocusTime: TimeOfDay {
        let calendar = Calendar.current
        let hourCounts = store.sessions.filter { $0.phaseType == .focus }.reduce(into: [Int: Int]()) { counts, session in
            let hour = calendar.component(.hour, from: session.date)
            counts[hour, default: 0] += 1
        }
        
        guard let maxHour = hourCounts.max(by: { $0.value < $1.value })?.key else {
            return .unknown
        }
        
        switch maxHour {
        case 5..<12: return .morning
        case 12..<17: return .afternoon
        case 17..<22: return .evening
        default: return .night
        }
    }
    
    /// Most consistent focus day of week
    var mostConsistentDay: DayOfWeek? {
        let calendar = Calendar.current
        let dayCounts = store.sessions.filter { $0.phaseType == .focus }.reduce(into: [Int: Int]()) { counts, session in
            let weekday = calendar.component(.weekday, from: session.date)
            counts[weekday, default: 0] += 1
        }
        
        guard let maxDay = dayCounts.max(by: { $0.value < $1.value })?.key else { return nil }
        return DayOfWeek(rawValue: maxDay)
    }
    
    /// Longest streak ever achieved (calculated from historical focus sessions)
    var longestStreak: Int {
        guard !store.sessions.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        // Only count focus sessions for streak
        let focusSessions = store.sessions.filter { $0.phaseType == .focus && $0.completed }
        let sortedSessions = focusSessions.sorted { $0.date < $1.date }
        
        var longestStreak = 0
        var currentStreak = 0
        var lastDate: Date?
        
        for session in sortedSessions {
            let sessionDate = calendar.startOfDay(for: session.date)
            
            if let last = lastDate {
                let daysSinceLastSession = calendar.dateComponents([.day], from: last, to: sessionDate).day ?? 0
                
                if daysSinceLastSession == 1 {
                    // Consecutive day - continue streak
                    currentStreak += 1
                } else if daysSinceLastSession == 0 {
                    // Same day - multiple sessions don't count as separate streak days
                    continue
                } else {
                    // Gap detected - streak broken, check if this was the longest
                    longestStreak = max(longestStreak, currentStreak)
                    currentStreak = 1 // Start new streak
                }
            } else {
                // First session
                currentStreak = 1
            }
            
            lastDate = sessionDate
        }
        
        // Check if current streak is the longest
        longestStreak = max(longestStreak, currentStreak)
        
        return longestStreak
    }
    
    /// Total focus time spent (in minutes)
    var totalFocusTime: TimeInterval {
        return store.totalFocusTime
    }
    
    /// Daily focus time average
    var averageDailyFocusTime: TimeInterval {
        guard !store.sessions.isEmpty else { return 0 }
        let calendar = Calendar.current
        let focusSessions = store.sessions.filter { $0.phaseType == .focus }
        let uniqueDays = Set(focusSessions.map { calendar.startOfDay(for: $0.date) }).count
        guard uniqueDays > 0 else { return 0 }
        return totalFocusTime / Double(uniqueDays)
    }
    
    /// Focus frequency by day of week
    var focusFrequencyByDay: [DayOfWeek: Int] {
        let calendar = Calendar.current
        var frequency: [DayOfWeek: Int] = [:]
        
        for session in store.sessions.filter({ $0.phaseType == .focus }) {
            let weekday = calendar.component(.weekday, from: session.date)
            if let day = DayOfWeek(rawValue: weekday) {
                frequency[day, default: 0] += 1
            }
        }
        
        return frequency
    }
    
    /// Focus frequency by time of day
    var focusFrequencyByTime: [TimeOfDay: Int] {
        let calendar = Calendar.current
        var frequency: [TimeOfDay: Int] = [:]
        
        for session in store.sessions.filter({ $0.phaseType == .focus }) {
            let hour = calendar.component(.hour, from: session.date)
            let timeOfDay: TimeOfDay
            switch hour {
            case 5..<12: timeOfDay = .morning
            case 12..<17: timeOfDay = .afternoon
            case 17..<22: timeOfDay = .evening
            default: timeOfDay = .night
            }
            frequency[timeOfDay, default: 0] += 1
        }
        
        return frequency
    }
    
    /// Average focus session duration
    var averageDuration: TimeInterval {
        let focusSessions = store.sessions.filter { $0.phaseType == .focus }
        guard !focusSessions.isEmpty else { return 0 }
        let total = focusSessions.reduce(0.0) { $0 + $1.duration }
        return total / Double(focusSessions.count)
    }
    
    /// Progress over last 30 days
    var progress30Days: ProgressComparison {
        let calendar = Calendar.current
        let today = Date()
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: today) ?? today
        let sixtyDaysAgo = calendar.date(byAdding: .day, value: -60, to: today) ?? today
        
        let recent30 = store.sessions.filter { $0.date >= thirtyDaysAgo && $0.phaseType == .focus }.count
        let previous30 = store.sessions.filter { $0.date >= sixtyDaysAgo && $0.date < thirtyDaysAgo && $0.phaseType == .focus }.count
        
        let change = recent30 > 0 && previous30 > 0 ? Double(recent30 - previous30) / Double(previous30) * 100 : 0
        
        return ProgressComparison(
            recent: recent30,
            previous: previous30,
            change: change
        )
    }
    
    /// Progress over last 7 days
    var progress7Days: ProgressComparison {
        let calendar = Calendar.current
        let today = Date()
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: today) ?? today
        let fourteenDaysAgo = calendar.date(byAdding: .day, value: -14, to: today) ?? today
        
        let recent7 = store.sessions.filter { $0.date >= sevenDaysAgo && $0.phaseType == .focus }.count
        let previous7 = store.sessions.filter { $0.date >= fourteenDaysAgo && $0.date < sevenDaysAgo && $0.phaseType == .focus }.count
        
        let change = recent7 > 0 && previous7 > 0 ? Double(recent7 - previous7) / Double(previous7) * 100 : 0
        
        return ProgressComparison(
            recent: recent7,
            previous: previous7,
            change: change
        )
    }
    
    /// Total Pomodoro cycles completed (4 sessions = 1 cycle)
    var totalCycles: Int {
        let focusSessions = store.sessions.filter { $0.phaseType == .focus && $0.completed }
        return focusSessions.count / 4
    }
    
    /// Average sessions per cycle
    var averageSessionsPerCycle: Double {
        let focusSessions = store.sessions.filter { $0.phaseType == .focus && $0.completed }
        guard !focusSessions.isEmpty else { return 0 }
        return Double(focusSessions.count) / Double(max(1, totalCycles))
    }
    
    // MARK: - Insights
    
    /// Generate personalized insights based on focus patterns
    func generateInsights() -> [FocusInsight] {
        var insights: [FocusInsight] = []
        
        // Streak insights
        if store.streak >= 7 {
            insights.append(.init(
                type: .streak,
                title: "🔥 On Fire!",
                message: "You've maintained a \(store.streak)-day focus streak! Keep it up!",
                icon: "flame.fill",
                color: .orange
            ))
        } else if store.streak >= 3 {
            insights.append(.init(
                type: .streak,
                title: "Great Start!",
                message: "You're building momentum with a \(store.streak)-day streak.",
                icon: "flame.fill",
                color: .orange
            ))
        }
        
        // Frequency insights
        if let mostDay = mostConsistentDay {
            insights.append(.init(
                type: .pattern,
                title: "Consistency Counts",
                message: "You focus most on \(mostDay.displayName)s. Keep it consistent!",
                icon: "calendar",
                color: .blue
            ))
        }
        
        // Time of day insights
        switch bestFocusTime {
        case .morning:
            insights.append(.init(
                type: .pattern,
                title: "Early Bird",
                message: "You focus best in the morning. Great way to start the day!",
                icon: "sunrise.fill",
                color: .yellow
            ))
        case .afternoon:
            insights.append(.init(
                type: .pattern,
                title: "Midday Momentum",
                message: "You prefer afternoon focus sessions. Perfect for a midday boost!",
                icon: "sun.max.fill",
                color: .orange
            ))
        case .evening:
            insights.append(.init(
                type: .pattern,
                title: "Evening Warrior",
                message: "You focus in the evenings. Great way to wind down with productivity!",
                icon: "moon.stars.fill",
                color: .purple
            ))
        default:
            break
        }
        
        // Progress insights
        let progress7 = progress7Days
        if progress7.change > 20 {
            insights.append(.init(
                type: .progress,
                title: "Rising Star!",
                message: "You've increased your focus sessions by \(Int(progress7.change))% this week!",
                icon: "chart.line.uptrend.xyaxis",
                color: .green
            ))
        }
        
        // Completion rate insights
        if averageCompletionRate >= 95 {
            insights.append(.init(
                type: .achievement,
                title: "Focused!",
                message: "You're completing nearly all sessions. Outstanding dedication!",
                icon: "checkmark.circle.fill",
                color: .green
            ))
        }
        
        // Cycle insights
        if totalCycles >= 1 {
            insights.append(.init(
                type: .achievement,
                title: "Deep Focus",
                message: "You've completed \(totalCycles) full Pomodoro cycle\(totalCycles == 1 ? "" : "s")!",
                icon: "infinity",
                color: .blue
            ))
        }
        
        return insights
    }
    
    // MARK: - Agent 10: Advanced Analytics Methods
    
    /// Get focus likelihood prediction for today
    func getFocusLikelihoodToday() -> FocusLikelihood {
        return predictiveAnalytics.predictFocusLikelihoodToday()
    }
    
    /// Get optimal focus time prediction
    func getOptimalFocusTime() -> OptimalTimePrediction? {
        return predictiveAnalytics.predictOptimalFocusTime()
    }
    
    /// Get frequency trend analysis
    func getFrequencyTrend() -> FrequencyTrend {
        return trendAnalyzer.analyzeFrequencyTrend()
    }
    
    /// Get consistency trend analysis
    func getConsistencyTrend() -> ConsistencyTrend {
        return trendAnalyzer.analyzeConsistencyTrend()
    }
    
    /// Get week comparison
    func getWeekComparison() -> WeekComparison {
        return trendAnalyzer.compareThisWeekVsLastWeek()
    }
    
    /// Get month comparison
    func getMonthComparison() -> MonthComparison {
        return trendAnalyzer.compareThisMonthVsLastMonth()
    }
    
    /// Get performance trend
    func getPerformanceTrend() -> PerformanceTrend {
        return trendAnalyzer.analyzePerformanceTrend()
    }
    
    /// Get time-completion correlation analysis
    func getTimeCompletionCorrelation() -> CorrelationAnalysis? {
        return predictiveAnalytics.analyzeTimeCompletionCorrelation()
    }
    
    /// Generate personalized focus recommendations
    func generatePersonalizedRecommendations() -> [PersonalizedRecommendation] {
        var recommendations: [PersonalizedRecommendation] = []
        
        // Optimal time recommendation
        if let optimalTime = getOptimalFocusTime() {
            recommendations.append(PersonalizedRecommendation(
                type: .optimalTime,
                title: "Best Focus Time",
                description: "You perform best at \(optimalTime.timeDescription). Try scheduling focus sessions around this time!",
                priority: 1
            ))
        }
        
        // Goal achievement recommendation
        let frequencyTrend = getFrequencyTrend()
        if frequencyTrend.direction == .declining {
            recommendations.append(PersonalizedRecommendation(
                type: .frequency,
                title: "Getting Back on Track",
                description: "Your focus frequency has decreased. Try setting a weekly goal to stay motivated!",
                priority: 2
            ))
        }
        
        // Consistency recommendation
        let consistency = getConsistencyTrend()
        if consistency.level == .inconsistent {
            recommendations.append(PersonalizedRecommendation(
                type: .consistency,
                title: "Build Consistency",
                description: "Aim for more regular focus sessions. Even 2-3 times per week can make a big difference!",
                priority: 3
            ))
        }
        
        // Streak recommendation
        if store.streak > 0 && store.streak < 7 {
            recommendations.append(PersonalizedRecommendation(
                type: .frequency,
                title: "Keep the Streak Going!",
                description: "You're on a \(store.streak)-day streak! Keep it up to reach 7 days!",
                priority: 1
            ))
        }
        
        return recommendations
    }
    
    /// Generate weekly summary insights
    func generateWeeklySummary() -> FocusWeeklySummary? {
        let weekComparison = getWeekComparison()
        let consistency = getConsistencyTrend()
        let likelihood = getFocusLikelihoodToday()
        
        return FocusWeeklySummary(
            sessionsThisWeek: store.sessionsThisWeek,
            sessionsLastWeek: weekComparison.lastWeek,
            change: weekComparison.change,
            consistencyScore: consistency.consistencyScore,
            focusLikelihoodToday: likelihood.probability,
            insights: generatePersonalizedRecommendations()
        )
    }
    
    /// Generate monthly summary insights
    func generateMonthlySummary() -> FocusMonthlySummary? {
        let monthComparison = getMonthComparison()
        let performance = getPerformanceTrend()
        let consistency = getConsistencyTrend()
        
        // Calculate average completion rate from sessions
        let focusSessions = store.sessions.filter { $0.phaseType == .focus }
        let completedSessions = focusSessions.filter { $0.completed }.count
        let avgCompletionRate = focusSessions.isEmpty ? 0.0 : Double(completedSessions) / Double(focusSessions.count)
        
        return FocusMonthlySummary(
            sessionsThisMonth: store.sessionsThisMonth,
            sessionsLastMonth: monthComparison.lastMonth,
            change: monthComparison.change,
            averageCompletionRate: avgCompletionRate,
            consistencyScore: consistency.consistencyScore,
            trend: performance.trend
        )
    }
}

// MARK: - Focus Summary Types

struct FocusWeeklySummary {
    let sessionsThisWeek: Int
    let sessionsLastWeek: Int
    let change: Double
    let consistencyScore: Double
    let focusLikelihoodToday: Double
    let insights: [PersonalizedRecommendation]
}

struct FocusMonthlySummary {
    let sessionsThisMonth: Int
    let sessionsLastMonth: Int
    let change: Double
    let averageCompletionRate: Double
    let consistencyScore: Double
    let trend: TrendDirection
}

// MARK: - Supporting Types
// Note: DailyFocusCount and MonthlyFocusCount are defined in AnalyticsTypes.swift

struct FocusInsight: Identifiable {
    let id = UUID()
    let type: InsightType
    let title: String
    let message: String
    let icon: String
    let color: Color
    
    enum InsightType {
        case streak
        case pattern
        case progress
        case achievement
    }
}

struct FocusLikelihood {
    let probability: Double // 0.0 to 1.0
    let confidence: Confidence
    let factors: [String]
    
    var percentage: Int {
        Int(probability * 100)
    }
    
    var description: String {
        switch probability {
        case 0.8...1.0: return "Very Likely"
        case 0.6..<0.8: return "Likely"
        case 0.4..<0.6: return "Possible"
        case 0.2..<0.4: return "Unlikely"
        default: return "Very Unlikely"
        }
    }
}

// MARK: - Protocol for FocusStore (to be implemented by Agent 2)
// Note: This protocol is for reference only - the actual FocusStore class is in Models/FocusStore.swift
// Renamed to avoid conflict with the class
protocol FocusStoreProtocol {
    var sessions: [FocusSession] { get }
    var streak: Int { get }
    var totalSessions: Int { get }
    var totalFocusTime: TimeInterval { get }
    var sessionsThisWeek: Int { get }
    var sessionsThisMonth: Int { get }
}

