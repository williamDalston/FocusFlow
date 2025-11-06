import Foundation
import SwiftUI

/// Agent 25: Input Validator - Real-time validation for form inputs
/// Provides validation rules and error messages for common input types
enum InputValidator {
    
    // MARK: - Validation Rules
    
    /// Validates a workout name
    /// - Parameters:
    ///   - name: The workout name to validate
    /// - Returns: Validation result with error message if invalid
    static func validateWorkoutName(_ name: String) -> ValidationResult {
        if name.isEmpty {
            return .invalid("Workout name is required")
        }
        
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .invalid("Workout name cannot be only spaces")
        }
        
        if name.count > 50 {
            return .invalid("Workout name must be 50 characters or less")
        }
        
        if name.count < 2 {
            return .invalid("Workout name must be at least 2 characters")
        }
        
        return .valid
    }
    
    /// Validates exercise selection
    /// - Parameters:
    ///   - exerciseIds: Array of exercise IDs
    /// - Returns: Validation result with error message if invalid
    static func validateExerciseSelection(_ exerciseIds: [UUID]) -> ValidationResult {
        if exerciseIds.isEmpty {
            return .invalid("Please select at least one exercise")
        }
        
        if exerciseIds.count > 20 {
            return .invalid("Maximum 20 exercises allowed")
        }
        
        return .valid
    }
    
    /// Validates exercise duration
    /// - Parameters:
    ///   - duration: Duration in seconds
    /// - Returns: Validation result with error message if invalid
    static func validateExerciseDuration(_ duration: TimeInterval) -> ValidationResult {
        if duration < 5 {
            return .invalid("Exercise duration must be at least 5 seconds")
        }
        
        if duration > 120 {
            return .invalid("Exercise duration cannot exceed 120 seconds")
        }
        
        return .valid
    }
    
    /// Validates rest duration
    /// - Parameters:
    ///   - duration: Duration in seconds
    /// - Returns: Validation result with error message if invalid
    static func validateRestDuration(_ duration: TimeInterval) -> ValidationResult {
        if duration < 0 {
            return .invalid("Rest duration cannot be negative")
        }
        
        if duration > 60 {
            return .invalid("Rest duration cannot exceed 60 seconds")
        }
        
        return .valid
    }
    
    /// Validates prep duration
    /// - Parameters:
    ///   - duration: Duration in seconds
    /// - Returns: Validation result with error message if invalid
    static func validatePrepDuration(_ duration: TimeInterval) -> ValidationResult {
        if duration < 0 {
            return .invalid("Prep duration cannot be negative")
        }
        
        if duration > 30 {
            return .invalid("Prep duration cannot exceed 30 seconds")
        }
        
        return .valid
    }
    
    /// Validates workout description
    /// - Parameters:
    ///   - description: The description to validate
    /// - Returns: Validation result with error message if invalid
    static func validateWorkoutDescription(_ description: String) -> ValidationResult {
        if description.count > 200 {
            return .invalid("Description must be 200 characters or less")
        }
        
        return .valid
    }
    
    /// Validates that a focus session can be started (has valid preset)
    /// - Parameters:
    ///   - preset: Pomodoro preset to validate
    /// - Returns: Validation result with error message if invalid
    static func validateFocusSessionStart(preset: PomodoroPreset) -> ValidationResult {
        if preset.focusDuration <= 0 {
            return .invalid("Focus duration must be greater than 0")
        }
        
        if preset.focusDuration > 3600 {
            return .invalid("Focus duration cannot exceed 60 minutes")
        }
        
        return .valid
    }
}

// MARK: - Validation Result

/// Result of a validation check
enum ValidationResult {
    case valid
    case invalid(String)
    
    var isValid: Bool {
        switch self {
        case .valid:
            return true
        case .invalid:
            return false
        }
    }
    
    var errorMessage: String? {
        switch self {
        case .valid:
            return nil
        case .invalid(let message):
            return message
        }
    }
}


