import Foundation
import SwiftUI

/// Agent 10: Goal Manager - Manages workout goals and progress tracking
@MainActor
final class GoalManager: ObservableObject {
    private let store: WorkoutStore
    
    @Published private(set) var weeklyGoal: Int = 0
    @Published private(set) var monthlyGoal: Int = 0
    @Published private(set) var weeklyProgress: Int = 0
    @Published private(set) var monthlyProgress: Int = 0
    
    private let weeklyGoalKey = "goal.weekly.v1"
    private let monthlyGoalKey = "goal.monthly.v1"
    
    init(store: WorkoutStore) {
        self.store = store
        load()
        updateProgress()
    }
    
    // MARK: - Goal Management
    
    /// Set weekly workout goal
    func setWeeklyGoal(_ goal: Int) {
        guard goal >= 0 && goal <= 14 else { return } // Max 2 per day
        weeklyGoal = goal
        save()
        updateProgress()
    }
    
    /// Set monthly workout goal
    func setMonthlyGoal(_ goal: Int) {
        guard goal >= 0 && goal <= 60 else { return } // Max ~2 per day
        monthlyGoal = goal
        save()
        updateProgress()
    }
    
    /// Get adaptive goal suggestion based on user's current performance
    func getAdaptiveGoalSuggestion(for period: GoalPeriod) -> Int {
        let calendar = Calendar.current
        let today = Date()
        
        switch period {
        case .weekly:
            // Suggest based on average workouts per week
            let weeksOfData = calculateWeeksOfData()
            guard weeksOfData > 0 else { return 3 } // Default suggestion
            
            let avgPerWeek = Double(store.totalWorkouts) / Double(weeksOfData)
            // Suggest slightly above average (20% increase)
            let suggestion = Int(avgPerWeek * 1.2)
            return max(1, min(7, suggestion)) // Between 1 and 7
            
        case .monthly:
            // Suggest based on average workouts per month
            let monthsOfData = calculateMonthsOfData()
            guard monthsOfData > 0 else { return 12 } // Default suggestion
            
            let avgPerMonth = Double(store.totalWorkouts) / Double(monthsOfData)
            // Suggest slightly above average (20% increase)
            let suggestion = Int(avgPerMonth * 1.2)
            return max(4, min(30, suggestion)) // Between 4 and 30
        }
    }
    
    /// Update progress tracking
    func updateProgress() {
        weeklyProgress = store.workoutsThisWeek
        monthlyProgress = store.workoutsThisMonth
    }
    
    // MARK: - Progress Calculation
    
    /// Get weekly goal progress percentage
    var weeklyProgressPercentage: Double {
        guard weeklyGoal > 0 else { return 0 }
        return min(1.0, Double(weeklyProgress) / Double(weeklyGoal))
    }
    
    /// Get monthly goal progress percentage
    var monthlyProgressPercentage: Double {
        guard monthlyGoal > 0 else { return 0 }
        return min(1.0, Double(monthlyProgress) / Double(monthlyGoal))
    }
    
    /// Check if weekly goal is achieved
    var isWeeklyGoalAchieved: Bool {
        guard weeklyGoal > 0 else { return false }
        return weeklyProgress >= weeklyGoal
    }
    
    /// Check if monthly goal is achieved
    var isMonthlyGoalAchieved: Bool {
        guard monthlyGoal > 0 else { return false }
        return monthlyProgress >= monthlyGoal
    }
    
    /// Get workouts remaining for weekly goal
    var weeklyWorkoutsRemaining: Int {
        return max(0, weeklyGoal - weeklyProgress)
    }
    
    /// Get workouts remaining for monthly goal
    var monthlyWorkoutsRemaining: Int {
        return max(0, monthlyGoal - monthlyProgress)
    }
    
    /// Get days remaining in week
    var daysRemainingInWeek: Int {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        return max(0, 7 - weekday)
    }
    
    /// Get days remaining in month
    var daysRemainingInMonth: Int {
        let calendar = Calendar.current
        let today = Date()
        guard let endOfMonth = calendar.dateInterval(of: .month, for: today)?.end else {
            return 0
        }
        let days = calendar.dateComponents([.day], from: today, to: endOfMonth).day ?? 0
        return max(0, days)
    }
    
    /// Get recommended daily workouts for weekly goal
    var recommendedDailyForWeekly: Double {
        let daysRemaining = daysRemainingInWeek
        guard daysRemaining > 0 else { return 0 }
        return Double(weeklyWorkoutsRemaining) / Double(daysRemaining)
    }
    
    /// Get recommended daily workouts for monthly goal
    var recommendedDailyForMonthly: Double {
        let daysRemaining = daysRemainingInMonth
        guard daysRemaining > 0 else { return 0 }
        return Double(monthlyWorkoutsRemaining) / Double(daysRemaining)
    }
    
    // MARK: - Goal Achievement Prediction
    
    /// Predict if weekly goal will be achieved
    func predictWeeklyGoalAchievement() -> GoalPrediction {
        guard weeklyGoal > 0 else {
            return GoalPrediction(achievable: false, probability: 0, confidence: .low)
        }
        
        let daysRemaining = daysRemainingInWeek
        let avgPerDay = calculateAverageWorkoutsPerDay()
        let predicted = Double(weeklyProgress) + (Double(daysRemaining) * avgPerDay)
        let probability = min(1.0, max(0.0, predicted / Double(weeklyGoal)))
        
        let confidence: Confidence
        if store.totalWorkouts >= 20 {
            confidence = .high
        } else if store.totalWorkouts >= 10 {
            confidence = .medium
        } else {
            confidence = .low
        }
        
        return GoalPrediction(
            achievable: probability >= 0.7,
            probability: probability,
            confidence: confidence
        )
    }
    
    /// Predict if monthly goal will be achieved
    func predictMonthlyGoalAchievement() -> GoalPrediction {
        guard monthlyGoal > 0 else {
            return GoalPrediction(achievable: false, probability: 0, confidence: .low)
        }
        
        let daysRemaining = daysRemainingInMonth
        let avgPerDay = calculateAverageWorkoutsPerDay()
        let predicted = Double(monthlyProgress) + (Double(daysRemaining) * avgPerDay)
        let probability = min(1.0, max(0.0, predicted / Double(monthlyGoal)))
        
        let confidence: Confidence
        if store.totalWorkouts >= 20 {
            confidence = .high
        } else if store.totalWorkouts >= 10 {
            confidence = .medium
        } else {
            confidence = .low
        }
        
        return GoalPrediction(
            achievable: probability >= 0.7,
            probability: probability,
            confidence: confidence
        )
    }
    
    // MARK: - Persistence
    
    private func load() {
        let d = UserDefaults.standard
        weeklyGoal = d.integer(forKey: weeklyGoalKey)
        monthlyGoal = d.integer(forKey: monthlyGoalKey)
    }
    
    private func save() {
        let d = UserDefaults.standard
        d.set(weeklyGoal, forKey: weeklyGoalKey)
        d.set(monthlyGoal, forKey: monthlyGoalKey)
    }
    
    // MARK: - Helper Methods
    
    private func calculateWeeksOfData() -> Int {
        guard !store.sessions.isEmpty else { return 0 }
        let calendar = Calendar.current
        let oldest = store.sessions.last?.date ?? Date()
        let newest = store.sessions.first?.date ?? Date()
        let components = calendar.dateComponents([.weekOfYear], from: oldest, to: newest)
        return max(1, (components.weekOfYear ?? 0) + 1)
    }
    
    private func calculateMonthsOfData() -> Int {
        guard !store.sessions.isEmpty else { return 0 }
        let calendar = Calendar.current
        let oldest = store.sessions.last?.date ?? Date()
        let newest = store.sessions.first?.date ?? Date()
        let components = calendar.dateComponents([.month], from: oldest, to: newest)
        return max(1, (components.month ?? 0) + 1)
    }
    
    private func calculateAverageWorkoutsPerDay() -> Double {
        guard !store.sessions.isEmpty else { return 0 }
        let calendar = Calendar.current
        let oldest = store.sessions.last?.date ?? Date()
        let today = Date()
        let days = calendar.dateComponents([.day], from: oldest, to: today).day ?? 1
        return Double(store.sessions.count) / Double(max(1, days))
    }
}

// MARK: - Supporting Types

enum GoalPeriod {
    case weekly
    case monthly
    
    var displayName: String {
        switch self {
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        }
    }
}

struct GoalPrediction {
    let achievable: Bool
    let probability: Double // 0-1
    let confidence: Confidence
    
    var percentage: Int {
        Int(probability * 100)
    }
}

