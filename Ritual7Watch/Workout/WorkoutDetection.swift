import Foundation
import CoreMotion
import WatchKit

/// Agent 15: Workout Detection - Automatic workout detection and auto-pause on wrist-down
@MainActor
class WorkoutDetection: ObservableObject {
    static let shared = WorkoutDetection()
    
    @Published private(set) var isWristDown: Bool = false
    @Published private(set) var isWorkoutDetected: Bool = false
    @Published private(set) var shouldAutoPause: Bool = false
    
    private let motionManager = CMMotionManager()
    private var motionQueue: OperationQueue?
    private var wristDownTimer: Timer?
    
    // Configuration
    private let wristDownThreshold: TimeInterval = 2.0 // Auto-pause after 2 seconds of wrist down
    private let activityThreshold: Double = 0.5 // Acceleration threshold for activity detection
    
    private init() {
        setupMotionManager()
    }
    
    // MARK: - Setup
    
    private func setupMotionManager() {
        motionQueue = OperationQueue()
        motionQueue?.name = "WorkoutDetectionQueue"
        motionQueue?.maxConcurrentOperationCount = 1
    }
    
    // MARK: - Detection
    
    /// Start detecting workout activity and wrist position
    func startDetection() {
        guard motionManager.isDeviceMotionAvailable else {
            print("Device motion is not available")
            return
        }
        
        guard !motionManager.isDeviceMotionActive else {
            return // Already active
        }
        
        motionManager.deviceMotionUpdateInterval = 0.1 // 10 updates per second
        
        motionManager.startDeviceMotionUpdates(to: motionQueue!) { [weak self] motion, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Motion update error: \(error.localizedDescription)")
                return
            }
            
            guard let motion = motion else { return }
            
            Task { @MainActor in
                self.processMotionData(motion)
            }
        }
        
        // Also check wrist orientation
        startWristOrientationDetection()
    }
    
    /// Stop detecting workout activity
    func stopDetection() {
        motionManager.stopDeviceMotionUpdates()
        wristDownTimer?.invalidate()
        wristDownTimer = nil
        isWristDown = false
        isWorkoutDetected = false
        shouldAutoPause = false
    }
    
    // MARK: - Private Methods
    
    private func processMotionData(_ motion: CMDeviceMotion) {
        // Calculate total acceleration (excluding gravity)
        let userAcceleration = motion.userAcceleration
        let totalAcceleration = sqrt(
            pow(userAcceleration.x, 2) +
            pow(userAcceleration.y, 2) +
            pow(userAcceleration.z, 2)
        )
        
        // Detect workout activity
        if totalAcceleration > activityThreshold {
            isWorkoutDetected = true
        } else {
            // If activity stops for a while, reset detection
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                if totalAcceleration < activityThreshold {
                    self.isWorkoutDetected = false
                }
            }
        }
        
        // Detect wrist down position
        // When wrist is down, gravity Z should be positive (or close to 1.0)
        let gravity = motion.gravity
        let wristDown = gravity.z > 0.7 // Wrist is down when gravity Z is high
        
        if wristDown != isWristDown {
            isWristDown = wristDown
            handleWristDownChange(isDown: wristDown)
        }
    }
    
    private func startWristOrientationDetection() {
        // Use WatchKit's device orientation if available
        // For now, rely on motion data
    }
    
    private func handleWristDownChange(isDown: Bool) {
        if isDown {
            // Wrist just went down - start timer for auto-pause
            wristDownTimer?.invalidate()
            wristDownTimer = Timer.scheduledTimer(withTimeInterval: wristDownThreshold, repeats: false) { [weak self] _ in
                Task { @MainActor [weak self] in
                    guard let self = self else { return }
                    self.shouldAutoPause = true
                    
                    // Haptic feedback to notify user
                    WKInterfaceDevice.current().play(.notification)
                }
            }
        } else {
            // Wrist back up - cancel auto-pause
            wristDownTimer?.invalidate()
            wristDownTimer = nil
            shouldAutoPause = false
        }
    }
    
    // MARK: - Manual Control
    
    /// Reset auto-pause flag (called when user manually pauses)
    func resetAutoPause() {
        shouldAutoPause = false
        wristDownTimer?.invalidate()
        wristDownTimer = nil
    }
    
    /// Check if workout is actively happening based on motion
    var isActiveWorkout: Bool {
        return isWorkoutDetected && !isWristDown
    }
}

