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
                return "A focus session is already in progress. Please complete or stop the current session before starting a new one."
            case .engineNotReady:
                return "The timer engine is not ready. Please try again in a moment."
            case .sessionExpired:
                return "Your focus session has expired. Please start a new focus session."
            case .dataCorrupted:
                return "Your focus session data appears to be corrupted. The app will attempt to recover."
            case .networkUnavailable:
                return "Network connection is unavailable. Some features may not work."
            case .invalidState:
                return "The app is in an invalid state. Please restart the app."
            case .workoutInterrupted:
                return "Your focus session was interrupted. You can resume from where you left off."
            case .backgroundTransitionFailed:
                return "Failed to handle background transition. Your focus session progress has been saved."
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
                return "Stop the current focus session or wait for it to complete."
            case .engineNotReady:
                return "Wait a moment and try again."
            case .sessionExpired:
                return "Start a new focus session."
            case .dataCorrupted:
                return "The app will attempt to recover your data automatically."
            case .networkUnavailable:
                return "Check your network connection and try again."
            case .invalidState:
                return "Try restarting the app to reset the state."
            case .workoutInterrupted:
                return "You can resume your focus session from the main screen."
            case .backgroundTransitionFailed:
                return "Your focus session progress has been saved. You can continue from where you left off."
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
    /// Posts notification for UI to handle and logs for debugging
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
            
            // Post notification for UI to handle
            NotificationCenter.default.post(
                name: NSNotification.Name(AppConstants.NotificationNames.errorOccurred),
                object: nil,
                userInfo: [
                    "error": workoutError,
                    "context": context
                ]
            )
        }
    }
    
    // MARK: - Recovery Actions
    
    /// Attempts to recover from an error
    static func attemptRecovery(from error: WorkoutError) -> Bool {
        switch error {
        case .workoutInProgress:
            // Cannot automatically recover - requires user action
            return false
        case .engineNotReady:
            // Retry after a short delay with exponential backoff
            // Post notification for UI to handle retry
            NotificationCenter.default.post(
                name: NSNotification.Name(AppConstants.NotificationNames.errorOccurred),
                object: nil,
                userInfo: [
                    "error": error,
                    "action": "retry",
                    "retryDelay": 1.0, // 1 second initial delay
                    "maxRetries": 3
                ]
            )
            return true
        case .sessionExpired:
            // Reset session - this would be handled by PomodoroEngine
            // Post notification to reset session
            NotificationCenter.default.post(
                name: NSNotification.Name(AppConstants.NotificationNames.errorOccurred),
                object: nil,
                userInfo: ["error": error, "action": "resetSession"]
            )
            return true
        case .dataCorrupted:
            // Attempt data recovery with actual implementation
            let recoveryResult = attemptDataRecovery()
            if recoveryResult {
                // Notify that data was recovered
                NotificationCenter.default.post(
                    name: NSNotification.Name(AppConstants.NotificationNames.errorOccurred),
                    object: nil,
                    userInfo: ["error": error, "action": "dataRecovered", "recovered": true]
                )
            }
            return recoveryResult
        case .networkUnavailable:
            // Cannot recover automatically
            return false
        case .invalidState:
            // Reset state
            return attemptBasicRecovery()
        case .workoutInterrupted:
            // Save current state for resume - this is handled by PomodoroEngine
            // Recovery is successful if state can be saved
            return true
        case .backgroundTransitionFailed:
            // Save state and allow resume - this is handled by PomodoroEngine
            // Recovery is successful if state can be saved
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
        if let backupData = UserDefaults.standard.data(forKey: AppConstants.UserDefaultsKeys.focusSessionsBackup) {
            do {
                let decoder = JSONDecoder()
                let _ = try decoder.decode([FocusSession].self, from: backupData)
                // Validate backup data before restoring
                // Restore from backup
                UserDefaults.standard.set(backupData, forKey: AppConstants.UserDefaultsKeys.focusSessions)
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
        // Clear URL cache
        URLCache.shared.removeAllCachedResponses()
        
        // Clear image cache if available
        // Note: In a real app, you might have a custom image cache to clear
        
        // Attempt to recover focus state (FocusStore handles state recovery now)
        // Note: FocusStore automatically handles state recovery, no need for legacy workout state check
        // Check if FocusStore has any sessions to recover from
        os_log("Attempting basic recovery - FocusStore handles state recovery automatically", log: .default, type: .info)
        
        return true
    }
    
    private static func attemptMemoryRecovery() -> Bool {
        // Attempt to free memory for low memory situations
        os_log("Attempting memory recovery", log: .default, type: .info)
        
        // Clear caches, reduce memory usage
        URLCache.shared.removeAllCachedResponses()
        
        // Trigger performance optimizer to clear non-essential caches
        PerformanceOptimizer.clearNonEssentialCaches()
        
        // Attempt to optimize memory usage
        PerformanceOptimizer.optimizeMemoryUsage()
        
        // Check if memory recovery was successful
        let memoryInfo = PerformanceOptimizer.getMemoryInfo()
        if memoryInfo.usageRatio < AppConstants.PerformanceConstants.memoryUsageWarningThreshold {
            os_log("Memory recovery successful", log: .default, type: .info)
            return true
        } else {
            os_log("Memory recovery partially successful - usage ratio: %{public}@", log: .default, type: .info, String(memoryInfo.usageRatio))
            return false
        }
    }
    
    // MARK: - Data Validation
    
    /// Validates focus session data
    /// Uses consistent validation rules to prevent data inconsistencies
    static func validateSessionData(duration: TimeInterval, exercisesCompleted: Int) -> Result<Void, WorkoutError> {
        // Use focus session validation constants
        // Duration must be > 0 to prevent invalid sessions
        guard duration > AppConstants.ValidationConstants.minFocusDuration else {
            return .failure(.invalidData(description: "Focus session duration must be greater than 0"))
        }
        
        guard duration <= AppConstants.ValidationConstants.maxFocusDuration else {
            return .failure(.invalidData(description: "Focus session duration exceeds maximum allowed (\(Int(AppConstants.ValidationConstants.maxFocusDuration)) seconds)"))
        }
        
        // Note: exercisesCompleted parameter kept for backward compatibility but not validated for Pomodoro timer
        // Focus sessions don't have exercises, so this parameter is ignored
        // TODO: Remove exercisesCompleted parameter in future version
        
        return .success(())
    }
    
    /// Validates focus session data (Pomodoro timer specific)
    /// Uses consistent validation rules for focus sessions
    static func validateFocusSessionData(duration: TimeInterval) -> Result<Void, WorkoutError> {
        // Use focus session validation constants
        // Duration must be > 0 to prevent invalid sessions
        guard duration > AppConstants.ValidationConstants.minFocusDuration else {
            return .failure(.invalidData(description: "Focus session duration must be greater than 0"))
        }
        
        guard duration <= AppConstants.ValidationConstants.maxFocusDuration else {
            return .failure(.invalidData(description: "Focus session duration exceeds maximum allowed (\(Int(AppConstants.ValidationConstants.maxFocusDuration)) seconds)"))
        }
        
        return .success(())
    }
    
    /// Validates Pomodoro preset data
    static func validatePresetData(preset: PomodoroPreset) -> Result<Void, WorkoutError> {
        guard !preset.displayName.isEmpty else {
            return .failure(.invalidData(description: "Preset name cannot be empty"))
        }
        
        guard preset.focusDuration > 0 else {
            return .failure(.invalidData(description: "Focus duration must be greater than 0"))
        }
        
        guard preset.focusDuration <= 3600 else {
            return .failure(.invalidData(description: "Focus duration cannot exceed 60 minutes"))
        }
        
        return .success(())
    }
    
    // MARK: - Retry Helper
    
    /// Retry helper with exponential backoff for async operations
    /// - Parameters:
    ///   - maxAttempts: Maximum number of retry attempts (default: 3)
    ///   - initialDelay: Initial delay in seconds before first retry (default: 1.0)
    ///   - backoffMultiplier: Multiplier for exponential backoff (default: 2.0)
    ///   - operation: The async operation to retry
    /// - Returns: Result of the operation or failure after all retries
    static func retryWithBackoff<T>(
        maxAttempts: Int = 3,
        initialDelay: TimeInterval = 1.0,
        backoffMultiplier: Double = 2.0,
        operation: @escaping () async throws -> T
    ) async -> Result<T, Error> {
        var lastError: Error?
        var delay = initialDelay
        
        for attempt in 1...maxAttempts {
            do {
                let result = try await operation()
                return .success(result)
            } catch {
                lastError = error
                os_log("Retry attempt %d failed: %{public}@", log: .default, type: .error, attempt, error.localizedDescription)
                
                // Don't wait after the last attempt
                if attempt < maxAttempts {
                    try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    delay *= backoffMultiplier
                }
            }
        }
        
        return .failure(lastError ?? NSError(domain: "ErrorHandling", code: -1, userInfo: [NSLocalizedDescriptionKey: "Retry failed after \(maxAttempts) attempts"]))
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
        VStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: DesignSystem.IconSize.xxlarge, weight: .bold))
                .foregroundStyle(.orange)
            
            Text("Oops!")
                .font(Theme.title2)
            
            Text(error.localizedDescription)
                .font(Theme.body)
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
            
            HStack(spacing: DesignSystem.Spacing.md) {
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
            .padding(.top, DesignSystem.Spacing.sm)
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

// MARK: - Global Error Handler

/// Global error handler that listens for errors and displays them
@MainActor
class GlobalErrorHandler: ObservableObject {
    static let shared = GlobalErrorHandler()
    
    @Published var currentError: ErrorHandling.WorkoutError?
    @Published var showError: Bool = false
    
    private var observers: [NSObjectProtocol] = []
    
    private init() {
        setupErrorObserver()
    }
    
    private func setupErrorObserver() {
        let observer = NotificationCenter.default.addObserver(
            forName: NSNotification.Name(AppConstants.NotificationNames.errorOccurred),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self,
                  let userInfo = notification.userInfo,
                  let error = userInfo["error"] as? ErrorHandling.WorkoutError else {
                return
            }
            
            // Ensure MainActor isolation for property mutations
            Task { @MainActor in
                self.currentError = error
                self.showError = true
                
                // Haptic feedback for error
                Haptics.error()
            }
        }
        
        observers.append(observer)
    }
    
    deinit {
        observers.forEach { NotificationCenter.default.removeObserver($0) }
    }
    
    func dismissError() {
        showError = false
        currentError = nil
    }
}

/// View modifier that automatically handles errors globally
struct GlobalErrorHandlerModifier: ViewModifier {
    @StateObject private var errorHandler = GlobalErrorHandler.shared
    
    func body(content: Content) -> some View {
        content
            .alert("Error", isPresented: $errorHandler.showError, presenting: errorHandler.currentError) { error in
                Button("OK") {
                    errorHandler.dismissError()
                }
                
                // Add retry button if recovery is possible
                if ErrorHandling.attemptRecovery(from: error) {
                    Button("Try Again") {
                        errorHandler.dismissError()
                        // Retry logic can be added here
                    }
                }
            } message: { error in
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(error.localizedDescription)
                    
                    if let suggestion = error.recoverySuggestion {
                        Text(suggestion)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
    }
}

extension View {
    /// Adds global error handling to the view hierarchy
    func globalErrorHandler() -> some View {
        modifier(GlobalErrorHandlerModifier())
    }
}


