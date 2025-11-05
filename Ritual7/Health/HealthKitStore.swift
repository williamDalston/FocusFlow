import Foundation
import SwiftUI
import HealthKit

/// Agent 5: HealthKit Store - Manages HealthKit permissions and state
@MainActor
class HealthKitStore: ObservableObject {
    static let shared = HealthKitStore()
    
    @Published var isAuthorized: Bool = false
    @Published var authorizationStatus: HKAuthorizationStatus = .notDetermined
    @Published var hasRequestedAuthorization: Bool = false
    
    private let healthKitManager = HealthKitManager.shared
    private let hasRequestedKey = "healthkit.hasRequestedAuthorization"
    private let isEnabledKey = "healthkit.isEnabled"
    
    private init() {
        loadState()
        checkAuthorizationStatus()
    }
    
    // MARK: - State Management
    
    private func loadState() {
        hasRequestedAuthorization = UserDefaults.standard.bool(forKey: hasRequestedKey)
    }
    
    private func saveState() {
        UserDefaults.standard.set(hasRequestedAuthorization, forKey: hasRequestedKey)
    }
    
    func checkAuthorizationStatus() {
        guard healthKitManager.isHealthKitAvailable else {
            authorizationStatus = .notDetermined
            isAuthorized = false
            return
        }
        
        authorizationStatus = healthKitManager.workoutAuthorizationStatus
        isAuthorized = authorizationStatus == .sharingAuthorized
    }
    
    // MARK: - Authorization
    
    /// Request HealthKit authorization
    func requestAuthorization() async {
        guard !hasRequestedAuthorization else {
            // Already requested, just check status
            checkAuthorizationStatus()
            return
        }
        
        do {
            let granted = try await healthKitManager.requestAuthorization()
            hasRequestedAuthorization = true
            isAuthorized = granted
            authorizationStatus = healthKitManager.workoutAuthorizationStatus
            saveState()
        } catch {
            print("HealthKit authorization error: \(error.localizedDescription)")
            hasRequestedAuthorization = true
            checkAuthorizationStatus()
            saveState()
        }
    }
    
    /// Check if HealthKit is available and configured
    var isAvailable: Bool {
        healthKitManager.isHealthKitAvailable
    }
    
    /// Check if we can write workouts
    var canWriteWorkouts: Bool {
        healthKitManager.canWriteWorkouts
    }
}


