import Foundation
import SwiftUI

/// Agent 16: Personalization Engine - Learns user preferences and adapts recommendations
@MainActor
final class PersonalizationEngine: ObservableObject {
    @Published var personalizationData: PersonalizationData
    
    private let dataKey = "personalization.data.v1"
    private let workoutStore: WorkoutStore
    
    init(workoutStore: WorkoutStore) {
        self.workoutStore = workoutStore
        self.personalizationData = PersonalizationEngine.loadData()
    }
    
    // MARK: - Learning & Adaptation
    
    /// Learn from a completed workout session
    func learnFromWorkout(session: WorkoutSession, workoutType: WorkoutType? = nil) {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: session.date)
        let weekday = calendar.component(.weekday, from: session.date)
        
        // Update workout time preferences
        updatePreferredWorkoutTime(hour: hour)
        
        // Update weekday preferences
        updatePreferredWorkoutDay(weekday: weekday)
        
        // Update workout type preferences
        if let workoutType = workoutType {
            updatePreferredWorkoutType(workoutType)
        }
        
        // Update consistency patterns
        updateConsistencyPattern(date: session.date)
        
        // Save updated data
        saveData()
    }
    
    /// Update preferred workout time based on usage patterns
    private func updatePreferredWorkoutTime(hour: Int) {
        var timeFrequency = personalizationData.workoutTimeFrequency
        timeFrequency[hour, default: 0] += 1
        personalizationData.workoutTimeFrequency = timeFrequency
        
        // Calculate most frequent hour
        if let mostFrequent = timeFrequency.max(by: { $0.value < $1.value }) {
            personalizationData.preferredWorkoutTime = mostFrequent.key
        }
    }
    
    /// Update preferred workout day based on usage patterns
    private func updatePreferredWorkoutDay(weekday: Int) {
        var dayFrequency = personalizationData.workoutDayFrequency
        dayFrequency[weekday, default: 0] += 1
        personalizationData.workoutDayFrequency = dayFrequency
        
        // Calculate most frequent day
        if let mostFrequent = dayFrequency.max(by: { $0.value < $1.value }) {
            personalizationData.preferredWorkoutDay = mostFrequent.key
        }
    }
    
    /// Update preferred workout type
    private func updatePreferredWorkoutType(_ type: WorkoutType) {
        var typeFrequency = personalizationData.workoutTypeFrequency
        typeFrequency[type, default: 0] += 1
        personalizationData.workoutTypeFrequency = typeFrequency
        
        // Calculate most frequent type
        if let mostFrequent = typeFrequency.max(by: { $0.value < $1.value }) {
            personalizationData.preferredWorkoutType = mostFrequent.key
        }
    }
    
    /// Update consistency patterns
    private func updateConsistencyPattern(date: Date) {
        personalizationData.lastWorkoutDate = date
        personalizationData.totalWorkouts += 1
        
        // Calculate average workouts per week
        let weeksSinceFirst = max(1, Date().timeIntervalSince(personalizationData.firstWorkoutDate ?? date) / (7 * 24 * 60 * 60))
        personalizationData.averageWorkoutsPerWeek = Double(personalizationData.totalWorkouts) / weeksSinceFirst
    }
    
    // MARK: - Recommendations
    
    /// Get personalized workout recommendation
    func getRecommendedWorkout() -> WorkoutRecommendation {
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: Date())
        let currentWeekday = calendar.component(.weekday, from: Date())
        
        // Determine best time for workout today
        let optimalTime = getOptimalWorkoutTime(for: currentWeekday)
        
        // Get workout type recommendation
        let recommendedType = getRecommendedWorkoutType()
        
        // Get duration recommendation
        let recommendedDuration = getRecommendedDuration()
        
        return WorkoutRecommendation(
            optimalTime: optimalTime,
            recommendedWorkoutType: recommendedType,
            recommendedDuration: recommendedDuration,
            confidence: calculateConfidence()
        )
    }
    
    /// Get optimal workout time for a specific day
    func getOptimalWorkoutTime(for weekday: Int) -> Date? {
        guard let preferredHour = personalizationData.preferredWorkoutTime else {
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
    
    /// Get recommended workout type based on time and patterns
    func getRecommendedWorkoutType() -> WorkoutType {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: Date())
        
        // Use preferred type if available
        if let preferred = personalizationData.preferredWorkoutType {
            return preferred
        }
        
        // Suggest based on time of day
        switch hour {
        case 5..<12:
            return .morningEnergizer
        case 12..<17:
            return .officeBreak
        case 17..<22:
            return .full7
        default:
            return .eveningStretch
        }
    }
    
    /// Get recommended workout duration based on patterns
    func getRecommendedDuration() -> TimeInterval {
        // Get average workout duration from history
        let averageDuration = workoutStore.averageWorkoutDuration
        
        if averageDuration > 0 {
            // Recommend based on average, with some variation
            return averageDuration
        }
        
        // Default to 7 minutes
        return 7 * 60
    }
    
    /// Calculate confidence in recommendations (0.0 to 1.0)
    private func calculateConfidence() -> Double {
        let totalWorkouts = personalizationData.totalWorkouts
        
        // Need at least 5 workouts for meaningful patterns
        guard totalWorkouts >= 5 else {
            return Double(totalWorkouts) / 5.0
        }
        
        // Calculate confidence based on consistency
        let consistency = min(1.0, personalizationData.averageWorkoutsPerWeek / 3.0)
        let patternStrength = min(1.0, Double(totalWorkouts) / 20.0)
        
        return (consistency + patternStrength) / 2.0
    }
    
    /// Get adaptive rest duration suggestion
    func getAdaptiveRestDuration(basedOn exercise: Exercise, currentFitnessLevel: WorkoutPreferences.FitnessLevel) -> TimeInterval {
        // Base rest duration on fitness level
        var baseRest: TimeInterval
        
        switch currentFitnessLevel {
        case .beginner:
            baseRest = 15.0
        case .intermediate:
            baseRest = 10.0
        case .advanced:
            baseRest = 5.0
        }
        
        // Adjust based on exercise intensity
        switch exercise.intensityLevel {
        case .beginner:
            baseRest -= 2.0
        case .intermediate:
            break
        case .advanced:
            baseRest += 3.0
        }
        
        // Ensure minimum rest
        return max(5.0, baseRest)
    }
    
    /// Get personalized workout schedule
    func getPersonalizedSchedule() -> WorkoutSchedule {
        let calendar = Calendar.current
        let currentWeekday = calendar.component(.weekday, from: Date())
        
        // Analyze patterns to suggest schedule
        var suggestedDays: [Int] = []
        
        // Add preferred day if available
        if let preferredDay = personalizationData.preferredWorkoutDay {
            suggestedDays.append(preferredDay)
        }
        
        // Add most frequent workout days
        let topDays = personalizationData.workoutDayFrequency
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
        
        return WorkoutSchedule(
            suggestedDays: suggestedDays,
            preferredTime: personalizationData.preferredWorkoutTime ?? 8,
            frequency: max(3, Int(personalizationData.averageWorkoutsPerWeek))
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
    var preferredWorkoutTime: Int? // Hour of day (0-23)
    var preferredWorkoutDay: Int? // Weekday (1-7, Sunday = 1)
    var preferredWorkoutType: WorkoutType?
    var workoutTimeFrequency: [Int: Int] = [:] // Hour -> Count
    var workoutDayFrequency: [Int: Int] = [:] // Weekday -> Count
    var workoutTypeFrequency: [WorkoutType: Int] = [:] // Type -> Count
    var firstWorkoutDate: Date?
    var lastWorkoutDate: Date?
    var totalWorkouts: Int = 0
    var averageWorkoutsPerWeek: Double = 0.0
    
    init() {
        self.workoutTimeFrequency = [:]
        self.workoutDayFrequency = [:]
        self.workoutTypeFrequency = [:]
    }
}

/// Workout type classification
enum WorkoutType: String, Codable, Hashable {
    case full7 = "full7"
    case quick5 = "quick5"
    case extended10 = "extended10"
    case morningEnergizer = "morning"
    case eveningStretch = "evening"
    case officeBreak = "office"
    case recoveryDay = "recovery"
    case custom = "custom"
    
    var displayName: String {
        switch self {
        case .full7: return "Full 7"
        case .quick5: return "Quick 5"
        case .extended10: return "Extended 10"
        case .morningEnergizer: return "Morning Energizer"
        case .eveningStretch: return "Evening Stretch"
        case .officeBreak: return "Office Break"
        case .recoveryDay: return "Recovery Day"
        case .custom: return "Custom"
        }
    }
}

/// Workout recommendation
struct WorkoutRecommendation {
    let optimalTime: Date?
    let recommendedWorkoutType: WorkoutType
    let recommendedDuration: TimeInterval
    let confidence: Double
    
    var confidencePercentage: Int {
        Int(confidence * 100)
    }
}

/// Personalized workout schedule
struct WorkoutSchedule {
    let suggestedDays: [Int] // Weekday numbers (1-7)
    let preferredTime: Int // Hour (0-23)
    let frequency: Int // Workouts per week
    
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

