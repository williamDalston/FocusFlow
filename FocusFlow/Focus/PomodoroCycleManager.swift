import Foundation

/// Manages Pomodoro cycle logic (4 sessions = long break)
final class PomodoroCycleManager {
    // MARK: - Properties
    
    /// Number of sessions before long break
    private(set) var cycleLength: Int
    
    /// Current session number in the cycle (1-based)
    private(set) var currentSessionNumber: Int = 1
    
    /// Total sessions completed in current cycle
    private(set) var sessionsCompleted: Int = 0
    
    // MARK: - Initialization
    
    /// Creates a new cycle manager
    /// - Parameter cycleLength: Number of sessions before long break (default: 4)
    init(cycleLength: Int = AppConstants.TimingConstants.defaultPomodoroCycleLength) {
        self.cycleLength = cycleLength
    }
    
    // MARK: - Public Methods
    
    /// Completes the current session
    func completeSession() {
        sessionsCompleted += 1
    }
    
    /// Prepares for the next session
    func prepareNextSession() {
        currentSessionNumber += 1
    }
    
    /// Starts a new cycle (after long break)
    func startNewCycle() {
        currentSessionNumber = 1
        sessionsCompleted = 0
    }
    
    /// Resets the cycle manager
    func reset() {
        currentSessionNumber = 1
        sessionsCompleted = 0
    }
    
    /// Updates the cycle length
    /// - Parameter cycleLength: New cycle length
    func updateCycleLength(_ cycleLength: Int) {
        self.cycleLength = cycleLength
    }
    
    /// Whether it's time for a long break
    /// - Returns: True if 4 sessions completed, false otherwise
    func shouldTakeLongBreak() -> Bool {
        return sessionsCompleted >= cycleLength
    }
    
    /// Progress through current cycle (0.0 to 1.0)
    var cycleProgress: Double {
        guard cycleLength > 0 else { return 0 }
        return Double(sessionsCompleted) / Double(cycleLength)
    }
}

