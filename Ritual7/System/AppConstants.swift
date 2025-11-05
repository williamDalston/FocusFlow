import Foundation

/// App-wide constants for UserDefaults keys, notification names, and other magic strings
enum AppConstants {
    
    // MARK: - UserDefaults Keys
    
    enum UserDefaultsKeys {
        // Workout Store
        static let workoutSessions = "workout.sessions.v1"
        static let workoutSessionsBackup = "workout.sessions.backup"
        static let workoutStreak = "workout.streak.v1"
        static let workoutLastDay = "workout.lastDay.v1"
        static let workoutTotalWorkouts = "workout.totalWorkouts.v1"
        static let workoutTotalMinutes = "workout.totalMinutes.v1"
        static let workoutPersonalBest = "workout.personalBest.v1"
        static let workoutPersonalBestExercises = "workout.personalBest.v1.exercises"
        
        // Workout State Recovery
        static let workoutStateRecovery = "workout.state.recovery"
        
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
        
        // Workout Events
        static let workoutCompleted = "workoutCompleted"
        static let startWorkoutFromShortcut = "StartWorkoutFromShortcut"
        
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
        
        // Durations (in seconds)
        static let defaultWorkoutDuration: TimeInterval = 420.0 // 7 minutes
        static let defaultExerciseDuration: TimeInterval = 30.0
        static let defaultRestDuration: TimeInterval = 10.0
        static let defaultPrepDuration: TimeInterval = 10.0
        
        // Launch Time
        static let targetLaunchTime: TimeInterval = 1.5
        static let launchTimeCheckDelay: TimeInterval = 0.1
        
        // Memory Recovery
        static let memoryRecoveryCheckInterval: TimeInterval = 0.01
        static let maxMemoryRecoveryAttempts = 100
    }
    
    // MARK: - Data Validation Constants
    
    enum ValidationConstants {
        // Session Validation
        static let minWorkoutDuration: TimeInterval = 0.0
        static let maxWorkoutDuration: TimeInterval = 3600.0 // 1 hour
        static let minExercisesCompleted = 0
        static let maxExercisesCompleted = 12
        
        // Exercise Validation
        static let minExerciseOrder = 0
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
        static let workoutScheme = "sevenminuteworkout"
        static let startHost = "start"
    }
    
    // MARK: - Activity Types
    
    enum ActivityTypes {
        static let startWorkout = "com.williamalston.Ritual7.startWorkout"
    }
}

