import Foundation
import SwiftUI

/// Agent 6: Focus Preferences Store - Manages user Pomodoro timer preferences
/// Agent 14: Enhanced with validation, export/import, and data versioning
/// Handles persistence and management of focus session preferences including:
/// - Timer preset selection
/// - Custom interval configuration
/// - Sound/haptic preferences
/// - Notification preferences
/// - Auto-start settings
@MainActor
final class FocusPreferencesStore: ObservableObject {
    @Published var preferences: FocusPreferences
    
    // Agent 14: Data versioning support
    private static let dataVersion = 1
    private let preferencesKey = "focus.preferences.v1"
    private let dataVersionKey = "focus.preferences.version"
    
    init() {
        // Agent 14: Initialize data version
        if UserDefaults.standard.object(forKey: dataVersionKey) == nil {
            UserDefaults.standard.set(Self.dataVersion, forKey: dataVersionKey)
        }
        
        // Load preferences from UserDefaults
        if let data = UserDefaults.standard.data(forKey: preferencesKey),
           let decoded = try? JSONDecoder().decode(FocusPreferences.self, from: data) {
            // Agent 14: Validate loaded preferences
            preferences = Self.validatePreferences(decoded) ? decoded : FocusPreferences()
        } else {
            preferences = FocusPreferences()
        }
    }
    
    /// Save preferences to UserDefaults
    func savePreferences() {
        if let encoded = try? JSONEncoder().encode(preferences) {
            UserDefaults.standard.set(encoded, forKey: preferencesKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    /// Update selected preset
    func updateSelectedPreset(_ preset: PomodoroPreset) {
        preferences.selectedPreset = preset
        savePreferences()
    }
    
    /// Update custom intervals (with validation)
    func updateCustomIntervals(
        focusDuration: TimeInterval? = nil,
        shortBreakDuration: TimeInterval? = nil,
        longBreakDuration: TimeInterval? = nil,
        cycleLength: Int? = nil
    ) {
        // Agent 14: Use validated version
        _ = updateCustomIntervalsSafely(
            focusDuration: focusDuration,
            shortBreakDuration: shortBreakDuration,
            longBreakDuration: longBreakDuration,
            cycleLength: cycleLength
        )
    }
    
    /// Toggle auto-start breaks
    func setAutoStartBreaks(_ enabled: Bool) {
        preferences.autoStartBreaks = enabled
        savePreferences()
    }
    
    /// Toggle auto-start next session
    func setAutoStartNextSession(_ enabled: Bool) {
        preferences.autoStartNextSession = enabled
        savePreferences()
    }
    
    /// Update sound preferences
    func updateSoundPreferences(
        soundEnabled: Bool? = nil,
        hapticsEnabled: Bool? = nil,
        soundType: FocusPreferences.SoundType? = nil
    ) {
        if let sound = soundEnabled {
            preferences.soundEnabled = sound
        }
        if let haptics = hapticsEnabled {
            preferences.hapticsEnabled = haptics
        }
        if let sound = soundType {
            preferences.soundType = sound
        }
        savePreferences()
    }
    
    /// Get current timer configuration
    func getCurrentTimerConfiguration() -> PomodoroPresetConfiguration {
        if preferences.useCustomIntervals {
            return PomodoroPresetConfiguration(
                focusDuration: preferences.customFocusDuration,
                shortBreakDuration: preferences.customShortBreakDuration,
                longBreakDuration: preferences.customLongBreakDuration,
                cycleLength: preferences.customCycleLength
            )
        } else {
            return PomodoroPresetConfiguration(
                focusDuration: preferences.selectedPreset.focusDuration,
                shortBreakDuration: preferences.selectedPreset.shortBreakDuration,
                longBreakDuration: preferences.selectedPreset.longBreakDuration,
                cycleLength: preferences.selectedPreset.cycleLength
            )
        }
    }
    
    // MARK: - Agent 14: Validation
    
    /// Validate preferences and fix invalid values
    private static func validatePreferences(_ prefs: FocusPreferences) -> Bool {
        // Validate custom intervals if used
        if prefs.useCustomIntervals {
            guard prefs.customFocusDuration >= 60 && prefs.customFocusDuration <= 7200 else {
                return false // 1 minute to 2 hours
            }
            guard prefs.customShortBreakDuration >= 0 && prefs.customShortBreakDuration <= 3600 else {
                return false // 0 to 1 hour
            }
            guard prefs.customLongBreakDuration >= 0 && prefs.customLongBreakDuration <= 7200 else {
                return false // 0 to 2 hours
            }
            guard prefs.customCycleLength >= 1 && prefs.customCycleLength <= 20 else {
                return false // 1 to 20 sessions
            }
        }
        return true
    }
    
    /// Validate and fix current preferences
    func validateAndFixPreferences() {
        if !Self.validatePreferences(preferences) {
            // Reset to defaults if invalid
            preferences = FocusPreferences()
            savePreferences()
        }
    }
    
    // MARK: - Agent 14: Export & Import
    
    /// Export preferences to JSON data
    func exportPreferences() -> Data? {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            return try encoder.encode(preferences)
        } catch {
            return nil
        }
    }
    
    /// Import preferences from JSON data
    func importPreferences(from data: Data) -> Bool {
        do {
            let decoder = JSONDecoder()
            let imported = try decoder.decode(FocusPreferences.self, from: data)
            
            if Self.validatePreferences(imported) {
                preferences = imported
                savePreferences()
                return true
            }
            return false
        } catch {
            return false
        }
    }
    
    // MARK: - Agent 14: Enhanced Update Methods with Validation
    
    /// Update custom intervals with validation
    func updateCustomIntervalsSafely(
        focusDuration: TimeInterval? = nil,
        shortBreakDuration: TimeInterval? = nil,
        longBreakDuration: TimeInterval? = nil,
        cycleLength: Int? = nil
    ) -> Bool {
        var updated = false
        
        if let focus = focusDuration,
           focus >= 60 && focus <= 7200 {
            preferences.customFocusDuration = focus
            updated = true
        }
        if let shortBreak = shortBreakDuration,
           shortBreak >= 0 && shortBreak <= 3600 {
            preferences.customShortBreakDuration = shortBreak
            updated = true
        }
        if let longBreak = longBreakDuration,
           longBreak >= 0 && longBreak <= 7200 {
            preferences.customLongBreakDuration = longBreak
            updated = true
        }
        if let cycle = cycleLength,
           cycle >= 1 && cycle <= 20 {
            preferences.customCycleLength = cycle
            updated = true
        }
        
        if updated {
            savePreferences()
        }
        return updated
    }
}

/// Agent 6: Focus Preferences - User's Pomodoro timer customization preferences
struct FocusPreferences: Codable {
    // Timer Preset
    var selectedPreset: PomodoroPreset = .classic
    var useCustomIntervals: Bool = false
    
    // Custom Intervals (in seconds)
    var customFocusDuration: TimeInterval = 25 * 60 // 25 minutes
    var customShortBreakDuration: TimeInterval = 5 * 60 // 5 minutes
    var customLongBreakDuration: TimeInterval = 15 * 60 // 15 minutes
    var customCycleLength: Int = 4 // sessions before long break
    
    // Auto-start Settings
    var autoStartBreaks: Bool = false
    var autoStartNextSession: Bool = false
    
    // Sound & Haptics
    var soundEnabled: Bool = true
    var hapticsEnabled: Bool = true
    var soundType: SoundType = .default
    
    // Notifications
    var dailyReminderEnabled: Bool = false
    var breakReminderEnabled: Bool = false
    var streakReminderEnabled: Bool = false
    
    // Focus Mode Integration
    var enableFocusMode: Bool = false
    var enableDoNotDisturb: Bool = false
    
    // Ambient Sounds
    var ambientSoundsEnabled: Bool = false
    var ambientSoundType: AmbientSoundType = .none
    
    enum SoundType: String, Codable, CaseIterable {
        case `default` = "default"
        case gentle = "gentle"
        case energetic = "energetic"
        case none = "none"
        
        var displayName: String {
            switch self {
            case .default: return "Default"
            case .gentle: return "Gentle"
            case .energetic: return "Energetic"
            case .none: return "None"
            }
        }
    }
    
    enum AmbientSoundType: String, Codable, CaseIterable {
        case none = "none"
        case whiteNoise = "whiteNoise"
        case rain = "rain"
        case forest = "forest"
        case ocean = "ocean"
        case cafe = "cafe"
        
        var displayName: String {
            switch self {
            case .none: return "None"
            case .whiteNoise: return "White Noise"
            case .rain: return "Rain"
            case .forest: return "Forest"
            case .ocean: return "Ocean"
            case .cafe: return "Café"
            }
        }
        
        var icon: String {
            switch self {
            case .none: return "speaker.slash"
            case .whiteNoise: return "waveform"
            case .rain: return "cloud.rain"
            case .forest: return "leaf"
            case .ocean: return "water.waves"
            case .cafe: return "cup.and.saucer"
            }
        }
    }
}
