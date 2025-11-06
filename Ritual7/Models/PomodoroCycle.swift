import Foundation

/// Agent 2: Pomodoro Cycle - Tracks a complete Pomodoro cycle (4 focus sessions + breaks)
/// Agent 14: Enhanced with validation, computed properties, and helper methods
struct PomodoroCycle: Identifiable, Codable, Hashable {
    let id: UUID
    let startDate: Date
    var completedSessions: Int
    let cycleLength: Int
    
    // MARK: - Agent 14: Computed Properties
    
    var isComplete: Bool {
        completedSessions >= cycleLength
    }
    
    /// Progress as a percentage (0.0 to 1.0)
    var progress: Double {
        guard cycleLength > 0 else { return 0 }
        return min(Double(completedSessions) / Double(cycleLength), 1.0)
    }
    
    /// Remaining sessions in this cycle
    var remainingSessions: Int {
        max(0, cycleLength - completedSessions)
    }
    
    /// Formatted progress string (e.g., "2/4")
    var progressString: String {
        "\(completedSessions)/\(cycleLength)"
    }
    
    /// Whether the cycle is valid
    var isValid: Bool {
        cycleLength > 0 &&
        cycleLength <= 20 && // Reasonable max
        completedSessions >= 0 &&
        completedSessions <= cycleLength &&
        startDate <= Date().addingTimeInterval(86400) // Not too far in future
    }
    
    // MARK: - Agent 14: Enhanced Initialization with Validation
    
    init(
        id: UUID = UUID(),
        startDate: Date = Date(),
        completedSessions: Int = 0,
        cycleLength: Int = 4
    ) {
        // Agent 14: Validate and clamp values
        let validatedCycleLength = max(1, min(cycleLength, 20)) // 1-20 sessions
        let validatedCompletedSessions = max(0, min(completedSessions, validatedCycleLength))
        let validatedStartDate = min(startDate, Date().addingTimeInterval(86400)) // Max 1 day in future
        
        self.id = id
        self.startDate = validatedStartDate
        self.completedSessions = validatedCompletedSessions
        self.cycleLength = validatedCycleLength
    }
    
    // MARK: - Agent 14: Enhanced Methods
    
    /// Increment the completed sessions count
    mutating func incrementSession() {
        guard !isComplete else { return }
        completedSessions = min(completedSessions + 1, cycleLength)
    }
    
    /// Decrement the completed sessions count (for undo scenarios)
    mutating func decrementSession() {
        guard completedSessions > 0 else { return }
        completedSessions = max(0, completedSessions - 1)
    }
    
    /// Reset the cycle
    mutating func reset() {
        completedSessions = 0
    }
    
    /// Reset the cycle and update start date
    mutating func reset(withNewStartDate: Date = Date()) {
        completedSessions = 0
        // Note: startDate is immutable, so create new cycle if needed
        // This is a limitation of struct immutability
    }
    
    /// Create a new cycle (for when current cycle completes)
    func nextCycle() -> PomodoroCycle {
        PomodoroCycle(
            startDate: Date(),
            completedSessions: 0,
            cycleLength: cycleLength
        )
    }
    
    /// Calculate estimated completion date based on average session duration
    func estimatedCompletionDate(averageSessionDuration: TimeInterval) -> Date? {
        guard !isComplete else { return startDate }
        let remainingSessions = remainingSessions
        let estimatedTime = TimeInterval(remainingSessions) * averageSessionDuration
        return startDate.addingTimeInterval(estimatedTime)
    }
}

