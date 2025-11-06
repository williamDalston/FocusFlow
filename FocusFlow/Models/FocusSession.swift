import Foundation

/// Agent 2: Focus Session - Represents a completed Pomodoro focus session
/// Agent 14: Enhanced with validation, computed properties, and helper methods
/// Refactored from WorkoutSession for Pomodoro Timer app
struct FocusSession: Identifiable, Codable, Hashable {
    let id: UUID
    let date: Date
    let duration: TimeInterval
    let phaseType: PhaseType
    let completed: Bool
    var notes: String?
    
    /// Phase type for the session (focus, short break, or long break)
    enum PhaseType: String, Codable, CaseIterable {
        case focus = "focus"
        case shortBreak = "shortBreak"
        case longBreak = "longBreak"
        
        var displayName: String {
            switch self {
            case .focus: return "Focus"
            case .shortBreak: return "Short Break"
            case .longBreak: return "Long Break"
            }
        }
        
        /// Icon name for the phase type
        var icon: String {
            switch self {
            case .focus: return "brain.head.profile"
            case .shortBreak: return "cup.and.saucer"
            case .longBreak: return "moon.zzz"
            }
        }
        
        /// Color name for the phase type
        var colorName: String {
            switch self {
            case .focus: return "focus"
            case .shortBreak: return "breakShort"
            case .longBreak: return "breakLong"
            }
        }
    }
    
    // MARK: - Agent 14: Enhanced Initialization with Validation
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        duration: TimeInterval,
        phaseType: PhaseType,
        completed: Bool = true,
        notes: String? = nil
    ) {
        // Agent 14: Validate and clamp duration
        let validatedDuration = max(0, min(duration, 7200)) // Clamp to 0-2 hours
        
        // Agent 14: Validate date (can't be too far in future)
        let validatedDate = min(date, Date().addingTimeInterval(3600)) // Max 1 hour in future
        
        self.id = id
        self.date = validatedDate
        self.duration = validatedDuration
        self.phaseType = phaseType
        self.completed = completed
        self.notes = notes?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // MARK: - Agent 14: Computed Properties
    
    /// Duration in minutes (for display)
    var durationMinutes: Int {
        Int(duration / 60)
    }
    
    /// Duration in seconds (for display)
    var durationSeconds: Int {
        Int(duration.truncatingRemainder(dividingBy: 60))
    }
    
    /// Formatted duration string (e.g., "25:00")
    var formattedDuration: String {
        let minutes = durationMinutes
        let seconds = durationSeconds
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    /// Formatted date string
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    /// Short formatted date string (e.g., "Today", "Yesterday", or date)
    var relativeDateString: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return formatter.string(from: date)
        }
    }
    
    /// Whether this session is valid
    var isValid: Bool {
        duration >= 0 && duration <= 7200 && // 0-2 hours
        date <= Date().addingTimeInterval(3600) && // Not too far in future
        (notes == nil || !notes!.isEmpty) // Notes are optional, but if provided should not be empty
    }
    
    // MARK: - Agent 14: Helper Methods
    
    /// Create a copy with updated notes
    func withNotes(_ newNotes: String?) -> FocusSession {
        FocusSession(
            id: id,
            date: date,
            duration: duration,
            phaseType: phaseType,
            completed: completed,
            notes: newNotes
        )
    }
    
    /// Create a copy with updated completion status
    func withCompleted(_ completed: Bool) -> FocusSession {
        FocusSession(
            id: id,
            date: date,
            duration: duration,
            phaseType: phaseType,
            completed: completed,
            notes: notes
        )
    }
}

