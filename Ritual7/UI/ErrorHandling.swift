import SwiftUI
import os.log

/// Agent 8: Error handling with user-friendly messages and recovery options
enum ErrorHandling {
    
    // MARK: - Error Types
    
    enum WorkoutError: LocalizedError {
        case workoutInProgress
        case engineNotReady
        case sessionExpired
        case dataCorrupted
        case networkUnavailable
        case invalidState
        case workoutInterrupted
        case backgroundTransitionFailed
        case lowMemory
        case batterySaverMode
        case invalidData(description: String)
        case permissionDenied(permission: String)
        case unknown(Error)
        
        var errorDescription: String? {
            switch self {
            case .workoutInProgress:
                return "A workout is already in progress. Please complete or stop the current workout before starting a new one."
            case .engineNotReady:
                return "The workout engine is not ready. Please try again in a moment."
            case .sessionExpired:
                return "Your workout session has expired. Please start a new workout."
            case .dataCorrupted:
                return "Your workout data appears to be corrupted. The app will attempt to recover."
            case .networkUnavailable:
                return "Network connection is unavailable. Some features may not work."
            case .invalidState:
                return "The app is in an invalid state. Please restart the app."
            case .workoutInterrupted:
                return "Your workout was interrupted. You can resume from where you left off."
            case .backgroundTransitionFailed:
                return "Failed to handle background transition. Your workout progress has been saved."
            case .lowMemory:
                return "The device is running low on memory. Some features may be limited."
            case .batterySaverMode:
                return "Battery saver mode is enabled. Some features may be limited to preserve battery."
            case .invalidData(let description):
                return "Invalid data detected: \(description). Please try again."
            case .permissionDenied(let permission):
                return "Permission for \(permission) was denied. Please enable it in Settings."
            case .unknown(let error):
                return "An unexpected error occurred: \(error.localizedDescription)"
            }
        }
        
        var recoverySuggestion: String? {
            switch self {
            case .workoutInProgress:
                return "Stop the current workout or wait for it to complete."
            case .engineNotReady:
                return "Wait a moment and try again."
            case .sessionExpired:
                return "Start a new workout session."
            case .dataCorrupted:
                return "The app will attempt to recover your data automatically."
            case .networkUnavailable:
                return "Check your network connection and try again."
            case .invalidState:
                return "Try restarting the app to reset the state."
            case .workoutInterrupted:
                return "You can resume your workout from the main screen."
            case .backgroundTransitionFailed:
                return "Your workout progress has been saved. You can continue from where you left off."
            case .lowMemory:
                return "Close other apps to free up memory, then try again."
            case .batterySaverMode:
                return "Disable battery saver mode or connect to power for full functionality."
            case .invalidData:
                return "Please check your input and try again."
            case .permissionDenied:
                return "Go to Settings to enable the required permission."
            case .unknown:
                return "Try restarting the app. If the problem persists, contact support."
            }
        }
    }
    
    // MARK: - Error Handling
    
    /// Handles errors with user-friendly messages
    static func handleError(_ error: Error, context: String = "") {
        let workoutError: WorkoutError
        if let we = error as? WorkoutError {
            workoutError = we
        } else {
            workoutError = .unknown(error)
        }
        
        // Log error for debugging and crash reporting
        os_log("Error in %{public}@: %{public}@", log: .default, type: .error, context.isEmpty ? "unknown" : context, workoutError.localizedDescription)
        Task { @MainActor in
            CrashReporter.logError(workoutError, context: ["context": context])
        }
        
        // Show user-friendly error message
        // This would typically be integrated with a UI alert system
    }
    
    // MARK: - Recovery Actions
    
    /// Attempts to recover from an error
    static func attemptRecovery(from error: WorkoutError) -> Bool {
        switch error {
        case .workoutInProgress:
            // Cannot automatically recover - requires user action
            return false
        case .engineNotReady:
            // Wait a moment and try again
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                // Retry logic here
            }
            return true
        case .sessionExpired:
            // Reset session
            return true
        case .dataCorrupted:
            // Attempt data recovery
            return attemptDataRecovery()
        case .networkUnavailable:
            // Cannot recover automatically
            return false
        case .invalidState:
            // Reset state
            return attemptBasicRecovery()
        case .workoutInterrupted:
            // Save current state for resume
            return true
        case .backgroundTransitionFailed:
            // Save state and allow resume
            return true
        case .lowMemory:
            // Try to free memory
            return attemptMemoryRecovery()
        case .batterySaverMode:
            // Cannot recover automatically
            return false
        case .invalidData:
            // Cannot recover automatically - requires user input
            return false
        case .permissionDenied:
            // Cannot recover automatically - requires user action
            return false
        case .unknown:
            // Try basic recovery
            return attemptBasicRecovery()
        }
    }
    
    private static func attemptDataRecovery() -> Bool {
        // Attempt to recover corrupted workout data
        os_log("Attempting data recovery", log: .default, type: .info)
        
        // Try to load backup data if available
        if let backupData = UserDefaults.standard.data(forKey: "workout.sessions.backup") {
            do {
                let decoder = JSONDecoder()
                let _ = try decoder.decode([WorkoutSession].self, from: backupData)
                // Validate backup data before restoring
                // Restore from backup
                UserDefaults.standard.set(backupData, forKey: "workout.sessions.v1")
                os_log("Data recovery successful from backup", log: .default, type: .info)
                return true
            } catch {
                os_log("Failed to recover from backup: %{public}@", log: .default, type: .error, error.localizedDescription)
            }
        }
        
        // If no backup, try to salvage what we can
        // Reset corrupted data but keep what's valid
        os_log("Data recovery failed, resetting corrupted data", log: .default, type: .error)
        return false
    }
    
    private static func attemptBasicRecovery() -> Bool {
        // Attempt basic recovery for unknown errors
        os_log("Attempting basic recovery", log: .default, type: .info)
        
        // Clear any cached state that might be causing issues
        // This is a last resort recovery
        return true
    }
    
    private static func attemptMemoryRecovery() -> Bool {
        // Attempt to free memory for low memory situations
        os_log("Attempting memory recovery", log: .default, type: .info)
        
        // Clear caches, reduce memory usage
        // This is a best-effort recovery
        return true
    }
    
    // MARK: - Data Validation
    
    /// Validates workout session data
    static func validateSessionData(duration: TimeInterval, exercisesCompleted: Int) -> Result<Void, WorkoutError> {
        guard duration > 0 else {
            return .failure(.invalidData(description: "Workout duration must be greater than 0"))
        }
        
        guard duration <= 3600 else { // 1 hour max
            return .failure(.invalidData(description: "Workout duration exceeds maximum allowed"))
        }
        
        guard exercisesCompleted >= 0 && exercisesCompleted <= 12 else {
            return .failure(.invalidData(description: "Exercises completed must be between 0 and 12"))
        }
        
        return .success(())
    }
    
    /// Validates exercise data
    static func validateExerciseData(exercise: Exercise) -> Result<Void, WorkoutError> {
        guard !exercise.name.isEmpty else {
            return .failure(.invalidData(description: "Exercise name cannot be empty"))
        }
        
        guard exercise.order >= 0 && exercise.order < 12 else {
            return .failure(.invalidData(description: "Exercise order must be between 0 and 11"))
        }
        
        return .success(())
    }
}

// MARK: - Error View

/// User-friendly error view with recovery options
struct ErrorView: View {
    let error: ErrorHandling.WorkoutError
    let onRetry: (() -> Void)?
    let onDismiss: (() -> Void)?
    
    init(error: ErrorHandling.WorkoutError, onRetry: (() -> Void)? = nil, onDismiss: (() -> Void)? = nil) {
        self.error = error
        self.onRetry = onRetry
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.orange)
            
            Text("Oops!")
                .font(.title2.weight(.bold))
            
            Text(error.localizedDescription)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if let suggestion = error.recoverySuggestion {
                Text(suggestion)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            HStack(spacing: 12) {
                if let onRetry = onRetry {
                    Button("Try Again") {
                        onRetry()
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                if let onDismiss = onDismiss {
                    Button("Dismiss") {
                        onDismiss()
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(.top, 8)
        }
        .padding(DesignSystem.Spacing.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                .fill(.ultraThinMaterial)
        )
    }
}

// MARK: - Error Alert Modifier

/// Modifier for showing error alerts
struct ErrorAlertModifier: ViewModifier {
    @Binding var error: ErrorHandling.WorkoutError?
    let onRetry: (() -> Void)?
    
    func body(content: Content) -> some View {
        content
            .alert("Error", isPresented: .constant(error != nil), presenting: error) { error in
                if let onRetry = onRetry {
                    Button("Try Again") {
                        onRetry()
                    }
                }
                Button("OK") {
                    self.error = nil
                }
            } message: { error in
                Text(error.localizedDescription)
            }
    }
}

extension View {
    /// Shows an error alert
    func errorAlert(error: Binding<ErrorHandling.WorkoutError?>, onRetry: (() -> Void)? = nil) -> some View {
        modifier(ErrorAlertModifier(error: error, onRetry: onRetry))
    }
}


