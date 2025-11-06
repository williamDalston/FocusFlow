import Foundation
import WatchConnectivity

/// Manages focus session data on Apple Watch
/// Refactored from WatchWorkoutStore for Pomodoro Timer app
@MainActor
final class WatchFocusStore: ObservableObject {
    @Published private(set) var sessions: [FocusSession] = []
    @Published private(set) var streak: Int = 0
    @Published private(set) var totalSessions: Int = 0
    @Published private(set) var totalFocusMinutes: TimeInterval = 0
    
    private let session = WCSession.default
    private let sessionsKey = "watch_focus_sessions"
    private let streakKey = "watch_focus_streak"
    private let totalSessionsKey = "watch_total_focus_sessions"
    private let totalMinutesKey = "watch_total_focus_minutes"
    private let lastDayKey = "watch_last_focus_day"
    
    init() {
        if WCSession.isSupported() {
            session.delegate = WatchFocusSessionDelegate(store: self)
            session.activate()
        }
        loadFromWatchStorage()
        updateStreak()
    }
    
    func addSession(duration: TimeInterval, phaseType: FocusSession.PhaseType, completed: Bool = true, notes: String? = nil) {
        let newSession = FocusSession(
            date: Date(),
            duration: duration,
            phaseType: phaseType,
            completed: completed,
            notes: notes
        )
        sessions.insert(newSession, at: 0)
        
        // Only count focus sessions for streak
        if phaseType == .focus && completed {
            bumpStreakIfNeeded()
            totalSessions += 1
            totalFocusMinutes += duration / 60.0
        }
        
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
           let decoded = try? JSONDecoder().decode([FocusSession].self, from: data) {
            sessions = decoded
        }
        
        // Load statistics
        streak = UserDefaults.standard.integer(forKey: streakKey)
        totalSessions = UserDefaults.standard.integer(forKey: totalSessionsKey)
        totalFocusMinutes = UserDefaults.standard.double(forKey: totalMinutesKey)
    }
    
    private func saveToWatchStorage() {
        // Save sessions
        if let data = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(data, forKey: sessionsKey)
        }
        
        // Save statistics
        UserDefaults.standard.set(streak, forKey: streakKey)
        UserDefaults.standard.set(totalSessions, forKey: totalSessionsKey)
        UserDefaults.standard.set(totalFocusMinutes, forKey: totalMinutesKey)
    }
    
    private func updateStreak() {
        let calendar = Calendar.current
        let today = Date()
        let lastFocusDay = UserDefaults.standard.object(forKey: lastDayKey) as? Date
        
        guard let lastDay = lastFocusDay else {
            streak = 0
            return
        }
        
        if calendar.isDateInToday(lastDay) {
            // Already focused today, keep current streak
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
        let lastFocusDay = UserDefaults.standard.object(forKey: lastDayKey) as? Date
        
        if let lastDay = lastFocusDay {
            if calendar.isDateInToday(lastDay) {
                // Already focused today, don't increment
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
            // First focus session
            streak = 1
            UserDefaults.standard.set(today, forKey: lastDayKey)
        }
        saveToWatchStorage()
    }
    
    private func sendToiPhone(_ focusSession: FocusSession) {
        guard session.isReachable else { return }
        
        let message = [
            "action": "add_session",
            "session": try? JSONEncoder().encode(focusSession)
        ] as [String : Any]
        
        session.sendMessage(message, replyHandler: nil, errorHandler: nil)
    }
    
    private func requestDataFromiPhone() {
        guard session.isReachable else { return }
        
        let message = ["action": "request_focus_data"]
        session.sendMessage(message, replyHandler: { response in
            DispatchQueue.main.async {
                if let sessionsData = response["sessions"] as? Data,
                   let decoded = try? JSONDecoder().decode([FocusSession].self, from: sessionsData) {
                    self.sessions = decoded
                    self.updateStreak()
                    self.saveToWatchStorage()
                }
                
                if let streak = response["streak"] as? Int {
                    self.streak = streak
                }
                
                if let totalSessions = response["totalSessions"] as? Int {
                    self.totalSessions = totalSessions
                }
                
                if let totalMinutes = response["totalFocusMinutes"] as? TimeInterval {
                    self.totalFocusMinutes = totalMinutes
                }
            }
        }, errorHandler: nil)
    }
    
    func syncWithiPhone(_ sessions: [FocusSession], streak: Int, totalSessions: Int, totalFocusMinutes: TimeInterval) {
        self.sessions = sessions
        self.streak = streak
        self.totalSessions = totalSessions
        self.totalFocusMinutes = totalFocusMinutes
        saveToWatchStorage()
    }
}

// MARK: - Watch Connectivity Delegate

class WatchFocusSessionDelegate: NSObject, WCSessionDelegate {
    private weak var store: WatchFocusStore?
    
    init(store: WatchFocusStore) {
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
                   let decoded = try? JSONDecoder().decode([FocusSession].self, from: data) {
                    self.store?.sessions = decoded
                    self.store?.saveToWatchStorage()
                }
                
                if let streak = message["streak"] as? Int {
                    self.store?.streak = streak
                }
                
                if let totalSessions = message["totalSessions"] as? Int {
                    self.store?.totalSessions = totalSessions
                }
                
                if let totalMinutes = message["totalFocusMinutes"] as? TimeInterval {
                    self.store?.totalFocusMinutes = totalMinutes
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

