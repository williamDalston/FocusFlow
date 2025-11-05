import Foundation
import os.log

/// Agent 9: Crash reporting utility for production error tracking
/// 
/// This provides a lightweight crash reporting mechanism that can be extended
/// to integrate with services like Firebase Crashlytics, Sentry, or custom endpoints.
/// 
/// Usage:
/// ```swift
/// CrashReporter.logError(error, context: ["action": "workout_start"])
/// CrashReporter.logMessage("User completed workout", level: .info)
/// ```
@MainActor
final class CrashReporter {
    // MARK: - Singleton
    
    static let shared = CrashReporter()
    
    private init() {}
    
    // MARK: - Log Levels
    
    enum LogLevel: String, CaseIterable {
        case debug = "DEBUG"
        case info = "INFO"
        case warning = "WARNING"
        case error = "ERROR"
        case critical = "CRITICAL"
    }
    
    // MARK: - Configuration
    
    /// Whether crash reporting is enabled (default: true in production)
    var isEnabled: Bool = true
    
    /// Whether to log to console (useful for debugging)
    var logToConsole: Bool = true
    
    /// Custom crash reporting service integration point
    var customCrashHandler: ((Error, [String: Any]?) -> Void)?
    
    // MARK: - Error Logging
    
    /// Logs an error with optional context
    /// - Parameters:
    ///   - error: The error to log
    ///   - context: Additional context information
    ///   - file: Source file name (automatically captured)
    ///   - function: Function name (automatically captured)
    ///   - line: Line number (automatically captured)
    func logError(
        _ error: Error,
        context: [String: Any]? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        guard isEnabled else { return }
        
        let errorInfo = [
            "error": error.localizedDescription,
            "error_type": String(describing: type(of: error)),
            "file": (file as NSString).lastPathComponent,
            "function": function,
            "line": line,
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "context": context ?? [:]
        ] as [String: Any]
        
        // Log to console if enabled
        if logToConsole {
            os_log("❌ Error: %{public}@", log: .default, type: .error, error.localizedDescription)
            if let context = context {
                os_log("Context: %{public}@", log: .default, type: .error, String(describing: context))
            }
        }
        
        // Call custom handler if set (e.g., Firebase Crashlytics)
        customCrashHandler?(error, errorInfo)
        
        // Agent 2: Integration point for crash reporting service
        // To integrate with Firebase Crashlytics:
        // 1. Add Firebase SDK to project
        // 2. Import FirebaseCrashlytics
        // 3. Uncomment and configure:
        //    Crashlytics.crashlytics().record(error: error)
        //    if let context = context {
        //        for (key, value) in context {
        //            Crashlytics.crashlytics().setCustomValue(value, forKey: key)
        //        }
        //    }
        //
        // To integrate with Sentry:
        // 1. Add Sentry SDK to project
        // 2. Import Sentry
        // 3. Uncomment and configure:
        //    SentrySDK.capture(error: error) { scope in
        //        if let context = context {
        //            for (key, value) in context {
        //                scope.setContext(value: value, key: key)
        //            }
        //        }
        //    }
    }
    
    /// Logs a message with a specific level
    /// - Parameters:
    ///   - message: The message to log
    ///   - level: The log level
    ///   - context: Additional context information
    func logMessage(
        _ message: String,
        level: LogLevel = .info,
        context: [String: Any]? = nil
    ) {
        guard isEnabled else { return }
        
        let logInfo = [
            "message": message,
            "level": level.rawValue,
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "context": context ?? [:]
        ] as [String: Any]
        
        // Log to console if enabled
        if logToConsole {
            let osLogType: OSLogType = {
                switch level {
                case .debug: return .debug
                case .info: return .info
                case .warning: return .default
                case .error: return .error
                case .critical: return .fault
                }
            }()
            
            os_log("%{public}@: %{public}@", log: .default, type: osLogType, level.rawValue, message)
        }
        
        // Call custom handler if set
        if level == .error || level == .critical {
            let error = NSError(
                domain: "CrashReporter",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: message]
            )
            customCrashHandler?(error, logInfo)
        }
    }
    
    // MARK: - Non-Fatal Error Reporting
    
    /// Records a non-fatal error (doesn't crash the app)
    /// - Parameters:
    ///   - error: The error to record
    ///   - context: Additional context
    func recordNonFatalError(_ error: Error, context: [String: Any]? = nil) {
        logError(error, context: context)
        
        // Agent 2: Integration point for non-fatal error reporting
        // See logError method for integration examples with Firebase Crashlytics or Sentry
    }
    
    // MARK: - User Context
    
    /// Sets user identifier for crash reports
    /// - Parameter userId: User identifier (optional for privacy)
    func setUserIdentifier(_ userId: String?) {
        // Agent 2: Integration point for user identification
        // Firebase Crashlytics: Crashlytics.crashlytics().setUserID(userId)
        // Sentry: SentrySDK.setUser(User(userId: userId))
    }
    
    /// Sets custom user properties
    /// - Parameter properties: Dictionary of user properties
    func setUserProperties(_ properties: [String: String]) {
        // Agent 2: Integration point for user properties
        // Firebase Crashlytics:
        //   for (key, value) in properties {
        //       Crashlytics.crashlytics().setCustomValue(value, forKey: key)
        //   }
        // Sentry:
        //   SentrySDK.setUser(User(data: properties))
    }
    
    // MARK: - Breadcrumbs
    
    /// Adds a breadcrumb for debugging (tracks user actions leading to errors)
    /// - Parameter message: The breadcrumb message
    func addBreadcrumb(_ message: String) {
        guard isEnabled else { return }
        
        if logToConsole {
            os_log("📍 Breadcrumb: %{public}@", log: .default, type: .debug, message)
        }
        
        // Agent 2: Integration point for breadcrumbs
        // Sentry:
        //   let breadcrumb = Breadcrumb(level: .info, category: "user_action")
        //   breadcrumb.message = message
        //   SentrySDK.addBreadcrumb(breadcrumb)
        // Firebase Crashlytics: Breadcrumbs are automatically captured
    }
}

// MARK: - Convenience Extensions

extension CrashReporter {
    /// Convenience method for logging errors
    static func logError(
        _ error: Error,
        context: [String: Any]? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        Task { @MainActor in
            shared.logError(error, context: context, file: file, function: function, line: line)
        }
    }
    
    /// Convenience method for logging messages
    static func logMessage(
        _ message: String,
        level: LogLevel = .info,
        context: [String: Any]? = nil
    ) {
        Task { @MainActor in
            shared.logMessage(message, level: level, context: context)
        }
    }
    
    /// Convenience method for recording non-fatal errors
    static func recordNonFatalError(_ error: Error, context: [String: Any]? = nil) {
        Task { @MainActor in
            shared.recordNonFatalError(error, context: context)
        }
    }
    
    /// Convenience method for adding breadcrumbs
    static func addBreadcrumb(_ message: String) {
        Task { @MainActor in
            shared.addBreadcrumb(message)
        }
    }
}

