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
        CrashReporter.logError(workoutError, context: ["context": context])
        
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
        case .unknown:
            // Try basic recovery
            return attemptBasicRecovery()
        }
    }
    
    private static func attemptDataRecovery() -> Bool {
        // Implement data recovery logic
        return true
    }
    
    private static func attemptBasicRecovery() -> Bool {
        // Implement basic recovery logic
        return true
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
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
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


