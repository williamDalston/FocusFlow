import Foundation

/// Focus Session - Represents a completed Pomodoro focus session
/// This model is used by the Watch app and mirrors the iPhone app's FocusSession
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
    }
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        duration: TimeInterval,
        phaseType: PhaseType,
        completed: Bool = true,
        notes: String? = nil
    ) {
        self.id = id
        self.date = date
        self.duration = duration
        self.phaseType = phaseType
        self.completed = completed
        self.notes = notes
    }
}

