import Foundation
import HealthKit

/// Agent 13: Workout Intensity Analyzer - Analyzes workout intensity and heart rate zones
/// Provides real-time intensity analysis during workouts
@MainActor
class WorkoutIntensityAnalyzer {
    static let shared = WorkoutIntensityAnalyzer()
    
    private let healthStore = HKHealthStore()
    private let healthKitManager = HealthKitManager.shared
    
    // MARK: - Heart Rate Zones
    
    /// Calculates heart rate zones based on age and resting heart rate
    func calculateHeartRateZones(age: Int? = nil, restingHeartRate: Double? = nil) -> HeartRateZones {
        // Default values if not provided
        let userAge = age ?? 30
        let restingHR = restingHeartRate ?? 60
        
        // Calculate maximum heart rate (220 - age)
        let maxHeartRate = Double(220 - userAge)
        
        // Calculate heart rate reserve (HRR)
        let heartRateReserve = maxHeartRate - restingHR
        
        // Define zones based on HRR method
        let zone1Max = restingHR + (heartRateReserve * 0.5)  // 50% of HRR
        let zone2Max = restingHR + (heartRateReserve * 0.6)  // 60% of HRR
        let zone3Max = restingHR + (heartRateReserve * 0.7)  // 70% of HRR
        let zone4Max = restingHR + (heartRateReserve * 0.85) // 85% of HRR
        // Zone 5 is above 85% of HRR
        
        return HeartRateZones(
            zone1: HeartRateZone(range: restingHR...zone1Max, name: "Recovery", intensity: .veryLight),
            zone2: HeartRateZone(range: zone1Max...zone2Max, name: "Aerobic", intensity: .light),
            zone3: HeartRateZone(range: zone2Max...zone3Max, name: "Aerobic", intensity: .moderate),
            zone4: HeartRateZone(range: zone3Max...zone4Max, name: "Anaerobic", intensity: .hard),
            zone5: HeartRateZone(range: zone4Max...maxHeartRate, name: "Maximum", intensity: .maximum),
            maxHeartRate: maxHeartRate,
            restingHeartRate: restingHR
        )
    }
    
    /// Determines the heart rate zone for a given heart rate
    func getHeartRateZone(for heartRate: Double, zones: HeartRateZones) -> HeartRateZone {
        if zones.zone1.range.contains(heartRate) {
            return zones.zone1
        } else if zones.zone2.range.contains(heartRate) {
            return zones.zone2
        } else if zones.zone3.range.contains(heartRate) {
            return zones.zone3
        } else if zones.zone4.range.contains(heartRate) {
            return zones.zone4
        } else if zones.zone5.range.contains(heartRate) {
            return zones.zone5
        }
        
        // Default to zone 3 if outside all zones
        return zones.zone3
    }
    
    /// Calculates workout intensity based on heart rate data
    func calculateWorkoutIntensity(workout: HKWorkout) -> WorkoutIntensity {
        guard let hrType = HKQuantityType.quantityType(forIdentifier: .heartRate),
              let avgHR = workout.statistics(for: hrType)?.averageQuantity() else {
            // No heart rate data, estimate based on workout type and duration
            return estimateIntensityFromWorkout(workout: workout)
        }
        
        let bpm = avgHR.doubleValue(for: HKUnit(from: "count/min"))
        
        // Get heart rate zones
        let zones = calculateHeartRateZones()
        let currentZone = getHeartRateZone(for: bpm, zones: zones)
        
        // Calculate time in each zone (if we had detailed HR samples)
        // For now, estimate based on average HR
        
        // Calculate intensity percentage (0-100)
        let intensityPercentage: Double
        if bpm <= zones.zone1.range.upperBound {
            intensityPercentage = 30 + ((bpm - zones.restingHeartRate) / (zones.zone1.range.upperBound - zones.restingHeartRate)) * 20
        } else if bpm <= zones.zone2.range.upperBound {
            intensityPercentage = 50 + ((bpm - zones.zone1.range.upperBound) / (zones.zone2.range.upperBound - zones.zone1.range.upperBound)) * 20
        } else if bpm <= zones.zone3.range.upperBound {
            intensityPercentage = 70 + ((bpm - zones.zone2.range.upperBound) / (zones.zone3.range.upperBound - zones.zone2.range.upperBound)) * 15
        } else if bpm <= zones.zone4.range.upperBound {
            intensityPercentage = 85 + ((bpm - zones.zone3.range.upperBound) / (zones.zone4.range.upperBound - zones.zone3.range.upperBound)) * 10
        } else {
            intensityPercentage = 95 + min((bpm - zones.zone4.range.upperBound) / (zones.maxHeartRate - zones.zone4.range.upperBound) * 5, 5)
        }
        
        return WorkoutIntensity(
            averageHeartRate: bpm,
            currentZone: currentZone,
            intensityPercentage: intensityPercentage,
            description: generateIntensityDescription(intensityPercentage: intensityPercentage, zone: currentZone)
        )
    }
    
    /// Estimates intensity when heart rate data is not available
    private func estimateIntensityFromWorkout(workout: HKWorkout) -> WorkoutIntensity {
        // For 7-minute HIIT workouts, estimate high intensity
        let estimatedHR = 150.0 // Estimated average HR for HIIT
        let zones = calculateHeartRateZones()
        let zone = getHeartRateZone(for: estimatedHR, zones: zones)
        
        return WorkoutIntensity(
            averageHeartRate: estimatedHR,
            currentZone: zone,
            intensityPercentage: 75.0, // Estimated for HIIT
            description: "High intensity interval training"
        )
    }
    
    /// Generates intensity description
    private func generateIntensityDescription(intensityPercentage: Double, zone: HeartRateZone) -> String {
        if intensityPercentage >= 85 {
            return "Very High Intensity"
        } else if intensityPercentage >= 70 {
            return "High Intensity"
        } else if intensityPercentage >= 50 {
            return "Moderate Intensity"
        } else {
            return "Light Intensity"
        }
    }
    
    /// Analyzes time spent in each heart rate zone during a workout
    func analyzeTimeInZones(workout: HKWorkout) async throws -> ZoneAnalysis {
        guard let hrType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            throw HealthKitManager.HealthKitError.notAvailable
        }
        
        // Query heart rate samples for this workout
        let predicate = HKQuery.predicateForSamples(
            withStart: workout.startDate,
            end: workout.endDate,
            options: .strictStartDate
        )
        
        let samples: [HKQuantitySample] = try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: hrType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let hrSamples = samples?.compactMap { $0 as? HKQuantitySample } ?? []
                continuation.resume(returning: hrSamples)
            }
            
            healthStore.execute(query)
        }
        
        guard !samples.isEmpty else {
            // No HR samples, return estimated analysis
            return ZoneAnalysis(
                zone1Time: 0,
                zone2Time: 0,
                zone3Time: 0,
                zone4Time: 0,
                zone5Time: 0,
                totalTime: workout.duration
            )
        }
        
        // Calculate time in each zone
        let zones = calculateHeartRateZones()
        var zone1Time: TimeInterval = 0
        var zone2Time: TimeInterval = 0
        var zone3Time: TimeInterval = 0
        var zone4Time: TimeInterval = 0
        var zone5Time: TimeInterval = 0
        
        for i in 0..<samples.count {
            let sample = samples[i]
            let bpm = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            let zone = getHeartRateZone(for: bpm, zones: zones)
            
            // Calculate duration for this sample
            let duration: TimeInterval
            if i < samples.count - 1 {
                duration = samples[i + 1].startDate.timeIntervalSince(sample.startDate)
            } else {
                duration = workout.endDate.timeIntervalSince(sample.startDate)
            }
            
            // Add to appropriate zone
            switch zone.intensity {
            case .veryLight:
                zone1Time += duration
            case .light:
                zone2Time += duration
            case .moderate:
                zone3Time += duration
            case .hard:
                zone4Time += duration
            case .maximum:
                zone5Time += duration
            }
        }
        
        return ZoneAnalysis(
            zone1Time: zone1Time,
            zone2Time: zone2Time,
            zone3Time: zone3Time,
            zone4Time: zone4Time,
            zone5Time: zone5Time,
            totalTime: workout.duration
        )
    }
}

// MARK: - Supporting Types

/// Heart rate zones configuration
struct HeartRateZones {
    let zone1: HeartRateZone
    let zone2: HeartRateZone
    let zone3: HeartRateZone
    let zone4: HeartRateZone
    let zone5: HeartRateZone
    let maxHeartRate: Double
    let restingHeartRate: Double
}

/// Heart rate zone
struct HeartRateZone {
    let range: ClosedRange<Double>
    let name: String
    let intensity: IntensityLevel
    
    var color: Color {
        switch intensity {
        case .veryLight:
            return .blue
        case .light:
            return .green
        case .moderate:
            return .yellow
        case .hard:
            return .orange
        case .maximum:
            return .red
        }
    }
}

/// Intensity level
enum IntensityLevel: String {
    case veryLight = "Very Light"
    case light = "Light"
    case moderate = "Moderate"
    case hard = "Hard"
    case maximum = "Maximum"
}

/// Workout intensity analysis
struct WorkoutIntensity {
    let averageHeartRate: Double
    let currentZone: HeartRateZone
    let intensityPercentage: Double // 0-100
    let description: String
}

/// Zone analysis showing time spent in each heart rate zone
struct ZoneAnalysis {
    let zone1Time: TimeInterval
    let zone2Time: TimeInterval
    let zone3Time: TimeInterval
    let zone4Time: TimeInterval
    let zone5Time: TimeInterval
    let totalTime: TimeInterval
    
    var zone1Percentage: Double {
        totalTime > 0 ? (zone1Time / totalTime) * 100 : 0
    }
    
    var zone2Percentage: Double {
        totalTime > 0 ? (zone2Time / totalTime) * 100 : 0
    }
    
    var zone3Percentage: Double {
        totalTime > 0 ? (zone3Time / totalTime) * 100 : 0
    }
    
    var zone4Percentage: Double {
        totalTime > 0 ? (zone4Time / totalTime) * 100 : 0
    }
    
    var zone5Percentage: Double {
        totalTime > 0 ? (zone5Time / totalTime) * 100 : 0
    }
    
    var primaryZone: IntensityLevel {
        let times = [
            (zone1Time, IntensityLevel.veryLight),
            (zone2Time, IntensityLevel.light),
            (zone3Time, IntensityLevel.moderate),
            (zone4Time, IntensityLevel.hard),
            (zone5Time, IntensityLevel.maximum)
        ]
        
        return times.max(by: { $0.0 < $1.0 })?.1 ?? .moderate
    }
}

// Import SwiftUI for Color
import SwiftUI

