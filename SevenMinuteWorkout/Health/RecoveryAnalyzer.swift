import Foundation
import HealthKit

/// Agent 13: Recovery Analyzer - Analyzes recovery needs and training load
/// Provides recovery time suggestions and tracks training load
@MainActor
class RecoveryAnalyzer: ObservableObject {
    static let shared = RecoveryAnalyzer()
    
    private let healthStore = HKHealthStore()
    private let healthKitManager = HealthKitManager.shared
    
    private init() {}
    
    // MARK: - Recovery Analysis
    
    /// Analyzes recovery needs based on recent workouts
    func analyzeRecoveryNeeds() async throws -> RecoveryAnalysis {
        guard healthKitManager.isHealthKitAvailable else {
            throw HealthKitManager.HealthKitError.notAvailable
        }
        
        // Get recent workouts (last 7 days)
        let workouts = try await fetchRecentWorkouts(days: 7)
        
        // Calculate training load
        let trainingLoad = calculateTrainingLoad(workouts: workouts)
        
        // Analyze recovery time needed
        let recoveryTime = calculateRecoveryTime(trainingLoad: trainingLoad, workouts: workouts)
        
        // Get fatigue indicators
        let fatigueIndicators = try await analyzeFatigueIndicators(workouts: workouts)
        
        return RecoveryAnalysis(
            trainingLoad: trainingLoad,
            recommendedRecoveryTime: recoveryTime,
            fatigueLevel: fatigueIndicators.fatigueLevel,
            readinessScore: calculateReadinessScore(trainingLoad: trainingLoad, fatigue: fatigueIndicators),
            recommendations: generateRecoveryRecommendations(
                trainingLoad: trainingLoad,
                recoveryTime: recoveryTime,
                fatigue: fatigueIndicators.fatigueLevel
            )
        )
    }
    
    /// Calculates training load based on workout intensity and frequency
    private func calculateTrainingLoad(workouts: [HKWorkout]) -> TrainingLoad {
        guard !workouts.isEmpty else {
            return TrainingLoad(score: 0, level: .low, description: "No recent workouts")
        }
        
        // Calculate factors:
        // 1. Workout frequency (more workouts = higher load)
        // 2. Workout intensity (heart rate zones)
        // 3. Total duration
        
        let workoutCount = workouts.count
        let totalDuration = workouts.reduce(0.0) { $0 + $1.duration }
        let averageDuration = totalDuration / Double(workoutCount)
        
        // Calculate intensity score (0-100)
        var intensityScore: Double = 0
        var intensityCount = 0
        
        for workout in workouts {
            if let hrType = HKQuantityType.quantityType(forIdentifier: .heartRate),
               let avgHR = workout.statistics(for: hrType)?.averageQuantity() {
                let bpm = avgHR.doubleValue(for: HKUnit(from: "count/min"))
                // Estimate intensity based on heart rate (assuming max HR of 200)
                // Moderate: 50-70%, Vigorous: 70-85%, Maximum: 85%+
                let intensity = min(bpm / 200.0, 1.0) * 100
                intensityScore += intensity
                intensityCount += 1
            }
        }
        
        if intensityCount > 0 {
            intensityScore /= Double(intensityCount)
        } else {
            // Default to moderate intensity if no HR data
            intensityScore = 60
        }
        
        // Calculate training load score (0-100)
        // Frequency weight: 40%
        // Intensity weight: 40%
        // Duration weight: 20%
        let frequencyScore = min(Double(workoutCount) / 7.0 * 100, 100) // 7 workouts = 100%
        let durationScore = min(averageDuration / 420.0 * 100, 100) // 7 minutes = baseline
        
        let loadScore = (frequencyScore * 0.4) + (intensityScore * 0.4) + (durationScore * 0.2)
        
        let level: TrainingLoadLevel
        if loadScore < 30 {
            level = .low
        } else if loadScore < 60 {
            level = .moderate
        } else if loadScore < 80 {
            level = .high
        } else {
            level = .veryHigh
        }
        
        return TrainingLoad(
            score: loadScore,
            level: level,
            description: generateTrainingLoadDescription(level: level, workouts: workoutCount)
        )
    }
    
    /// Calculates recommended recovery time in hours
    private func calculateRecoveryTime(trainingLoad: TrainingLoad, workouts: [HKWorkout]) -> TimeInterval {
        // Base recovery time: 24 hours for moderate workout
        let baseRecoveryHours: Double = 24
        
        // Adjust based on training load
        let multiplier: Double
        switch trainingLoad.level {
        case .low:
            multiplier = 0.5 // 12 hours
        case .moderate:
            multiplier = 1.0 // 24 hours
        case .high:
            multiplier = 1.5 // 36 hours
        case .veryHigh:
            multiplier = 2.0 // 48 hours
        }
        
        // Adjust based on consecutive workout days
        let consecutiveDays = calculateConsecutiveWorkoutDays(workouts: workouts)
        if consecutiveDays >= 5 {
            // Add extra recovery for extended periods
            let additionalHours = Double(consecutiveDays - 4) * 6 // 6 hours per extra day
            return (baseRecoveryHours * multiplier + additionalHours) * 3600 // Convert to seconds
        }
        
        return baseRecoveryHours * multiplier * 3600
    }
    
    /// Calculates consecutive workout days
    private func calculateConsecutiveWorkoutDays(workouts: [HKWorkout]) -> Int {
        guard !workouts.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let workoutDays = Set(workouts.map { calendar.startOfDay(for: $0.startDate) })
        let sortedDays = workoutDays.sorted(by: >)
        
        guard !sortedDays.isEmpty else { return 0 }
        
        var consecutiveCount = 1
        var currentDay = sortedDays[0]
        
        for day in sortedDays.dropFirst() {
            if let daysBetween = calendar.dateComponents([.day], from: day, to: currentDay).day,
               daysBetween == 1 {
                consecutiveCount += 1
                currentDay = day
            } else {
                break
            }
        }
        
        return consecutiveCount
    }
    
    /// Analyzes fatigue indicators from health data
    private func analyzeFatigueIndicators(workouts: [HKWorkout]) async throws -> FatigueIndicators {
        // Check resting heart rate trends
        let restingHR = try await fetchLatestRestingHeartRate()
        
        // Check workout heart rate trends (increasing HR = potential fatigue)
        var heartRateTrend: HeartRateTrend = .stable
        if workouts.count >= 3 {
            let recentHR = workouts.suffix(3).compactMap { workout -> Double? in
                guard let hrType = HKQuantityType.quantityType(forIdentifier: .heartRate),
                      let avgHR = workout.statistics(for: hrType)?.averageQuantity() else {
                    return nil
                }
                return avgHR.doubleValue(for: HKUnit(from: "count/min"))
            }
            
            if recentHR.count >= 3 {
                let firstHalf = recentHR.prefix(recentHR.count / 2).reduce(0, +) / Double(recentHR.count / 2)
                let secondHalf = recentHR.suffix(recentHR.count / 2).reduce(0, +) / Double(recentHR.count / 2)
                
                if secondHalf > firstHalf * 1.1 {
                    heartRateTrend = .increasing
                } else if secondHalf < firstHalf * 0.9 {
                    heartRateTrend = .decreasing
                }
            }
        }
        
        // Determine fatigue level
        let fatigueLevel: FatigueLevel
        if heartRateTrend == .increasing && restingHR != nil {
            fatigueLevel = .moderate
        } else if heartRateTrend == .increasing {
            fatigueLevel = .mild
        } else {
            fatigueLevel = .low
        }
        
        return FatigueIndicators(
            restingHeartRate: restingHR,
            heartRateTrend: heartRateTrend,
            fatigueLevel: fatigueLevel
        )
    }
    
    /// Fetches latest resting heart rate
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
    
    /// Fetches recent workouts
    private func fetchRecentWorkouts(days: Int) async throws -> [HKWorkout] {
        let workoutType = HKObjectType.workoutType()
        
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
    
    /// Calculates readiness score (0-100)
    private func calculateReadinessScore(trainingLoad: TrainingLoad, fatigue: FatigueIndicators) -> Double {
        // Base score: 100
        var score: Double = 100
        
        // Reduce score based on training load
        switch trainingLoad.level {
        case .low:
            score -= 0
        case .moderate:
            score -= 10
        case .high:
            score -= 25
        case .veryHigh:
            score -= 40
        }
        
        // Reduce score based on fatigue
        switch fatigue.fatigueLevel {
        case .low:
            score -= 0
        case .mild:
            score -= 15
        case .moderate:
            score -= 30
        case .high:
            score -= 50
        }
        
        return max(0, min(100, score))
    }
    
    /// Generates recovery recommendations
    private func generateRecoveryRecommendations(
        trainingLoad: TrainingLoad,
        recoveryTime: TimeInterval,
        fatigue: FatigueLevel
    ) -> [RecoveryRecommendation] {
        var recommendations: [RecoveryRecommendation] = []
        
        let recoveryHours = recoveryTime / 3600
        
        if recoveryHours >= 36 {
            recommendations.append(RecoveryRecommendation(
                type: .rest,
                priority: .high,
                title: "Extended Recovery Recommended",
                message: "Your recent training load suggests \(Int(recoveryHours)) hours of recovery before your next intense workout.",
                action: "Consider light activities like walking or stretching."
            ))
        } else if recoveryHours >= 24 {
            recommendations.append(RecoveryRecommendation(
                type: .rest,
                priority: .medium,
                title: "Rest Day Recommended",
                message: "Take a rest day to allow your body to recover fully.",
                action: "Focus on hydration and sleep for optimal recovery."
            ))
        }
        
        if fatigue == .moderate || fatigue == .high {
            recommendations.append(RecoveryRecommendation(
                type: .fatigue,
                priority: .high,
                title: "Signs of Fatigue Detected",
                message: "Your heart rate patterns suggest you may need more recovery.",
                action: "Consider reducing workout intensity or taking additional rest days."
            ))
        }
        
        if trainingLoad.level == .veryHigh {
            recommendations.append(RecoveryRecommendation(
                type: .overtraining,
                priority: .high,
                title: "High Training Load",
                message: "You've been training very intensely. Recovery is crucial to prevent overtraining.",
                action: "Consider a lighter week or active recovery activities."
            ))
        }
        
        return recommendations
    }
    
    /// Generates training load description
    private func generateTrainingLoadDescription(level: TrainingLoadLevel, workouts: Int) -> String {
        switch level {
        case .low:
            return "Low training load. \(workouts) workout\(workouts == 1 ? "" : "s") in the last week."
        case .moderate:
            return "Moderate training load. \(workouts) workout\(workouts == 1 ? "" : "s") in the last week."
        case .high:
            return "High training load. \(workouts) workout\(workouts == 1 ? "" : "s") in the last week."
        case .veryHigh:
            return "Very high training load. \(workouts) workout\(workouts == 1 ? "" : "s") in the last week."
        }
    }
}

// MARK: - Supporting Types

/// Recovery analysis result
struct RecoveryAnalysis {
    let trainingLoad: TrainingLoad
    let recommendedRecoveryTime: TimeInterval
    let fatigueLevel: FatigueLevel
    let readinessScore: Double
    let recommendations: [RecoveryRecommendation]
}

/// Training load information
struct TrainingLoad {
    let score: Double // 0-100
    let level: TrainingLoadLevel
    let description: String
}

enum TrainingLoadLevel {
    case low
    case moderate
    case high
    case veryHigh
}

/// Fatigue indicators
struct FatigueIndicators {
    let restingHeartRate: Double?
    let heartRateTrend: HeartRateTrend
    let fatigueLevel: FatigueLevel
}

enum HeartRateTrend {
    case decreasing
    case stable
    case increasing
}

enum FatigueLevel {
    case low
    case mild
    case moderate
    case high
}

/// Recovery recommendation
struct RecoveryRecommendation: Identifiable {
    let id = UUID()
    let type: RecommendationType
    let priority: Priority
    let title: String
    let message: String
    let action: String
    
    enum RecommendationType {
        case rest
        case fatigue
        case overtraining
        case hydration
        case sleep
    }
    
    enum Priority {
        case low
        case medium
        case high
    }
}

