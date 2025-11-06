import Foundation
@testable import FocusFlow

/// Mock implementation of FocusTimerProtocol for testing
@MainActor
final class MockFocusTimer: FocusTimerProtocol {
    var onUpdate: ((TimeInterval) -> Void)?
    var onComplete: (() -> Void)?
    
    private(set) var timeRemaining: TimeInterval = 0
    private(set) var isRunning: Bool = false
    
    private var startDuration: TimeInterval = 0
    private var startCallCount = 0
    private var pauseCallCount = 0
    private var resumeCallCount = 0
    private var stopCallCount = 0
    
    // Test control
    var shouldCallCompletionImmediately = false
    var updateInterval: TimeInterval = 0.1
    var shouldSimulateTime = true
    
    func start(duration: TimeInterval) {
        startCallCount += 1
        startDuration = duration
        timeRemaining = duration
        isRunning = true
        
        if shouldCallCompletionImmediately {
            // Immediately complete
            Task { @MainActor in
                self.timeRemaining = 0
                self.isRunning = false
                self.onComplete?()
            }
        } else if shouldSimulateTime {
            // Simulate timer updates
            simulateTimerUpdates(duration: duration)
        }
    }
    
    func pause() {
        pauseCallCount += 1
        isRunning = false
    }
    
    func resume() {
        resumeCallCount += 1
        isRunning = true
        if shouldSimulateTime {
            simulateTimerUpdates(duration: timeRemaining)
        }
    }
    
    func stop() {
        stopCallCount += 1
        isRunning = false
        timeRemaining = 0
    }
    
    // MARK: - Test Helpers
    
    func triggerUpdate(timeRemaining: TimeInterval) {
        self.timeRemaining = timeRemaining
        onUpdate?(timeRemaining)
    }
    
    func triggerCompletion() {
        timeRemaining = 0
        isRunning = false
        onComplete?()
    }
    
    func fastForward(by seconds: TimeInterval) {
        guard isRunning else { return }
        timeRemaining = max(0, timeRemaining - seconds)
        onUpdate?(timeRemaining)
        
        if timeRemaining <= 0 {
            triggerCompletion()
        }
    }
    
    // MARK: - Test Assertions
    
    var wasStarted: Bool {
        startCallCount > 0
    }
    
    var startCallCountValue: Int {
        startCallCount
    }
    
    var pauseCallCountValue: Int {
        pauseCallCount
    }
    
    var resumeCallCountValue: Int {
        resumeCallCount
    }
    
    var stopCallCountValue: Int {
        stopCallCount
    }
    
    var lastStartDuration: TimeInterval {
        startDuration
    }
    
    // MARK: - Private
    
    private func simulateTimerUpdates(duration: TimeInterval) {
        // For testing, we'll use a simple timer that counts down
        // In actual tests, we'll control this manually
    }
    
    func reset() {
        stop()
        startCallCount = 0
        pauseCallCount = 0
        resumeCallCount = 0
        stopCallCount = 0
        shouldCallCompletionImmediately = false
        shouldSimulateTime = true
    }
}

