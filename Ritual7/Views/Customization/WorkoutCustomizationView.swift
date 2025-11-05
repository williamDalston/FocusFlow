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
                    VStack(spacing: 0) {
                        // Agent 16: Personalization Recommendations
                        if preferencesStore.preferences.enablePersonalization,
                           let recommendation = preferencesStore.personalizationEngine?.getRecommendedWorkout() {
                            personalizationRecommendationSection(recommendation: recommendation)
                                .padding(.bottom, DesignSystem.Spacing.sectionSpacing)
                        }
                        
                        // Quick toggles at top: Warm-up, Cooldown, Voice cues, Haptics per spec
                        quickTogglesSection
                            .padding(.bottom, DesignSystem.Spacing.sectionSpacing)
                        
                        // Subtle divider
                        Divider()
                            .background(Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle))
                            .padding(.vertical, DesignSystem.Spacing.lg)
                        
                        // Preset Selection
                        presetSection
                            .padding(.bottom, DesignSystem.Spacing.sectionSpacing)
                        
                        // Subtle divider
                        Divider()
                            .background(Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle))
                            .padding(.vertical, DesignSystem.Spacing.lg)
                        
                        // Custom Workouts
                        customWorkoutsSection
                            .padding(.bottom, DesignSystem.Spacing.sectionSpacing)
                        
                        // Subtle divider
                        Divider()
                            .background(Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle))
                            .padding(.vertical, DesignSystem.Spacing.lg)
                        
                        // Duration Settings
                        durationSection
                            .padding(.bottom, DesignSystem.Spacing.sectionSpacing)
                        
                        // Subtle divider
                        Divider()
                            .background(Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle))
                            .padding(.vertical, DesignSystem.Spacing.lg)
                        
                        // Fitness Level
                        fitnessLevelSection
                            .padding(.bottom, DesignSystem.Spacing.sectionSpacing)
                        
                        // Agent 16: Advanced Customization
                        advancedCustomizationSection
                            .padding(.bottom, DesignSystem.Spacing.sectionSpacing)
                        
                        // Agent 16: Personalization Settings
                        personalizationSettingsSection
                            .padding(.bottom, DesignSystem.Spacing.sectionSpacing)
                        
                        // Agent 16: Habit Insights
                        if preferencesStore.preferences.enableHabitInsights,
                           let habitLearner = preferencesStore.habitLearner {
                            // Subtle divider
                            Divider()
                                .background(Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle))
                                .padding(.vertical, DesignSystem.Spacing.lg)
                            
                            habitInsightsSection(habitLearner: habitLearner)
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.vertical, DesignSystem.Spacing.lg)
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
    
    // MARK: - Quick Toggles Section
    
    private var quickTogglesSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            Text("Quick Settings")
                .font(Theme.headline)
                .foregroundStyle(Theme.textPrimary)
                .padding(.horizontal, DesignSystem.Spacing.xs / 2)
            
            GlassCard(material: .ultraThinMaterial) {
                VStack(spacing: DesignSystem.Spacing.md) {
                    // Warm-up toggle
                    Toggle(isOn: Binding(
                        get: { !preferencesStore.preferences.skipPrepTime },
                        set: { preferencesStore.updateSkipPrepTime(!$0) }
                    )) {
                        HStack {
                            Image(systemName: "figure.walk")
                                .foregroundStyle(Theme.accentA)
                                .frame(width: DesignSystem.IconSize.medium)
                            Text("Warm-up")
                                .font(Theme.body)
                                .foregroundStyle(Theme.textPrimary)
                        }
                    }
                    .tint(Theme.accentA)
                    
                    Divider()
                    
                    // Cooldown toggle (if available in preferences)
                    Toggle(isOn: Binding(
                        get: { preferencesStore.preferences.restDuration > 0 },
                        set: { _ in } // Rest duration is controlled via slider
                    )) {
                        HStack {
                            Image(systemName: "figure.cooldown")
                                .foregroundStyle(Theme.accentB)
                                .frame(width: DesignSystem.IconSize.medium)
                            Text("Cooldown")
                                .font(Theme.body)
                                .foregroundStyle(Theme.textPrimary)
                        }
                    }
                    .tint(Theme.accentB)
                    .disabled(true) // Controlled via duration slider
                    
                    Divider()
                    
                    // Voice cues toggle
                    Toggle(isOn: Binding(
                        get: { VoiceCuesManager.shared.voiceEnabled },
                        set: { 
                            VoiceCuesManager.shared.voiceEnabled = $0
                            VoiceCuesManager.shared.saveSettings()
                        }
                    )) {
                        HStack {
                            Image(systemName: "speaker.wave.2")
                                .foregroundStyle(Theme.accentC)
                                .frame(width: DesignSystem.IconSize.medium)
                            Text("Voice cues")
                                .font(Theme.body)
                                .foregroundStyle(Theme.textPrimary)
                        }
                    }
                    .tint(Theme.accentC)
                    
                    Divider()
                    
                    // Haptics toggle
                    Toggle(isOn: Binding(
                        get: { SoundManager.shared.vibrationEnabled },
                        set: { SoundManager.shared.vibrationEnabled = $0 }
                    )) {
                        HStack {
                            Image(systemName: "hand.tap")
                                .foregroundStyle(Theme.accentA)
                                .frame(width: DesignSystem.IconSize.medium)
                            Text("Haptics")
                                .font(Theme.body)
                                .foregroundStyle(Theme.textPrimary)
                        }
                    }
                    .tint(Theme.accentA)
                }
                .regularCardPadding()
            }
        }
    }
    
    // MARK: - Preset Section
    
    private var presetSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            Text("Workout Presets")
                .font(Theme.headline)
                .foregroundStyle(Theme.textPrimary)
                .padding(.horizontal, DesignSystem.Spacing.xs / 2)
            
            Button {
                showPresetSelector = true
            } label: {
                GlassCard(material: .ultraThinMaterial) {
                    HStack {
                        if let preset = preferencesStore.preferences.selectedPreset {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: preset.icon)
                                        .font(Theme.title3)
                                        .foregroundStyle(Theme.accentA)
                                    
                                    Text(preset.displayName)
                                        .font(Theme.headline)
                                        .foregroundStyle(Theme.textPrimary)
                                }
                                
                                Text(preset.description)
                                    .font(Theme.subheadline)
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                HStack(spacing: 12) {
                                    Label("\(preset.exerciseIndices.count) exercises", systemImage: "figure.run")
                                        .font(Theme.caption)
                                        .foregroundStyle(.secondary)
                                    
                                    Label("~\(preset.estimatedMinutes) min", systemImage: "timer")
                                        .font(Theme.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        } else {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Select a Preset")
                                    .font(Theme.headline)
                                    .foregroundStyle(Theme.textPrimary)
                                
                                Text("Choose from predefined workout configurations")
                                    .font(Theme.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                    .padding(DesignSystem.Spacing.lg)
                }
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Custom Workouts Section
    
    private var customWorkoutsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            HStack {
                Text("Custom Workouts")
                    .font(Theme.headline)
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
                        .font(Theme.title3)
                        .foregroundStyle(Theme.accentA)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.xs / 2)
            
            if preferencesStore.customWorkouts.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "list.bullet.rectangle")
                        .font(Theme.title2)
                        .foregroundStyle(.secondary)
                    
                    Text("No custom workouts yet")
                        .font(Theme.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text("Create your own workout routine")
                        .font(Theme.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignSystem.Spacing.xl)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous)
                        .fill(Color(.systemGray6))
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous)
                                .stroke(Color(.systemGray4), lineWidth: DesignSystem.Border.subtle)
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
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            Text("Duration Settings")
                .font(Theme.headline)
                .foregroundStyle(Theme.textPrimary)
                .padding(.horizontal, DesignSystem.Spacing.xs / 2)
            
            GlassCard(material: .ultraThinMaterial) {
                VStack(spacing: 20) {
                    // Exercise Duration
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Exercise Duration")
                                .font(Theme.subheadline.weight(.semibold))
                                .foregroundStyle(Theme.textPrimary)
                            
                            Spacer()
                            
                            Text("\(Int(preferencesStore.preferences.exerciseDuration))s")
                                .font(Theme.subheadline.weight(.semibold))
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
                                .font(Theme.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("60s")
                                .font(Theme.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Divider()
                    
                    // Rest Duration
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Rest Duration")
                                .font(Theme.subheadline.weight(.semibold))
                                .foregroundStyle(Theme.textPrimary)
                            
                            Spacer()
                            
                            Text("\(Int(preferencesStore.preferences.restDuration))s")
                                .font(Theme.subheadline.weight(.semibold))
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
                                .font(Theme.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("30s")
                                .font(Theme.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Divider()
                    
                    // Prep Duration
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Prep Duration")
                                .font(Theme.subheadline.weight(.semibold))
                                .foregroundStyle(Theme.textPrimary)
                            
                            Spacer()
                            
                            Text("\(Int(preferencesStore.preferences.prepDuration))s")
                                .font(Theme.subheadline.weight(.semibold))
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
                                .font(Theme.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("15s")
                                .font(Theme.caption)
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
                .regularCardPadding()
            }
        }
    }
    
    // MARK: - Fitness Level Section
    
    private var fitnessLevelSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            Text("Fitness Level")
                .font(Theme.headline)
                .foregroundStyle(Theme.textPrimary)
                .padding(.horizontal, DesignSystem.Spacing.xs / 2)
            
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
                    .font(Theme.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, DesignSystem.Spacing.xs)
            }
            .regularCardPadding()
        }
    }
    
    // MARK: - Agent 16: Advanced Customization Section
    
    private var advancedCustomizationSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            Text("Advanced Options")
                .font(Theme.headline)
                .foregroundStyle(Theme.textPrimary)
                .padding(.horizontal, DesignSystem.Spacing.xs / 2)
            
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
                                    .font(Theme.headline)
                                    .foregroundStyle(Theme.textPrimary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                                    .font(Theme.caption)
                            }
                        }
                        .buttonStyle(.plain)
                        
                        Text("Customize exercise order, per-exercise rest periods, and sets")
                            .font(Theme.caption)
                            .foregroundStyle(.secondary)
                    }
                    .regularCardPadding()
                }
            }
        }
    }
    
    // MARK: - Agent 16: Personalization Settings Section
    
    private var personalizationSettingsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            Text("Personalization")
                .font(Theme.headline)
                .foregroundStyle(Theme.textPrimary)
                .padding(.horizontal, DesignSystem.Spacing.xs / 2)
            
            GlassCard(material: .ultraThinMaterial) {
                VStack(spacing: DesignSystem.Spacing.lg) {
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
                            .font(Theme.caption)
                            .foregroundStyle(.secondary)
                            .padding(.top, DesignSystem.Spacing.xs / 2)
                    }
                }
                .regularCardPadding()
            }
        }
    }
    
    // MARK: - Agent 16: Personalization Recommendation Section
    
    private func personalizationRecommendationSection(recommendation: WorkoutRecommendation) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            Text("Recommended for You")
                .font(Theme.headline)
                .foregroundStyle(Theme.textPrimary)
                .padding(.horizontal, DesignSystem.Spacing.xs)
            
            GlassCard(material: .ultraThinMaterial) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundStyle(Theme.accentA)
                            .font(Theme.title3)
                        
                        Text(recommendation.recommendedWorkoutType.displayName)
                            .font(Theme.headline)
                            .foregroundStyle(Theme.textPrimary)
                        
                        Spacer()
                        
                        if let optimalTime = recommendation.optimalTime {
                            Text(optimalTime, style: .time)
                                .font(Theme.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    HStack {
                        // Hide "0% confidence" or show user-friendly message per spec
                        if recommendation.confidencePercentage > 0 {
                            Label("Based on your patterns", systemImage: "chart.line.uptrend.xyaxis")
                                .font(Theme.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        if let optimalTime = recommendation.optimalTime {
                            Label("Optimal time: \(optimalTime, style: .time)", systemImage: "clock")
                                .font(Theme.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(DesignSystem.Spacing.lg)
            }
        }
    }
    
    // MARK: - Agent 16: Habit Insights Section
    
    private func habitInsightsSection(habitLearner: HabitLearner) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            Text("Your Workout Habits")
                .font(Theme.headline)
                .foregroundStyle(Theme.textPrimary)
                .padding(.horizontal, DesignSystem.Spacing.xs)
            
            let insights = habitLearner.getHabitInsights()
            
            ForEach(insights) { insight in
                GlassCard(material: .ultraThinMaterial) {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: insight.type.icon)
                            .foregroundStyle(insight.type.color)
                            .font(Theme.title3)
                            .frame(width: DesignSystem.IconSize.large)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(insight.title)
                                .font(Theme.headline)
                                .foregroundStyle(Theme.textPrimary)
                            
                            Text(insight.message)
                                .font(Theme.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .regularCardPadding()
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
        Button(action: onEdit) {
            GlassCard(material: .ultraThinMaterial) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(workout.name)
                            .font(Theme.headline)
                            .foregroundStyle(Theme.textPrimary)
                        
                        if !workout.description.isEmpty {
                            Text(workout.description)
                                .font(Theme.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        HStack(spacing: 12) {
                            Label("\(workout.exerciseIds.count) exercises", systemImage: "figure.run")
                                .font(Theme.caption)
                                .foregroundStyle(.secondary)
                            
                            Label("~\(workout.estimatedMinutes) min", systemImage: "timer")
                                .font(Theme.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        // Chevron affordance per spec
                        Image(systemName: "chevron.right")
                            .font(Theme.caption)
                            .foregroundStyle(.secondary)
                        
                        Button {
                            onDelete()
                            Haptics.tap()
                        } label: {
                            Image(systemName: "trash")
                                .foregroundStyle(.red)
                                .font(Theme.title3)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .regularCardPadding()
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Custom Workout Editor View

struct CustomWorkoutEditorView: View {
    @EnvironmentObject private var preferencesStore: WorkoutPreferencesStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var workout: CustomWorkout
    @State private var showExerciseSelector = false
    @State private var selectedExerciseIds: Set<UUID>
    
    // Agent 25: Real-time validation
    @StateObject private var nameValidation = ValidationState()
    @StateObject private var exerciseValidation = ValidationState()
    
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
                        // Agent 25: Real-time validation for workout name
                        TextField("Workout Name", text: $workout.name)
                            .onChangeCompat(of: workout.name) { newValue in
                                nameValidation.touch()
                                nameValidation.validate(newValue) { InputValidator.validateWorkoutName($0) }
                            }
                            .validation(nameValidation.validation, showError: nameValidation.hasBeenTouched)
                        
                        TextField("Description (optional)", text: $workout.description, axis: .vertical)
                            .lineLimit(3...6)
                            .onChangeCompat(of: workout.description) { newValue in
                                _ = InputValidator.validateWorkoutDescription(newValue)
                            }
                    }
                    
                    Section("Exercises") {
                        // Agent 25: Real-time validation for exercise selection
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
                                    .font(Theme.caption)
                            }
                        }
                        .onChangeCompat(of: selectedExerciseIds) { _ in
                            exerciseValidation.touch()
                            let exerciseArray = Array(selectedExerciseIds)
                            exerciseValidation.validate(exerciseArray) { InputValidator.validateExerciseSelection($0) }
                        }
                        
                        if exerciseValidation.hasBeenTouched, let errorMessage = exerciseValidation.errorMessage {
                            Text(errorMessage)
                                .font(Theme.caption)
                                .foregroundStyle(Theme.error)
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
                        // Agent 25: Validate before saving
                        nameValidation.touch()
                        exerciseValidation.touch()
                        
                        nameValidation.validate(workout.name) { InputValidator.validateWorkoutName($0) }
                        exerciseValidation.validate(Array(selectedExerciseIds)) { InputValidator.validateExerciseSelection($0) }
                        
                        // Only save if valid
                        guard nameValidation.isValid && exerciseValidation.isValid else {
                            return
                        }
                        
                        workout.exerciseIds = Array(selectedExerciseIds)
                        workout.updateLastModified()
                        preferencesStore.saveCustomWorkout(workout)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(!nameValidation.isValid || !exerciseValidation.isValid)
                }
            }
            .sheet(isPresented: $showExerciseSelector) {
                ExerciseSelectorView(selectedExerciseIds: $selectedExerciseIds)
            }
        }
    }
}

// MARK: - Compatibility Extension for onChange

extension View {
    /// Compatibility wrapper for onChange that works on iOS 14+ and iOS 17+
    @ViewBuilder
    func onChangeCompat<T: Equatable>(of value: T, perform action: @escaping (T) -> Void) -> some View {
        if #available(iOS 17.0, *) {
            self.onChange(of: value) { _, newValue in
                action(newValue)
            }
        } else {
            self.onChange(of: value, perform: action)
        }
    }
}

