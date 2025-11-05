import Foundation
import SwiftUI

/// Agent 10: Predictive Analytics - Predicts workout likelihood and provides insights
@MainActor
final class PredictiveAnalytics: ObservableObject {
    let store: WorkoutStore
    
    init(store: WorkoutStore) {
        self.store = store
    }
    
    // MARK: - Workout Likelihood Prediction
    
    /// Predicts the likelihood of working out today based on historical patterns
    func predictWorkoutLikelihoodToday() -> WorkoutLikelihood {
        let calendar = Calendar.current
        let today = Date()
        
        // Get historical data for today's day of week
        let weekday = calendar.component(.weekday, from: today)
        let historicalWorkouts = store.sessions.filter { session in
            calendar.component(.weekday, from: session.date) == weekday
        }
        
        // Calculate workout frequency for this day of week
        let totalWeeks = calculateTotalWeeks()
        guard totalWeeks > 0 else {
            return WorkoutLikelihood(probability: 0.5, confidence: .low, factors: ["No historical data"])
        }
        
        let workoutsOnThisDay = historicalWorkouts.count
        let probability = min(1.0, Double(workoutsOnThisDay) / Double(totalWeeks))
        
        // Consider recent streak
        let streakFactor = min(1.0, Double(store.streak) / 7.0)
        let adjustedProbability = (probability * 0.7) + (streakFactor * 0.3)
        
        // Determine confidence
        let confidence: Confidence
        if totalWeeks >= 4 {
            confidence = .high
        } else if totalWeeks >= 2 {
            confidence = .medium
        } else {
            confidence = .low
        }
        
        // Generate factors
        var factors: [String] = []
        if store.streak > 0 {
            factors.append("Active \(store.streak)-day streak")
        }
        if probability > 0.7 {
            factors.append("You typically work out on \(DayOfWeek(rawValue: weekday)?.displayName ?? "this day")")
        }
        if store.workoutsThisWeek > 0 {
            factors.append("Already \(store.workoutsThisWeek) workout(s) this week")
        }
        
        return WorkoutLikelihood(
            probability: adjustedProbability,
            confidence: confidence,
            factors: factors.isEmpty ? ["No patterns detected"] : factors
        )
    }
    
    /// Predicts optimal workout time based on historical patterns
    func predictOptimalWorkoutTime() -> OptimalTimePrediction? {
        guard !store.sessions.isEmpty else { return nil }
        
        let calendar = Calendar.current
        var hourCounts: [Int: Int] = [:]
        var hourCompletionRates: [Int: Double] = [:]
        
        for session in store.sessions {
            let hour = calendar.component(.hour, from: session.date)
            hourCounts[hour, default: 0] += 1
            let completionRate = Double(session.exercisesCompleted) / 12.0
            hourCompletionRates[hour] = (hourCompletionRates[hour] ?? 0.0) + completionRate
        }
        
        // Find hour with highest count and completion rate
        guard let bestHour = hourCounts.max(by: { $0.value < $1.value })?.key else {
            return nil
        }
        
        let avgCompletionRate = hourCompletionRates[bestHour, default: 0.0] / Double(hourCounts[bestHour] ?? 1)
        
        let timeOfDay: TimeOfDay
        switch bestHour {
        case 5..<12: timeOfDay = .morning
        case 12..<17: timeOfDay = .afternoon
        case 17..<22: timeOfDay = .evening
        default: timeOfDay = .night
        }
        
        return OptimalTimePrediction(
            hour: bestHour,
            timeOfDay: timeOfDay,
            workoutCount: hourCounts[bestHour] ?? 0,
            averageCompletionRate: avgCompletionRate,
            confidence: hourCounts[bestHour] ?? 0 >= 3 ? .high : .medium
        )
    }
    
    /// Predicts weekly workout goal achievement likelihood
    func predictWeeklyGoalAchievement(goal: Int) -> GoalAchievementPrediction {
        let workoutsSoFar = store.workoutsThisWeek
        let daysRemaining = daysRemainingInWeek()
        let averageWorkoutsPerDay = calculateAverageWorkoutsPerDay()
        
        let predictedTotal = Double(workoutsSoFar) + (Double(daysRemaining) * averageWorkoutsPerDay)
        let probability = min(1.0, max(0.0, predictedTotal / Double(goal)))
        
        let confidence: Confidence
        if store.totalWorkouts >= 20 {
            confidence = .high
        } else if store.totalWorkouts >= 10 {
            confidence = .medium
        } else {
            confidence = .low
        }
        
        let needs = max(0, goal - workoutsSoFar)
        let recommendedDaily = needs > 0 && daysRemaining > 0 ? Double(needs) / Double(daysRemaining) : 0.0
        
        return GoalAchievementPrediction(
            goal: goal,
            current: workoutsSoFar,
            predicted: Int(predictedTotal),
            probability: probability,
            confidence: confidence,
            workoutsNeeded: needs,
            recommendedDaily: recommendedDaily
        )
    }
    
    // MARK: - Correlation Analysis
    
    /// Analyzes correlation between workout time and completion rate
    func analyzeTimeCompletionCorrelation() -> CorrelationAnalysis? {
        guard store.sessions.count >= 5 else { return nil }
        
        let calendar = Calendar.current
        var morningSessions: [WorkoutSession] = []
        var afternoonSessions: [WorkoutSession] = []
        var eveningSessions: [WorkoutSession] = []
        
        for session in store.sessions {
            let hour = calendar.component(.hour, from: session.date)
            switch hour {
            case 5..<12: morningSessions.append(session)
            case 12..<17: afternoonSessions.append(session)
            case 17..<22: eveningSessions.append(session)
            default: break
            }
        }
        
        func averageCompletionRate(for sessions: [WorkoutSession]) -> Double {
            guard !sessions.isEmpty else { return 0 }
            let total = sessions.reduce(0.0) { $0 + Double($1.exercisesCompleted) / 12.0 }
            return total / Double(sessions.count)
        }
        
        let morningRate = averageCompletionRate(for: morningSessions)
        let afternoonRate = averageCompletionRate(for: afternoonSessions)
        let eveningRate = averageCompletionRate(for: eveningSessions)
        
        return CorrelationAnalysis(
            morningCompletionRate: morningRate,
            afternoonCompletionRate: afternoonRate,
            eveningCompletionRate: eveningRate,
            bestTime: [.morning: morningRate, .afternoon: afternoonRate, .evening: eveningRate]
                .max(by: { $0.value < $1.value })?.key ?? .morning
        )
    }
    
    // MARK: - Helper Methods
    
    private func calculateTotalWeeks() -> Int {
        guard !store.sessions.isEmpty else { return 0 }
        let calendar = Calendar.current
        let oldest = store.sessions.last?.date ?? Date()
        let newest = store.sessions.first?.date ?? Date()
        let components = calendar.dateComponents([.weekOfYear], from: oldest, to: newest)
        return max(1, (components.weekOfYear ?? 0) + 1)
    }
    
    private func calculateAverageWorkoutsPerDay() -> Double {
        guard !store.sessions.isEmpty else { return 0 }
        let calendar = Calendar.current
        let oldest = store.sessions.last?.date ?? Date()
        let today = Date()
        let days = calendar.dateComponents([.day], from: oldest, to: today).day ?? 1
        return Double(store.sessions.count) / Double(max(1, days))
    }
    
    private func daysRemainingInWeek() -> Int {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        // Days remaining in week (Sunday = 1, Saturday = 7)
        return max(0, 7 - weekday)
    }
}

// MARK: - Supporting Types

struct WorkoutLikelihood {
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

struct OptimalTimePrediction {
    let hour: Int
    let timeOfDay: TimeOfDay
    let workoutCount: Int
    let averageCompletionRate: Double
    let confidence: Confidence
    
    var timeDescription: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        let date = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: Date()) ?? Date()
        return formatter.string(from: date)
    }
    
    var completionPercentage: Int {
        Int(averageCompletionRate * 100)
    }
}

struct GoalAchievementPrediction {
    let goal: Int
    let current: Int
    let predicted: Int
    let probability: Double
    let confidence: Confidence
    let workoutsNeeded: Int
    let recommendedDaily: Double
    
    var percentage: Int {
        Int(probability * 100)
    }
    
    var onTrack: Bool {
        probability >= 0.7
    }
}

struct CorrelationAnalysis {
    let morningCompletionRate: Double
    let afternoonCompletionRate: Double
    let eveningCompletionRate: Double
    let bestTime: TimeOfDay
    
    var bestCompletionRate: Double {
        max(morningCompletionRate, afternoonCompletionRate, eveningCompletionRate)
    }
    
    var bestCompletionPercentage: Int {
        Int(bestCompletionRate * 100)
    }
}

enum Confidence {
    case low
    case medium
    case high
    
    var description: String {
        switch self {
        case .low: return "Low Confidence"
        case .medium: return "Medium Confidence"
        case .high: return "High Confidence"
        }
    }
}

