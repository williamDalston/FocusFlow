import Foundation
import Combine

/// Protocol for workout timer functionality to enable dependency injection and testing
protocol WorkoutTimerProtocol: AnyObject {
    /// Callback when timer updates
    var onUpdate: ((TimeInterval) -> Void)? { get set }
    
    /// Callback when timer reaches zero
    var onComplete: (() -> Void)? { get set }
    
    /// Starts the timer with the given duration
    func start(duration: TimeInterval)
    
    /// Pauses the timer
    func pause()
    
    /// Resumes the timer
    func resume()
    
    /// Stops the timer
    func stop()
    
    /// Current remaining time
    var timeRemaining: TimeInterval { get }
    
    /// Whether the timer is currently running
    var isRunning: Bool { get }
}

/// Timer implementation for workout phases with countdown functionality
@MainActor
final class WorkoutTimer: WorkoutTimerProtocol {
    // MARK: - Properties
    
    /// Callback invoked on each timer update (every 0.1 seconds)
    var onUpdate: ((TimeInterval) -> Void)?
    
    /// Callback invoked when timer reaches zero
    var onComplete: (() -> Void)?
    
    /// Current remaining time
    private(set) var timeRemaining: TimeInterval = 0
    
    /// Whether the timer is currently running
    private(set) var isRunning: Bool = false
    
    /// The original duration set when timer started
    private var originalDuration: TimeInterval = 0
    
    /// The timer instance
    private var timer: Timer?
    
    /// Whether the timer is paused
    private var isPaused: Bool = false
    
    /// Time when timer was paused
    private var pauseStartTime: Date?
    
    /// Total accumulated paused time
    private var totalPausedTime: TimeInterval = 0
    
    /// Time when timer started
    private var startTime: Date?
    
    // MARK: - Public Methods
    
    /// Starts the timer with the given duration
    /// - Parameter duration: The duration in seconds
    func start(duration: TimeInterval) {
        guard duration > 0 else {
            // Invalid duration, call completion immediately
            onComplete?()
            return
        }
        
        stop() // Stop any existing timer
        
        originalDuration = duration
        timeRemaining = duration
        isRunning = true
        isPaused = false
        totalPausedTime = 0
        startTime = Date()
        
        startTimer()
    }
    
    /// Pauses the timer
    func pause() {
        guard isRunning && !isPaused else { return }
        
        isPaused = true
        pauseStartTime = Date()
        
        // Calculate current remaining time before pausing
        if let start = startTime {
            let elapsed = Date().timeIntervalSince(start) - totalPausedTime
            timeRemaining = max(0, originalDuration - elapsed)
        }
        
        timer?.invalidate()
        timer = nil
    }
    
    /// Resumes the timer
    func resume() {
        guard isRunning && isPaused else { return }
        
        isPaused = false
        
        // Accumulate paused time
        if let pauseStart = pauseStartTime {
            totalPausedTime += Date().timeIntervalSince(pauseStart)
            pauseStartTime = nil
        }
        
        // Restart timer with remaining time
        originalDuration = timeRemaining
        startTime = Date()
        totalPausedTime = 0
        
        startTimer()
    }
    
    /// Stops the timer and resets state
    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        isPaused = false
        timeRemaining = 0
        originalDuration = 0
        totalPausedTime = 0
        pauseStartTime = nil
        startTime = nil
    }
    
    deinit {
        timer?.invalidate()
    }
    
    // MARK: - Private Methods
    
    /// Starts the internal timer
    private func startTimer() {
        guard isRunning && !isPaused else { return }
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self, self.isRunning && !self.isPaused else { return }
                
                // Calculate elapsed time accounting for pauses
                let elapsed: TimeInterval
                if let start = self.startTime {
                    let totalElapsed = Date().timeIntervalSince(start)
                    elapsed = totalElapsed - self.totalPausedTime
                } else {
                    elapsed = 0
                }
                
                // Update remaining time
                self.timeRemaining = max(0, self.originalDuration - elapsed)
                
                // Notify update
                self.onUpdate?(self.timeRemaining)
                
                // Check if timer completed
                if self.timeRemaining <= 0 {
                    self.stop()
                    self.onComplete?()
                }
            }
        }
        
        // Add to common run loop mode for better responsiveness
        if let timer = timer {
            RunLoop.current.add(timer, forMode: .common)
        }
    }
}

