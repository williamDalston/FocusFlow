import SwiftUI

/// Agent 3: Workout Customization View - Main customization interface
struct WorkoutCustomizationView: View {
    @EnvironmentObject private var preferencesStore: WorkoutPreferencesStore
    @Environment(\.dismiss) private var dismiss
    @StateObject private var engine = WorkoutEngine()
    
    @State private var showPresetSelector = false
    @State private var showExerciseSelector = false
    @State private var showCustomWorkoutEditor = false
    @State private var editingCustomWorkout: CustomWorkout?
    
    var body: some View {
        NavigationStack {
            ZStack {
                ThemeBackground()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Agent 16: Personalization Recommendations
                        if preferencesStore.preferences.enablePersonalization,
                           let recommendation = preferencesStore.personalizationEngine?.getRecommendedWorkout() {
                            personalizationRecommendationSection(recommendation: recommendation)
                        }
                        
                        // Preset Selection
                        presetSection
                        
                        // Custom Workouts
                        customWorkoutsSection
                        
                        // Duration Settings
                        durationSection
                        
                        // Fitness Level
                        fitnessLevelSection
                        
                        // Agent 16: Advanced Customization
                        advancedCustomizationSection
                        
                        // Agent 16: Personalization Settings
                        personalizationSettingsSection
                        
                        // Agent 16: Habit Insights
                        if preferencesStore.preferences.enableHabitInsights,
                           let habitLearner = preferencesStore.habitLearner {
                            habitInsightsSection(habitLearner: habitLearner)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("Customize Workout")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(Theme.accentA)
                }
            }
            .sheet(isPresented: $showPresetSelector) {
                PresetSelectorView(selectedPreset: Binding(
                    get: { preferencesStore.preferences.selectedPreset },
                    set: { preferencesStore.updateSelectedPreset($0) }
                ))
                .environmentObject(preferencesStore)
            }
            .sheet(isPresented: $showExerciseSelector) {
                // Exercise selector for custom workout creation
            }
            .sheet(item: $editingCustomWorkout) { workout in
                CustomWorkoutEditorView(workout: workout)
                    .environmentObject(preferencesStore)
            }
            .sheet(item: Binding(
                get: { editingCustomWorkout != nil ? editingCustomWorkout : nil },
                set: { editingCustomWorkout = $0 }
            )) { workout in
                AdvancedCustomizationView(workout: workout)
                    .environmentObject(preferencesStore)
            }
        }
    }
    
    // MARK: - Preset Section
    
    private var presetSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Workout Presets")
                .font(.headline.weight(.semibold))
                .foregroundStyle(Theme.textPrimary)
                .padding(.horizontal, 4)
            
            Button {
                showPresetSelector = true
            } label: {
                GlassCard(material: .ultraThinMaterial) {
                    HStack {
                        if let preset = preferencesStore.preferences.selectedPreset {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: preset.icon)
                                        .font(.title2)
                                        .foregroundStyle(Theme.accentA)
                                    
                                    Text(preset.displayName)
                                        .font(.headline.weight(.semibold))
                                        .foregroundStyle(Theme.textPrimary)
                                }
                                
                                Text(preset.description)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                HStack(spacing: 12) {
                                    Label("\(preset.exerciseIndices.count) exercises", systemImage: "figure.run")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    
                                    Label("~\(preset.estimatedMinutes) min", systemImage: "timer")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        } else {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Select a Preset")
                                    .font(.headline)
                                    .foregroundStyle(Theme.textPrimary)
                                
                                Text("Choose from predefined workout configurations")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                    .padding(16)
                }
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Custom Workouts Section
    
    private var customWorkoutsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Custom Workouts")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)
                
                Spacer()
                
                Button {
                    let newWorkout = CustomWorkout(
                        name: "My Custom Workout",
                        description: "",
                        exerciseIds: Array(Exercise.sevenMinuteWorkout.prefix(5)).map { $0.id },
                        exerciseDuration: 30.0,
                        restDuration: 10.0,
                        prepDuration: 10.0,
                        skipPrepTime: false
                    )
                    editingCustomWorkout = newWorkout
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Theme.accentA)
                }
            }
            .padding(.horizontal, 4)
            
            if preferencesStore.customWorkouts.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "list.bullet.rectangle")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    
                    Text("No custom workouts yet")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text("Create your own workout routine")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.systemGray6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color(.systemGray4), lineWidth: 0.5)
                        )
                )
            } else {
                ForEach(preferencesStore.customWorkouts) { workout in
                    CustomWorkoutRow(workout: workout) {
                        editingCustomWorkout = workout
                    } onDelete: {
                        preferencesStore.deleteCustomWorkout(workout)
                    }
                }
            }
        }
    }
    
    // MARK: - Duration Section
    
    private var durationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Duration Settings")
                .font(.headline.weight(.semibold))
                .foregroundStyle(Theme.textPrimary)
                .padding(.horizontal, 4)
            
            GlassCard(material: .ultraThinMaterial) {
                VStack(spacing: 20) {
                    // Exercise Duration
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Exercise Duration")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Theme.textPrimary)
                            
                            Spacer()
                            
                            Text("\(Int(preferencesStore.preferences.exerciseDuration))s")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Theme.accentA)
                        }
                        
                        Slider(
                            value: Binding(
                                get: { preferencesStore.preferences.exerciseDuration },
                                set: { preferencesStore.updateExerciseDuration($0) }
                            ),
                            in: 15...60,
                            step: 5
                        )
                        .tint(Theme.accentA)
                        
                        HStack {
                            Text("15s")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("60s")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Divider()
                    
                    // Rest Duration
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Rest Duration")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Theme.textPrimary)
                            
                            Spacer()
                            
                            Text("\(Int(preferencesStore.preferences.restDuration))s")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Theme.accentA)
                        }
                        
                        Slider(
                            value: Binding(
                                get: { preferencesStore.preferences.restDuration },
                                set: { preferencesStore.updateRestDuration($0) }
                            ),
                            in: 5...30,
                            step: 5
                        )
                        .tint(Theme.accentA)
                        
                        HStack {
                            Text("5s")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("30s")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Divider()
                    
                    // Prep Duration
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Prep Duration")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Theme.textPrimary)
                            
                            Spacer()
                            
                            Text("\(Int(preferencesStore.preferences.prepDuration))s")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Theme.accentA)
                        }
                        
                        Slider(
                            value: Binding(
                                get: { preferencesStore.preferences.prepDuration },
                                set: { preferencesStore.updatePrepDuration($0) }
                            ),
                            in: 5...15,
                            step: 5
                        )
                        .tint(Theme.accentA)
                        
                        HStack {
                            Text("5s")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("15s")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Divider()
                    
                    // Skip Prep Time
                    Toggle("Skip Prep Time", isOn: Binding(
                        get: { preferencesStore.preferences.skipPrepTime },
                        set: { preferencesStore.updateSkipPrepTime($0) }
                    ))
                    .tint(Theme.accentA)
                }
                .padding(16)
            }
        }
    }
    
    // MARK: - Fitness Level Section
    
    private var fitnessLevelSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Fitness Level")
                .font(.headline.weight(.semibold))
                .foregroundStyle(Theme.textPrimary)
                .padding(.horizontal, 4)
            
            GlassCard(material: .ultraThinMaterial) {
                Picker("Fitness Level", selection: Binding(
                    get: { preferencesStore.preferences.fitnessLevel },
                    set: { preferencesStore.updateFitnessLevel($0) }
                )) {
                    ForEach(WorkoutPreferences.FitnessLevel.allCases, id: \.self) { level in
                        Text(level.displayName).tag(level)
                    }
                }
                .pickerStyle(.segmented)
                .tint(Theme.accentA)
                
                Text("This will adjust recommended durations for your fitness level.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
            }
            .padding(16)
        }
    }
    
    // MARK: - Agent 16: Advanced Customization Section
    
    private var advancedCustomizationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Advanced Options")
                .font(.headline.weight(.semibold))
                .foregroundStyle(Theme.textPrimary)
                .padding(.horizontal, 4)
            
            if let selectedCustomWorkoutId = preferencesStore.preferences.selectedCustomWorkoutId,
               let customWorkout = preferencesStore.getCustomWorkout(id: selectedCustomWorkoutId) {
                GlassCard(material: .ultraThinMaterial) {
                    VStack(spacing: 12) {
                        Button {
                            editingCustomWorkout = customWorkout
                        } label: {
                            HStack {
                                Image(systemName: "slider.horizontal.3")
                                    .foregroundStyle(Theme.accentA)
                                
                                Text("Advanced Customization")
                                    .font(.headline)
                                    .foregroundStyle(Theme.textPrimary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                            }
                        }
                        .buttonStyle(.plain)
                        
                        Text("Customize exercise order, per-exercise rest periods, and sets")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(16)
                }
            }
        }
    }
    
    // MARK: - Agent 16: Personalization Settings Section
    
    private var personalizationSettingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Personalization")
                .font(.headline.weight(.semibold))
                .foregroundStyle(Theme.textPrimary)
                .padding(.horizontal, 4)
            
            GlassCard(material: .ultraThinMaterial) {
                VStack(spacing: 16) {
                    Toggle("Enable Personalization", isOn: Binding(
                        get: { preferencesStore.preferences.enablePersonalization },
                        set: { preferencesStore.preferences.enablePersonalization = $0; preferencesStore.updatePreferences(preferencesStore.preferences) }
                    ))
                    .tint(Theme.accentA)
                    
                    if preferencesStore.preferences.enablePersonalization {
                        Divider()
                        
                        Toggle("Adaptive Recommendations", isOn: Binding(
                            get: { preferencesStore.preferences.enableAdaptiveRecommendations },
                            set: { preferencesStore.preferences.enableAdaptiveRecommendations = $0; preferencesStore.updatePreferences(preferencesStore.preferences) }
                        ))
                        .tint(Theme.accentA)
                        
                        Toggle("Habit Insights", isOn: Binding(
                            get: { preferencesStore.preferences.enableHabitInsights },
                            set: { preferencesStore.preferences.enableHabitInsights = $0; preferencesStore.updatePreferences(preferencesStore.preferences) }
                        ))
                        .tint(Theme.accentA)
                        
                        Toggle("Optimal Time Suggestions", isOn: Binding(
                            get: { preferencesStore.preferences.enableOptimalTimeSuggestions },
                            set: { preferencesStore.preferences.enableOptimalTimeSuggestions = $0; preferencesStore.updatePreferences(preferencesStore.preferences) }
                        ))
                        .tint(Theme.accentA)
                        
                        Text("Personalization learns your workout patterns and adapts recommendations to help you build stronger habits.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.top, 4)
                    }
                }
                .padding(16)
            }
        }
    }
    
    // MARK: - Agent 16: Personalization Recommendation Section
    
    private func personalizationRecommendationSection(recommendation: WorkoutRecommendation) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recommended for You")
                .font(.headline.weight(.semibold))
                .foregroundStyle(Theme.textPrimary)
                .padding(.horizontal, 4)
            
            GlassCard(material: .ultraThinMaterial) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundStyle(Theme.accentA)
                            .font(.title3)
                        
                        Text(recommendation.recommendedWorkoutType.displayName)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(Theme.textPrimary)
                        
                        Spacer()
                        
                        if let optimalTime = recommendation.optimalTime {
                            Text(optimalTime, style: .time)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    HStack {
                        Label("\(recommendation.confidencePercentage)% confidence", systemImage: "chart.line.uptrend.xyaxis")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        if let optimalTime = recommendation.optimalTime {
                            Label("Optimal time: \(optimalTime, style: .time)", systemImage: "clock")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(16)
            }
        }
    }
    
    // MARK: - Agent 16: Habit Insights Section
    
    private func habitInsightsSection(habitLearner: HabitLearner) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Workout Habits")
                .font(.headline.weight(.semibold))
                .foregroundStyle(Theme.textPrimary)
                .padding(.horizontal, 4)
            
            let insights = habitLearner.getHabitInsights()
            
            ForEach(insights) { insight in
                GlassCard(material: .ultraThinMaterial) {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: insight.type.icon)
                            .foregroundStyle(insight.type.color)
                            .font(.title3)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(insight.title)
                                .font(.headline)
                                .foregroundStyle(Theme.textPrimary)
                            
                            Text(insight.message)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(16)
                }
            }
        }
    }
}

// MARK: - Custom Workout Row

private struct CustomWorkoutRow: View {
    let workout: CustomWorkout
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        GlassCard(material: .ultraThinMaterial) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(workout.name)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Theme.textPrimary)
                    
                    if !workout.description.isEmpty {
                        Text(workout.description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack(spacing: 12) {
                        Label("\(workout.exerciseIds.count) exercises", systemImage: "figure.run")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Label("~\(workout.estimatedMinutes) min", systemImage: "timer")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button {
                        onEdit()
                        Haptics.tap()
                    } label: {
                        Image(systemName: "pencil")
                            .foregroundStyle(Theme.accentA)
                            .font(.title3)
                    }
                    
                    Button(role: .destructive) {
                        onDelete()
                        Haptics.tap()
                    } label: {
                        Image(systemName: "trash")
                            .foregroundStyle(.red)
                            .font(.title3)
                    }
                }
            }
            .padding(16)
        }
    }
}

// MARK: - Custom Workout Editor View

struct CustomWorkoutEditorView: View {
    @EnvironmentObject private var preferencesStore: WorkoutPreferencesStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var workout: CustomWorkout
    @State private var showExerciseSelector = false
    @State private var selectedExerciseIds: Set<UUID>
    
    init(workout: CustomWorkout) {
        _workout = State(initialValue: workout)
        _selectedExerciseIds = State(initialValue: Set(workout.exerciseIds))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                ThemeBackground()
                
                Form {
                    Section("Workout Details") {
                        TextField("Workout Name", text: $workout.name)
                        TextField("Description (optional)", text: $workout.description, axis: .vertical)
                            .lineLimit(3...6)
                    }
                    
                    Section("Exercises") {
                        Button {
                            showExerciseSelector = true
                        } label: {
                            HStack {
                                Text("Select Exercises")
                                Spacer()
                                Text("\(selectedExerciseIds.count) selected")
                                    .foregroundStyle(.secondary)
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                            }
                        }
                    }
                    
                    Section("Duration Settings") {
                        Stepper("Exercise Duration: \(Int(workout.exerciseDuration))s", value: $workout.exerciseDuration, in: 15...60, step: 5)
                        Stepper("Rest Duration: \(Int(workout.restDuration))s", value: $workout.restDuration, in: 5...30, step: 5)
                        Stepper("Prep Duration: \(Int(workout.prepDuration))s", value: $workout.prepDuration, in: 5...15, step: 5)
                        Toggle("Skip Prep Time", isOn: $workout.skipPrepTime)
                    }
                    
                    Section {
                        Button(role: .destructive) {
                            preferencesStore.deleteCustomWorkout(workout)
                            dismiss()
                        } label: {
                            Text("Delete Workout")
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Edit Custom Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        workout.exerciseIds = Array(selectedExerciseIds)
                        workout.updateLastModified()
                        preferencesStore.saveCustomWorkout(workout)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(workout.name.isEmpty || selectedExerciseIds.isEmpty)
                }
            }
            .sheet(isPresented: $showExerciseSelector) {
                ExerciseSelectorView(selectedExerciseIds: $selectedExerciseIds)
            }
        }
    }
}

