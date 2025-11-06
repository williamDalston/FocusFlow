import Foundation
import SwiftUI
import os.log

/// Agent 2: Focus Store - Manages focus session data persistence and statistics
/// Agent 14: Enhanced with data versioning, export, and advanced validation
/// Refactored from WorkoutStore for Pomodoro Timer app
@MainActor
final class FocusStore: ObservableObject {
    @Published private(set) var sessions: [FocusSession] = []
    @Published private(set) var streak: Int = 0
    @Published private(set) var totalSessions: Int = 0
    @Published private(set) var totalFocusTime: TimeInterval = 0 // in minutes
    @Published private(set) var currentCycle: PomodoroCycle?
    
    // Agent 14: Data versioning support
    private static let dataVersion = 1
    private let dataVersionKey = "focus.data.version"
    
    private let sessionsKey = AppConstants.UserDefaultsKeys.focusSessions
    private let streakKey = AppConstants.UserDefaultsKeys.focusStreak
    private let lastDayKey = AppConstants.UserDefaultsKeys.focusLastDay
    private let totalSessionsKey = AppConstants.UserDefaultsKeys.focusTotalSessions
    private let totalFocusTimeKey = AppConstants.UserDefaultsKeys.focusTotalMinutes
    private let currentCycleKey = AppConstants.UserDefaultsKeys.focusCurrentCycle
    
    // Agent 35: WatchSessionManager configured for FocusStore
    private var watchSessionManager: WatchSessionManager?
    
    // Synchronization for loading state
    private var isLoading = false
    private let loadLock = NSLock()
    private var loadCompleted = false
    
    // Agent 35: Watch connectivity setup - WatchSessionManager now supports FocusStore
    private func setupWatchConnectivity() {
        watchSessionManager = WatchSessionManager.shared
        watchSessionManager?.configure(with: self)
    }
    
    // MARK: - Public API
    
    func addSession(
        duration: TimeInterval,
        phaseType: FocusSession.PhaseType,
        completed: Bool = true,
        notes: String? = nil,
        startDate: Date? = nil
    ) {
        // Ensure load has completed before adding session
        loadLock.lock()
        let wasLoading = isLoading
        loadLock.unlock()
        
        if wasLoading {
            os_log("addSession called while load is in progress - this may cause data inconsistency", log: .default, type: .info)
        }
        
        // Agent 14: Enhanced validation
        guard validateSessionData(duration: duration, phaseType: phaseType) else {
            os_log("Failed to add session: Invalid data", log: .default, type: .error)
            return
        }
        
        let sessionDate = startDate ?? Date()
        let newSession = FocusSession(
            date: sessionDate,
            duration: duration,
            phaseType: phaseType,
            completed: completed,
            notes: notes
        )
        sessions.insert(newSession, at: 0)
        bumpStreakIfNeeded()
        
        // Only count focus sessions (not breaks) in statistics
        if phaseType == .focus && completed {
            totalSessions += 1
            totalFocusTime += duration / 60.0
        }
        
        // Update Pomodoro cycle if this is a focus session
        if phaseType == .focus && completed {
            updateCurrentCycle()
        }
        
        // Create backup before saving
        createBackup()
        
        save()
        
        // Check for achievements
        checkAchievements(focusTime: sessionDate)
        
        // Agent 35: Watch sync - send new session and update complications
        watchSessionManager?.sendNewSessionToWatch(newSession)
        watchSessionManager?.updateWatchComplications()
        
        // Notify personalization components
        NotificationCenter.default.post(
            name: NSNotification.Name(AppConstants.NotificationNames.focusCompleted),
            object: nil,
            userInfo: ["session": newSession]
        )
        
        // ASO: Consider review prompt after focus completion
        Task { @MainActor in
            ReviewGate.considerPromptAfterWorkout(totalWorkouts: totalSessions)
            
            // ASO: Track engagement
            ASOAnalytics.shared.trackEngagement(event: "focus_completed", value: totalSessions)
            
            // ASO: Track conversion funnel
            if totalSessions == 1 {
                ASOAnalytics.shared.trackConversionFunnel(stage: "first_focus")
            } else if totalSessions == 3 {
                ASOAnalytics.shared.trackConversionFunnel(stage: "focus_3")
            }
            
            // ASO: Consider review prompt after streak milestone
            if streak >= 7 {
                ReviewGate.considerPromptAfterStreak(streak: streak)
                ASOAnalytics.shared.trackEngagement(event: "streak_milestone", value: streak)
            }
        }
    }
    
    // MARK: - Pomodoro Cycle Management
    
    private func updateCurrentCycle() {
        if var cycle = currentCycle {
            cycle.incrementSession()
            if cycle.isComplete {
                // Cycle complete, start new cycle
                currentCycle = PomodoroCycle(startDate: Date())
            } else {
                currentCycle = cycle
            }
        } else {
            // Start new cycle
            currentCycle = PomodoroCycle(startDate: Date(), completedSessions: 1)
        }
        save()
    }
    
    func getCurrentCycleProgress() -> (completed: Int, total: Int) {
        guard let cycle = currentCycle else {
            return (0, 4)
        }
        return (cycle.completedSessions, cycle.cycleLength)
    }
    
    // MARK: - Agent 25: Undo support for deleted sessions
    
    private var deletedSessionsBackup: [FocusSession] = []
    private var deletedSessionsStats: (totalSessions: Int, totalFocusTime: TimeInterval)?
    
    func deleteSession(at offsets: IndexSet) {
        // Filter out invalid indices to prevent crashes
        let validOffsets = offsets.filter { $0 >= 0 && $0 < sessions.count }
        guard !validOffsets.isEmpty else { return }
        
        // Store backup for undo
        deletedSessionsBackup = validOffsets.map { sessions[$0] }
        deletedSessionsStats = (totalSessions, totalFocusTime)
        
        let deletedSessions = validOffsets.map { sessions[$0] }
        for session in deletedSessions {
            if session.phaseType == .focus && session.completed {
                totalSessions = max(0, totalSessions - 1)
                totalFocusTime = max(0, totalFocusTime - session.duration / 60.0)
            }
        }
        sessions.remove(atOffsets: IndexSet(validOffsets))
        save()
    }
    
    /// Undo the last deletion
    func undoDelete() {
        guard !deletedSessionsBackup.isEmpty else { return }
        
        // Restore deleted sessions
        for session in deletedSessionsBackup.reversed() {
            sessions.insert(session, at: 0)
        }
        
        // Restore stats
        if let stats = deletedSessionsStats {
            totalSessions = stats.totalSessions
            totalFocusTime = stats.totalFocusTime
        }
        
        // Clear backup
        deletedSessionsBackup = []
        deletedSessionsStats = nil
        
        save()
    }
    
    /// Check if undo is available
    var canUndoDelete: Bool {
        !deletedSessionsBackup.isEmpty
    }
    
    func reset() {
        sessions.removeAll()
        streak = 0
        totalSessions = 0
        totalFocusTime = 0
        currentCycle = nil
        UserDefaults.standard.removeObject(forKey: lastDayKey)
        save()
    }
    
    // MARK: - Statistics
    
    var sessionsThisWeek: Int {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return sessions.filter { $0.date >= weekAgo && $0.phaseType == .focus && $0.completed }.count
    }
    
    var sessionsThisMonth: Int {
        let calendar = Calendar.current
        let now = Date()
        return sessions.filter { 
            calendar.isDate($0.date, equalTo: now, toGranularity: .month) &&
            $0.phaseType == .focus &&
            $0.completed
        }.count
    }
    
    var averageSessionDuration: TimeInterval {
        let focusSessions = sessions.filter { $0.phaseType == .focus && $0.completed }
        guard !focusSessions.isEmpty else { return 0 }
        let total = focusSessions.reduce(0.0) { $0 + $1.duration }
        return total / Double(focusSessions.count)
    }
    
    // MARK: - Analytics Helpers
    
    /// Get sessions in a date range
    func sessions(in range: ClosedRange<Date>) -> [FocusSession] {
        return sessions.filter { range.contains($0.date) }
    }
    
    /// Get sessions for a specific date
    func sessions(on date: Date) -> [FocusSession] {
        let calendar = Calendar.current
        return sessions.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    /// Get sessions for a specific month
    func sessions(in month: Date) -> [FocusSession] {
        let calendar = Calendar.current
        return sessions.filter { calendar.isDate($0.date, equalTo: month, toGranularity: .month) }
    }
    
    /// Get focus sessions only (excluding breaks)
    func focusSessions() -> [FocusSession] {
        return sessions.filter { $0.phaseType == .focus }
    }
    
    // MARK: - Agent 14: Advanced Validation
    
    /// Validates session data before adding
    private func validateSessionData(duration: TimeInterval, phaseType: FocusSession.PhaseType) -> Bool {
        // Duration must be non-negative and reasonable (max 2 hours)
        guard duration >= 0, duration <= 7200 else {
            return false
        }
        
        // Phase type must be valid
        guard FocusSession.PhaseType.allCases.contains(phaseType) else {
            return false
        }
        
        return true
    }
    
    /// Validates a FocusSession for data integrity
    func validateSession(_ session: FocusSession) -> Bool {
        return validateSessionData(duration: session.duration, phaseType: session.phaseType) &&
               session.date <= Date() // Session date can't be in the future
    }
    
    // MARK: - Agent 14: Data Export & Import
    
    /// Export all sessions to JSON data
    func exportSessions() -> Data? {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            return try encoder.encode(sessions)
        } catch {
            os_log("Failed to export sessions: %{public}@", log: .default, type: .error, error.localizedDescription)
            return nil
        }
    }
    
    /// Export sessions to CSV format
    func exportSessionsToCSV() -> String {
        var csv = "Date,Phase Type,Duration (seconds),Completed,Notes\n"
        for session in sessions {
            let dateFormatter = ISO8601DateFormatter()
            let dateString = dateFormatter.string(from: session.date)
            let notes = session.notes?.replacingOccurrences(of: ",", with: ";") ?? ""
            csv += "\(dateString),\(session.phaseType.rawValue),\(Int(session.duration)),\(session.completed),\(notes)\n"
        }
        return csv
    }
    
    /// Import sessions from JSON data (with validation)
    func importSessions(from data: Data) -> (imported: Int, failed: Int) {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let importedSessions = try decoder.decode([FocusSession].self, from: data)
            
            var imported = 0
            var failed = 0
            
            for session in importedSessions {
                if validateSession(session) {
                    sessions.append(session)
                    imported += 1
                } else {
                    failed += 1
                }
            }
            
            if imported > 0 {
                recalculateStatistics()
                save()
            }
            
            return (imported, failed)
        } catch {
            os_log("Failed to import sessions: %{public}@", log: .default, type: .error, error.localizedDescription)
            return (0, 0)
        }
    }
    
    // MARK: - Agent 14: Data Migration Support
    
    /// Check if data migration is needed
    private func checkDataVersion() -> Bool {
        let storedVersion = UserDefaults.standard.integer(forKey: dataVersionKey)
        return storedVersion == Self.dataVersion
    }
    
    /// Perform data migration if needed
    private func migrateDataIfNeeded() {
        let storedVersion = UserDefaults.standard.integer(forKey: dataVersionKey)
        
        if storedVersion == 0 {
            // First time setup - no migration needed
            UserDefaults.standard.set(Self.dataVersion, forKey: dataVersionKey)
            return
        }
        
        if storedVersion < Self.dataVersion {
            // Perform migration
            os_log("Migrating FocusStore data from version %d to %d", log: .default, type: .info, storedVersion, Self.dataVersion)
            
            // Future migration logic can be added here
            // For now, just update version
            UserDefaults.standard.set(Self.dataVersion, forKey: dataVersionKey)
        }
    }
    
    // MARK: - Persistence
    
    // MARK: - Data Backup & Recovery
    
    /// Creates a backup of current session data
    private func createBackup() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(sessions)
            UserDefaults.standard.set(data, forKey: AppConstants.UserDefaultsKeys.focusSessionsBackup)
        } catch {
            os_log("Failed to create backup: %{public}@", log: .default, type: .error, error.localizedDescription)
        }
    }
    
    /// Attempts to recover from corrupted data
    private func attemptDataRecovery() -> Bool {
        // Try to load from backup
        if let backupData = UserDefaults.standard.data(forKey: AppConstants.UserDefaultsKeys.focusSessionsBackup) {
            do {
                let decoder = JSONDecoder()
                let recoveredSessions = try decoder.decode([FocusSession].self, from: backupData)
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
        let focusSessions = sessions.filter { $0.phaseType == .focus && $0.completed }
        totalSessions = focusSessions.count
        totalFocusTime = focusSessions.reduce(0) { $0 + $1.duration / 60.0 }
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
        
        // Agent 14: Check data version and migrate if needed
        migrateDataIfNeeded()
        
        // Try to load data with error handling
        do {
            guard let data = UserDefaults.standard.data(forKey: sessionsKey) else {
                // No data saved yet, this is normal for first launch
                return
            }
            
            let decoder = JSONDecoder()
            let loadedSessions = try decoder.decode([FocusSession].self, from: data)
            
            // Agent 14: Enhanced validation using validateSession method
            let validSessions = loadedSessions.filter { validateSession($0) }
            
            if validSessions.count != loadedSessions.count {
                let invalidCount = loadedSessions.count - validSessions.count
                os_log("Filtered out %d invalid sessions during load", log: .default, type: .info, invalidCount)
            }
            
            sessions = validSessions
            recalculateStatistics()
            
            // Load current cycle
            if let cycleData = UserDefaults.standard.data(forKey: currentCycleKey),
               let cycle = try? decoder.decode(PomodoroCycle.self, from: cycleData) {
                currentCycle = cycle
            }
            
        } catch {
            // Data corruption detected, attempt recovery
            os_log("Data corruption detected, attempting recovery: %{public}@", log: .default, type: .error, error.localizedDescription)
            
            if !attemptDataRecovery() {
                // Recovery failed, reset to empty state
                os_log("Data recovery failed, resetting to empty state", log: .default, type: .error)
                sessions = []
                streak = 0
                totalSessions = 0
                totalFocusTime = 0
                currentCycle = nil
            }
        }
    }
    
    private func save() {
        let d = UserDefaults.standard
        
        if let data = try? JSONEncoder().encode(sessions) {
            d.set(data, forKey: sessionsKey)
        }
        
        d.set(streak, forKey: streakKey)
        d.set(totalSessions, forKey: totalSessionsKey)
        d.set(totalFocusTime, forKey: totalFocusTimeKey)
        
        // Save current cycle
        if let cycle = currentCycle,
           let cycleData = try? JSONEncoder().encode(cycle) {
            d.set(cycleData, forKey: currentCycleKey)
        }
    }
    
    // MARK: - Streaks
    
    private func bumpStreakIfNeeded() {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let d = UserDefaults.standard
        let last = d.object(forKey: lastDayKey) as? Date
        
        // Only count focus sessions for streaks
        let hasFocusToday = sessions.contains { session in
            cal.isDateInToday(session.date) && session.phaseType == .focus && session.completed
        }
        
        if !hasFocusToday {
            // No focus session today, don't update streak
            return
        }
        
        if let last = last {
            if cal.isDateInToday(last) {
                // Already focused today
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
            // First focus session
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
    
    // MARK: - Achievement Checking
    
    private func checkAchievements(focusTime: Date) {
        let achievementNotifier = AchievementNotifier.shared
        
        // Check first focus session
        if let firstFocus = achievementNotifier.checkFirstSession(totalSessions: totalSessions) {
            NotificationManager.scheduleAchievementNotification(firstFocus)
        }
        
        // Check other achievements
        let newAchievements = achievementNotifier.checkAchievements(
            streak: streak,
            totalSessions: totalSessions,
            sessionsThisWeek: sessionsThisWeek,
            sessionTime: focusTime
        )
        
        // Schedule notifications for new achievements
        for achievement in newAchievements {
            NotificationManager.scheduleAchievementNotification(achievement)
        }
    }
    
    init() {
        // Agent 14: Initialize data version
        let dataVersionKey = "focus.data.version"
        if UserDefaults.standard.object(forKey: dataVersionKey) == nil {
            UserDefaults.standard.set(Self.dataVersion, forKey: dataVersionKey)
        }
        
        // Load minimal data synchronously for immediate UI display
        
        // Defer heavy operations to avoid blocking UI
        Task { @MainActor in
            load()
            recalcStreakIfNeeded()
        }
        
        // Agent 35: Watch connectivity setup - defer to avoid blocking initial render
        DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(AppConstants.TimingConstants.watchConnectivityDelay) / 1_000_000_000) { [weak self] in
            self?.setupWatchConnectivity()
        }
    }
}

