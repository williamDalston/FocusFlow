import Foundation
import SwiftUI

/// Agent 16: Workout Template Manager - Manages workout templates and sharing
@MainActor
final class WorkoutTemplateManager: ObservableObject {
    @Published var templates: [WorkoutTemplate] = []
    @Published var sharedTemplates: [WorkoutTemplate] = []
    
    private let templatesKey = "workout.templates.v1"
    private let sharedTemplatesKey = "workout.sharedTemplates.v1"
    
    init() {
        loadTemplates()
        loadSharedTemplates()
    }
    
    // MARK: - Template Management
    
    /// Create a template from a custom workout
    func createTemplate(from workout: CustomWorkout) -> WorkoutTemplate {
        let template = WorkoutTemplate(
            id: UUID(),
            name: workout.name,
            description: workout.description,
            exerciseIds: workout.exerciseIds,
            exerciseDuration: workout.exerciseDuration,
            restDuration: workout.restDuration,
            prepDuration: workout.prepDuration,
            skipPrepTime: workout.skipPrepTime,
            customRestDurations: workout.customRestDurations,
            customExerciseDurations: workout.customExerciseDurations,
            exerciseSets: workout.exerciseSets,
            useCustomDurations: workout.useCustomDurations,
            useCustomRest: workout.useCustomRest,
            createdAt: Date(),
            isShared: false
        )
        
        templates.append(template)
        saveTemplates()
        
        return template
    }
    
    /// Save a template
    func saveTemplate(_ template: WorkoutTemplate) {
        if let index = templates.firstIndex(where: { $0.id == template.id }) {
            templates[index] = template
        } else {
            templates.append(template)
        }
        saveTemplates()
    }
    
    /// Delete a template
    func deleteTemplate(_ template: WorkoutTemplate) {
        templates.removeAll { $0.id == template.id }
        saveTemplates()
    }
    
    /// Get a template by ID
    func getTemplate(id: UUID) -> WorkoutTemplate? {
        return templates.first { $0.id == id } ?? sharedTemplates.first { $0.id == id }
    }
    
    /// Convert template to custom workout
    func convertTemplateToWorkout(_ template: WorkoutTemplate) -> CustomWorkout {
        return CustomWorkout(
            name: template.name,
            description: template.description,
            exerciseIds: template.exerciseIds,
            exerciseDuration: template.exerciseDuration,
            restDuration: template.restDuration,
            prepDuration: template.prepDuration,
            skipPrepTime: template.skipPrepTime,
            customRestDurations: template.customRestDurations,
            customExerciseDurations: template.customExerciseDurations,
            exerciseSets: template.exerciseSets,
            useCustomDurations: template.useCustomDurations,
            useCustomRest: template.useCustomRest
        )
    }
    
    // MARK: - Sharing
    
    /// Share a template
    func shareTemplate(_ template: WorkoutTemplate) {
        var sharedTemplate = template
        sharedTemplate.isShared = true
        sharedTemplate.sharedAt = Date()
        
        sharedTemplates.append(sharedTemplate)
        saveSharedTemplates()
    }
    
    /// Import a shared template
    func importSharedTemplate(_ template: WorkoutTemplate) -> CustomWorkout {
        return convertTemplateToWorkout(template)
    }
    
    /// Export template as JSON
    func exportTemplate(_ template: WorkoutTemplate) -> Data? {
        return try? JSONEncoder().encode(template)
    }
    
    /// Import template from JSON
    func importTemplate(from data: Data) -> WorkoutTemplate? {
        return try? JSONDecoder().decode(WorkoutTemplate.self, from: data)
    }
    
    // MARK: - Persistence
    
    private func loadTemplates() {
        guard let data = UserDefaults.standard.data(forKey: templatesKey),
              let decoded = try? JSONDecoder().decode([WorkoutTemplate].self, from: data) else {
            templates = []
            return
        }
        templates = decoded
    }
    
    private func saveTemplates() {
        if let data = try? JSONEncoder().encode(templates) {
            UserDefaults.standard.set(data, forKey: templatesKey)
        }
    }
    
    private func loadSharedTemplates() {
        guard let data = UserDefaults.standard.data(forKey: sharedTemplatesKey),
              let decoded = try? JSONDecoder().decode([WorkoutTemplate].self, from: data) else {
            sharedTemplates = []
            return
        }
        sharedTemplates = decoded
    }
    
    private func saveSharedTemplates() {
        if let data = try? JSONEncoder().encode(sharedTemplates) {
            UserDefaults.standard.set(data, forKey: sharedTemplatesKey)
        }
    }
}

// MARK: - Workout Template

/// Agent 16: Workout Template - Shareable workout configuration
struct WorkoutTemplate: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var description: String
    var exerciseIds: [UUID]
    var exerciseDuration: TimeInterval
    var restDuration: TimeInterval
    var prepDuration: TimeInterval
    var skipPrepTime: Bool
    var customRestDurations: [UUID: TimeInterval]
    var customExerciseDurations: [UUID: TimeInterval]
    var exerciseSets: [UUID: Int]
    var useCustomDurations: Bool
    var useCustomRest: Bool
    var createdAt: Date
    var isShared: Bool
    var sharedAt: Date?
    
    init(
        id: UUID = UUID(),
        name: String,
        description: String = "",
        exerciseIds: [UUID],
        exerciseDuration: TimeInterval = 30.0,
        restDuration: TimeInterval = 10.0,
        prepDuration: TimeInterval = 10.0,
        skipPrepTime: Bool = false,
        customRestDurations: [UUID: TimeInterval] = [:],
        customExerciseDurations: [UUID: TimeInterval] = [:],
        exerciseSets: [UUID: Int] = [:],
        useCustomDurations: Bool = false,
        useCustomRest: Bool = false,
        createdAt: Date = Date(),
        isShared: Bool = false,
        sharedAt: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.exerciseIds = exerciseIds
        self.exerciseDuration = exerciseDuration
        self.restDuration = restDuration
        self.prepDuration = prepDuration
        self.skipPrepTime = skipPrepTime
        self.customRestDurations = customRestDurations
        self.customExerciseDurations = customExerciseDurations
        self.exerciseSets = exerciseSets
        self.useCustomDurations = useCustomDurations
        self.useCustomRest = useCustomRest
        self.createdAt = createdAt
        self.isShared = isShared
        self.sharedAt = sharedAt
    }
    
    var estimatedDuration: TimeInterval {
        let prep = skipPrepTime ? 0 : prepDuration
        var totalExerciseTime: TimeInterval = 0
        var totalRestTime: TimeInterval = 0
        
        for (index, exerciseId) in exerciseIds.enumerated() {
            let sets = exerciseSets[exerciseId] ?? 1
            let exerciseDuration = useCustomDurations ? (customExerciseDurations[exerciseId] ?? self.exerciseDuration) : self.exerciseDuration
            totalExerciseTime += Double(sets) * exerciseDuration
            
            if index < exerciseIds.count - 1 {
                let restDuration = useCustomRest ? (customRestDurations[exerciseId] ?? self.restDuration) : self.restDuration
                totalRestTime += restDuration
            }
        }
        
        return prep + totalExerciseTime + totalRestTime
    }
    
    var estimatedMinutes: Int {
        Int(ceil(estimatedDuration / 60.0))
    }
}

