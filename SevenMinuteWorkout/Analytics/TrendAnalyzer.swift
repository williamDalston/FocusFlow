import Foundation
import SwiftUI

/// Agent 10: Trend Analyzer - Analyzes workout trends (improving/declining patterns)
@MainActor
final class TrendAnalyzer: ObservableObject {
    let store: WorkoutStore
    
    init(store: WorkoutStore) {
        self.store = store
    }
    
    // MARK: - Trend Analysis
    
    /// Analyzes workout frequency trend over the last 30 days
    func analyzeFrequencyTrend() -> FrequencyTrend {
        let calendar = Calendar.current
        let today = Date()
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: today) ?? today
        
        // Split into two 15-day periods
        let fifteenDaysAgo = calendar.date(byAdding: .day, value: -15, to: today) ?? today
        
        let recentPeriod = store.sessions.filter { $0.date >= fifteenDaysAgo && $0.date <= today }
        let previousPeriod = store.sessions.filter { $0.date >= thirtyDaysAgo && $0.date < fifteenDaysAgo }
        
        let recentCount = recentPeriod.count
        let previousCount = previousPeriod.count
        
        let change = previousCount > 0 
            ? Double(recentCount - previousCount) / Double(previousCount) * 100
            : (recentCount > 0 ? 100.0 : 0.0)
        
        let direction: TrendDirection
        if change > 10 {
            direction = .improving
        } else if change < -10 {
            direction = .declining
        } else {
            direction = .stable
        }
        
        return FrequencyTrend(
            recentPeriod: recentCount,
            previousPeriod: previousCount,
            change: change,
            direction: direction,
            confidence: calculateConfidence(recent: recentCount, previous: previousCount)
        )
    }
    
    /// Analyzes consistency trend (workout frequency variance)
    func analyzeConsistencyTrend() -> ConsistencyTrend {
        let calendar = Calendar.current
        let today = Date()
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: today) ?? today
        
        // Get daily workout counts for last 30 days
        var dailyCounts: [Int] = []
        var currentDate = thirtyDaysAgo
        
        while currentDate <= today {
            let count = store.sessions.filter { calendar.isDate($0.date, inSameDayAs: currentDate) }.count
            dailyCounts.append(count)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }
        
        // Calculate variance (lower = more consistent)
        let average = Double(dailyCounts.reduce(0, +)) / Double(dailyCounts.count)
        let variance = dailyCounts.reduce(0.0) { sum, count in
            sum + pow(Double(count) - average, 2)
        } / Double(dailyCounts.count)
        let standardDeviation = sqrt(variance)
        
        // Consistency score (0-1, where 1 is most consistent)
        let maxDeviation = max(1.0, average)
        let consistencyScore = max(0.0, min(1.0, 1.0 - (standardDeviation / maxDeviation)))
        
        let level: ConsistencyLevel
        if consistencyScore >= 0.8 {
            level = .veryConsistent
        } else if consistencyScore >= 0.6 {
            level = .consistent
        } else if consistencyScore >= 0.4 {
            level = .moderate
        } else {
            level = .inconsistent
        }
        
        return ConsistencyTrend(
            consistencyScore: consistencyScore,
            level: level,
            averageWorkoutsPerDay: average,
            standardDeviation: standardDeviation
        )
    }
    
    /// Compares this week vs last week
    func compareThisWeekVsLastWeek() -> WeekComparison {
        let calendar = Calendar.current
        let today = Date()
        let startOfThisWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        let startOfLastWeek = calendar.date(byAdding: .day, value: -7, to: startOfThisWeek) ?? today
        let endOfLastWeek = startOfThisWeek
        
        let thisWeek = store.sessions.filter { $0.date >= startOfThisWeek }
        let lastWeek = store.sessions.filter { $0.date >= startOfLastWeek && $0.date < endOfLastWeek }
        
        let thisWeekCount = thisWeek.count
        let lastWeekCount = lastWeek.count
        
        let change = lastWeekCount > 0
            ? Double(thisWeekCount - lastWeekCount) / Double(lastWeekCount) * 100
            : (thisWeekCount > 0 ? 100.0 : 0.0)
        
        // Calculate average completion rate
        let thisWeekCompletion = thisWeek.isEmpty ? 0.0 : thisWeek.reduce(0.0) { $0 + Double($1.exercisesCompleted) / 12.0 } / Double(thisWeek.count)
        let lastWeekCompletion = lastWeek.isEmpty ? 0.0 : lastWeek.reduce(0.0) { $0 + Double($1.exercisesCompleted) / 12.0 } / Double(lastWeek.count)
        
        return WeekComparison(
            thisWeek: thisWeekCount,
            lastWeek: lastWeekCount,
            change: change,
            thisWeekCompletionRate: thisWeekCompletion,
            lastWeekCompletionRate: lastWeekCompletion,
            completionChange: thisWeekCompletion - lastWeekCompletion
        )
    }
    
    /// Compares this month vs last month
    func compareThisMonthVsLastMonth() -> MonthComparison {
        let calendar = Calendar.current
        let today = Date()
        let startOfThisMonth = calendar.dateInterval(of: .month, for: today)?.start ?? today
        let startOfLastMonth = calendar.date(byAdding: .month, value: -1, to: startOfThisMonth) ?? today
        let endOfLastMonth = startOfThisMonth
        
        let thisMonth = store.sessions.filter { $0.date >= startOfThisMonth }
        let lastMonth = store.sessions.filter { $0.date >= startOfLastMonth && $0.date < endOfLastMonth }
        
        let thisMonthCount = thisMonth.count
        let lastMonthCount = lastMonth.count
        
        let change = lastMonthCount > 0
            ? Double(thisMonthCount - lastMonthCount) / Double(lastMonthCount) * 100
            : (thisMonthCount > 0 ? 100.0 : 0.0)
        
        // Calculate average duration
        let thisMonthAvgDuration = thisMonth.isEmpty ? 0.0 : thisMonth.reduce(0.0) { $0 + $1.duration } / Double(thisMonth.count)
        let lastMonthAvgDuration = lastMonth.isEmpty ? 0.0 : lastMonth.reduce(0.0) { $0 + $1.duration } / Double(lastMonth.count)
        
        return MonthComparison(
            thisMonth: thisMonthCount,
            lastMonth: lastMonthCount,
            change: change,
            thisMonthAvgDuration: thisMonthAvgDuration,
            lastMonthAvgDuration: lastMonthAvgDuration,
            durationChange: thisMonthAvgDuration - lastMonthAvgDuration
        )
    }
    
    /// Analyzes performance metrics trend
    func analyzePerformanceTrend() -> PerformanceTrend {
        let calendar = Calendar.current
        let today = Date()
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: today) ?? today
        let sixtyDaysAgo = calendar.date(byAdding: .day, value: -60, to: today) ?? today
        
        let recent = store.sessions.filter { $0.date >= thirtyDaysAgo }
        let previous = store.sessions.filter { $0.date >= sixtyDaysAgo && $0.date < thirtyDaysAgo }
        
        guard !recent.isEmpty && !previous.isEmpty else {
            return PerformanceTrend(
                averageCompletionTime: 0,
                averageCompletionRate: 0,
                consistencyScore: 0,
                trend: .stable
            )
        }
        
        // Average completion time
        let recentAvgTime = recent.reduce(0.0) { $0 + $1.duration } / Double(recent.count)
        let previousAvgTime = previous.reduce(0.0) { $0 + $1.duration } / Double(previous.count)
        
        // Average completion rate
        let recentAvgRate = recent.reduce(0.0) { $0 + Double($1.exercisesCompleted) / 12.0 } / Double(recent.count)
        let previousAvgRate = previous.reduce(0.0) { $0 + Double($1.exercisesCompleted) / 12.0 } / Double(previous.count)
        
        // Consistency score (based on completion rate variance)
        let recentVariance = recent.reduce(0.0) { sum, session in
            let rate = Double(session.exercisesCompleted) / 12.0
            return sum + pow(rate - recentAvgRate, 2)
        } / Double(recent.count)
        let recentConsistency = 1.0 - min(1.0, sqrt(recentVariance))
        
        let previousVariance = previous.reduce(0.0) { sum, session in
            let rate = Double(session.exercisesCompleted) / 12.0
            return sum + pow(rate - previousAvgRate, 2)
        } / Double(previous.count)
        let previousConsistency = 1.0 - min(1.0, sqrt(previousVariance))
        
        // Determine overall trend
        let timeImproving = recentAvgTime < previousAvgTime // Lower time = faster = better
        let rateImproving = recentAvgRate > previousAvgRate
        let consistencyImproving = recentConsistency > previousConsistency
        
        let improvements = [timeImproving, rateImproving, consistencyImproving].filter { $0 }.count
        let trend: TrendDirection
        if improvements >= 2 {
            trend = .improving
        } else if improvements == 0 {
            trend = .declining
        } else {
            trend = .stable
        }
        
        return PerformanceTrend(
            averageCompletionTime: recentAvgTime,
            averageCompletionRate: recentAvgRate,
            consistencyScore: recentConsistency,
            trend: trend
        )
    }
    
    // MARK: - Helper Methods
    
    private func calculateConfidence(recent: Int, previous: Int) -> Confidence {
        let total = recent + previous
        if total >= 20 {
            return .high
        } else if total >= 10 {
            return .medium
        } else {
            return .low
        }
    }
}

// MARK: - Supporting Types

struct FrequencyTrend {
    let recentPeriod: Int
    let previousPeriod: Int
    let change: Double // Percentage change
    let direction: TrendDirection
    let confidence: Confidence
    
    var changePercentage: Int {
        Int(abs(change))
    }
    
    var isImproving: Bool {
        direction == .improving
    }
}

struct ConsistencyTrend {
    let consistencyScore: Double // 0-1
    let level: ConsistencyLevel
    let averageWorkoutsPerDay: Double
    let standardDeviation: Double
    
    var consistencyPercentage: Int {
        Int(consistencyScore * 100)
    }
}

struct WeekComparison {
    let thisWeek: Int
    let lastWeek: Int
    let change: Double // Percentage change
    let thisWeekCompletionRate: Double
    let lastWeekCompletionRate: Double
    let completionChange: Double
    
    var changePercentage: Int {
        Int(abs(change))
    }
    
    var isImproving: Bool {
        change > 0
    }
}

struct MonthComparison {
    let thisMonth: Int
    let lastMonth: Int
    let change: Double // Percentage change
    let thisMonthAvgDuration: TimeInterval
    let lastMonthAvgDuration: TimeInterval
    let durationChange: TimeInterval
    
    var changePercentage: Int {
        Int(abs(change))
    }
    
    var isImproving: Bool {
        change > 0
    }
}

struct PerformanceTrend {
    let averageCompletionTime: TimeInterval
    let averageCompletionRate: Double // 0-1
    let consistencyScore: Double // 0-1
    let trend: TrendDirection
    
    var completionPercentage: Int {
        Int(averageCompletionRate * 100)
    }
    
    var consistencyPercentage: Int {
        Int(consistencyScore * 100)
    }
}

enum TrendDirection {
    case improving
    case stable
    case declining
    
    var description: String {
        switch self {
        case .improving: return "Improving"
        case .stable: return "Stable"
        case .declining: return "Declining"
        }
    }
    
    var icon: String {
        switch self {
        case .improving: return "arrow.up.right.circle.fill"
        case .stable: return "arrow.right.circle.fill"
        case .declining: return "arrow.down.right.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .improving: return .green
        case .stable: return .orange
        case .declining: return .red
        }
    }
}

enum ConsistencyLevel {
    case veryConsistent
    case consistent
    case moderate
    case inconsistent
    
    var description: String {
        switch self {
        case .veryConsistent: return "Very Consistent"
        case .consistent: return "Consistent"
        case .moderate: return "Moderate"
        case .inconsistent: return "Inconsistent"
        }
    }
}

