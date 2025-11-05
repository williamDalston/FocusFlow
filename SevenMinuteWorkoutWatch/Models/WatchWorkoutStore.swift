import Foundation
import WatchConnectivity

/// Manages workout data on Apple Watch
@MainActor
final class WatchWorkoutStore: ObservableObject {
    @Published private(set) var sessions: [WorkoutSession] = []
    @Published private(set) var streak: Int = 0
    @Published private(set) var totalWorkouts: Int = 0
    @Published private(set) var totalMinutes: TimeInterval = 0
    
    private let session = WCSession.default
    private let sessionsKey = "watch_workout_sessions"
    private let streakKey = "watch_workout_streak"
    private let totalWorkoutsKey = "watch_total_workouts"
    private let totalMinutesKey = "watch_total_minutes"
    private let lastDayKey = "watch_last_workout_day"
    
    init() {
        if WCSession.isSupported() {
            session.delegate = WatchWorkoutSessionDelegate(store: self)
            session.activate()
        }
        loadFromWatchStorage()
        updateStreak()
    }
    
    func addSession(duration: TimeInterval, exercisesCompleted: Int, notes: String? = nil) {
        let newSession = WorkoutSession(
            date: Date(),
            duration: duration,
            exercisesCompleted: exercisesCompleted,
            notes: notes
        )
        sessions.insert(newSession, at: 0)
        bumpStreakIfNeeded()
        totalWorkouts += 1
        totalMinutes += duration / 60.0
        saveToWatchStorage()
        
        // Send to iPhone if connected
        sendToiPhone(newSession)
    }
    
    func load() {
        loadFromWatchStorage()
        requestDataFromiPhone()
    }
    
    private func loadFromWatchStorage() {
        // Load sessions
        if let data = UserDefaults.standard.data(forKey: sessionsKey),
           let decoded = try? JSONDecoder().decode([WorkoutSession].self, from: data) {
            sessions = decoded
        }
        
        // Load statistics
        streak = UserDefaults.standard.integer(forKey: streakKey)
        totalWorkouts = UserDefaults.standard.integer(forKey: totalWorkoutsKey)
        totalMinutes = UserDefaults.standard.double(forKey: totalMinutesKey)
    }
    
    private func saveToWatchStorage() {
        // Save sessions
        if let data = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(data, forKey: sessionsKey)
        }
        
        // Save statistics
        UserDefaults.standard.set(streak, forKey: streakKey)
        UserDefaults.standard.set(totalWorkouts, forKey: totalWorkoutsKey)
        UserDefaults.standard.set(totalMinutes, forKey: totalMinutesKey)
    }
    
    private func updateStreak() {
        let calendar = Calendar.current
        let today = Date()
        let lastWorkoutDay = UserDefaults.standard.object(forKey: lastDayKey) as? Date
        
        guard let lastDay = lastWorkoutDay else {
            streak = 0
            return
        }
        
        if calendar.isDateInToday(lastDay) {
            // Already worked out today, keep current streak
            return
        }
        
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
           calendar.isDate(lastDay, inSameDayAs: yesterday) {
            // Consecutive day - streak continues
            return
        }
        
        // Streak broken
        streak = 0
    }
    
    private func bumpStreakIfNeeded() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastWorkoutDay = UserDefaults.standard.object(forKey: lastDayKey) as? Date
        
        if let lastDay = lastWorkoutDay {
            if calendar.isDateInToday(lastDay) {
                // Already worked out today, don't increment
            } else if let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
                      calendar.isDate(lastDay, inSameDayAs: yesterday) {
                // Consecutive day
                streak += 1
                UserDefaults.standard.set(today, forKey: lastDayKey)
            } else {
                // Missed a day; reset to 1
                streak = 1
                UserDefaults.standard.set(today, forKey: lastDayKey)
            }
        } else {
            // First workout
            streak = 1
            UserDefaults.standard.set(today, forKey: lastDayKey)
        }
        saveToWatchStorage()
    }
    
    private func sendToiPhone(_ workoutSession: WorkoutSession) {
        guard session.isReachable else { return }
        
        let message = [
            "action": "add_session",
            "session": try? JSONEncoder().encode(workoutSession)
        ] as [String : Any]
        
        session.sendMessage(message, replyHandler: nil, errorHandler: nil)
    }
    
    private func requestDataFromiPhone() {
        guard session.isReachable else { return }
        
        let message = ["action": "request_workout_data"]
        session.sendMessage(message, replyHandler: { response in
            DispatchQueue.main.async {
                if let sessionsData = response["sessions"] as? Data,
                   let decoded = try? JSONDecoder().decode([WorkoutSession].self, from: sessionsData) {
                    self.sessions = decoded
                    self.updateStreak()
                    self.saveToWatchStorage()
                }
                
                if let streak = response["streak"] as? Int {
                    self.streak = streak
                }
                
                if let totalWorkouts = response["totalWorkouts"] as? Int {
                    self.totalWorkouts = totalWorkouts
                }
                
                if let totalMinutes = response["totalMinutes"] as? TimeInterval {
                    self.totalMinutes = totalMinutes
                }
            }
        }, errorHandler: nil)
    }
    
    func syncWithiPhone(_ sessions: [WorkoutSession], streak: Int, totalWorkouts: Int, totalMinutes: TimeInterval) {
        self.sessions = sessions
        self.streak = streak
        self.totalWorkouts = totalWorkouts
        self.totalMinutes = totalMinutes
        saveToWatchStorage()
    }
}

// MARK: - Watch Connectivity Delegate

class WatchWorkoutSessionDelegate: NSObject, WCSessionDelegate {
    private weak var store: WatchWorkoutStore?
    
    init(store: WatchWorkoutStore) {
        self.store = store
        super.init()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Handle activation completion
        if activationState == .activated {
            store?.requestDataFromiPhone()
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            guard let action = message["action"] as? String else { return }
            
            switch action {
            case "sync_sessions":
                if let data = message["sessions"] as? Data,
                   let decoded = try? JSONDecoder().decode([WorkoutSession].self, from: data) {
                    self.store?.sessions = decoded
                    self.store?.saveToWatchStorage()
                }
                
                if let streak = message["streak"] as? Int {
                    self.store?.streak = streak
                }
                
                if let totalWorkouts = message["totalWorkouts"] as? Int {
                    self.store?.totalWorkouts = totalWorkouts
                }
                
                if let totalMinutes = message["totalMinutes"] as? TimeInterval {
                    self.store?.totalMinutes = totalMinutes
                }
                
            case "update_complications":
                // Complications updated, no action needed
                break
                
            default:
                break
            }
        }
    }
}

