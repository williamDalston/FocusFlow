import SwiftUI

/// Agent 6: Focus Customization View - Main customization interface for Pomodoro timer
struct FocusCustomizationView: View {
    @EnvironmentObject private var preferencesStore: FocusPreferencesStore
    @Environment(\.dismiss) private var dismiss
    @StateObject private var presetManager = PomodoroPresetManager()
    
    @State private var showPresetSelector = false
    @State private var showCustomIntervalEditor = false
    @State private var useCustomIntervals = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                ThemeBackground()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Timer Preset Section
                        presetSection
                            .padding(.bottom, DesignSystem.Spacing.sectionSpacing)
                        
                        Divider()
                            .background(Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle))
                            .padding(.vertical, DesignSystem.Spacing.lg)
                        
                        // Custom Intervals Section
                        customIntervalsSection
                            .padding(.bottom, DesignSystem.Spacing.sectionSpacing)
                        
                        Divider()
                            .background(Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle))
                            .padding(.vertical, DesignSystem.Spacing.lg)
                        
                        // Auto-start Settings
                        autoStartSection
                            .padding(.bottom, DesignSystem.Spacing.sectionSpacing)
                        
                        Divider()
                            .background(Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle))
                            .padding(.vertical, DesignSystem.Spacing.lg)
                        
                        // Sound & Haptics Section
                        soundSection
                            .padding(.bottom, DesignSystem.Spacing.sectionSpacing)
                        
                        Divider()
                            .background(Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle))
                            .padding(.vertical, DesignSystem.Spacing.lg)
                        
                        // Focus Features Section
                        focusFeaturesSection
                            .padding(.bottom, DesignSystem.Spacing.sectionSpacing)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.vertical, DesignSystem.Spacing.lg)
                }
            }
            .navigationTitle("Customize Focus")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(Theme.accentA)
                }
            }
            .onAppear {
                useCustomIntervals = preferencesStore.preferences.useCustomIntervals
            }
        }
    }
    
    // MARK: - Preset Section
    
    private var presetSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            Text("Timer Presets")
                .font(Theme.headline)
                .foregroundStyle(Theme.textPrimary)
                .padding(.horizontal, DesignSystem.Spacing.xs / 2)
            
            Button {
                showPresetSelector = true
            } label: {
                GlassCard(material: .ultraThinMaterial) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: preferencesStore.preferences.selectedPreset.icon)
                                    .font(Theme.title3)
                                    .foregroundStyle(Theme.accentA)
                                
                                Text(preferencesStore.preferences.selectedPreset.displayName)
                                    .font(Theme.headline)
                                    .foregroundStyle(Theme.textPrimary)
                            }
                            
                            Text(preferencesStore.preferences.selectedPreset.description)
                                .font(Theme.subheadline)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            HStack(spacing: 12) {
                                Label("\(preferencesStore.preferences.selectedPreset.focusDurationMinutes) min focus", systemImage: "brain.head.profile")
                                    .font(Theme.caption)
                                    .foregroundStyle(.secondary)
                                
                                Label("\(preferencesStore.preferences.selectedPreset.shortBreakDurationMinutes) min break", systemImage: "pause.circle")
                                    .font(Theme.caption)
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
        .sheet(isPresented: $showPresetSelector) {
            PomodoroPresetSelectorView(
                selectedPreset: Binding(
                    get: { preferencesStore.preferences.selectedPreset },
                    set: { preferencesStore.updateSelectedPreset($0) }
                )
            )
            .environmentObject(preferencesStore)
            .iPadOptimizedSheetPresentation()
        }
    }
    
    // MARK: - Custom Intervals Section
    
    private var customIntervalsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            Text("Custom Intervals")
                .font(Theme.headline)
                .foregroundStyle(Theme.textPrimary)
                .padding(.horizontal, DesignSystem.Spacing.xs / 2)
            
            GlassCard(material: .ultraThinMaterial) {
                VStack(spacing: DesignSystem.Spacing.md) {
                    Toggle(isOn: $useCustomIntervals) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Use Custom Intervals")
                                .font(Theme.body)
                                .foregroundStyle(Theme.textPrimary)
                            Text("Override preset with custom timer durations")
                                .font(Theme.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .tint(Theme.accentA)
                    .onChange(of: useCustomIntervals) { newValue in
                        preferencesStore.preferences.useCustomIntervals = newValue
                        preferencesStore.savePreferences()
                    }
                    
                    if useCustomIntervals {
                        Divider()
                        
                        VStack(spacing: DesignSystem.Spacing.md) {
                            // Focus Duration
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                                Text("Focus Duration")
                                    .font(Theme.body)
                                    .foregroundStyle(Theme.textPrimary)
                                
                                HStack {
                                    Slider(
                                        value: Binding(
                                            get: { preferencesStore.preferences.customFocusDuration / 60 },
                                            set: { preferencesStore.updateCustomIntervals(focusDuration: $0 * 60) }
                                        ),
                                        in: 5...90,
                                        step: 5
                                    )
                                    .tint(Theme.accentA)
                                    
                                    Text("\(Int(preferencesStore.preferences.customFocusDuration / 60)) min")
                                        .font(Theme.body)
                                        .foregroundStyle(Theme.textPrimary)
                                        .frame(width: 60, alignment: .trailing)
                                }
                            }
                            
                            Divider()
                            
                            // Short Break Duration
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                                Text("Short Break Duration")
                                    .font(Theme.body)
                                    .foregroundStyle(Theme.textPrimary)
                                
                                HStack {
                                    Slider(
                                        value: Binding(
                                            get: { preferencesStore.preferences.customShortBreakDuration / 60 },
                                            set: { preferencesStore.updateCustomIntervals(shortBreakDuration: $0 * 60) }
                                        ),
                                        in: 1...15,
                                        step: 1
                                    )
                                    .tint(Theme.accentB)
                                    
                                    Text("\(Int(preferencesStore.preferences.customShortBreakDuration / 60)) min")
                                        .font(Theme.body)
                                        .foregroundStyle(Theme.textPrimary)
                                        .frame(width: 60, alignment: .trailing)
                                }
                            }
                            
                            Divider()
                            
                            // Long Break Duration
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                                Text("Long Break Duration")
                                    .font(Theme.body)
                                    .foregroundStyle(Theme.textPrimary)
                                
                                HStack {
                                    Slider(
                                        value: Binding(
                                            get: { preferencesStore.preferences.customLongBreakDuration / 60 },
                                            set: { preferencesStore.updateCustomIntervals(longBreakDuration: $0 * 60) }
                                        ),
                                        in: 5...60,
                                        step: 5
                                    )
                                    .tint(Theme.accentC)
                                    
                                    Text("\(Int(preferencesStore.preferences.customLongBreakDuration / 60)) min")
                                        .font(Theme.body)
                                        .foregroundStyle(Theme.textPrimary)
                                        .frame(width: 60, alignment: .trailing)
                                }
                            }
                            
                            Divider()
                            
                            // Cycle Length
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                                Text("Sessions Before Long Break")
                                    .font(Theme.body)
                                    .foregroundStyle(Theme.textPrimary)
                                
                                HStack {
                                    Slider(
                                        value: Binding(
                                            get: { Double(preferencesStore.preferences.customCycleLength) },
                                            set: { preferencesStore.updateCustomIntervals(cycleLength: Int($0)) }
                                        ),
                                        in: 2...8,
                                        step: 1
                                    )
                                    .tint(Theme.accentA)
                                    
                                    Text("\(preferencesStore.preferences.customCycleLength)")
                                        .font(Theme.body)
                                        .foregroundStyle(Theme.textPrimary)
                                        .frame(width: 60, alignment: .trailing)
                                }
                            }
                        }
                    }
                }
                .regularCardPadding()
            }
        }
    }
    
    // MARK: - Auto-start Section
    
    private var autoStartSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            Text("Auto-start Settings")
                .font(Theme.headline)
                .foregroundStyle(Theme.textPrimary)
                .padding(.horizontal, DesignSystem.Spacing.xs / 2)
            
            GlassCard(material: .ultraThinMaterial) {
                VStack(spacing: DesignSystem.Spacing.md) {
                    Toggle(isOn: Binding(
                        get: { preferencesStore.preferences.autoStartBreaks },
                        set: { preferencesStore.setAutoStartBreaks($0) }
                    )) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Auto-start Breaks")
                                .font(Theme.body)
                                .foregroundStyle(Theme.textPrimary)
                            Text("Automatically start break timer after focus session")
                                .font(Theme.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .tint(Theme.accentA)
                    
                    Divider()
                    
                    Toggle(isOn: Binding(
                        get: { preferencesStore.preferences.autoStartNextSession },
                        set: { preferencesStore.setAutoStartNextSession($0) }
                    )) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Auto-start Next Session")
                                .font(Theme.body)
                                .foregroundStyle(Theme.textPrimary)
                            Text("Automatically start next focus session after break")
                                .font(Theme.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .tint(Theme.accentB)
                }
                .regularCardPadding()
            }
        }
    }
    
    // MARK: - Sound Section
    
    private var soundSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            Text("Sound & Haptics")
                .font(Theme.headline)
                .foregroundStyle(Theme.textPrimary)
                .padding(.horizontal, DesignSystem.Spacing.xs / 2)
            
            GlassCard(material: .ultraThinMaterial) {
                VStack(spacing: DesignSystem.Spacing.md) {
                    Toggle(isOn: Binding(
                        get: { preferencesStore.preferences.soundEnabled },
                        set: { preferencesStore.updateSoundPreferences(soundEnabled: $0) }
                    )) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Sound Effects")
                                .font(Theme.body)
                                .foregroundStyle(Theme.textPrimary)
                            Text("Play sounds during timer transitions")
                                .font(Theme.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .tint(Theme.accentA)
                    
                    if preferencesStore.preferences.soundEnabled {
                        Divider()
                        
                        Picker("Sound Type", selection: Binding(
                            get: { preferencesStore.preferences.soundType },
                            set: { newValue in
                                preferencesStore.updateSoundPreferences(soundType: newValue)
                            }
                        )) {
                            ForEach(FocusPreferences.SoundType.allCases, id: \.self) { soundType in
                                Text(soundType.displayName).tag(soundType)
                            }
                        }
                        .pickerStyle(.segmented)
                        .tint(Theme.accentA)
                    }
                    
                    Divider()
                    
                    Toggle(isOn: Binding(
                        get: { preferencesStore.preferences.hapticsEnabled },
                        set: { preferencesStore.updateSoundPreferences(hapticsEnabled: $0) }
                    )) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Haptic Feedback")
                                .font(Theme.body)
                                .foregroundStyle(Theme.textPrimary)
                            Text("Vibration feedback during timer transitions")
                                .font(Theme.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .tint(Theme.accentB)
                }
                .regularCardPadding()
            }
        }
    }
    
    // MARK: - Focus Features Section
    
    private var focusFeaturesSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            Text("Focus Features")
                .font(Theme.headline)
                .foregroundStyle(Theme.textPrimary)
                .padding(.horizontal, DesignSystem.Spacing.xs / 2)
            
            GlassCard(material: .ultraThinMaterial) {
                VStack(spacing: DesignSystem.Spacing.md) {
                    Toggle(isOn: Binding(
                        get: { preferencesStore.preferences.enableFocusMode },
                        set: { preferencesStore.preferences.enableFocusMode = $0; preferencesStore.savePreferences() }
                    )) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Focus Mode Integration")
                                .font(Theme.body)
                                .foregroundStyle(Theme.textPrimary)
                            Text("Suggest iOS Focus Mode activation during sessions")
                                .font(Theme.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .tint(Theme.accentA)
                    
                    Divider()
                    
                    Toggle(isOn: Binding(
                        get: { preferencesStore.preferences.ambientSoundsEnabled },
                        set: { preferencesStore.preferences.ambientSoundsEnabled = $0; preferencesStore.savePreferences() }
                    )) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Ambient Sounds")
                                .font(Theme.body)
                                .foregroundStyle(Theme.textPrimary)
                            Text("Play background sounds during focus sessions")
                                .font(Theme.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .tint(Theme.accentB)
                    
                    if preferencesStore.preferences.ambientSoundsEnabled {
                        Divider()
                        
                        Picker("Ambient Sound", selection: Binding(
                            get: { preferencesStore.preferences.ambientSoundType },
                            set: { preferencesStore.preferences.ambientSoundType = $0; preferencesStore.savePreferences() }
                        )) {
                            ForEach(FocusPreferences.AmbientSoundType.allCases, id: \.self) { soundType in
                                if soundType != .none {
                                    Label(soundType.displayName, systemImage: soundType.icon).tag(soundType)
                                } else {
                                    Text(soundType.displayName).tag(soundType)
                                }
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(Theme.accentC)
                    }
                }
                .regularCardPadding()
            }
        }
    }
}

/// Agent 6: Pomodoro Preset Selector View - Select timer preset
struct PomodoroPresetSelectorView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var preferencesStore: FocusPreferencesStore
    @Binding var selectedPreset: PomodoroPreset
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(PomodoroPreset.allCases) { preset in
                    Button {
                        selectedPreset = preset
                        preferencesStore.updateSelectedPreset(preset)
                        dismiss()
                    } label: {
                        HStack {
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
                                    Label("\(preset.focusDurationMinutes) min", systemImage: "brain.head.profile")
                                        .font(Theme.caption)
                                        .foregroundStyle(.secondary)
                                    
                                    Label("\(preset.shortBreakDurationMinutes) min break", systemImage: "pause.circle")
                                        .font(Theme.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            if selectedPreset == preset {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Theme.accentA)
                            }
                        }
                        .padding(.vertical, DesignSystem.Spacing.sm)
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Select Preset")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

