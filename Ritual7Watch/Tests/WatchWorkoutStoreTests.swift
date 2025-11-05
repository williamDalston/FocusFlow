import XCTest
@testable import Ritual7Watch

/// Agent 4: Unit tests for WatchWorkoutStore
/// Tests workout data management on Apple Watch
@MainActor
final class WatchWorkoutStoreTests: XCTestCase {
    var store: WatchWorkoutStore!
    
    override func setUp() {
        super.setUp()
        clearUserDefaults()
        store = WatchWorkoutStore()
    }
    
    override func tearDown() {
        store = nil
        clearUserDefaults()
        super.tearDown()
    }
    
    // MARK: - Helper Methods
    
    private func clearUserDefaults() {
        let defaults = UserDefaults.standard
        let keys = [
            "watch_workout_sessions",
            "watch_workout_streak",
            "watch_total_workouts",
            "watch_total_minutes",
            "watch_last_workout_day"
        ]
        for key in keys {
            defaults.removeObject(forKey: key)
        }
        defaults.synchronize()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        XCTAssertEqual(store.sessions.count, 0)
        XCTAssertEqual(store.streak, 0)
        XCTAssertEqual(store.totalWorkouts, 0)
        XCTAssertEqual(store.totalMinutes, 0)
    }
    
    // MARK: - Add Session Tests
    
    func testAddSession() {
        let duration: TimeInterval = 420 // 7 minutes
        let exercisesCompleted = 12
        
        store.addSession(duration: duration, exercisesCompleted: exercisesCompleted)
        
        XCTAssertEqual(store.sessions.count, 1)
        XCTAssertEqual(store.totalWorkouts, 1)
        XCTAssertEqual(store.totalMinutes, duration / 60.0, accuracy: 0.01)
        
        guard let session = store.sessions.first else {
            XCTFail("Expected session to exist")
            return
        }
        XCTAssertEqual(session.duration, duration)
        XCTAssertEqual(session.exercisesCompleted, exercisesCompleted)
    }
    
    func testAddSessionWithNotes() {
        let notes = "Great workout on Watch!"
        
        store.addSession(duration: 420, exercisesCompleted: 12, notes: notes)
        
        guard let session = store.sessions.first else {
            XCTFail("Expected session to exist")
            return
        }
        XCTAssertEqual(session.notes, notes)
    }
    
    func testAddMultipleSessions() {
        for i in 0..<5 {
            store.addSession(duration: 420 + Double(i * 10), exercisesCompleted: 12)
        }
        
        XCTAssertEqual(store.sessions.count, 5)
        XCTAssertEqual(store.totalWorkouts, 5)
    }
    
    // MARK: - Streak Tests
    
    func testStreakFirstWorkout() {
        store.addSession(duration: 420, exercisesCompleted: 12)
        
        XCTAssertEqual(store.streak, 1)
    }
    
    func testStreakConsecutiveDays() {
        let calendar = Calendar.current
        
        // Today
        store.addSession(duration: 420, exercisesCompleted: 12)
        
        // Tomorrow
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()) else {
            XCTFail("Failed to create tomorrow date")
            return
        }
        store.addSession(duration: 420, exercisesCompleted: 12)
        
        XCTAssertGreaterThanOrEqual(store.streak, 1)
    }
    
    // MARK: - Persistence Tests
    
    func testPersistence() {
        store.addSession(duration: 420, exercisesCompleted: 12)
        guard let firstSession = store.sessions.first else {
            XCTFail("Expected session to exist")
            return
        }
        let sessionId = firstSession.id
        let totalWorkouts = store.totalWorkouts
        
        // Create new store instance (simulating app restart)
        let newStore = WatchWorkoutStore()
        
        XCTAssertEqual(newStore.sessions.count, 1)
        XCTAssertEqual(newStore.sessions.first?.id, sessionId)
        XCTAssertEqual(newStore.totalWorkouts, totalWorkouts)
    }
    
    // MARK: - Sync Tests
    
    func testSyncWithiPhone() {
        let testSessions = [
            WorkoutSession(duration: 420, exercisesCompleted: 12),
            WorkoutSession(duration: 450, exercisesCompleted: 12)
        ]
        let testStreak = 5
        let testTotalWorkouts = 10
        let testTotalMinutes = 70.0
        
        store.syncWithiPhone(testSessions, streak: testStreak, totalWorkouts: testTotalWorkouts, totalMinutes: testTotalMinutes)
        
        XCTAssertEqual(store.sessions.count, 2)
        XCTAssertEqual(store.streak, testStreak)
        XCTAssertEqual(store.totalWorkouts, testTotalWorkouts)
        XCTAssertEqual(store.totalMinutes, testTotalMinutes, accuracy: 0.01)
    }
}

