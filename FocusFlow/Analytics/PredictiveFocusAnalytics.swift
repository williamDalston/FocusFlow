import Foundation
import SwiftUI

/// Agent 4: Predictive Focus Analytics - Predicts focus likelihood and provides insights
/// Refactored from PredictiveAnalytics for Pomodoro Timer app
@MainActor
final class PredictiveFocusAnalytics: ObservableObject {
    let store: FocusStore
    
    init(store: FocusStore) {
        self.store = store
    }
    
    // MARK: - Focus Likelihood Prediction
    
    /// Predicts the likelihood of focusing today based on historical patterns
    func predictFocusLikelihoodToday() -> FocusLikelihood {
        let calendar = Calendar.current
        let today = Date()
        
        // Get historical data for today's day of week (only focus sessions)
        let weekday = calendar.component(.weekday, from: today)
        let historicalFocusSessions = store.sessions.filter { session in
            calendar.component(.weekday, from: session.date) == weekday && session.phaseType == .focus
        }
        
        // Calculate focus frequency for this day of week
        let totalWeeks = calculateTotalWeeks()
        guard totalWeeks > 0 else {
            return FocusLikelihood(probability: 0.5, confidence: .low, factors: ["No historical data"])
        }
        
        let sessionsOnThisDay = historicalFocusSessions.count
        let probability = min(1.0, Double(sessionsOnThisDay) / Double(totalWeeks))
        
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
            factors.append("You typically focus on \(DayOfWeek(rawValue: weekday)?.displayName ?? "this day")")
        }
        if store.sessionsThisWeek > 0 {
            factors.append("Already \(store.sessionsThisWeek) focus session(s) this week")
        }
        
        return FocusLikelihood(
            probability: adjustedProbability,
            confidence: confidence,
            factors: factors.isEmpty ? ["No patterns detected"] : factors
        )
    }
    
    /// Predicts optimal focus time based on historical patterns
    func predictOptimalFocusTime() -> OptimalTimePrediction? {
        let focusSessions = store.sessions.filter { $0.phaseType == .focus }
        guard !focusSessions.isEmpty else { return nil }
        
        let calendar = Calendar.current
        var hourCounts: [Int: Int] = [:]
        var hourCompletionRates: [Int: Double] = [:]
        
        for session in focusSessions {
            let hour = calendar.component(.hour, from: session.date)
            hourCounts[hour, default: 0] += 1
            let completionRate = session.completed ? 1.0 : 0.0
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
    
    /// Predicts weekly focus goal achievement likelihood
    func predictWeeklyGoalAchievement(goal: Int) -> GoalAchievementPrediction {
        let sessionsSoFar = store.sessionsThisWeek
        let daysRemaining = daysRemainingInWeek()
        let averageSessionsPerDay = calculateAverageSessionsPerDay()
        
        let predictedTotal = Double(sessionsSoFar) + (Double(daysRemaining) * averageSessionsPerDay)
        let probability = min(1.0, max(0.0, predictedTotal / Double(goal)))
        
        let confidence: Confidence
        if store.totalSessions >= 20 {
            confidence = .high
        } else if store.totalSessions >= 10 {
            confidence = .medium
        } else {
            confidence = .low
        }
        
        let needs = max(0, goal - sessionsSoFar)
        let recommendedDaily = needs > 0 && daysRemaining > 0 ? Double(needs) / Double(daysRemaining) : 0.0
        
        return GoalAchievementPrediction(
            goal: goal,
            current: sessionsSoFar,
            predicted: Int(predictedTotal),
            probability: probability,
            confidence: confidence,
            workoutsNeeded: needs,
            recommendedDaily: recommendedDaily
        )
    }
    
    // MARK: - Correlation Analysis
    
    /// Analyzes correlation between focus time and completion rate
    func analyzeTimeCompletionCorrelation() -> CorrelationAnalysis? {
        let focusSessions = store.sessions.filter { $0.phaseType == .focus }
        guard focusSessions.count >= 5 else { return nil }
        
        let calendar = Calendar.current
        var morningSessions: [FocusSession] = []
        var afternoonSessions: [FocusSession] = []
        var eveningSessions: [FocusSession] = []
        
        for session in focusSessions {
            let hour = calendar.component(.hour, from: session.date)
            switch hour {
            case 5..<12: morningSessions.append(session)
            case 12..<17: afternoonSessions.append(session)
            case 17..<22: eveningSessions.append(session)
            default: break
            }
        }
        
        func averageCompletionRate(for sessions: [FocusSession]) -> Double {
            guard !sessions.isEmpty else { return 0 }
            let completed = sessions.filter { $0.completed }.count
            return Double(completed) / Double(sessions.count)
        }
        
        let morningRate = averageCompletionRate(for: morningSessions)
        let afternoonRate = averageCompletionRate(for: afternoonSessions)
        let eveningRate = averageCompletionRate(for: eveningSessions)
        
        return CorrelationAnalysis(
            morningCompletionRate: morningRate,
            afternoonCompletionRate: afternoonRate,
            eveningCompletionRate: eveningRate,
            bestTime: [CorrelationTimeOfDay.morning: morningRate, .afternoon: afternoonRate, .evening: eveningRate]
                .max(by: { $0.value < $1.value })?.key ?? .morning
        )
    }
    
    // MARK: - Helper Methods
    
    private func calculateTotalWeeks() -> Int {
        let focusSessions = store.sessions.filter { $0.phaseType == .focus }
        guard !focusSessions.isEmpty else { return 0 }
        let calendar = Calendar.current
        let sortedSessions = focusSessions.sorted { $0.date < $1.date }
        let oldest = sortedSessions.first?.date ?? Date()
        let newest = sortedSessions.last?.date ?? Date()
        let components = calendar.dateComponents([.weekOfYear], from: oldest, to: newest)
        return max(1, (components.weekOfYear ?? 0) + 1)
    }
    
    private func calculateAverageSessionsPerDay() -> Double {
        let focusSessions = store.sessions.filter { $0.phaseType == .focus }
        guard !focusSessions.isEmpty else { return 0 }
        let calendar = Calendar.current
        let sortedSessions = focusSessions.sorted { $0.date < $1.date }
        let oldest = sortedSessions.first?.date ?? Date()
        let today = Date()
        let days = calendar.dateComponents([.day], from: oldest, to: today).day ?? 1
        return Double(focusSessions.count) / Double(max(1, days))
    }
    
    private func daysRemainingInWeek() -> Int {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        // Days remaining in week (Sunday = 1, Saturday = 7)
        return max(0, 7 - weekday)
    }
}

