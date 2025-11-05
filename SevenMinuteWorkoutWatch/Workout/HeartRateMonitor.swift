import Foundation
import HealthKit
import SwiftUI
import WatchKit

/// Agent 15: Heart Rate Monitor - Real-time heart rate monitoring during workouts
@MainActor
class HeartRateMonitor: ObservableObject {
    static let shared = HeartRateMonitor()
    
    @Published private(set) var currentHeartRate: Double? = nil
    @Published private(set) var averageHeartRate: Double? = nil
    @Published private(set) var maxHeartRate: Double? = nil
    @Published private(set) var heartRateZone: HeartRateZone = .unknown
    @Published private(set) var isMonitoring: Bool = false
    
    private let healthStore = HKHealthStore()
    private var heartRateQuery: HKAnchoredObjectQuery?
    private var heartRateSamples: [HKQuantitySample] = []
    private var workoutSession: HKWorkoutSession?
    private var workoutConfiguration: HKWorkoutConfiguration?
    
    // Heart rate zones (based on age or default)
    private var maxHeartRate: Double {
        // Default max HR: 220 - age (or use 190 as default)
        // For now, use age-based calculation if available, otherwise default zones
        return 190.0 // Default max HR
    }
    
    private var restingHeartRate: Double = 60.0 // Default resting HR
    
    enum HeartRateZone: String, CaseIterable {
        case unknown = "unknown"
        case resting = "resting"      // 50-60% of max HR
        case warmUp = "warmup"        // 60-70% of max HR
        case fatBurn = "fatburn"     // 70-80% of max HR
        case aerobic = "aerobic"     // 80-90% of max HR
        case anaerobic = "anaerobic" // 90-100% of max HR
        
        var displayName: String {
            switch self {
            case .unknown: return "Unknown"
            case .resting: return "Resting"
            case .warmUp: return "Warm Up"
            case .fatBurn: return "Fat Burn"
            case .aerobic: return "Aerobic"
            case .anaerobic: return "Anaerobic"
            }
        }
        
        var color: Color {
            switch self {
            case .unknown: return .gray
            case .resting: return .blue
            case .warmUp: return .green
            case .fatBurn: return .yellow
            case .aerobic: return .orange
            case .anaerobic: return .red
            }
        }
    }
    
    private init() {}
    
    // MARK: - Authorization
    
    /// Request HealthKit authorization for heart rate
    func requestAuthorization() async throws -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else {
            return false
        }
        
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            return false
        }
        
        let typesToRead: Set<HKObjectType> = [heartRateType]
        let typesToWrite: Set<HKSampleType> = [heartRateType]
        
        try await healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead)
        
        let status = healthStore.authorizationStatus(for: heartRateType)
        return status == .sharingAuthorized
    }
    
    // MARK: - Monitoring
    
    /// Start monitoring heart rate during workout
    func startMonitoring() async throws {
        guard !isMonitoring else { return }
        
        // Request authorization if needed
        let authorized = try await requestAuthorization()
        guard authorized else {
            throw HeartRateError.notAuthorized
        }
        
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            throw HeartRateError.notAvailable
        }
        
        // Reset state
        heartRateSamples.removeAll()
        currentHeartRate = nil
        averageHeartRate = nil
        maxHeartRate = nil
        heartRateZone = .unknown
        
        // Create workout configuration for better HR accuracy
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .highIntensityIntervalTraining
        configuration.locationType = .indoor
        
        // Start workout session for better heart rate readings
        do {
            workoutConfiguration = configuration
            let session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            workoutSession = session
            try await session.startActivity(with: Date())
        } catch {
            // If workout session fails, continue without it
            print("Failed to start workout session: \(error.localizedDescription)")
        }
        
        // Create heart rate query
        let query = HKAnchoredObjectQuery(
            type: heartRateType,
            predicate: nil,
            anchor: nil,
            limit: HKObjectQueryNoLimit
        ) { [weak self] _, samples, deletedObjects, anchor, error in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                
                if let error = error {
                    print("Heart rate query error: \(error.localizedDescription)")
                    return
                }
                
                if let samples = samples as? [HKQuantitySample] {
                    self.processHeartRateSamples(samples)
                }
            }
        }
        
        // Update handler for continuous updates
        query.updateHandler = { [weak self] _, samples, deletedObjects, anchor, error in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                
                if let error = error {
                    print("Heart rate query update error: \(error.localizedDescription)")
                    return
                }
                
                if let samples = samples as? [HKQuantitySample] {
                    self.processHeartRateSamples(samples)
                }
            }
        }
        
        heartRateQuery = query
        healthStore.execute(query)
        isMonitoring = true
    }
    
    /// Stop monitoring heart rate
    func stopMonitoring() async {
        guard isMonitoring else { return }
        
        // End workout session
        if let session = workoutSession {
            await session.end()
            workoutSession = nil
            workoutConfiguration = nil
        }
        
        // Stop heart rate query
        if let query = heartRateQuery {
            healthStore.stop(query)
            heartRateQuery = nil
        }
        
        isMonitoring = false
    }
    
    // MARK: - Private Methods
    
    private func processHeartRateSamples(_ samples: [HKQuantitySample]) {
        guard !samples.isEmpty else { return }
        
        // Get the most recent heart rate
        let sortedSamples = samples.sorted { $0.endDate > $1.endDate }
        if let latestSample = sortedSamples.first {
            let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
            let bpm = latestSample.quantity.doubleValue(for: heartRateUnit)
            currentHeartRate = bpm
            updateHeartRateZone(bpm: bpm)
        }
        
        // Add to samples array
        heartRateSamples.append(contentsOf: samples)
        
        // Calculate average and max
        let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
        let allRates = heartRateSamples.map { $0.quantity.doubleValue(for: heartRateUnit) }
        
        if !allRates.isEmpty {
            averageHeartRate = allRates.reduce(0, +) / Double(allRates.count)
            maxHeartRate = allRates.max()
        }
    }
    
    private func updateHeartRateZone(bpm: Double) {
        let percentage = (bpm / maxHeartRate) * 100
        
        if percentage < 60 {
            heartRateZone = .resting
        } else if percentage < 70 {
            heartRateZone = .warmUp
        } else if percentage < 80 {
            heartRateZone = .fatBurn
        } else if percentage < 90 {
            heartRateZone = .aerobic
        } else {
            heartRateZone = .anaerobic
        }
    }
    
    // MARK: - Heart Rate Zones
    
    /// Get heart rate zone for a given BPM
    func getHeartRateZone(bpm: Double) -> HeartRateZone {
        let percentage = (bpm / maxHeartRate) * 100
        
        if percentage < 60 {
            return .resting
        } else if percentage < 70 {
            return .warmUp
        } else if percentage < 80 {
            return .fatBurn
        } else if percentage < 90 {
            return .aerobic
        } else {
            return .anaerobic
        }
    }
    
    /// Get all heart rate samples for HealthKit sync
    func getHeartRateSamples() -> [HKQuantitySample] {
        return heartRateSamples
    }
    
    // MARK: - Errors
    
    enum HeartRateError: LocalizedError {
        case notAvailable
        case notAuthorized
        case monitoringFailed(Error)
        
        var errorDescription: String? {
            switch self {
            case .notAvailable:
                return "Heart rate monitoring is not available on this device."
            case .notAuthorized:
                return "HealthKit permission has not been granted for heart rate."
            case .monitoringFailed(let error):
                return "Failed to monitor heart rate: \(error.localizedDescription)"
            }
        }
    }
}

// MARK: - HKWorkoutSession Extension

extension HKWorkoutSession {
    func startActivity(with date: Date) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            startActivity(with: date) { success, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: NSError(domain: "HeartRateMonitor", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to start workout session"]))
                }
            }
        }
    }
    
    func end() async {
        await withCheckedContinuation { continuation in
            end()
            // Wait a bit for the session to end
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                continuation.resume()
            }
        }
    }
}

