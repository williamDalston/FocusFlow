import Foundation
import HealthKit
import SwiftUI

/// Agent 13: Health Insights Manager - Analyzes workout impact on health metrics
/// Provides personalized health recommendations and trend analysis
@MainActor
class HealthInsightsManager: ObservableObject {
    static let shared = HealthInsightsManager()
    
    private let healthStore = HKHealthStore()
    private let healthKitManager = HealthKitManager.shared
    
    // MARK: - Published Properties
    
    @Published var latestInsights: HealthInsight?
    @Published var healthTrends: [HealthTrend] = []
    @Published var personalizedRecommendations: [HealthRecommendation] = []
    
    private init() {
        Task {
            await loadLatestInsights()
        }
    }
    
    // MARK: - Health Insights
    
    /// Analyzes workout impact on health metrics
    func analyzeWorkoutImpact() async throws -> HealthInsight {
        guard healthKitManager.isHealthKitAvailable else {
            throw HealthKitError.notAvailable
        }
        
        // Get recent workouts
        let workouts = try await fetchRecentWorkouts(days: 30)
        
        // Get health metrics
        let restingHeartRate = try await fetchLatestRestingHeartRate()
        let averageHeartRate = try await calculateAverageWorkoutHeartRate(workouts: workouts)
        let activeCalories = try await calculateTotalActiveCalories(workouts: workouts)
        
        // Calculate correlations
        let consistencyScore = calculateConsistencyScore(workouts: workouts)
        let improvementTrend = calculateImprovementTrend(workouts: workouts)
        
        // Generate insights
        let insight = HealthInsight(
            date: Date(),
            workoutsCount: workouts.count,
            averageHeartRate: averageHeartRate,
            restingHeartRate: restingHeartRate,
            totalCaloriesBurned: activeCalories,
            consistencyScore: consistencyScore,
            improvementTrend: improvementTrend,
            recommendations: generateRecommendations(
                workouts: workouts,
                consistency: consistencyScore,
                improvement: improvementTrend
            )
        )
        
        latestInsights = insight
        return insight
    }
    
    /// Loads the latest health insights
    private func loadLatestInsights() async {
        do {
            _ = try await analyzeWorkoutImpact()
        } catch {
            print("Failed to load health insights: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Health Data Fetching
    
    /// Fetches recent workouts from HealthKit
    private func fetchRecentWorkouts(days: Int) async throws -> [HKWorkout] {
        guard let workoutType = HKObjectType.workoutType() else {
            return []
        }
        
        let status = healthStore.authorizationStatus(for: workoutType)
        guard status == .sharingAuthorized else {
            return []
        }
        
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: endDate) ?? endDate
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: workoutType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let workouts = samples?.compactMap { $0 as? HKWorkout } ?? []
                continuation.resume(returning: workouts)
            }
            
            healthStore.execute(query)
        }
    }
    
    /// Fetches the latest resting heart rate
    private func fetchLatestRestingHeartRate() async throws -> Double? {
        guard let restingHeartRateType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) else {
            return nil
        }
        
        let status = healthStore.authorizationStatus(for: restingHeartRateType)
        guard status == .sharingAuthorized else {
            return nil
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: restingHeartRateType,
                predicate: nil,
                limit: 1,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let sample = samples?.first as? HKQuantitySample else {
                    continuation.resume(returning: nil)
                    return
                }
                
                let bpm = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                continuation.resume(returning: bpm)
            }
            
            healthStore.execute(query)
        }
    }
    
    /// Calculates average heart rate during workouts
    private func calculateAverageWorkoutHeartRate(workouts: [HKWorkout]) async throws -> Double? {
        guard !workouts.isEmpty else { return nil }
        
        var totalHeartRate: Double = 0
        var count: Int = 0
        
        for workout in workouts {
            if let avgHeartRate = workout.statistics(for: HKQuantityType.quantityType(forIdentifier: .heartRate)!)?.averageQuantity() {
                let bpm = avgHeartRate.doubleValue(for: HKUnit(from: "count/min"))
                totalHeartRate += bpm
                count += 1
            }
        }
        
        guard count > 0 else { return nil }
        return totalHeartRate / Double(count)
    }
    
    /// Calculates total active calories from workouts
    private func calculateTotalActiveCalories(workouts: [HKWorkout]) async throws -> Double {
        guard !workouts.isEmpty else { return 0 }
        
        var totalCalories: Double = 0
        
        for workout in workouts {
            if let energyBurned = workout.totalEnergyBurned {
                totalCalories += energyBurned.doubleValue(for: HKUnit.kilocalorie())
            }
        }
        
        return totalCalories
    }
    
    // MARK: - Analysis
    
    /// Calculates consistency score (0.0 to 1.0)
    private func calculateConsistencyScore(workouts: [HKWorkout]) -> Double {
        guard !workouts.isEmpty else { return 0 }
        
        // Calculate workout frequency
        let calendar = Calendar.current
        let days = Set(workouts.map { calendar.startOfDay(for: $0.startDate) })
        let uniqueDays = days.count
        
        // Ideal: 7 workouts per week = 1.0
        // Calculate based on days with workouts vs total days
        let daysWithWorkouts = uniqueDays
        let totalDays = 30 // Last 30 days
        let consistency = min(Double(daysWithWorkouts) / Double(totalDays) * 7.0, 1.0) // Normalize to weekly
        
        return consistency
    }
    
    /// Calculates improvement trend
    private func calculateImprovementTrend(workouts: [HKWorkout]) -> ImprovementTrend {
        guard workouts.count >= 7 else { return .insufficientData }
        
        // Split workouts into two halves
        let sortedWorkouts = workouts.sorted { $0.startDate < $1.startDate }
        let midpoint = sortedWorkouts.count / 2
        let firstHalf = Array(sortedWorkouts[..<midpoint])
        let secondHalf = Array(sortedWorkouts[midpoint...])
        
        // Calculate average heart rate for each half
        var firstHalfHR: [Double] = []
        var secondHalfHR: [Double] = []
        
        for workout in firstHalf {
            if let hr = workout.statistics(for: HKQuantityType.quantityType(forIdentifier: .heartRate)!)?.averageQuantity() {
                firstHalfHR.append(hr.doubleValue(for: HKUnit(from: "count/min")))
            }
        }
        
        for workout in secondHalf {
            if let hr = workout.statistics(for: HKQuantityType.quantityType(forIdentifier: .heartRate)!)?.averageQuantity() {
                secondHalfHR.append(hr.doubleValue(for: HKUnit(from: "count/min")))
            }
        }
        
        guard !firstHalfHR.isEmpty, !secondHalfHR.isEmpty else {
            return .insufficientData
        }
        
        let firstAvg = firstHalfHR.reduce(0, +) / Double(firstHalfHR.count)
        let secondAvg = secondHalfHR.reduce(0, +) / Double(secondHalfHR.count)
        
        // Lower heart rate = better fitness
        if secondAvg < firstAvg * 0.95 {
            return .improving
        } else if secondAvg > firstAvg * 1.05 {
            return .declining
        } else {
            return .stable
        }
    }
    
    /// Generates personalized health recommendations
    private func generateRecommendations(
        workouts: [HKWorkout],
        consistency: Double,
        improvement: ImprovementTrend
    ) -> [HealthRecommendation] {
        var recommendations: [HealthRecommendation] = []
        
        // Consistency recommendations
        if consistency < 0.5 {
            recommendations.append(HealthRecommendation(
                type: .consistency,
                priority: .high,
                title: "Increase Workout Frequency",
                message: "Aim for at least 4-5 workouts per week to see better results.",
                action: "Try scheduling specific times for your workouts."
            ))
        } else if consistency >= 0.8 {
            recommendations.append(HealthRecommendation(
                type: .consistency,
                priority: .low,
                title: "Great Consistency!",
                message: "You're maintaining excellent workout habits. Keep it up!",
                action: nil
            ))
        }
        
        // Improvement recommendations
        switch improvement {
        case .improving:
            recommendations.append(HealthRecommendation(
                type: .improvement,
                priority: .low,
                title: "Fitness Improving",
                message: "Your heart rate patterns show you're getting fitter!",
                action: nil
            ))
        case .declining:
            recommendations.append(HealthRecommendation(
                type: .improvement,
                priority: .medium,
                title: "Consider Recovery",
                message: "Your recent workouts show higher heart rates. Consider adding rest days.",
                action: "Listen to your body and take breaks when needed."
            ))
        case .stable, .insufficientData:
            break
        }
        
        // Recovery recommendations
        if workouts.count >= 5 {
            let recentWorkouts = workouts.sorted { $0.startDate > $1.startDate }.prefix(5)
            let daysWithWorkouts = Set(recentWorkouts.map { Calendar.current.startOfDay(for: $0.startDate) }).count
            
            if daysWithWorkouts >= 5 {
                recommendations.append(HealthRecommendation(
                    type: .recovery,
                    priority: .medium,
                    title: "Rest Day Recommended",
                    message: "You've been working out consistently. Consider a rest day for recovery.",
                    action: "Rest is important for muscle recovery and preventing injury."
                ))
            }
        }
        
        return recommendations
    }
    
    // MARK: - Health Trends
    
    /// Fetches health trends over time
    func fetchHealthTrends(days: Int = 30) async throws {
        let workouts = try await fetchRecentWorkouts(days: days)
        
        var trends: [HealthTrend] = []
        
        // Group workouts by week
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: workouts) { workout in
            calendar.dateInterval(of: .weekOfYear, for: workout.startDate)?.start ?? workout.startDate
        }
        
        for (weekStart, weekWorkouts) in grouped.sorted(by: { $0.key < $1.key }) {
            let calories = weekWorkouts.compactMap { $0.totalEnergyBurned?.doubleValue(for: HKUnit.kilocalorie()) }.reduce(0, +)
            let duration = weekWorkouts.reduce(0.0) { $0 + $1.duration }
            
            trends.append(HealthTrend(
                date: weekStart,
                workoutsCount: weekWorkouts.count,
                totalCalories: calories,
                totalDuration: duration,
                averageHeartRate: nil // Would need to calculate from heart rate samples
            ))
        }
        
        healthTrends = trends
    }
}

// MARK: - Supporting Types

/// Health insight containing analyzed data and recommendations
struct HealthInsight {
    let date: Date
    let workoutsCount: Int
    let averageHeartRate: Double?
    let restingHeartRate: Double?
    let totalCaloriesBurned: Double
    let consistencyScore: Double
    let improvementTrend: ImprovementTrend
    let recommendations: [HealthRecommendation]
}

/// Improvement trend indicator
enum ImprovementTrend: String {
    case improving = "Improving"
    case stable = "Stable"
    case declining = "Declining"
    case insufficientData = "Insufficient Data"
}

/// Health recommendation for the user
struct HealthRecommendation: Identifiable {
    let id = UUID()
    let type: RecommendationType
    let priority: Priority
    let title: String
    let message: String
    let action: String?
    
    enum RecommendationType {
        case consistency
        case improvement
        case recovery
        case nutrition
        case sleep
    }
    
    enum Priority {
        case low
        case medium
        case high
    }
}

/// Health trend data point
struct HealthTrend: Identifiable {
    let id = UUID()
    let date: Date
    let workoutsCount: Int
    let totalCalories: Double
    let totalDuration: TimeInterval
    let averageHeartRate: Double?
}

