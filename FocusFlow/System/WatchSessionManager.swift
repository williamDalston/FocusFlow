import Foundation
import WatchConnectivity

/// Manages communication between iPhone and Apple Watch for focus session data
/// Agent 5: Updated to support FocusStore for Pomodoro Timer app
@MainActor
final class WatchSessionManager: NSObject, ObservableObject {
    static let shared = WatchSessionManager()
    
    @Published private(set) var isWatchConnected = false
    @Published private(set) var isWatchAppInstalled = false
    @Published private(set) var isReachable = false
    
    private var session: WCSession?
    private weak var workoutStore: WorkoutStore?
    private weak var focusStore: FocusStore?
    
    override init() {
        super.init()
        setupWatchConnectivity()
    }
    
    func configure(with workoutStore: WorkoutStore) {
        self.workoutStore = workoutStore
        self.focusStore = nil
    }
    
    func configure(with focusStore: FocusStore) {
        self.focusStore = focusStore
        self.workoutStore = nil
    }
    
    private func setupWatchConnectivity() {
        guard WCSession.isSupported() else {
            print("⚠️ WatchConnectivity not supported on this device")
            return
        }
        
        session = WCSession.default
        session?.delegate = self
        session?.activate()
    }
    
    // MARK: - Public Methods
    
    func sendSessionsToWatch() {
        guard let session = session,
              session.isReachable else {
            print("⚠️ Cannot send sessions to Watch - not reachable")
            return
        }
        
        // Support both FocusStore and WorkoutStore
        if let focusStore = focusStore {
            let message = [
                "action": "sync_sessions",
                "sessions": (try? JSONEncoder().encode(focusStore.sessions)) as Any,
                "streak": focusStore.streak,
                "totalSessions": focusStore.totalSessions,
                "totalFocusMinutes": focusStore.totalFocusTime
            ] as [String : Any]
            
            session.sendMessage(message, replyHandler: { response in
                print("✅ Successfully sent focus sessions to Watch")
            }, errorHandler: { error in
                print("❌ Failed to send focus sessions to Watch: \(error.localizedDescription)")
            })
        } else if let workoutStore = workoutStore {
            let message = [
                "action": "sync_sessions",
                "sessions": (try? JSONEncoder().encode(workoutStore.sessions)) as Any,
                "streak": workoutStore.streak,
                "totalWorkouts": workoutStore.totalWorkouts,
                "totalMinutes": workoutStore.totalMinutes
            ] as [String : Any]
            
            session.sendMessage(message, replyHandler: { response in
                print("✅ Successfully sent workout sessions to Watch")
            }, errorHandler: { error in
                print("❌ Failed to send workout sessions to Watch: \(error.localizedDescription)")
            })
        }
    }
    
    func sendNewSessionToWatch(_ workoutSession: WorkoutSession) {
        guard let wcSession = session,
              wcSession.isReachable else {
            print("⚠️ Watch not reachable, will sync later")
            return
        }
        
        let message = [
            "action": "add_session",
            "session": (try? JSONEncoder().encode(workoutSession)) as Any
        ] as [String : Any]
        
        wcSession.sendMessage(message, replyHandler: { response in
            print("✅ Successfully sent new workout session to Watch")
        }, errorHandler: { error in
            print("❌ Failed to send new workout session to Watch: \(error.localizedDescription)")
        })
    }
    
    func sendNewSessionToWatch(_ focusSession: FocusSession) {
        guard let wcSession = session,
              wcSession.isReachable else {
            print("⚠️ Watch not reachable, will sync later")
            return
        }
        
        let message = [
            "action": "add_session",
            "session": (try? JSONEncoder().encode(focusSession)) as Any
        ] as [String : Any]
        
        wcSession.sendMessage(message, replyHandler: { response in
            print("✅ Successfully sent new focus session to Watch")
        }, errorHandler: { error in
            print("❌ Failed to send new focus session to Watch: \(error.localizedDescription)")
        })
    }
    
    func requestWatchData() {
        guard let session = session,
              session.isReachable else {
            print("⚠️ Cannot request data from Watch - not reachable")
            return
        }
        
        // Request focus data if using FocusStore, otherwise request workout data
        let action = focusStore != nil ? "request_focus_data" : "request_workout_data"
        let message = ["action": action]
        session.sendMessage(message, replyHandler: { response in
            DispatchQueue.main.async {
                if let focusStore = self.focusStore,
                   let sessionsData = response["sessions"] as? Data,
                   let sessions = try? JSONDecoder().decode([FocusSession].self, from: sessionsData) {
                    // Merge focus sessions from Watch
                    for session in sessions {
                        let contains = focusStore.sessions.contains(where: { $0.id == session.id })
                        if !contains {
                            focusStore.addSession(
                                duration: session.duration,
                                phaseType: session.phaseType,
                                completed: session.completed,
                                notes: session.notes,
                                startDate: session.date
                            )
                        }
                    }
                } else if let workoutStore = self.workoutStore,
                          let sessionsData = response["sessions"] as? Data,
                          let sessions = try? JSONDecoder().decode([WorkoutSession].self, from: sessionsData) {
                    // Merge workout sessions from Watch
                    for session in sessions {
                        let contains = workoutStore.sessions.contains(where: { $0.id == session.id }) ?? false
                        if !contains {
                            workoutStore.addSession(
                                duration: session.duration,
                                exercisesCompleted: session.exercisesCompleted,
                                notes: session.notes
                            )
                        }
                    }
                }
            }
        }, errorHandler: { error in
            print("❌ Failed to request data from Watch: \(error.localizedDescription)")
        })
    }
    
    func updateWatchComplications() {
        guard let session = session else { return }
        
        // Update complications with current streak
        if let focusStore = focusStore {
            let userInfo = [
                "streak": focusStore.streak,
                "todays_focus_sessions": todaysFocusSessionCount,
                "last_updated": Date().timeIntervalSince1970
            ] as [String : Any]
            session.transferUserInfo(userInfo)
        } else if let workoutStore = workoutStore {
            let userInfo = [
                "streak": workoutStore.streak,
                "todays_workouts": todaysWorkoutCount,
                "last_updated": Date().timeIntervalSince1970
            ] as [String : Any]
            session.transferUserInfo(userInfo)
        }
    }
    
    // MARK: - Private Helpers
    
    private var todaysWorkoutCount: Int {
        guard let workoutStore = workoutStore else { return 0 }
        let calendar = Calendar.current
        let today = Date()
        return workoutStore.sessions.filter { session in
            calendar.isDate(session.date, inSameDayAs: today)
        }.count
    }
    
    private var todaysFocusSessionCount: Int {
        guard let focusStore = focusStore else { return 0 }
        let calendar = Calendar.current
        let today = Date()
        return focusStore.sessions.filter { session in
            calendar.isDate(session.date, inSameDayAs: today) && session.phaseType == .focus
        }.count
    }
    
    private func updateConnectionStatus() {
        guard let session = session else { return }
        
        DispatchQueue.main.async {
            self.isWatchConnected = session.isPaired
            self.isWatchAppInstalled = session.isWatchAppInstalled
            self.isReachable = session.isReachable
        }
    }
}

// MARK: - WCSessionDelegate

extension WatchSessionManager: @MainActor WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("❌ Watch session activation failed: \(error.localizedDescription)")
        } else {
            print("✅ Watch session activated successfully")
            updateConnectionStatus()
            
            // Send current data to Watch if it becomes available
            if activationState == .activated {
                sendSessionsToWatch()
                updateWatchComplications()
            }
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("⚠️ Watch session became inactive")
        updateConnectionStatus()
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("⚠️ Watch session deactivated")
        updateConnectionStatus()
        
        // Reactivate session
        session.activate()
    }
    
    func sessionWatchStateDidChange(_ session: WCSession) {
        print("🔄 Watch state changed")
        updateConnectionStatus()
        
        // If Watch becomes available, sync data
        if session.isReachable && session.isWatchAppInstalled {
            sendSessionsToWatch()
            updateWatchComplications()
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        print("🔄 Watch reachability changed: \(session.isReachable)")
        updateConnectionStatus()
        
        // If Watch becomes reachable, sync data
        if session.isReachable {
            sendSessionsToWatch()
            updateWatchComplications()
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("📱 Received message from Watch: \(message)")
        
        DispatchQueue.main.async {
            guard let action = message["action"] as? String else { return }
            
            switch action {
            case "add_session":
                // Try to decode as FocusSession first, then WorkoutSession
                if let data = message["session"] as? Data {
                    if let focusSession = try? JSONDecoder().decode(FocusSession.self, from: data),
                       let focusStore = self.focusStore {
                        let contains = focusStore.sessions.contains(where: { $0.id == focusSession.id })
                        if !contains {
                            focusStore.addSession(
                                duration: focusSession.duration,
                                phaseType: focusSession.phaseType,
                                completed: focusSession.completed,
                                notes: focusSession.notes,
                                startDate: focusSession.date
                            )
                        }
                    } else if let workoutSession = try? JSONDecoder().decode(WorkoutSession.self, from: data),
                              let workoutStore = self.workoutStore {
                        let contains = workoutStore.sessions.contains(where: { $0.id == workoutSession.id }) ?? false
                        if !contains {
                            workoutStore.addSession(
                                duration: workoutSession.duration,
                                exercisesCompleted: workoutSession.exercisesCompleted,
                                notes: workoutSession.notes
                            )
                        }
                    }
                }
                
            case "request_focus_data", "request_workout_data":
                // Watch is requesting current data
                self.sendSessionsToWatch()
                
            case "sync_complete":
                print("✅ Watch sync completed")
                
            default:
                print("⚠️ Unknown action from Watch: \(action)")
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("📱 Received message with reply from Watch: \(message)")
        
        DispatchQueue.main.async {
            guard let action = message["action"] as? String else {
                replyHandler(["error": "Unknown action"])
                return
            }
            
            switch action {
            case "request_focus_data":
                if let focusStore = self.focusStore {
                    let response = [
                        "sessions": (try? JSONEncoder().encode(focusStore.sessions)) as Any,
                        "streak": focusStore.streak,
                        "totalSessions": focusStore.totalSessions,
                        "totalFocusMinutes": focusStore.totalFocusTime
                    ] as [String : Any]
                    replyHandler(response)
                } else {
                    replyHandler(["error": "No focus data available"])
                }
                
            case "request_workout_data":
                if let workoutStore = self.workoutStore {
                    let response = [
                        "sessions": (try? JSONEncoder().encode(workoutStore.sessions)) as Any,
                        "streak": workoutStore.streak,
                        "totalWorkouts": workoutStore.totalWorkouts,
                        "totalMinutes": workoutStore.totalMinutes
                    ] as [String : Any]
                    replyHandler(response)
                } else {
                    replyHandler(["error": "No workout data available"])
                }
                
            case "add_session":
                if let data = message["session"] as? Data {
                    // Try FocusSession first
                    if let focusSession = try? JSONDecoder().decode(FocusSession.self, from: data),
                       let focusStore = self.focusStore {
                        let contains = focusStore.sessions.contains(where: { $0.id == focusSession.id })
                        if !contains {
                            focusStore.addSession(
                                duration: focusSession.duration,
                                phaseType: focusSession.phaseType,
                                completed: focusSession.completed,
                                notes: focusSession.notes,
                                startDate: focusSession.date
                            )
                        }
                        replyHandler(["success": true])
                    } else if let workoutSession = try? JSONDecoder().decode(WorkoutSession.self, from: data),
                              let workoutStore = self.workoutStore {
                        let contains = workoutStore.sessions.contains(where: { $0.id == workoutSession.id }) ?? false
                        if !contains {
                            workoutStore.addSession(
                                duration: workoutSession.duration,
                                exercisesCompleted: workoutSession.exercisesCompleted,
                                notes: workoutSession.notes
                            )
                        }
                        replyHandler(["success": true])
                    } else {
                        replyHandler(["error": "Invalid session data"])
                    }
                } else {
                    replyHandler(["error": "No session data"])
                }
                
            default:
                replyHandler(["error": "Unknown action"])
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        print("📱 Received user info from Watch: \(userInfo)")
        
        DispatchQueue.main.async {
            // Handle any user info updates from Watch
            if let watchSessions = userInfo["sessions"] as? Data {
                // Try FocusSession first
                if let focusStore = self.focusStore,
                   let sessions = try? JSONDecoder().decode([FocusSession].self, from: watchSessions) {
                    for session in sessions {
                        let contains = focusStore.sessions.contains(where: { $0.id == session.id })
                        if !contains {
                            focusStore.addSession(
                                duration: session.duration,
                                phaseType: session.phaseType,
                                completed: session.completed,
                                notes: session.notes,
                                startDate: session.date
                            )
                        }
                    }
                } else if let workoutStore = self.workoutStore,
                          let sessions = try? JSONDecoder().decode([WorkoutSession].self, from: watchSessions) {
                    for session in sessions {
                        let contains = workoutStore.sessions.contains(where: { $0.id == session.id }) ?? false
                        if !contains {
                            workoutStore.addSession(
                                duration: session.duration,
                                exercisesCompleted: session.exercisesCompleted,
                                notes: session.notes
                            )
                        }
                    }
                }
            }
        }
    }
}
