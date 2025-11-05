import Foundation
import HealthKit

/// Agent 5: HealthKit Manager - Core HealthKit operations for workout tracking
@MainActor
class HealthKitManager {
    static let shared = HealthKitManager()
    
    private let healthStore = HKHealthStore()
    
    // MARK: - Agent 13: Real-time Heart Rate Monitoring
    
    /// Current active workout session for real-time monitoring
    private var activeWorkoutSession: HKWorkoutSession?
    private var heartRateQuery: HKAnchoredObjectQuery?
    private var heartRateUpdateHandler: ((Double) -> Void)?
    private var collectedHeartRateSamples: [HKQuantitySample] = []
    
    // MARK: - Types to read
    private let readTypes: Set<HKObjectType> = {
        var types: Set<HKObjectType> = []
        
        // Body measurements
        if let weight = HKObjectType.quantityType(forIdentifier: .bodyMass) {
            types.insert(weight)
        }
        
        // Heart rate
        if let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate) {
            types.insert(heartRate)
        }
        
        // Resting heart rate
        if let restingHeartRate = HKObjectType.quantityType(forIdentifier: .restingHeartRate) {
            types.insert(restingHeartRate)
        }
        
        // Activity level
        if let activityLevel = HKObjectType.categoryType(forIdentifier: .appleExerciseTime) {
            types.insert(activityLevel)
        }
        
        return types
    }()
    
    // Types to write
    private let writeTypes: Set<HKSampleType> = {
        var types: Set<HKSampleType> = []
        
        // Workout sessions
        if let workout = HKObjectType.workoutType() {
            types.insert(workout)
        }
        
        // Active energy (calories)
        if let activeEnergy = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) {
            types.insert(activeEnergy)
        }
        
        // Exercise minutes
        if let exerciseTime = HKObjectType.quantityType(forIdentifier: .appleExerciseTime) {
            types.insert(exerciseTime)
        }
        
        // Heart rate (if available during workout)
        if let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate) {
            types.insert(heartRate)
        }
        
        return types
    }()
    
    private init() {}
    
    // MARK: - Authorization
    
    /// Check if HealthKit is available on this device
    var isHealthKitAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }
    
    /// Request HealthKit authorization
    func requestAuthorization() async throws -> Bool {
        guard isHealthKitAvailable else {
            throw HealthKitError.notAvailable
        }
        
        guard !readTypes.isEmpty || !writeTypes.isEmpty else {
            throw HealthKitError.noTypesConfigured
        }
        
        do {
            try await healthStore.requestAuthorization(toShare: writeTypes, read: readTypes)
            
            // Check if we actually got write permission for workouts
            let workoutStatus = healthStore.authorizationStatus(for: HKObjectType.workoutType())
            return workoutStatus == .sharingAuthorized
        } catch {
            throw HealthKitError.authorizationFailed(error)
        }
    }
    
    /// Check authorization status for workout type
    var workoutAuthorizationStatus: HKAuthorizationStatus {
        healthStore.authorizationStatus(for: HKObjectType.workoutType())
    }
    
    /// Check if we have write permission for workouts
    var canWriteWorkouts: Bool {
        workoutAuthorizationStatus == .sharingAuthorized
    }
    
    // MARK: - Writing Workouts
    
    /// Save a workout session to HealthKit
    func saveWorkout(
        startDate: Date,
        endDate: Date,
        duration: TimeInterval,
        exercisesCompleted: Int,
        totalEnergyBurned: Double? = nil,
        heartRateSamples: [HKQuantitySample]? = nil
    ) async throws {
        guard isHealthKitAvailable else {
            throw HealthKitError.notAvailable
        }
        
        guard canWriteWorkouts else {
            throw HealthKitError.notAuthorized
        }
        
        // Create workout metadata
        var metadata: [String: Any] = [
            "exercisesCompleted": exercisesCompleted,
            "workoutType": "Ritual7",
            "appName": "Ritual7"
        ]
        
        // Create the workout
        let workout = HKWorkout(
            activityType: .highIntensityIntervalTraining,
            start: startDate,
            end: endDate,
            duration: duration,
            totalEnergyBurned: totalEnergyBurned.map { HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: $0) },
            totalDistance: nil,
            metadata: metadata
        )
        
        // Save the workout
        do {
            try await healthStore.save(workout)
            
            // Save associated samples (energy, heart rate, exercise time)
            var samplesToSave: [HKSample] = []
            
            // Active energy burned
            if let energyBurned = totalEnergyBurned {
                let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
                let energyQuantity = HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: energyBurned)
                let energySample = HKQuantitySample(
                    type: energyType,
                    quantity: energyQuantity,
                    start: startDate,
                    end: endDate
                )
                samplesToSave.append(energySample)
            }
            
            // Exercise minutes
            let exerciseTimeType = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!
            let exerciseMinutes = duration / 60.0
            let exerciseQuantity = HKQuantity(unit: HKUnit.minute(), doubleValue: exerciseMinutes)
            let exerciseSample = HKQuantitySample(
                type: exerciseTimeType,
                quantity: exerciseQuantity,
                start: startDate,
                end: endDate
            )
            samplesToSave.append(exerciseSample)
            
            // Heart rate samples (if available)
            if let heartRateSamples = heartRateSamples {
                samplesToSave.append(contentsOf: heartRateSamples)
            }
            
            // Associate samples with workout
            if !samplesToSave.isEmpty {
                try await healthStore.add(samplesToSave, to: workout)
            }
        } catch {
            throw HealthKitError.saveFailed(error)
        }
    }
    
    // MARK: - Reading Health Data
    
    /// Read user's weight for better calorie estimation
    func readLatestWeight() async throws -> Double? {
        guard isHealthKitAvailable else {
            throw HealthKitError.notAvailable
        }
        
        guard let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass) else {
            return nil
        }
        
        let status = healthStore.authorizationStatus(for: weightType)
        guard status == .sharingAuthorized else {
            return nil
        }
        
        let query = HKSampleQuery(
            sampleType: weightType,
            predicate: nil,
            limit: 1,
            sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]
        ) { _, samples, error in
            // Handle in completion handler
        }
        
        // For now, return nil as we'd need to use async/await properly
        // This is a simplified version
        return nil
    }
    
    /// Estimate calories burned based on duration and weight
    func estimateCaloriesBurned(duration: TimeInterval, weight: Double? = nil) -> Double {
        // Basic estimation: ~7 calories per minute for HIIT
        // This is a rough estimate - actual calories depend on intensity, weight, age, etc.
        let baseCaloriesPerMinute = 7.0
        let minutes = duration / 60.0
        
        // If we have weight, we can refine the estimate
        // For now, use a simple formula
        var calories = baseCaloriesPerMinute * minutes
        
        if let weight = weight {
            // Adjust based on weight (heavier people burn more)
            let weightMultiplier = weight / 70.0 // Normalize to 70kg
            calories *= weightMultiplier
        }
        
        return max(calories, 10.0) // Minimum 10 calories
    }
    
    // MARK: - Agent 13: Real-time Heart Rate Monitoring
    
    /// Starts real-time heart rate monitoring during workout
    func startHeartRateMonitoring(
        startDate: Date,
        onHeartRateUpdate: @escaping (Double) -> Void
    ) async throws {
        guard isHealthKitAvailable else {
            throw HealthKitError.notAvailable
        }
        
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            throw HealthKitError.notAvailable
        }
        
        // Check read authorization
        let status = healthStore.authorizationStatus(for: heartRateType)
        guard status == .sharingAuthorized else {
            throw HealthKitError.notAuthorized
        }
        
        // Store update handler
        heartRateUpdateHandler = onHeartRateUpdate
        collectedHeartRateSamples = []
        
        // Create workout configuration
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .highIntensityIntervalTraining
        configuration.locationType = .indoor
        
        // Create workout session
        do {
            let session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            activeWorkoutSession = session
            
            // Start the session
            session.startActivity(with: startDate)
            
            // Start heart rate query
            startHeartRateQuery(session: session)
        } catch {
            throw HealthKitError.saveFailed(error)
        }
    }
    
    /// Stops real-time heart rate monitoring
    func stopHeartRateMonitoring() async {
        // Stop heart rate query
        if let query = heartRateQuery {
            healthStore.stop(query)
            heartRateQuery = nil
        }
        
        // End workout session
        if let session = activeWorkoutSession {
            session.end()
            activeWorkoutSession = nil
        }
        
        heartRateUpdateHandler = nil
    }
    
    /// Gets collected heart rate samples from the current workout
    func getCollectedHeartRateSamples() -> [HKQuantitySample] {
        return collectedHeartRateSamples
    }
    
    /// Starts the heart rate query for real-time monitoring
    private func startHeartRateQuery(session: HKWorkoutSession) {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            return
        }
        
        // Create predicate for heart rate samples during workout
        let predicate = HKQuery.predicateForSamples(
            withStart: session.startDate,
            end: nil,
            options: .strictStartDate
        )
        
        // Create anchored query for real-time updates
        let query = HKAnchoredObjectQuery(
            type: heartRateType,
            predicate: predicate,
            anchor: nil,
            limit: HKObjectQueryNoLimit
        ) { [weak self] _, samples, _, _, error in
            guard let self = self, let samples = samples else { return }
            
            // Process heart rate samples
            for sample in samples {
                if let quantitySample = sample as? HKQuantitySample {
                    let bpm = quantitySample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                    
                    // Store sample
                    self.collectedHeartRateSamples.append(quantitySample)
                    
                    // Call update handler on main actor
                    Task { @MainActor in
                        self.heartRateUpdateHandler?(bpm)
                    }
                }
            }
        }
        
        // Update handler for continuous updates
        query.updateHandler = { [weak self] _, samples, _, _, error in
            guard let self = self, let samples = samples else { return }
            
            // Process new heart rate samples
            for sample in samples {
                if let quantitySample = sample as? HKQuantitySample {
                    let bpm = quantitySample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                    
                    // Store sample
                    self.collectedHeartRateSamples.append(quantitySample)
                    
                    // Call update handler on main actor
                    Task { @MainActor in
                        self.heartRateUpdateHandler?(bpm)
                    }
                }
            }
        }
        
        heartRateQuery = query
        healthStore.execute(query)
    }
    
    /// Reads the latest heart rate sample
    func readLatestHeartRate() async throws -> Double? {
        guard isHealthKitAvailable else {
            throw HealthKitError.notAvailable
        }
        
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            return nil
        }
        
        let status = healthStore.authorizationStatus(for: heartRateType)
        guard status == .sharingAuthorized else {
            return nil
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: heartRateType,
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
    
    // MARK: - HealthKit Errors
    
    enum HealthKitError: LocalizedError {
        case notAvailable
        case notAuthorized
        case noTypesConfigured
        case authorizationFailed(Error)
        case saveFailed(Error)
        
        var errorDescription: String? {
            switch self {
            case .notAvailable:
                return "HealthKit is not available on this device."
            case .notAuthorized:
                return "HealthKit permission has not been granted."
            case .noTypesConfigured:
                return "No HealthKit types have been configured."
            case .authorizationFailed(let error):
                return "Failed to authorize HealthKit: \(error.localizedDescription)"
            case .saveFailed(let error):
                return "Failed to save workout to HealthKit: \(error.localizedDescription)"
            }
        }
    }
}


