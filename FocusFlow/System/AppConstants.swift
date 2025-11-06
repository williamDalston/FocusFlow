import Foundation

/// App-wide constants for UserDefaults keys, notification names, and other magic strings
enum AppConstants {
    
    // MARK: - UserDefaults Keys
    
    enum UserDefaultsKeys {
        // MARK: - Deprecated: Workout Store (Agent 14: Will be removed after migration)
        // These constants are kept for backward compatibility during migration
        // TODO: Remove after all agents migrate to Focus models
        @available(*, deprecated, message: "Use FocusStore instead. Will be removed after migration.")
        static let workoutSessions = "workout.sessions.v1"
        @available(*, deprecated, message: "Use FocusStore instead. Will be removed after migration.")
        static let workoutSessionsBackup = "workout.sessions.backup"
        @available(*, deprecated, message: "Use FocusStore instead. Will be removed after migration.")
        static let workoutStreak = "workout.streak.v1"
        @available(*, deprecated, message: "Use FocusStore instead. Will be removed after migration.")
        static let workoutLastDay = "workout.lastDay.v1"
        @available(*, deprecated, message: "Use FocusStore instead. Will be removed after migration.")
        static let workoutTotalWorkouts = "workout.totalWorkouts.v1"
        @available(*, deprecated, message: "Use FocusStore instead. Will be removed after migration.")
        static let workoutTotalMinutes = "workout.totalMinutes.v1"
        @available(*, deprecated, message: "Use FocusStore instead. Will be removed after migration.")
        static let workoutPersonalBest = "workout.personalBest.v1"
        @available(*, deprecated, message: "Use FocusStore instead. Will be removed after migration.")
        static let workoutPersonalBestExercises = "workout.personalBest.v1.exercises"
        
        // Workout State Recovery
        @available(*, deprecated, message: "Use FocusStore instead. Will be removed after migration.")
        static let workoutStateRecovery = "workout.state.recovery"
        
        // Focus Store (Agent 2: Pomodoro Timer)
        static let focusSessions = "focus.sessions.v1"
        static let focusSessionsBackup = "focus.sessions.backup"
        static let focusStreak = "focus.streak.v1"
        static let focusLastDay = "focus.lastDay.v1"
        static let focusTotalSessions = "focus.totalSessions.v1"
        static let focusTotalMinutes = "focus.totalMinutes.v1"
        static let focusCurrentCycle = "focus.currentCycle.v1"
        
        // Sound Settings
        static let soundEnabled = "workout.soundEnabled"
        static let vibrationEnabled = "workout.vibrationEnabled"
        
        // App Tracking
        static let hasRequestedATT = "hasRequestedATT"
        static let reminderScheduled = "reminderScheduled"
    }
    
    // MARK: - Notification Names
    
    enum NotificationNames {
        // App Lifecycle
        static let appDidBecomeActive = "appDidBecomeActive"
        static let appDidEnterBackground = "appDidEnterBackground"
        
        // MARK: - Deprecated: Workout Events (Agent 14: Will be removed after migration)
        @available(*, deprecated, message: "Use focusCompleted instead. Will be removed after migration.")
        static let workoutCompleted = "workoutCompleted"
        @available(*, deprecated, message: "Use startFocusFromShortcut instead. Will be removed after migration.")
        static let startWorkoutFromShortcut = "StartWorkoutFromShortcut"
        
        // Focus Events (Agent 2: Pomodoro Timer)
        static let focusCompleted = "focusCompleted"
        static let startFocusFromShortcut = "StartFocusFromShortcut"
        
        // Error Handling
        static let errorOccurred = "ErrorOccurred"
        
        // System Events
        static let lowMemoryWarning = "lowMemoryWarning"
        static let batterySaverModeEnabled = "batterySaverModeEnabled"
    }
    
    // MARK: - Timing Constants
    
    enum TimingConstants {
        // Delays (in nanoseconds)
        static let deferredOperationDelay: UInt64 = 300_000_000 // 0.3 seconds
        static let watchConnectivityDelay: UInt64 = 300_000_000 // 0.3 seconds
        static let heavyOperationDelay: UInt64 = 500_000_000 // 0.5 seconds
        
        // MARK: - Deprecated: Workout Durations (Agent 14: Will be removed after migration)
        @available(*, deprecated, message: "Use Pomodoro timer constants instead. Will be removed after migration.")
        static let defaultWorkoutDuration: TimeInterval = 420.0 // 7 minutes
        @available(*, deprecated, message: "Use Pomodoro timer constants instead. Will be removed after migration.")
        static let defaultExerciseDuration: TimeInterval = 30.0
        @available(*, deprecated, message: "Use Pomodoro timer constants instead. Will be removed after migration.")
        static let defaultRestDuration: TimeInterval = 10.0
        @available(*, deprecated, message: "Use Pomodoro timer constants instead. Will be removed after migration.")
        static let defaultPrepDuration: TimeInterval = 10.0
        
        // Pomodoro Timer Constants
        static let defaultFocusDuration: TimeInterval = 1500.0 // 25 minutes
        static let defaultShortBreakDuration: TimeInterval = 300.0 // 5 minutes
        static let defaultLongBreakDuration: TimeInterval = 900.0 // 15 minutes
        static let defaultPomodoroCycleLength: Int = 4 // 4 sessions = long break
        
        // Launch Time
        static let targetLaunchTime: TimeInterval = 1.5
        static let launchTimeCheckDelay: TimeInterval = 0.1
        
        // Memory Recovery
        static let memoryRecoveryCheckInterval: TimeInterval = 0.01
        static let maxMemoryRecoveryAttempts = 100
    }
    
    // MARK: - Data Validation Constants
    
    enum ValidationConstants {
        // MARK: - Deprecated: Workout Validation (Agent 14: Will be removed after migration)
        @available(*, deprecated, message: "Use Focus session validation instead. Will be removed after migration.")
        static let minWorkoutDuration: TimeInterval = 0.0
        @available(*, deprecated, message: "Use Focus session validation instead. Will be removed after migration.")
        static let maxWorkoutDuration: TimeInterval = 3600.0 // 1 hour
        @available(*, deprecated, message: "Not applicable for Pomodoro timer. Will be removed after migration.")
        static let minExercisesCompleted = 0
        @available(*, deprecated, message: "Not applicable for Pomodoro timer. Will be removed after migration.")
        static let maxExercisesCompleted = 12
        
        // MARK: - Focus Session Validation (Agent 20: Pomodoro Timer)
        static let minFocusDuration: TimeInterval = 0.0
        static let maxFocusDuration: TimeInterval = 3600.0 // 1 hour (60 minutes max)
        
        // Exercise Validation (Deprecated)
        @available(*, deprecated, message: "Not applicable for Pomodoro timer. Will be removed after migration.")
        static let minExerciseOrder = 0
        @available(*, deprecated, message: "Not applicable for Pomodoro timer. Will be removed after migration.")
        static let maxExerciseOrder = 11
    }
    
    // MARK: - Performance Constants
    
    enum PerformanceConstants {
        // Memory Thresholds (in MB)
        static let lowMemoryThresholdMB: Int = 4_000 // 4GB RAM
        static let memoryUsageWarningThreshold: Double = 0.85
        static let memoryUsageCriticalThreshold: Double = 0.90
        
        // Battery Thresholds
        static let lowBatteryThreshold: Float = 0.2 // 20%
        
        // Slow Operation Thresholds
        static let slowOperationThreshold: TimeInterval = 0.1
        static let highMemoryUsageThreshold: Int64 = 10_000_000 // 10MB
    }
    
    // MARK: - URL Schemes
    
    enum URLSchemes {
        // MARK: - Deprecated: Workout URL Scheme (Agent 14: Will be removed after migration)
        @available(*, deprecated, message: "Use pomodoroScheme instead. Will be removed after migration.")
        static let workoutScheme = "sevenminuteworkout"
        @available(*, deprecated, message: "Use startFocusHost instead. Will be removed after migration.")
        static let startHost = "start"
        
        // Agent 9: Focus/Pomodoro Timer URL Scheme (Primary)
        static let pomodoroScheme = "pomodorotimer"
        static let startFocusHost = "start"
        static let statsHost = "stats"
        static let historyHost = "history"
    }
    
    // MARK: - Activity Types
    
    enum ActivityTypes {
        // MARK: - Deprecated: Workout Activity Type (Agent 14: Will be removed after migration)
        @available(*, deprecated, message: "Use startFocus instead. Will be removed after migration.")
        static let startWorkout = "com.williamalston.FocusFlow.startWorkout"
        
        // Agent 9: Focus/Pomodoro Timer Activity Types (Primary)
        static let startFocus = "com.williamalston.FocusFlow.startFocus"
        static let startDeepWork = "com.williamalston.FocusFlow.startDeepWork"
        static let startQuickFocus = "com.williamalston.FocusFlow.startQuickFocus"
        static let showFocusStats = "com.williamalston.FocusFlow.showFocusStats"
    }
}


