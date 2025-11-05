import Foundation
import SwiftUI

/// Agent 16: Habit Learner - Recognizes workout patterns and optimal times
@MainActor
final class HabitLearner: ObservableObject {
    @Published var habitPatterns: HabitPatterns
    
    private let patternsKey = "habit.patterns.v1"
    private let workoutStore: WorkoutStore
    
    init(workoutStore: WorkoutStore) {
        self.workoutStore = workoutStore
        self.habitPatterns = HabitLearner.loadPatterns()
    }
    
    // MARK: - Pattern Recognition
    
    /// Analyze workout history and learn patterns
    func analyzePatterns() {
        let sessions = workoutStore.sessions
        
        guard !sessions.isEmpty else {
            habitPatterns = HabitPatterns()
            return
        }
        
        // Analyze time patterns
        analyzeTimePatterns(sessions: sessions)
        
        // Analyze frequency patterns
        analyzeFrequencyPatterns(sessions: sessions)
        
        // Analyze completion patterns
        analyzeCompletionPatterns(sessions: sessions)
        
        // Analyze consistency patterns
        analyzeConsistencyPatterns(sessions: sessions)
        
        // Save patterns
        savePatterns()
    }
    
    /// Analyze time-of-day patterns
    private func analyzeTimePatterns(sessions: [WorkoutSession]) {
        let calendar = Calendar.current
        var hourFrequency: [Int: Int] = [:]
        var weekdayFrequency: [Int: Int] = [:]
        
        for session in sessions {
            let hour = calendar.component(.hour, from: session.date)
            let weekday = calendar.component(.weekday, from: session.date)
            
            hourFrequency[hour, default: 0] += 1
            weekdayFrequency[weekday, default: 0] += 1
        }
        
        // Find most frequent hour
        if let mostFrequentHour = hourFrequency.max(by: { $0.value < $1.value }) {
            habitPatterns.optimalWorkoutHour = mostFrequentHour.key
        }
        
        // Find most frequent weekday
        if let mostFrequentDay = weekdayFrequency.max(by: { $0.value < $1.value }) {
            habitPatterns.optimalWorkoutDay = mostFrequentDay.key
        }
        
        // Calculate hour distribution
        habitPatterns.hourDistribution = hourFrequency
        habitPatterns.weekdayDistribution = weekdayFrequency
    }
    
    /// Analyze frequency patterns
    private func analyzeFrequencyPatterns(sessions: [WorkoutSession]) {
        let calendar = Calendar.current
        let now = Date()
        
        // Calculate workouts per week
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        let recentSessions = sessions.filter { $0.date >= sevenDaysAgo }
        habitPatterns.workoutsPerWeek = Double(recentSessions.count)
        
        // Calculate average days between workouts
        if sessions.count >= 2 {
            let intervals: [TimeInterval] = (1..<sessions.count).map { index in
                sessions[index - 1].date.timeIntervalSince(sessions[index].date)
            }
            let averageInterval = intervals.reduce(0, +) / Double(intervals.count)
            habitPatterns.averageDaysBetweenWorkouts = averageInterval / (24 * 60 * 60)
        }
    }
    
    /// Analyze completion patterns
    private func analyzeCompletionPatterns(sessions: [WorkoutSession]) {
        guard !sessions.isEmpty else { return }
        
        // Calculate average completion rate
        let totalExercises = sessions.reduce(0) { $0 + $1.exercisesCompleted }
        let averageExercises = Double(totalExercises) / Double(sessions.count)
        habitPatterns.averageExercisesCompleted = averageExercises
        
        // Calculate completion rate percentage (assuming 12 exercises per workout)
        habitPatterns.averageCompletionRate = averageExercises / 12.0
        
        // Track full workout completions
        let fullCompletions = sessions.filter { $0.exercisesCompleted >= 12 }.count
        habitPatterns.fullWorkoutCompletionRate = Double(fullCompletions) / Double(sessions.count)
    }
    
    /// Analyze consistency patterns
    private func analyzeConsistencyPatterns(sessions: [WorkoutSession]) {
        // Calculate streak stability
        let currentStreak = workoutStore.streak
        habitPatterns.currentStreak = currentStreak
        
        // Calculate longest streak (simplified - would need full history)
        if let longestStreak = calculateLongestStreak(sessions: sessions) {
            habitPatterns.longestStreak = longestStreak
        }
        
        // Calculate consistency score (0.0 to 1.0)
        habitPatterns.consistencyScore = calculateConsistencyScore(sessions: sessions)
    }
    
    /// Calculate longest streak from sessions
    private func calculateLongestStreak(sessions: [WorkoutSession]) -> Int? {
        guard !sessions.isEmpty else { return nil }
        
        let calendar = Calendar.current
        let sortedSessions = sessions.sorted(by: { $0.date < $1.date })
        
        var longestStreak = 1
        var currentStreak = 1
        var lastDate: Date?
        
        for session in sortedSessions {
            if let last = lastDate {
                let daysSince = calendar.dateComponents([.day], from: last, to: session.date).day ?? 0
                
                if daysSince == 1 {
                    // Consecutive day
                    currentStreak += 1
                    longestStreak = max(longestStreak, currentStreak)
                } else if daysSince > 1 {
                    // Streak broken
                    currentStreak = 1
                }
            }
            lastDate = session.date
        }
        
        return longestStreak
    }
    
    /// Calculate consistency score
    private func calculateConsistencyScore(sessions: [WorkoutSession]) -> Double {
        guard !sessions.isEmpty else { return 0.0 }
        
        let calendar = Calendar.current
        let now = Date()
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: now) ?? now
        
        let recentSessions = sessions.filter { $0.date >= thirtyDaysAgo }
        
        guard !recentSessions.isEmpty else { return 0.0 }
        
        // Calculate expected workouts (aim for 3-4 per week)
        let daysSince = calendar.dateComponents([.day], from: thirtyDaysAgo, to: now).day ?? 30
        let expectedWorkouts = (Double(daysSince) / 7.0) * 3.5 // 3.5 workouts per week
        
        // Calculate actual workouts
        let actualWorkouts = Double(recentSessions.count)
        
        // Calculate score (capped at 1.0)
        let score = min(1.0, actualWorkouts / expectedWorkouts)
        
        return score
    }
    
    // MARK: - Insights & Predictions
    
    /// Get habit strength score (0.0 to 1.0)
    func getHabitStrength() -> Double {
        // Combine multiple factors
        let consistencyWeight = 0.4
        let frequencyWeight = 0.3
        let completionWeight = 0.3
        
        let consistencyScore = habitPatterns.consistencyScore
        let frequencyScore = min(1.0, habitPatterns.workoutsPerWeek / 5.0) // 5 workouts per week = 1.0
        let completionScore = habitPatterns.averageCompletionRate
        
        return (consistencyScore * consistencyWeight) +
               (frequencyScore * frequencyWeight) +
               (completionScore * completionWeight)
    }
    
    /// Predict likelihood of working out today
    func predictWorkoutLikelihood() -> Double {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let hour = calendar.component(.hour, from: today)
        
        // Base likelihood on patterns
        var likelihood: Double = 0.5 // Default 50%
        
        // Adjust based on optimal day
        if let optimalDay = habitPatterns.optimalWorkoutDay, weekday == optimalDay {
            likelihood += 0.2
        }
        
        // Adjust based on optimal hour
        if let optimalHour = habitPatterns.optimalWorkoutHour {
            let hourDiff = abs(hour - optimalHour)
            if hourDiff <= 1 {
                likelihood += 0.2
            } else if hourDiff <= 3 {
                likelihood += 0.1
            }
        }
        
        // Adjust based on consistency
        likelihood += habitPatterns.consistencyScore * 0.1
        
        // Adjust based on recent activity
        let recentSessions = workoutStore.sessions.filter { $0.date >= calendar.date(byAdding: .day, value: -7, to: today) ?? today }
        if !recentSessions.isEmpty {
            likelihood += 0.1
        }
        
        // Cap at 1.0
        return min(1.0, likelihood)
    }
    
    /// Get optimal workout time for today
    func getOptimalWorkoutTime() -> Date? {
        guard let optimalHour = habitPatterns.optimalWorkoutHour else {
            return nil
        }
        
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = optimalHour
        components.minute = 0
        
        return calendar.date(from: components)
    }
    
    /// Get habit formation insights
    func getHabitInsights() -> [HabitInsight] {
        var insights: [HabitInsight] = []
        
        // Consistency insight
        if habitPatterns.consistencyScore >= 0.8 {
            insights.append(.init(
                type: .excellent,
                title: "Excellent Consistency",
                message: "You're maintaining a strong workout habit! Keep it up."
            ))
        } else if habitPatterns.consistencyScore >= 0.6 {
            insights.append(.init(
                type: .good,
                title: "Good Consistency",
                message: "You're building a solid habit. Try to maintain your current schedule."
            ))
        } else {
            insights.append(.init(
                type: .suggestion,
                title: "Build Consistency",
                message: "Try to work out at the same time each day to strengthen your habit."
            ))
        }
        
        // Time pattern insight
        if let optimalHour = habitPatterns.optimalWorkoutHour {
            let hourName = getHourName(optimalHour)
            insights.append(.init(
                type: .info,
                title: "Your Optimal Time",
                message: "You tend to work out most consistently at \(hourName)."
            ))
        }
        
        // Completion rate insight
        if habitPatterns.averageCompletionRate >= 0.9 {
            insights.append(.init(
                type: .excellent,
                title: "High Completion Rate",
                message: "You're completing most of your workouts! Great job."
            ))
        } else if habitPatterns.averageCompletionRate < 0.7 {
            insights.append(.init(
                type: .suggestion,
                title: "Improve Completion",
                message: "Consider shorter workouts or adjusting intensity to complete more exercises."
            ))
        }
        
        return insights
    }
    
    /// Get hour name for display
    private func getHourName(_ hour: Int) -> String {
        switch hour {
        case 0..<6:
            return "early morning"
        case 6..<12:
            return "morning"
        case 12..<17:
            return "afternoon"
        case 17..<22:
            return "evening"
        default:
            return "night"
        }
    }
    
    // MARK: - Persistence
    
    private static func loadPatterns() -> HabitPatterns {
        guard let data = UserDefaults.standard.data(forKey: "habit.patterns.v1"),
              let decoded = try? JSONDecoder().decode(HabitPatterns.self, from: data) else {
            return HabitPatterns()
        }
        return decoded
    }
    
    private func savePatterns() {
        if let data = try? JSONEncoder().encode(habitPatterns) {
            UserDefaults.standard.set(data, forKey: patternsKey)
        }
    }
}

// MARK: - Supporting Types

/// Habit pattern data
struct HabitPatterns: Codable {
    var optimalWorkoutHour: Int? // Hour of day (0-23)
    var optimalWorkoutDay: Int? // Weekday (1-7)
    var hourDistribution: [Int: Int] = [:] // Hour -> Count
    var weekdayDistribution: [Int: Int] = [:] // Weekday -> Count
    var workoutsPerWeek: Double = 0.0
    var averageDaysBetweenWorkouts: Double = 0.0
    var averageExercisesCompleted: Double = 0.0
    var averageCompletionRate: Double = 0.0
    var fullWorkoutCompletionRate: Double = 0.0
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var consistencyScore: Double = 0.0
    
    init() {
        self.hourDistribution = [:]
        self.weekdayDistribution = [:]
    }
}

/// Habit insight
struct HabitInsight: Identifiable {
    let id = UUID()
    let type: InsightType
    let title: String
    let message: String
    
    enum InsightType {
        case excellent
        case good
        case info
        case suggestion
        
        var color: Color {
            switch self {
            case .excellent: return .green
            case .good: return .blue
            case .info: return .secondary
            case .suggestion: return .orange
            }
        }
        
        var icon: String {
            switch self {
            case .excellent: return "star.fill"
            case .good: return "checkmark.circle.fill"
            case .info: return "info.circle.fill"
            case .suggestion: return "lightbulb.fill"
            }
        }
    }
}

