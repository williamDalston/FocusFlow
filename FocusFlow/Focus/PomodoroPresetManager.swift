import Foundation
import SwiftUI

/// Agent 6: Pomodoro Preset Manager - Manages timer presets and custom interval configurations
/// Handles saving, loading, and managing Pomodoro timer presets
@MainActor
final class PomodoroPresetManager: ObservableObject {
    @Published var selectedPreset: PomodoroPreset = .classic
    @Published var customPresets: [CustomPomodoroPreset] = []
    
    private let selectedPresetKey = "pomodoro.selectedPreset.v1"
    private let customPresetsKey = "pomodoro.customPresets.v1"
    
    init() {
        loadPresets()
    }
    
    /// Load saved presets from UserDefaults
    private func loadPresets() {
        // Load selected preset
        if let presetString = UserDefaults.standard.string(forKey: selectedPresetKey),
           let preset = PomodoroPreset(rawValue: presetString) {
            selectedPreset = preset
        }
        
        // Load custom presets
        if let data = UserDefaults.standard.data(forKey: customPresetsKey),
           let decoded = try? JSONDecoder().decode([CustomPomodoroPreset].self, from: data) {
            customPresets = decoded
        }
    }
    
    /// Save presets to UserDefaults
    func savePresets() {
        UserDefaults.standard.set(selectedPreset.rawValue, forKey: selectedPresetKey)
        
        if let encoded = try? JSONEncoder().encode(customPresets) {
            UserDefaults.standard.set(encoded, forKey: customPresetsKey)
        }
        
        UserDefaults.standard.synchronize()
    }
    
    /// Select a preset
    func selectPreset(_ preset: PomodoroPreset) {
        selectedPreset = preset
        savePresets()
    }
    
    /// Add a custom preset
    func addCustomPreset(_ preset: CustomPomodoroPreset) {
        customPresets.append(preset)
        savePresets()
    }
    
    /// Delete a custom preset
    func deleteCustomPreset(_ preset: CustomPomodoroPreset) {
        customPresets.removeAll { $0.id == preset.id }
        savePresets()
    }
    
    /// Update a custom preset
    func updateCustomPreset(_ preset: CustomPomodoroPreset) {
        if let index = customPresets.firstIndex(where: { $0.id == preset.id }) {
            customPresets[index] = preset
            savePresets()
        }
    }
    
    /// Get current preset configuration (selected preset or custom)
    func getCurrentPreset() -> PomodoroPresetConfiguration {
        // If a custom preset is selected, return it
        if let customPreset = customPresets.first(where: { $0.id == selectedPreset.rawValue }) {
            return PomodoroPresetConfiguration(
                focusDuration: customPreset.focusDuration,
                shortBreakDuration: customPreset.shortBreakDuration,
                longBreakDuration: customPreset.longBreakDuration,
                cycleLength: customPreset.cycleLength
            )
        }
        
        // Otherwise return the standard preset
        return PomodoroPresetConfiguration(
            focusDuration: selectedPreset.focusDuration,
            shortBreakDuration: selectedPreset.shortBreakDuration,
            longBreakDuration: selectedPreset.longBreakDuration,
            cycleLength: selectedPreset.cycleLength
        )
    }
}

/// Custom Pomodoro Preset - User-defined timer configuration
struct CustomPomodoroPreset: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var focusDuration: TimeInterval // in seconds
    var shortBreakDuration: TimeInterval // in seconds
    var longBreakDuration: TimeInterval // in seconds
    var cycleLength: Int // number of sessions before long break
    
    init(
        id: UUID = UUID(),
        name: String,
        focusDuration: TimeInterval,
        shortBreakDuration: TimeInterval,
        longBreakDuration: TimeInterval,
        cycleLength: Int = 4
    ) {
        self.id = id
        self.name = name
        self.focusDuration = focusDuration
        self.shortBreakDuration = shortBreakDuration
        self.longBreakDuration = longBreakDuration
        self.cycleLength = cycleLength
    }
}

/// Pomodoro Preset Configuration - Runtime configuration for timer
/// Agent 14: Enhanced with validation and helper methods
struct PomodoroPresetConfiguration {
    let focusDuration: TimeInterval
    let shortBreakDuration: TimeInterval
    let longBreakDuration: TimeInterval
    let cycleLength: Int
    
    // MARK: - Agent 14: Computed Properties
    
    var focusDurationMinutes: Int {
        Int(focusDuration / 60)
    }
    
    var shortBreakDurationMinutes: Int {
        Int(shortBreakDuration / 60)
    }
    
    var longBreakDurationMinutes: Int {
        Int(longBreakDuration / 60)
    }
    
    /// Whether this configuration is valid
    var isValid: Bool {
        focusDuration >= 60 && focusDuration <= 7200 && // 1 min to 2 hours
        shortBreakDuration >= 0 && shortBreakDuration <= 3600 && // 0 to 1 hour
        longBreakDuration >= 0 && longBreakDuration <= 7200 && // 0 to 2 hours
        cycleLength >= 1 && cycleLength <= 20 // 1 to 20 sessions
    }
    
    /// Total cycle duration (all focus + breaks)
    var totalCycleDuration: TimeInterval {
        let focusTime = TimeInterval(cycleLength) * focusDuration
        let shortBreakTime = TimeInterval(cycleLength - 1) * shortBreakDuration
        return focusTime + shortBreakTime + longBreakDuration
    }
    
    /// Total cycle duration in minutes
    var totalCycleDurationMinutes: Int {
        Int(totalCycleDuration / 60)
    }
    
    // MARK: - Agent 14: Initialization with Validation
    
    init(
        focusDuration: TimeInterval,
        shortBreakDuration: TimeInterval,
        longBreakDuration: TimeInterval,
        cycleLength: Int
    ) {
        // Agent 14: Validate and clamp values
        self.focusDuration = max(60, min(focusDuration, 7200))
        self.shortBreakDuration = max(0, min(shortBreakDuration, 3600))
        self.longBreakDuration = max(0, min(longBreakDuration, 7200))
        self.cycleLength = max(1, min(cycleLength, 20))
    }
}

