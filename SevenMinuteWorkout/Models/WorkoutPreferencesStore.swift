import Foundation
import SwiftUI

/// Agent 3 & 16: Workout Preferences Store - Manages user workout customization preferences
///
/// This class handles persistence and management of user workout preferences including:
/// - Workout duration settings (exercise, rest, prep)
/// - Selected presets and custom workouts
/// - Fitness level settings
/// - Personalization preferences (Agent 16)
///
/// Agent 16: Enhanced with personalization support including habit learning and
/// adaptive recommendations.
///
/// Usage:
/// ```swift
/// let preferencesStore = WorkoutPreferencesStore(workoutStore: workoutStore)
/// preferencesStore.updateExerciseDuration(45.0)
/// ```
@MainActor
final class WorkoutPreferencesStore: ObservableObject {
    @Published var preferences: WorkoutPreferences
    @Published var customWorkouts: [CustomWorkout] = []
    
    // Agent 16: Personalization
    @Published var personalizationEngine: PersonalizationEngine?
    @Published var habitLearner: HabitLearner?
    
    private let preferencesKey = "workout.preferences.v1"
    private let customWorkoutsKey = "workout.customWorkouts.v1"
    
    private var workoutStore: WorkoutStore?
    
    init(workoutStore: WorkoutStore? = nil) {
        self.workoutStore = workoutStore
        
        // Load preferences without calling instance methods
        // Can access stored property constants directly since they're already initialized
        if let data = UserDefaults.standard.data(forKey: preferencesKey),
           let decoded = try? JSONDecoder().decode(WorkoutPreferences.self, from: data) {
            preferences = decoded
        } else {
            preferences = WorkoutPreferences()
        }
        
        // Load custom workouts without calling instance methods
        if let data = UserDefaults.standard.data(forKey: customWorkoutsKey),
           let decoded = try? JSONDecoder().decode([CustomWorkout].self, from: data) {
            customWorkouts = decoded
        } else {
            customWorkouts = []
        }
        
        // Agent 16: Initialize personalization components if workoutStore is available
        if let workoutStore = workoutStore {
            personalizationEngine = PersonalizationEngine(workoutStore: workoutStore)
            habitLearner = HabitLearner(workoutStore: workoutStore)
            
            // Analyze patterns on initialization
            habitLearner?.analyzePatterns()
        }
    }
    
    /// Agent 16: Configure with workout store (for delayed initialization)
    func configure(with workoutStore: WorkoutStore) {
        guard self.workoutStore == nil else { return } // Already configured
        
        self.workoutStore = workoutStore
        
        // Initialize personalization components
        personalizationEngine = PersonalizationEngine(workoutStore: workoutStore)
        habitLearner = HabitLearner(workoutStore: workoutStore)
        
        // Defer pattern analysis to ensure WorkoutStore has finished loading
        // Give WorkoutStore time to complete its async initialization
        Task { @MainActor in
            // Wait a bit for WorkoutStore to finish loading its data asynchronously
            try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
            
            // Analyze patterns after WorkoutStore is ready
            habitLearner?.analyzePatterns()
        }
        
        // Agent 16: Listen for workout completions to learn patterns
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("workoutCompleted"),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let session = notification.userInfo?["session"] as? WorkoutSession else {
                return
            }
            
            // Learn from workout completion - ensure MainActor isolation
            Task { @MainActor in
                guard let self = self else { return }
                self.personalizationEngine?.learnFromWorkout(session: session)
                self.habitLearner?.analyzePatterns()
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("workoutCompleted"), object: nil)
    }
    
    // MARK: - Preferences Management
    
    func updatePreferences(_ newPreferences: WorkoutPreferences) {
        preferences = newPreferences
        savePreferences()
    }
    
    func updateExerciseDuration(_ duration: TimeInterval) {
        preferences.exerciseDuration = duration
        savePreferences()
    }
    
    func updateRestDuration(_ duration: TimeInterval) {
        preferences.restDuration = duration
        savePreferences()
    }
    
    func updatePrepDuration(_ duration: TimeInterval) {
        preferences.prepDuration = duration
        savePreferences()
    }
    
    func updateSkipPrepTime(_ skip: Bool) {
        preferences.skipPrepTime = skip
        savePreferences()
    }
    
    func updateSelectedPreset(_ preset: WorkoutPreset?) {
        preferences.selectedPreset = preset
        preferences.selectedCustomWorkoutId = nil // Clear custom workout when preset is selected
        savePreferences()
    }
    
    func updateSelectedCustomWorkout(_ workout: CustomWorkout?) {
        preferences.selectedCustomWorkoutId = workout?.id
        preferences.selectedPreset = nil // Clear preset when custom workout is selected
        savePreferences()
    }
    
    func updateFitnessLevel(_ level: WorkoutPreferences.FitnessLevel) {
        preferences.fitnessLevel = level
        // Update recommended durations based on fitness level
        preferences.exerciseDuration = level.recommendedExerciseDuration
        preferences.restDuration = level.recommendedRestDuration
        savePreferences()
    }
    
    // MARK: - Custom Workouts Management
    
    func saveCustomWorkout(_ workout: CustomWorkout) {
        if let index = customWorkouts.firstIndex(where: { $0.id == workout.id }) {
            var updatedWorkout = workout
            updatedWorkout.updateLastModified()
            customWorkouts[index] = updatedWorkout
        } else {
            var newWorkout = workout
            newWorkout.updateLastModified()
            customWorkouts.append(newWorkout)
        }
        saveCustomWorkouts()
    }
    
    func deleteCustomWorkout(_ workout: CustomWorkout) {
        customWorkouts.removeAll { $0.id == workout.id }
        if preferences.selectedCustomWorkoutId == workout.id {
            preferences.selectedCustomWorkoutId = nil
            preferences.selectedPreset = .full7
        }
        saveCustomWorkouts()
        savePreferences()
    }
    
    func getCustomWorkout(id: UUID) -> CustomWorkout? {
        customWorkouts.first { $0.id == id }
    }
    
    // MARK: - Persistence
    
    private func loadPreferences() -> WorkoutPreferences {
        guard let data = UserDefaults.standard.data(forKey: preferencesKey) else {
            return WorkoutPreferences() // Default preferences
        }
        
        if let decoded = try? JSONDecoder().decode(WorkoutPreferences.self, from: data) {
            return decoded
        }
        
        return WorkoutPreferences()
    }
    
    private func savePreferences() {
        if let data = try? JSONEncoder().encode(preferences) {
            UserDefaults.standard.set(data, forKey: preferencesKey)
        }
    }
    
    private func loadCustomWorkouts() -> [CustomWorkout] {
        guard let data = UserDefaults.standard.data(forKey: customWorkoutsKey) else {
            return []
        }
        
        if let decoded = try? JSONDecoder().decode([CustomWorkout].self, from: data) {
            return decoded
        }
        
        return []
    }
    
    private func saveCustomWorkouts() {
        if let data = try? JSONEncoder().encode(customWorkouts) {
            UserDefaults.standard.set(data, forKey: customWorkoutsKey)
        }
    }
}


