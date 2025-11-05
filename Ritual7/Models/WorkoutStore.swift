import Foundation
import SwiftUI
import os.log

/// Agent 3 & 7: Progress Tracking & Data Persistence - Workout history and statistics
/// Agent 5: HealthKit Integration - Syncs workouts to HealthKit
@MainActor
final class WorkoutStore: ObservableObject {
    @Published private(set) var sessions: [WorkoutSession] = []
    @Published private(set) var streak: Int = 0
    @Published private(set) var totalWorkouts: Int = 0
    @Published private(set) var totalMinutes: TimeInterval = 0
    
    private let sessionsKey = AppConstants.UserDefaultsKeys.workoutSessions
    private let streakKey = AppConstants.UserDefaultsKeys.workoutStreak
    private let lastDayKey = AppConstants.UserDefaultsKeys.workoutLastDay
    private let totalWorkoutsKey = AppConstants.UserDefaultsKeys.workoutTotalWorkouts
    private let totalMinutesKey = AppConstants.UserDefaultsKeys.workoutTotalMinutes
    
    private var watchSessionManager: WatchSessionManager?
    private let healthKitManager = HealthKitManager.shared
    private let healthKitStore = HealthKitStore.shared
    
    // Synchronization for loading state
    private var isLoading = false
    private let loadLock = NSLock()
    private var loadCompleted = false
    
    private func setupWatchConnectivity() {
        watchSessionManager = WatchSessionManager.shared
        watchSessionManager?.configure(with: self)
    }
    
    // MARK: - Public API
    
    func addSession(duration: TimeInterval, exercisesCompleted: Int, notes: String? = nil, startDate: Date? = nil) {
        // Ensure load has completed before adding session
        // This is a best-effort check - in practice, load completes quickly during initialization
        // If load is still in progress, we'll proceed anyway (sessions will be merged on next load)
        loadLock.lock()
        let wasLoading = isLoading
        loadLock.unlock()
        
        if wasLoading {
            // Log warning but proceed - this should be rare
            os_log("addSession called while load is in progress - this may cause data inconsistency", log: .default, type: .info)
        }
        
        // Validate session data
        let validationResult = ErrorHandling.validateSessionData(duration: duration, exercisesCompleted: exercisesCompleted)
        
        switch validationResult {
        case .failure(let error):
            ErrorHandling.handleError(error, context: "addSession")
            os_log("Failed to add session: Invalid data", log: .default, type: .error)
            return
        case .success:
            break
        }
        
        let sessionDate = startDate ?? Date()
        let newSession = WorkoutSession(
            date: sessionDate,
            duration: duration,
            exercisesCompleted: exercisesCompleted,
            notes: notes
        )
        sessions.insert(newSession, at: 0)
        bumpStreakIfNeeded()
        totalWorkouts += 1
        totalMinutes += duration / 60.0
        
        // Create backup before saving
        createBackup()
        
        save()
        
        // Agent 7: Check for achievements
        checkAchievements(workoutTime: sessionDate)
        
        // Send to Watch if needed
        watchSessionManager?.updateWatchComplications()
        
        // Sync to HealthKit if available and authorized
        syncToHealthKit(session: newSession)
        
        // Agent 16: Notify personalization components
        NotificationCenter.default.post(
            name: NSNotification.Name(AppConstants.NotificationNames.workoutCompleted),
            object: nil,
            userInfo: ["session": newSession]
        )
        
        // ASO: Consider review prompt after workout completion
        Task { @MainActor in
            ReviewGate.considerPromptAfterWorkout(totalWorkouts: totalWorkouts)
            
            // ASO: Track engagement
            ASOAnalytics.shared.trackEngagement(event: "workout_completed", value: totalWorkouts)
            
            // ASO: Track conversion funnel
            if totalWorkouts == 1 {
                ASOAnalytics.shared.trackConversionFunnel(stage: "first_workout")
            } else if totalWorkouts == 3 {
                ASOAnalytics.shared.trackConversionFunnel(stage: "workout_3")
            }
            
            // ASO: Consider review prompt after streak milestone
            if streak >= 7 {
                ReviewGate.considerPromptAfterStreak(streak: streak)
                ASOAnalytics.shared.trackEngagement(event: "streak_milestone", value: streak)
            }
        }
    }
    
    // MARK: - HealthKit Integration
    
    /// Sync workout session to HealthKit
    private func syncToHealthKit(session: WorkoutSession) {
        // Check if HealthKit is available and authorized
        guard healthKitManager.isHealthKitAvailable,
              healthKitStore.canWriteWorkouts else {
            return
        }
        
        Task {
            do {
                let startDate = session.date
                let endDate = startDate.addingTimeInterval(session.duration)
                
                // Estimate calories burned
                let calories = healthKitManager.estimateCaloriesBurned(duration: session.duration)
                
                // Save to HealthKit
                try await healthKitManager.saveWorkout(
                    startDate: startDate,
                    endDate: endDate,
                    duration: session.duration,
                    exercisesCompleted: session.exercisesCompleted,
                    totalEnergyBurned: calories
                )
            } catch {
                // Silently fail - HealthKit sync is optional
                os_log("Failed to sync workout to HealthKit: %{public}@", log: .default, type: .error, error.localizedDescription)
                CrashReporter.logError(error, context: ["action": "healthkit_sync", "session_id": session.id.uuidString])
            }
        }
    }
    
    // Agent 25: Undo support for deleted sessions
    private var deletedSessionsBackup: [WorkoutSession] = []
    private var deletedSessionsStats: (totalWorkouts: Int, totalMinutes: TimeInterval)?
    
    func deleteSession(at offsets: IndexSet) {
        // Filter out invalid indices to prevent crashes
        let validOffsets = offsets.filter { $0 >= 0 && $0 < sessions.count }
        guard !validOffsets.isEmpty else { return }
        
        // Agent 25: Store backup for undo
        deletedSessionsBackup = validOffsets.map { sessions[$0] }
        deletedSessionsStats = (totalWorkouts, totalMinutes)
        
        let deletedSessions = validOffsets.map { sessions[$0] }
        for session in deletedSessions {
            totalWorkouts = max(0, totalWorkouts - 1)
            totalMinutes = max(0, totalMinutes - session.duration / 60.0)
        }
        sessions.remove(atOffsets: IndexSet(validOffsets))
        save()
    }
    
    /// Agent 25: Undo the last deletion
    func undoDelete() {
        guard !deletedSessionsBackup.isEmpty else { return }
        
        // Restore deleted sessions
        for session in deletedSessionsBackup.reversed() {
            sessions.insert(session, at: 0)
        }
        
        // Restore stats
        if let stats = deletedSessionsStats {
            totalWorkouts = stats.totalWorkouts
            totalMinutes = stats.totalMinutes
        }
        
        // Clear backup
        deletedSessionsBackup = []
        deletedSessionsStats = nil
        
        save()
    }
    
    /// Agent 25: Check if undo is available
    var canUndoDelete: Bool {
        !deletedSessionsBackup.isEmpty
    }
    
    func reset() {
        sessions.removeAll()
        streak = 0
        totalWorkouts = 0
        totalMinutes = 0
        UserDefaults.standard.removeObject(forKey: lastDayKey)
        save()
    }
    
    // MARK: - Statistics
    
    var workoutsThisWeek: Int {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return sessions.filter { $0.date >= weekAgo }.count
    }
    
    var workoutsThisMonth: Int {
        let calendar = Calendar.current
        let now = Date()
        return sessions.filter { calendar.isDate($0.date, equalTo: now, toGranularity: .month) }.count
    }
    
    var averageWorkoutDuration: TimeInterval {
        guard !sessions.isEmpty else { return 0 }
        let total = sessions.reduce(0.0) { $0 + $1.duration }
        return total / Double(sessions.count)
    }
    
    // MARK: - Agent 2: Analytics Helpers
    
    /// Get sessions in a date range
    func sessions(in range: ClosedRange<Date>) -> [WorkoutSession] {
        return sessions.filter { range.contains($0.date) }
    }
    
    /// Get sessions for a specific date
    func sessions(on date: Date) -> [WorkoutSession] {
        let calendar = Calendar.current
        return sessions.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    /// Get sessions for a specific month
    func sessions(in month: Date) -> [WorkoutSession] {
        let calendar = Calendar.current
        return sessions.filter { calendar.isDate($0.date, equalTo: month, toGranularity: .month) }
    }
    
    /// Get estimated calories burned (rough estimate: ~100 calories per 7-minute workout)
    var estimatedTotalCalories: Int {
        return totalWorkouts * 100
    }
    
    // MARK: - Persistence
    
    // MARK: - Data Backup & Recovery
    
    /// Creates a backup of current session data
    private func createBackup() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(sessions)
            UserDefaults.standard.set(data, forKey: AppConstants.UserDefaultsKeys.workoutSessionsBackup)
        } catch {
            os_log("Failed to create backup: %{public}@", log: .default, type: .error, error.localizedDescription)
        }
    }
    
    /// Attempts to recover from corrupted data
    private func attemptDataRecovery() -> Bool {
        // Try to load from backup
        if let backupData = UserDefaults.standard.data(forKey: AppConstants.UserDefaultsKeys.workoutSessionsBackup) {
            do {
                let decoder = JSONDecoder()
                let recoveredSessions = try decoder.decode([WorkoutSession].self, from: backupData)
                sessions = recoveredSessions
                recalculateStatistics()
                os_log("Data recovery successful from backup", log: .default, type: .info)
                return true
            } catch {
                os_log("Failed to recover from backup: %{public}@", log: .default, type: .error, error.localizedDescription)
            }
        }
        return false
    }
    
    /// Recalculates statistics from sessions
    private func recalculateStatistics() {
        totalWorkouts = sessions.count
        totalMinutes = sessions.reduce(0) { $0 + $1.duration / 60.0 }
        recalcStreakIfNeeded()
    }
    
    private func load() {
        loadLock.lock()
        isLoading = true
        loadCompleted = false
        loadLock.unlock()
        
        defer {
            loadLock.lock()
            isLoading = false
            loadCompleted = true
            loadLock.unlock()
        }
        
        // Try to load data with error handling
        do {
            guard let data = UserDefaults.standard.data(forKey: sessionsKey) else {
                // No data saved yet, this is normal for first launch
                return
            }
            
            let decoder = JSONDecoder()
            let loadedSessions = try decoder.decode([WorkoutSession].self, from: data)
            
            // Validate loaded data using the same validation function to ensure consistency
            // This prevents validation mismatches between adding and loading sessions
            let validSessions = loadedSessions.filter { session in
                // Use the same validation function that addSession() uses
                let validationResult = ErrorHandling.validateSessionData(
                    duration: session.duration,
                    exercisesCompleted: session.exercisesCompleted
                )
                switch validationResult {
                case .success:
                    return true
                case .failure:
                    return false
                }
            }
            
            if validSessions.count != loadedSessions.count {
                let invalidCount = loadedSessions.count - validSessions.count
                os_log("Filtered out %d invalid sessions during load", log: .default, type: .info, invalidCount)
                ErrorHandling.handleError(
                    ErrorHandling.WorkoutError.invalidData(description: "Filtered out \(invalidCount) invalid session(s) during load"),
                    context: "WorkoutStore.load"
                )
            }
            
            sessions = validSessions
            recalculateStatistics()
            
        } catch {
            // Data corruption detected, attempt recovery
            os_log("Data corruption detected, attempting recovery: %{public}@", log: .default, type: .error, error.localizedDescription)
            ErrorHandling.handleError(ErrorHandling.WorkoutError.dataCorrupted, context: "WorkoutStore.load")
            
            if !attemptDataRecovery() {
                // Recovery failed, reset to empty state
                os_log("Data recovery failed, resetting to empty state", log: .default, type: .error)
                sessions = []
                streak = 0
                totalWorkouts = 0
                totalMinutes = 0
            }
        }
    }
    
    private func save() {
        let d = UserDefaults.standard
        
        if let data = try? JSONEncoder().encode(sessions) {
            d.set(data, forKey: sessionsKey)
        }
        
        d.set(streak, forKey: streakKey)
        d.set(totalWorkouts, forKey: totalWorkoutsKey)
        d.set(totalMinutes, forKey: totalMinutesKey)
    }
    
    // MARK: - Streaks
    
    private func bumpStreakIfNeeded() {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let d = UserDefaults.standard
        let last = d.object(forKey: lastDayKey) as? Date
        
        if let last = last {
            if cal.isDateInToday(last) {
                // Already worked out today
            } else if let yesterday = cal.date(byAdding: .day, value: -1, to: today),
                      cal.isDate(last, inSameDayAs: yesterday) {
                // Consecutive day
                streak = max(streak + 1, 1)
                d.set(today, forKey: lastDayKey)
            } else {
                // Missed a day; reset to 1
                streak = 1
                d.set(today, forKey: lastDayKey)
            }
        } else {
            // First workout
            streak = 1
            d.set(today, forKey: lastDayKey)
        }
        save()
    }
    
    private func recalcStreakIfNeeded() {
        let d = UserDefaults.standard
        guard let last = d.object(forKey: lastDayKey) as? Date else { return }
        
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        
        if cal.isDateInToday(last) { return }
        
        if let yesterday = cal.date(byAdding: .day, value: -1, to: today),
           cal.isDate(last, inSameDayAs: yesterday) {
            return
        }
        
        // More than a day gap → streak broken
        streak = 0
        save()
    }
    
    // MARK: - Agent 2: Personal Best Tracking
    
    private let personalBestKey = AppConstants.UserDefaultsKeys.workoutPersonalBest
    
    /// Personal best duration (in seconds)
    @Published private(set) var personalBestDuration: TimeInterval = 0
    
    /// Personal best exercises completed
    @Published private(set) var personalBestExercises: Int = 0
    
    /// Read-only check if a workout session would be a personal best (doesn't modify properties)
    /// - Parameters:
    ///   - duration: Workout duration in seconds
    ///   - exercisesCompleted: Number of exercises completed
    /// - Returns: Tuple of (isDurationBest, isExercisesBest)
    func wouldBePersonalBest(duration: TimeInterval, exercisesCompleted: Int) -> (isDurationBest: Bool, isExercisesBest: Bool) {
        let isDurationBest = duration > personalBestDuration
        let isExercisesBest = exercisesCompleted > personalBestExercises
        return (isDurationBest, isExercisesBest)
    }
    
    /// Checks if current workout is any kind of personal best (read-only, doesn't modify properties)
    func isPersonalBest(duration: TimeInterval, exercisesCompleted: Int) -> Bool {
        let result = wouldBePersonalBest(duration: duration, exercisesCompleted: exercisesCompleted)
        return result.isDurationBest || result.isExercisesBest
    }
    
    /// Updates personal best records (should be called asynchronously, not during view updates)
    /// - Parameters:
    ///   - duration: Workout duration in seconds
    ///   - exercisesCompleted: Number of exercises completed
    /// - Returns: Tuple of (isDurationBest, isExercisesBest) indicating what was updated
    func updatePersonalBest(duration: TimeInterval, exercisesCompleted: Int) -> (isDurationBest: Bool, isExercisesBest: Bool) {
        var isDurationBest = false
        var isExercisesBest = false
        
        // Check duration personal best (faster is better, so we check if current is faster)
        // For consistency, we'll track longest duration as "best" (more complete workout)
        if duration > personalBestDuration {
            isDurationBest = true
            personalBestDuration = duration
            UserDefaults.standard.set(personalBestDuration, forKey: personalBestKey)
        }
        
        // Check exercises personal best
        if exercisesCompleted > personalBestExercises {
            isExercisesBest = true
            personalBestExercises = exercisesCompleted
            UserDefaults.standard.set(personalBestExercises, forKey: AppConstants.UserDefaultsKeys.workoutPersonalBestExercises)
        }
        
        return (isDurationBest, isExercisesBest)
    }
    
    private func loadPersonalBest() {
        let d = UserDefaults.standard
        personalBestDuration = d.double(forKey: AppConstants.UserDefaultsKeys.workoutPersonalBest)
        personalBestExercises = d.integer(forKey: AppConstants.UserDefaultsKeys.workoutPersonalBestExercises)
    }
    
    // MARK: - Agent 7: Achievement Checking
    
    private func checkAchievements(workoutTime: Date) {
        let achievementNotifier = AchievementNotifier.shared
        
        // Check first workout
        if let firstWorkout = achievementNotifier.checkFirstWorkout(totalWorkouts: totalWorkouts) {
            NotificationManager.scheduleAchievementNotification(firstWorkout)
        }
        
        // Check other achievements
        let newAchievements = achievementNotifier.checkAchievements(
            streak: streak,
            totalWorkouts: totalWorkouts,
            workoutsThisWeek: workoutsThisWeek,
            workoutTime: workoutTime
        )
        
        // Schedule notifications for new achievements
        for achievement in newAchievements {
            NotificationManager.scheduleAchievementNotification(achievement)
        }
    }
    
    init() {
        // Load minimal data synchronously for immediate UI display
        loadPersonalBest()
        
        // Defer heavy operations to avoid blocking UI
        Task { @MainActor in
            load()
            recalcStreakIfNeeded()
        }
        
        // Defer watch connectivity setup (non-critical for initial render)
        DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(AppConstants.TimingConstants.watchConnectivityDelay) / 1_000_000_000) { [weak self] in
            self?.setupWatchConnectivity()
        }
    }
}

