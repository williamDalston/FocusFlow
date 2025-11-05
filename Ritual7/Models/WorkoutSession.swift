import Foundation

/// Represents a completed workout session
struct WorkoutSession: Identifiable, Codable, Hashable {
    let id: UUID
    let date: Date
    let duration: TimeInterval
    let exercisesCompleted: Int
    var notes: String?
    
    init(id: UUID = UUID(), date: Date = Date(), duration: TimeInterval, exercisesCompleted: Int, notes: String? = nil) {
        self.id = id
        self.date = date
        self.duration = duration
        self.exercisesCompleted = exercisesCompleted
        self.notes = notes
    }
}

