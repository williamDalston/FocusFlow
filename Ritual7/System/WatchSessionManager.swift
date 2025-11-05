import Foundation
import WatchConnectivity

/// Manages communication between iPhone and Apple Watch for workout data
@MainActor
final class WatchSessionManager: NSObject, ObservableObject {
    static let shared = WatchSessionManager()
    
    @Published private(set) var isWatchConnected = false
    @Published private(set) var isWatchAppInstalled = false
    @Published private(set) var isReachable = false
    
    private var session: WCSession?
    private weak var workoutStore: WorkoutStore?
    
    override init() {
        super.init()
        setupWatchConnectivity()
    }
    
    func configure(with workoutStore: WorkoutStore) {
        self.workoutStore = workoutStore
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
              session.isReachable,
              let workoutStore = workoutStore else {
            print("⚠️ Cannot send sessions to Watch - not reachable")
            return
        }
        
        let message = [
            "action": "sync_sessions",
            "sessions": (try? JSONEncoder().encode(workoutStore.sessions)) as Any,
            "streak": workoutStore.streak,
            "totalWorkouts": workoutStore.totalWorkouts,
            "totalMinutes": workoutStore.totalMinutes
        ] as [String : Any]
        
        session.sendMessage(message, replyHandler: { response in
            print("✅ Successfully sent sessions to Watch")
        }, errorHandler: { error in
            print("❌ Failed to send sessions to Watch: \(error.localizedDescription)")
        })
    }
    
    func sendNewSessionToWatch(_ workoutSession: WorkoutSession) {
        guard let wcSession = session,
              wcSession.isReachable else {
            // Store for later sync if Watch becomes available
            print("⚠️ Watch not reachable, will sync later")
            return
        }
        
        let message = [
            "action": "add_session",
            "session": (try? JSONEncoder().encode(workoutSession)) as Any
        ] as [String : Any]
        
        wcSession.sendMessage(message, replyHandler: { response in
            print("✅ Successfully sent new session to Watch")
        }, errorHandler: { error in
            print("❌ Failed to send new session to Watch: \(error.localizedDescription)")
        })
    }
    
    func requestWatchData() {
        guard let session = session,
              session.isReachable else {
            print("⚠️ Cannot request data from Watch - not reachable")
            return
        }
        
        let message = ["action": "request_workout_data"]
        session.sendMessage(message, replyHandler: { response in
            DispatchQueue.main.async {
                if let sessionsData = response["sessions"] as? Data,
                   let sessions = try? JSONDecoder().decode([WorkoutSession].self, from: sessionsData) {
                // Merge sessions from Watch
                for session in sessions {
                    let contains = self.workoutStore?.sessions.contains(where: { $0.id == session.id }) ?? false
                    if !contains {
                        // Add session if not already present
                        self.workoutStore?.addSession(
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
        let userInfo = [
            "streak": workoutStore?.streak ?? 0,
            "todays_workouts": todaysWorkoutCount,
            "last_updated": Date().timeIntervalSince1970
        ] as [String : Any]
        
        session.transferUserInfo(userInfo)
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
                if let data = message["session"] as? Data,
                   let workoutSession = try? JSONDecoder().decode(WorkoutSession.self, from: data) {
                    // Add session from Watch if not already present
                    let contains = self.workoutStore?.sessions.contains(where: { $0.id == workoutSession.id }) ?? false
                    if !contains {
                        self.workoutStore?.addSession(
                            duration: workoutSession.duration,
                            exercisesCompleted: workoutSession.exercisesCompleted,
                            notes: workoutSession.notes
                        )
                    }
                }
                
            case "request_workout_data":
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
                    replyHandler(["error": "No data available"])
                }
                
            case "add_session":
                if let data = message["session"] as? Data,
                   let workoutSession = try? JSONDecoder().decode(WorkoutSession.self, from: data) {
                    // Add session from Watch if not already present
                    let contains = self.workoutStore?.sessions.contains(where: { $0.id == workoutSession.id }) ?? false
                    if !contains {
                        self.workoutStore?.addSession(
                            duration: workoutSession.duration,
                            exercisesCompleted: workoutSession.exercisesCompleted,
                            notes: workoutSession.notes
                        )
                    }
                    replyHandler(["success": true])
                } else {
                    replyHandler(["error": "Invalid session data"])
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
            if let watchSessions = userInfo["sessions"] as? Data,
               let sessions = try? JSONDecoder().decode([WorkoutSession].self, from: watchSessions) {
                // Merge sessions from Watch
                for session in sessions {
                    let contains = self.workoutStore?.sessions.contains(where: { $0.id == session.id }) ?? false
                    if !contains {
                        self.workoutStore?.addSession(
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
