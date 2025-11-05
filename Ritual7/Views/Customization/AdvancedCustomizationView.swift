import SwiftUI

/// Agent 16: Advanced Customization View - UI for advanced workout customization options
struct AdvancedCustomizationView: View {
    @EnvironmentObject private var preferencesStore: WorkoutPreferencesStore
    @Environment(\.dismiss) private var dismiss
    @State private var workout: CustomWorkout
    @State private var selectedExerciseId: UUID?
    @State private var showExerciseCustomization = false
    
    init(workout: CustomWorkout) {
        _workout = State(initialValue: workout)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                ThemeBackground()
                
                Form {
                    Section("Advanced Options") {
                        Toggle("Use Custom Durations Per Exercise", isOn: $workout.useCustomDurations)
                            .tint(Theme.accentA)
                        
                        Toggle("Use Custom Rest Periods Per Exercise", isOn: $workout.useCustomRest)
                            .tint(Theme.accentA)
                    }
                    
                    Section("Exercise Customization") {
                        ForEach(workout.exerciseIds, id: \.self) { exerciseId in
                            if let exercise = Exercise.sevenMinuteWorkout.first(where: { $0.id == exerciseId }) {
                                ExerciseCustomizationRow(
                                    exercise: exercise,
                                    workout: $workout,
                                    onTap: {
                                        selectedExerciseId = exerciseId
                                        showExerciseCustomization = true
                                    }
                                )
                            }
                        }
                    }
                    
                    Section("Workout Summary") {
                        HStack {
                            Text("Total Duration")
                            Spacer()
                            Text("~\(workout.estimatedMinutes) min")
                                .foregroundStyle(Theme.accentA)
                        }
                        
                        HStack {
                            Text("Total Exercises")
                            Spacer()
                            Text("\(workout.exerciseIds.count)")
                                .foregroundStyle(Theme.accentA)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Advanced Customization")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        workout.updateLastModified()
                        preferencesStore.saveCustomWorkout(workout)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(Theme.accentA)
                }
            }
            .sheet(isPresented: $showExerciseCustomization) {
                if let exerciseId = selectedExerciseId,
                   let exercise = Exercise.sevenMinuteWorkout.first(where: { $0.id == exerciseId }) {
                    ExerciseCustomizationDetailView(
                        exercise: exercise,
                        workout: $workout
                    )
                }
            }
        }
    }
}

// MARK: - Exercise Customization Row

private struct ExerciseCustomizationRow: View {
    let exercise: Exercise
    @Binding var workout: CustomWorkout
    
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: exercise.icon)
                    .font(Theme.title3)
                    .foregroundStyle(Theme.accentA)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name)
                        .font(Theme.headline)
                        .foregroundStyle(Theme.textPrimary)
                    
                    HStack(spacing: 12) {
                        if workout.useCustomDurations {
                            Label("\(Int(workout.getExerciseDuration(for: exercise.id)))s", systemImage: "timer")
                                .font(Theme.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        if workout.useCustomRest {
                            Label("\(Int(workout.getRestDuration(for: exercise.id)))s rest", systemImage: "pause.circle")
                                .font(Theme.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        let sets = workout.getSets(for: exercise.id)
                        if sets > 1 {
                            Label("\(sets) sets", systemImage: "repeat")
                                .font(Theme.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
                    .font(Theme.caption)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Exercise Customization Detail View

private struct ExerciseCustomizationDetailView: View {
    let exercise: Exercise
    @Binding var workout: CustomWorkout
    @Environment(\.dismiss) private var dismiss
    
    @State private var exerciseDuration: TimeInterval
    @State private var restDuration: TimeInterval
    @State private var sets: Int
    
    init(exercise: Exercise, workout: Binding<CustomWorkout>) {
        self.exercise = exercise
        self._workout = workout
        
        let currentDuration = workout.wrappedValue.getExerciseDuration(for: exercise.id)
        let currentRest = workout.wrappedValue.getRestDuration(for: exercise.id)
        let currentSets = workout.wrappedValue.getSets(for: exercise.id)
        
        _exerciseDuration = State(initialValue: currentDuration)
        _restDuration = State(initialValue: currentRest)
        _sets = State(initialValue: currentSets)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                ThemeBackground()
                
                Form {
                    Section {
                        HStack {
                            Image(systemName: exercise.icon)
                                .font(Theme.title)
                                .foregroundStyle(Theme.accentA)
                            
                            Text(exercise.name)
                                .font(Theme.title2)
                                .foregroundStyle(Theme.textPrimary)
                        }
                    }
                    
                    if workout.useCustomDurations {
                        Section("Exercise Duration") {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Duration")
                                        .font(Theme.subheadline.weight(.semibold))
                                    
                                    Spacer()
                                    
                                    Text("\(Int(exerciseDuration))s")
                                        .font(Theme.subheadline.weight(.semibold))
                                        .foregroundStyle(Theme.accentA)
                                }
                                
                                Slider(
                                    value: $exerciseDuration,
                                    in: 15...60,
                                    step: 5
                                )
                                .tint(Theme.accentA)
                                
                                HStack {
                                    Text("15s")
                                        .font(Theme.caption)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Text("60s")
                                        .font(Theme.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    
                    if workout.useCustomRest {
                        Section("Rest Duration") {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Rest After Exercise")
                                        .font(Theme.subheadline.weight(.semibold))
                                    
                                    Spacer()
                                    
                                    Text("\(Int(restDuration))s")
                                        .font(Theme.subheadline.weight(.semibold))
                                        .foregroundStyle(Theme.accentA)
                                }
                                
                                Slider(
                                    value: $restDuration,
                                    in: 5...30,
                                    step: 5
                                )
                                .tint(Theme.accentA)
                                
                                HStack {
                                    Text("5s")
                                        .font(Theme.caption)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Text("30s")
                                        .font(Theme.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    
                    Section("Sets") {
                        Stepper("Sets: \(sets)", value: $sets, in: 1...5)
                            .tint(Theme.accentA)
                        
                        Text("Repeat this exercise \(sets) time\(sets == 1 ? "" : "s")")
                            .font(Theme.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Customize Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if workout.useCustomDurations {
                            workout.setExerciseDuration(exerciseDuration, for: exercise.id)
                        }
                        if workout.useCustomRest {
                            workout.setRestDuration(restDuration, for: exercise.id)
                        }
                        workout.setSets(sets, for: exercise.id)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(Theme.accentA)
                }
            }
        }
    }
}

