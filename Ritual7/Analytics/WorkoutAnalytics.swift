import Foundation
import SwiftUI

/// Agent 2: Analytics Engine - Comprehensive workout analytics and insights
/// Agent 10: Enhanced with predictive analytics and advanced insights
@MainActor
final class WorkoutAnalytics: ObservableObject {
    let store: WorkoutStore
    
    // Agent 10: Advanced analytics components
    lazy var predictiveAnalytics = PredictiveAnalytics(store: store)
    lazy var trendAnalyzer = TrendAnalyzer(store: store)
    
    init(store: WorkoutStore) {
        self.store = store
    }
    
    // MARK: - Enhanced Statistics
    
    /// Weekly workout trends
    var weeklyTrend: [DailyWorkoutCount] {
        let calendar = Calendar.current
        let today = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        
        return (0..<7).compactMap { dayOffset in
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek) else { return nil }
            let count = store.sessions.filter { calendar.isDate($0.date, inSameDayAs: date) }.count
            return DailyWorkoutCount(date: date, count: count)
        }
    }
    
    /// Monthly workout trends (last 30 days)
    var monthlyTrend: [DailyWorkoutCount] {
        let calendar = Calendar.current
        let today = Date()
        let startDate = calendar.date(byAdding: .day, value: -30, to: today) ?? today
        
        var trend: [DailyWorkoutCount] = []
        var currentDate = startDate
        
        while currentDate <= today {
            let count = store.sessions.filter { calendar.isDate($0.date, inSameDayAs: currentDate) }.count
            trend.append(DailyWorkoutCount(date: currentDate, count: count))
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }
        
        return trend
    }
    
    /// Yearly workout trends (last 12 months)
    var yearlyTrend: [MonthlyWorkoutCount] {
        let calendar = Calendar.current
        let today = Date()
        
        return (0..<12).compactMap { monthOffset in
            guard let monthDate = calendar.date(byAdding: .month, value: -monthOffset, to: today) else { return nil }
            let count = store.sessions.filter { calendar.isDate($0.date, equalTo: monthDate, toGranularity: .month) }.count
            return MonthlyWorkoutCount(month: monthDate, count: count)
        }.reversed()
    }
    
    /// Average workout completion rate (percentage of exercises completed)
    var averageCompletionRate: Double {
        guard !store.sessions.isEmpty else { return 0 }
        let totalCompletion = store.sessions.reduce(0) { $0 + $1.exercisesCompleted }
        let expectedTotal = store.sessions.count * 12 // 12 exercises per workout
        return Double(totalCompletion) / Double(expectedTotal) * 100
    }
    
    /// Best workout time of day
    var bestWorkoutTime: TimeOfDay {
        let calendar = Calendar.current
        let hourCounts = store.sessions.reduce(into: [Int: Int]()) { counts, session in
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
    
    /// Most consistent workout day of week
    var mostConsistentDay: DayOfWeek? {
        let calendar = Calendar.current
        let dayCounts = store.sessions.reduce(into: [Int: Int]()) { counts, session in
            let weekday = calendar.component(.weekday, from: session.date)
            counts[weekday, default: 0] += 1
        }
        
        guard let maxDay = dayCounts.max(by: { $0.value < $1.value })?.key else { return nil }
        return DayOfWeek(rawValue: maxDay)
    }
    
    /// Longest streak ever achieved (calculated from historical workout sessions)
    var longestStreak: Int {
        guard !store.sessions.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let sortedSessions = store.sessions.sorted { $0.date < $1.date }
        
        var longestStreak = 0
        var currentStreak = 0
        var lastDate: Date?
        
        for session in sortedSessions {
            let sessionDate = calendar.startOfDay(for: session.date)
            
            if let last = lastDate {
                let daysSinceLastWorkout = calendar.dateComponents([.day], from: last, to: sessionDate).day ?? 0
                
                if daysSinceLastWorkout == 1 {
                    // Consecutive day - continue streak
                    currentStreak += 1
                } else if daysSinceLastWorkout == 0 {
                    // Same day - multiple workouts don't count as separate streak days
                    continue
                } else {
                    // Gap detected - streak broken, check if this was the longest
                    longestStreak = max(longestStreak, currentStreak)
                    currentStreak = 1 // Start new streak
                }
            } else {
                // First workout
                currentStreak = 1
            }
            
            lastDate = sessionDate
        }
        
        // Check if current streak is the longest
        longestStreak = max(longestStreak, currentStreak)
        
        return longestStreak
    }
    
    /// Estimated total calories burned (rough estimate: ~100 calories per 7-minute workout)
    var estimatedTotalCalories: Int {
        return store.totalWorkouts * 100
    }
    
    /// Total time spent exercising (in minutes)
    var totalExerciseTime: TimeInterval {
        return store.totalMinutes * 60
    }
    
    /// Workout frequency by day of week
    var workoutFrequencyByDay: [DayOfWeek: Int] {
        let calendar = Calendar.current
        var frequency: [DayOfWeek: Int] = [:]
        
        for session in store.sessions {
            let weekday = calendar.component(.weekday, from: session.date)
            if let day = DayOfWeek(rawValue: weekday) {
                frequency[day, default: 0] += 1
            }
        }
        
        return frequency
    }
    
    /// Workout frequency by time of day
    var workoutFrequencyByTime: [TimeOfDay: Int] {
        let calendar = Calendar.current
        var frequency: [TimeOfDay: Int] = [:]
        
        for session in store.sessions {
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
    
    /// Exercise completion rate (percentage of exercises completed per workout)
    var exerciseCompletionRates: [Double] {
        return store.sessions.map { session in
            Double(session.exercisesCompleted) / 12.0 * 100
        }
    }
    
    /// Average workout duration
    var averageDuration: TimeInterval {
        return store.averageWorkoutDuration
    }
    
    /// Progress over last 30 days
    var progress30Days: ProgressComparison {
        let calendar = Calendar.current
        let today = Date()
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: today) ?? today
        let sixtyDaysAgo = calendar.date(byAdding: .day, value: -60, to: today) ?? today
        
        let recent30 = store.sessions.filter { $0.date >= thirtyDaysAgo }.count
        let previous30 = store.sessions.filter { $0.date >= sixtyDaysAgo && $0.date < thirtyDaysAgo }.count
        
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
        
        let recent7 = store.sessions.filter { $0.date >= sevenDaysAgo }.count
        let previous7 = store.sessions.filter { $0.date >= fourteenDaysAgo && $0.date < sevenDaysAgo }.count
        
        let change = recent7 > 0 && previous7 > 0 ? Double(recent7 - previous7) / Double(previous7) * 100 : 0
        
        return ProgressComparison(
            recent: recent7,
            previous: previous7,
            change: change
        )
    }
    
    // MARK: - Insights
    
    /// Generate personalized insights based on workout patterns
    func generateInsights() -> [WorkoutInsight] {
        var insights: [WorkoutInsight] = []
        
        // Streak insights
        if store.streak >= 7 {
            insights.append(.init(
                type: .streak,
                title: "🔥 On Fire!",
                message: "You've maintained a \(store.streak)-day streak! Keep it up!",
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
                message: "You work out most on \(mostDay.displayName)s. Keep it consistent!",
                icon: "calendar",
                color: .blue
            ))
        }
        
        // Time of day insights
        switch bestWorkoutTime {
        case .morning:
            insights.append(.init(
                type: .pattern,
                title: "Early Bird",
                message: "You're most active in the morning. Great way to start the day!",
                icon: "sunrise.fill",
                color: .yellow
            ))
        case .afternoon:
            insights.append(.init(
                type: .pattern,
                title: "Midday Momentum",
                message: "You prefer afternoon workouts. Perfect for a midday energy boost!",
                icon: "sun.max.fill",
                color: .orange
            ))
        case .evening:
            insights.append(.init(
                type: .pattern,
                title: "Evening Warrior",
                message: "You work out in the evenings. Great way to unwind!",
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
                message: "You've increased your workouts by \(Int(progress7.change))% this week!",
                icon: "chart.line.uptrend.xyaxis",
                color: .green
            ))
        }
        
        // Completion rate insights
        if averageCompletionRate >= 95 {
            insights.append(.init(
                type: .achievement,
                title: "Full Power!",
                message: "You're completing nearly all exercises. Outstanding dedication!",
                icon: "checkmark.circle.fill",
                color: .green
            ))
        }
        
        return insights
    }
    
    // MARK: - Agent 10: Advanced Analytics Methods
    
    /// Get workout likelihood prediction for today
    func getWorkoutLikelihoodToday() -> WorkoutLikelihood {
        return predictiveAnalytics.predictWorkoutLikelihoodToday()
    }
    
    /// Get optimal workout time prediction
    func getOptimalWorkoutTime() -> OptimalTimePrediction? {
        return predictiveAnalytics.predictOptimalWorkoutTime()
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
    
    /// Generate personalized workout recommendations
    func generatePersonalizedRecommendations() -> [PersonalizedRecommendation] {
        var recommendations: [PersonalizedRecommendation] = []
        
        // Optimal time recommendation
        if let optimalTime = getOptimalWorkoutTime() {
            recommendations.append(.init(
                type: .optimalTime,
                title: "Best Workout Time",
                message: "You perform best at \(optimalTime.timeDescription). Try scheduling workouts around this time!",
                icon: "clock.fill",
                color: .blue
            ))
        }
        
        // Goal achievement recommendation
        let frequencyTrend = getFrequencyTrend()
        if frequencyTrend.direction == .declining {
            recommendations.append(.init(
                type: .frequency,
                title: "Getting Back on Track",
                message: "Your workout frequency has decreased. Try setting a weekly goal to stay motivated!",
                icon: "target",
                color: .orange
            ))
        }
        
        // Consistency recommendation
        let consistency = getConsistencyTrend()
        if consistency.level == .inconsistent {
            recommendations.append(.init(
                type: .consistency,
                title: "Build Consistency",
                message: "Aim for more regular workouts. Even 2-3 times per week can make a big difference!",
                icon: "calendar.badge.clock",
                color: .purple
            ))
        }
        
        // Streak recommendation
        if store.streak > 0 && store.streak < 7 {
            recommendations.append(.init(
                type: .streak,
                title: "Keep the Streak Going!",
                message: "You're on a \(store.streak)-day streak! Keep it up to reach 7 days!",
                icon: "flame.fill",
                color: .orange
            ))
        }
        
        return recommendations
    }
    
    /// Generate weekly summary insights
    func generateWeeklySummary() -> WeeklySummary? {
        let weekComparison = getWeekComparison()
        let consistency = getConsistencyTrend()
        let likelihood = getWorkoutLikelihoodToday()
        
        return WeeklySummary(
            workoutsThisWeek: store.workoutsThisWeek,
            workoutsLastWeek: weekComparison.lastWeek,
            change: weekComparison.change,
            consistencyScore: consistency.consistencyScore,
            workoutLikelihoodToday: likelihood.probability,
            insights: generatePersonalizedRecommendations()
        )
    }
    
    /// Generate monthly summary insights
    func generateMonthlySummary() -> MonthlySummary? {
        let monthComparison = getMonthComparison()
        let performance = getPerformanceTrend()
        let consistency = getConsistencyTrend()
        
        return MonthlySummary(
            workoutsThisMonth: store.workoutsThisMonth,
            workoutsLastMonth: monthComparison.lastMonth,
            change: monthComparison.change,
            averageCompletionRate: performance.averageCompletionRate,
            consistencyScore: consistency.consistencyScore,
            trend: performance.trend
        )
    }
}

// MARK: - Supporting Types

struct DailyWorkoutCount: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
}

struct MonthlyWorkoutCount: Identifiable {
    let id = UUID()
    let month: Date
    let count: Int
}

struct ProgressComparison {
    let recent: Int
    let previous: Int
    let change: Double // Percentage change
}

enum TimeOfDay: String, CaseIterable, Identifiable {
    case morning = "Morning"
    case afternoon = "Afternoon"
    case evening = "Evening"
    case night = "Night"
    case unknown = "Unknown"
    
    var id: String { rawValue }
    
    var displayName: String {
        return rawValue
    }
}

enum DayOfWeek: Int, CaseIterable, Identifiable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    
    var id: Int { rawValue }
    
    var displayName: String {
        switch self {
        case .sunday: return "Sunday"
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        }
    }
    
    var shortName: String {
        switch self {
        case .sunday: return "Sun"
        case .monday: return "Mon"
        case .tuesday: return "Tue"
        case .wednesday: return "Wed"
        case .thursday: return "Thu"
        case .friday: return "Fri"
        case .saturday: return "Sat"
        }
    }
}

struct WorkoutInsight: Identifiable {
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

// MARK: - Agent 10: Advanced Analytics Types

struct PersonalizedRecommendation: Identifiable {
    let id = UUID()
    let type: RecommendationType
    let title: String
    let message: String
    let icon: String
    let color: Color
    
    enum RecommendationType {
        case optimalTime
        case frequency
        case consistency
        case streak
        case goal
    }
}

struct WeeklySummary {
    let workoutsThisWeek: Int
    let workoutsLastWeek: Int
    let change: Double
    let consistencyScore: Double
    let workoutLikelihoodToday: Double
    let insights: [PersonalizedRecommendation]
}

struct MonthlySummary {
    let workoutsThisMonth: Int
    let workoutsLastMonth: Int
    let change: Double
    let averageCompletionRate: Double
    let consistencyScore: Double
    let trend: TrendDirection
}

