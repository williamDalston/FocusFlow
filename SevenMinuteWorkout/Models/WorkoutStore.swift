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
    
    private let sessionsKey = "workout.sessions.v1"
    private let streakKey = "workout.streak.v1"
    private let lastDayKey = "workout.lastDay.v1"
    private let totalWorkoutsKey = "workout.totalWorkouts.v1"
    private let totalMinutesKey = "workout.totalMinutes.v1"
    
    private var watchSessionManager: WatchSessionManager?
    private let healthKitManager = HealthKitManager.shared
    private let healthKitStore = HealthKitStore.shared
    
    init() {
        load()
        recalcStreakIfNeeded()
        setupWatchConnectivity()
    }
    
    private func setupWatchConnectivity() {
        watchSessionManager = WatchSessionManager.shared
        watchSessionManager?.configure(with: self)
    }
    
    // MARK: - Public API
    
    func addSession(duration: TimeInterval, exercisesCompleted: Int, notes: String? = nil, startDate: Date? = nil) {
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
        save()
        
        // Agent 7: Check for achievements
        checkAchievements(workoutTime: sessionDate)
        
        // Send to Watch if needed
        watchSessionManager?.updateWatchComplications()
        
        // Sync to HealthKit if available and authorized
        syncToHealthKit(session: newSession)
        
        // Agent 16: Notify personalization components
        NotificationCenter.default.post(
            name: NSNotification.Name("workoutCompleted"),
            object: nil,
            userInfo: ["session": newSession]
        )
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
    
    func deleteSession(at offsets: IndexSet) {
        let deletedSessions = offsets.map { sessions[$0] }
        for session in deletedSessions {
            totalWorkouts = max(0, totalWorkouts - 1)
            totalMinutes = max(0, totalMinutes - session.duration / 60.0)
        }
        sessions.remove(atOffsets: offsets)
        save()
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
    
    private func load() {
        let d = UserDefaults.standard
        
        // Load sessions
        if let data = d.data(forKey: sessionsKey) {
            if let decoded = try? JSONDecoder().decode([WorkoutSession].self, from: data) {
                sessions = decoded
            } else {
                sessions = []
            }
        } else {
            sessions = []
        }
        
        // Load statistics
        streak = d.integer(forKey: streakKey)
        totalWorkouts = d.integer(forKey: totalWorkoutsKey)
        totalMinutes = d.double(forKey: totalMinutesKey)
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
}

