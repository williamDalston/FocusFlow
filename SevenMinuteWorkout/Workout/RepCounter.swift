import Foundation
import SwiftUI

/// Agent 11: Rep Counter - Tracks repetitions for applicable exercises
/// Provides visual feedback for exercises that can be counted by reps

class RepCounter: ObservableObject {
    @Published var currentReps: Int = 0
    @Published var isTracking: Bool = false
    
    private var repStartTime: Date?
    private var lastRepTime: Date?
    private let repDetectionThreshold: TimeInterval = 0.5 // Minimum time between reps
    
    // MARK: - Rep Counting
    
    /// Starts tracking reps for an exercise
    func startTracking(for exercise: Exercise) {
        guard canTrackReps(for: exercise) else {
            isTracking = false
            return
        }
        
        isTracking = true
        currentReps = 0
        repStartTime = Date()
        lastRepTime = nil
    }
    
    /// Stops tracking reps
    func stopTracking() {
        isTracking = false
        repStartTime = nil
        lastRepTime = nil
    }
    
    /// Records a rep (can be triggered manually or by motion detection)
    func recordRep() {
        guard isTracking else { return }
        
        let now = Date()
        
        // Prevent counting reps too quickly
        if let lastRep = lastRepTime {
            guard now.timeIntervalSince(lastRep) >= repDetectionThreshold else {
                return
            }
        }
        
        currentReps += 1
        lastRepTime = now
        
        // Haptic feedback for each rep
        Haptics.tap()
    }
    
    /// Resets the rep counter
    func reset() {
        currentReps = 0
        repStartTime = nil
        lastRepTime = nil
    }
    
    /// Gets estimated reps based on time and exercise type
    func getEstimatedReps(duration: TimeInterval, exercise: Exercise) -> Int {
        guard canTrackReps(for: exercise) else { return 0 }
        
        let estimatedRepsPerSecond = getRepsPerSecond(for: exercise)
        return max(0, Int(duration * estimatedRepsPerSecond))
    }
    
    // MARK: - Helpers
    
    private func canTrackReps(for exercise: Exercise) -> Bool {
        // Exercises that can be counted by reps
        let repCountableExercises = [
            "Jumping Jacks",
            "Push-up",
            "Abdominal Crunch",
            "Squat",
            "High Knees / Running in Place",
            "Lunge",
            "Push-up and Rotation"
        ]
        
        return repCountableExercises.contains(exercise.name)
    }
    
    private func getRepsPerSecond(for exercise: Exercise) -> Double {
        switch exercise.name {
        case "Jumping Jacks":
            return 1.5 // ~1.5 reps per second
        case "Push-up":
            return 0.5 // ~0.5 reps per second (slower)
        case "Abdominal Crunch":
            return 1.0 // ~1 rep per second
        case "Squat":
            return 0.8 // ~0.8 reps per second
        case "High Knees / Running in Place":
            return 2.0 // ~2 steps per second
        case "Lunge":
            return 0.6 // ~0.6 reps per second (alternating legs)
        case "Push-up and Rotation":
            return 0.3 // ~0.3 reps per second (slower with rotation)
        default:
            return 1.0
        }
    }
}

// MARK: - Rep Counter View

struct RepCounterView: View {
    @ObservedObject var repCounter: RepCounter
    let exercise: Exercise
    
    var body: some View {
        if repCounter.isTracking && canShowRepCounter(for: exercise) {
            HStack(spacing: 12) {
                Image(systemName: "figure.run")
                    .foregroundStyle(Theme.accentA)
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Reps")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text("\(repCounter.currentReps)")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Theme.textPrimary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Theme.accentA.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
    
    private func canShowRepCounter(for exercise: Exercise) -> Bool {
        let repCountableExercises = [
            "Jumping Jacks",
            "Push-up",
            "Abdominal Crunch",
            "Squat",
            "High Knees / Running in Place",
            "Lunge",
            "Push-up and Rotation"
        ]
        
        return repCountableExercises.contains(exercise.name)
    }
}

