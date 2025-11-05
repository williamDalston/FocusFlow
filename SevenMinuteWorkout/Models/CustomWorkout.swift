import Foundation

/// Agent 3 & 16: Custom Workout - User-created workout configurations
///
/// This model represents a user-defined workout routine with customizable exercises,
/// durations, and rest periods. Supports both simple (uniform durations) and advanced
/// (per-exercise customization) workout configurations.
///
/// Agent 16: Enhanced with custom exercise order, per-exercise rest periods, and sets
struct CustomWorkout: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var description: String
    var exerciseIds: [UUID] // Exercise IDs in order
    var exerciseDuration: TimeInterval // Default duration for all exercises
    var restDuration: TimeInterval // Default rest duration
    var prepDuration: TimeInterval
    var skipPrepTime: Bool
    var createdAt: Date
    var lastModified: Date
    
    // Agent 16: Advanced customization
    /// Custom rest duration per exercise (exerciseId -> rest duration)
    var customRestDurations: [UUID: TimeInterval] = [:]
    
    /// Custom exercise duration per exercise (exerciseId -> duration)
    var customExerciseDurations: [UUID: TimeInterval] = [:]
    
    /// Exercise sets/repetitions (exerciseId -> sets count)
    var exerciseSets: [UUID: Int] = [:]
    
    /// Whether to use custom durations per exercise
    var useCustomDurations: Bool = false
    
    /// Whether to use custom rest periods per exercise
    var useCustomRest: Bool = false
    
    init(
        id: UUID = UUID(),
        name: String,
        description: String = "",
        exerciseIds: [UUID],
        exerciseDuration: TimeInterval = 30.0,
        restDuration: TimeInterval = 10.0,
        prepDuration: TimeInterval = 10.0,
        skipPrepTime: Bool = false,
        createdAt: Date = Date(),
        lastModified: Date = Date(),
        customRestDurations: [UUID: TimeInterval] = [:],
        customExerciseDurations: [UUID: TimeInterval] = [:],
        exerciseSets: [UUID: Int] = [:],
        useCustomDurations: Bool = false,
        useCustomRest: Bool = false
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.exerciseIds = exerciseIds
        self.exerciseDuration = exerciseDuration
        self.restDuration = restDuration
        self.prepDuration = prepDuration
        self.skipPrepTime = skipPrepTime
        self.createdAt = createdAt
        self.lastModified = lastModified
        self.customRestDurations = customRestDurations
        self.customExerciseDurations = customExerciseDurations
        self.exerciseSets = exerciseSets
        self.useCustomDurations = useCustomDurations
        self.useCustomRest = useCustomRest
    }
    
    // MARK: - Agent 16: Per-Exercise Customization Methods
    
    /// Agent 16: Get rest duration for a specific exercise
    /// - Parameter exerciseId: The UUID of the exercise
    /// - Returns: The rest duration for this exercise (custom if set, otherwise default)
    func getRestDuration(for exerciseId: UUID) -> TimeInterval {
        if useCustomRest, let customRest = customRestDurations[exerciseId] {
            return customRest
        }
        return restDuration
    }
    
    /// Agent 16: Get exercise duration for a specific exercise
    /// - Parameter exerciseId: The UUID of the exercise
    /// - Returns: The exercise duration for this exercise (custom if set, otherwise default)
    func getExerciseDuration(for exerciseId: UUID) -> TimeInterval {
        if useCustomDurations, let customDuration = customExerciseDurations[exerciseId] {
            return customDuration
        }
        return exerciseDuration
    }
    
    /// Agent 16: Get sets count for a specific exercise
    /// - Parameter exerciseId: The UUID of the exercise
    /// - Returns: The number of sets for this exercise (defaults to 1 if not set)
    func getSets(for exerciseId: UUID) -> Int {
        return exerciseSets[exerciseId] ?? 1
    }
    
    /// Agent 16: Set rest duration for a specific exercise
    mutating func setRestDuration(_ duration: TimeInterval, for exerciseId: UUID) {
        customRestDurations[exerciseId] = duration
        useCustomRest = true
        updateLastModified()
    }
    
    /// Agent 16: Set exercise duration for a specific exercise
    mutating func setExerciseDuration(_ duration: TimeInterval, for exerciseId: UUID) {
        customExerciseDurations[exerciseId] = duration
        useCustomDurations = true
        updateLastModified()
    }
    
    /// Agent 16: Set sets count for a specific exercise
    mutating func setSets(_ sets: Int, for exerciseId: UUID) {
        exerciseSets[exerciseId] = sets
        updateLastModified()
    }
    
    var estimatedDuration: TimeInterval {
        let prep = skipPrepTime ? 0 : prepDuration
        
        var totalExerciseTime: TimeInterval = 0
        var totalRestTime: TimeInterval = 0
        
        for (index, exerciseId) in exerciseIds.enumerated() {
            let sets = getSets(for: exerciseId)
            let exerciseDuration = getExerciseDuration(for: exerciseId)
            totalExerciseTime += Double(sets) * exerciseDuration
            
            // Add rest after each exercise (except the last one)
            if index < exerciseIds.count - 1 {
                let restDuration = getRestDuration(for: exerciseId)
                totalRestTime += restDuration
            }
        }
        
        return prep + totalExerciseTime + totalRestTime
    }
    
    var estimatedMinutes: Int {
        Int(ceil(estimatedDuration / 60.0))
    }
    
    mutating func updateLastModified() {
        lastModified = Date()
    }
}

/// Agent 3 & 16: Workout Preferences - User's workout customization preferences
/// Agent 16: Enhanced with personalization preferences
struct WorkoutPreferences: Codable {
    var exerciseDuration: TimeInterval = 30.0
    var restDuration: TimeInterval = 10.0
    var prepDuration: TimeInterval = 10.0
    var skipPrepTime: Bool = false
    var selectedPreset: WorkoutPreset? = .full7
    var selectedCustomWorkoutId: UUID? = nil
    var fitnessLevel: FitnessLevel = .intermediate
    
    // Agent 16: Personalization preferences
    var enablePersonalization: Bool = true
    var enableAdaptiveRecommendations: Bool = true
    var enableHabitInsights: Bool = true
    var enableOptimalTimeSuggestions: Bool = true
    
    enum FitnessLevel: String, Codable, CaseIterable {
        case beginner = "beginner"
        case intermediate = "intermediate"
        case advanced = "advanced"
        
        var displayName: String {
            switch self {
            case .beginner: return "Beginner"
            case .intermediate: return "Intermediate"
            case .advanced: return "Advanced"
            }
        }
        
        var recommendedExerciseDuration: TimeInterval {
            switch self {
            case .beginner: return 25.0
            case .intermediate: return 30.0
            case .advanced: return 45.0
            }
        }
        
        var recommendedRestDuration: TimeInterval {
            switch self {
            case .beginner: return 15.0
            case .intermediate: return 10.0
            case .advanced: return 5.0
            }
        }
    }
}


