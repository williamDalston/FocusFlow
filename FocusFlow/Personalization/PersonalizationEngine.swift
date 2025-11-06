import Foundation
import SwiftUI

/// Agent 23: Personalization Engine - Learns user preferences and adapts recommendations
@MainActor
final class PersonalizationEngine: ObservableObject {
    @Published var personalizationData: PersonalizationData
    
    private let dataKey = "personalization.data.v1"
    private let focusStore: FocusStore
    
    init(focusStore: FocusStore) {
        self.focusStore = focusStore
        self.personalizationData = PersonalizationEngine.loadData()
    }
    
    // MARK: - Learning & Adaptation
    
    /// Learn from a completed focus session
    func learnFromSession(session: FocusSession) {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: session.date)
        let weekday = calendar.component(.weekday, from: session.date)
        
        // Update focus time preferences
        updatePreferredFocusTime(hour: hour)
        
        // Update weekday preferences
        updatePreferredFocusDay(weekday: weekday)
        
        // Update phase type preferences
        // Note: Focus sessions have phase types (focus/shortBreak/longBreak) for Pomodoro cycles
        
        // Update consistency patterns
        updateConsistencyPattern(date: session.date)
        
        // Save updated data
        saveData()
    }
    
    /// Update preferred focus time based on usage patterns
    private func updatePreferredFocusTime(hour: Int) {
        var timeFrequency = personalizationData.focusTimeFrequency
        timeFrequency[hour, default: 0] += 1
        personalizationData.focusTimeFrequency = timeFrequency
        
        // Calculate most frequent hour
        if let mostFrequent = timeFrequency.max(by: { $0.value < $1.value }) {
            personalizationData.preferredFocusTime = mostFrequent.key
        }
    }
    
    /// Update preferred focus day based on usage patterns
    private func updatePreferredFocusDay(weekday: Int) {
        var dayFrequency = personalizationData.focusDayFrequency
        dayFrequency[weekday, default: 0] += 1
        personalizationData.focusDayFrequency = dayFrequency
        
        // Calculate most frequent day
        if let mostFrequent = dayFrequency.max(by: { $0.value < $1.value }) {
            personalizationData.preferredFocusDay = mostFrequent.key
        }
    }
    
    /// Update consistency patterns
    private func updateConsistencyPattern(date: Date) {
        personalizationData.lastSessionDate = date
        personalizationData.totalSessions += 1
        
        // Calculate average sessions per week
        let weeksSinceFirst = max(1, Date().timeIntervalSince(personalizationData.firstSessionDate ?? date) / (7 * 24 * 60 * 60))
        personalizationData.averageSessionsPerWeek = Double(personalizationData.totalSessions) / weeksSinceFirst
    }
    
    // MARK: - Recommendations
    
    /// Get personalized focus recommendation
    func getRecommendedFocus() -> FocusRecommendation {
        let calendar = Calendar.current
        let currentWeekday = calendar.component(.weekday, from: Date())
        
        // Determine best time for focus today
        let optimalTime = getOptimalFocusTime(for: currentWeekday)
        
        // Get duration recommendation
        let recommendedDuration = getRecommendedDuration()
        
        return FocusRecommendation(
            optimalTime: optimalTime,
            recommendedDuration: recommendedDuration,
            confidence: calculateConfidence()
        )
    }
    
    /// Get optimal focus time for a specific day
    func getOptimalFocusTime(for weekday: Int) -> Date? {
        guard let preferredHour = personalizationData.preferredFocusTime else {
            // Default to morning (8 AM) if no preference learned
            let calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month, .day], from: Date())
            components.hour = 8
            components.minute = 0
            return calendar.date(from: components)
        }
        
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = preferredHour
        components.minute = 0
        return calendar.date(from: components)
    }
    
    /// Get recommended focus duration based on patterns
    func getRecommendedDuration() -> TimeInterval {
        // Get average focus session duration from history
        let sessions = focusStore.sessions.filter { $0.phaseType == .focus }
        guard !sessions.isEmpty else {
            // Default to 25 minutes (Classic Pomodoro)
            return 25 * 60
        }
        
        let averageDuration = sessions.reduce(0.0) { $0 + $1.duration } / Double(sessions.count)
        
        if averageDuration > 0 {
            // Recommend based on average
            return averageDuration
        }
        
        // Default to 25 minutes (Classic Pomodoro)
        return 25 * 60
    }
    
    /// Calculate confidence in recommendations (0.0 to 1.0)
    private func calculateConfidence() -> Double {
        let totalSessions = personalizationData.totalSessions
        
        // Need at least 5 sessions for meaningful patterns
        guard totalSessions >= 5 else {
            return Double(totalSessions) / 5.0
        }
        
        // Calculate confidence based on consistency
        let consistency = min(1.0, personalizationData.averageSessionsPerWeek / 3.0)
        let patternStrength = min(1.0, Double(personalizationData.totalSessions) / 20.0)
        
        return (consistency + patternStrength) / 2.0
    }
    
    /// Get personalized focus schedule
    func getPersonalizedSchedule() -> FocusSchedule {
        // Analyze patterns to suggest schedule
        var suggestedDays: [Int] = []
        
        // Add preferred day if available
        if let preferredDay = personalizationData.preferredFocusDay {
            suggestedDays.append(preferredDay)
        }
        
        // Add most frequent focus days
        let topDays = personalizationData.focusDayFrequency
            .sorted(by: { $0.value > $1.value })
            .prefix(3)
            .map { $0.key }
        
        suggestedDays.append(contentsOf: topDays)
        
        // Remove duplicates and ensure we have suggestions
        suggestedDays = Array(Set(suggestedDays))
        
        if suggestedDays.isEmpty {
            // Default: suggest Monday, Wednesday, Friday
            suggestedDays = [2, 4, 6] // Monday, Wednesday, Friday
        }
        
        return FocusSchedule(
            suggestedDays: suggestedDays,
            preferredTime: personalizationData.preferredFocusTime ?? 8,
            frequency: max(3, Int(personalizationData.averageSessionsPerWeek))
        )
    }
    
    // MARK: - Persistence
    
    private static func loadData() -> PersonalizationData {
        guard let data = UserDefaults.standard.data(forKey: "personalization.data.v1"),
              let decoded = try? JSONDecoder().decode(PersonalizationData.self, from: data) else {
            return PersonalizationData()
        }
        return decoded
    }
    
    private func saveData() {
        if let data = try? JSONEncoder().encode(personalizationData) {
            UserDefaults.standard.set(data, forKey: dataKey)
        }
    }
}

// MARK: - Supporting Types

/// Personalization data model
struct PersonalizationData: Codable {
    var preferredFocusTime: Int? // Hour of day (0-23)
    var preferredFocusDay: Int? // Weekday (1-7, Sunday = 1)
    var focusTimeFrequency: [Int: Int] = [:] // Hour -> Count
    var focusDayFrequency: [Int: Int] = [:] // Weekday -> Count
    var firstSessionDate: Date?
    var lastSessionDate: Date?
    var totalSessions: Int = 0
    var averageSessionsPerWeek: Double = 0.0
    
    init() {
        self.focusTimeFrequency = [:]
        self.focusDayFrequency = [:]
    }
}

// Note: PersonalizationEngine now uses FocusStore and FocusSession instead of WorkoutStore and WorkoutSession
// Focus sessions use PomodoroPreset (Classic, Deep Work, Short Sprints) and phase types (focus/shortBreak/longBreak)

/// Focus recommendation
struct FocusRecommendation {
    let optimalTime: Date?
    let recommendedDuration: TimeInterval
    let confidence: Double
    
    var confidencePercentage: Int {
        Int(confidence * 100)
    }
}

/// Personalized focus schedule
struct FocusSchedule {
    let suggestedDays: [Int] // Weekday numbers (1-7)
    let preferredTime: Int // Hour (0-23)
    let frequency: Int // Sessions per week
    
    var suggestedDayNames: [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        
        return suggestedDays.compactMap { weekday -> String? in
            let calendar = Calendar.current
            let today = Date()
            let currentWeekday = calendar.component(.weekday, from: today)
            let daysUntil = (weekday - currentWeekday + 7) % 7
            let targetDate = calendar.date(byAdding: .day, value: daysUntil, to: today) ?? today
            return formatter.string(from: targetDate)
        }
    }
}

