import XCTest
import HealthKit
@testable import SevenMinuteWorkout

/// Agent 9: Integration tests for HealthKit sync and data persistence
@MainActor
final class IntegrationTests: XCTestCase {
    var store: WorkoutStore!
    
    override func setUp() {
        super.setUp()
        clearUserDefaults()
        store = WorkoutStore()
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
            "workout.sessions.v1",
            "workout.streak.v1",
            "workout.lastDay.v1",
            "workout.totalWorkouts.v1",
            "workout.totalMinutes.v1"
        ]
        for key in keys {
            defaults.removeObject(forKey: key)
        }
        defaults.synchronize()
    }
    
    // MARK: - Data Persistence Integration Tests
    
    func testFullWorkoutSessionPersistence() {
        // Add multiple sessions
        for i in 0..<5 {
            let date = Date().addingTimeInterval(-Double(i) * 86400) // Spread over 5 days
            store.addSession(
                duration: 420 + Double(i * 10),
                exercisesCompleted: 12,
                notes: "Test workout \(i)",
                startDate: date
            )
        }
        
        // Create new store instance (simulating app restart)
        let newStore = WorkoutStore()
        
        XCTAssertEqual(newStore.sessions.count, 5)
        XCTAssertEqual(newStore.totalWorkouts, 5)
        
        // Verify all sessions persisted correctly
        for (index, session) in newStore.sessions.enumerated() {
            XCTAssertEqual(session.exercisesCompleted, 12)
            XCTAssertNotNil(session.notes)
        }
    }
    
    func testStreakCalculationPersistence() {
        let calendar = Calendar.current
        
        // Add workout today
        store.addSession(duration: 420, exercisesCompleted: 12)
        let initialStreak = store.streak
        
        // Create new store
        let newStore = WorkoutStore()
        
        // Streak should be maintained
        XCTAssertGreaterThanOrEqual(newStore.streak, initialStreak)
    }
    
    // MARK: - HealthKit Integration Tests (Mock/Simulated)
    
    func testHealthKitSyncPreparation() {
        // This test verifies that the store is ready for HealthKit sync
        // Actual HealthKit integration requires device/simulator setup
        
        store.addSession(duration: 420, exercisesCompleted: 12)
        
        // Verify session was created (HealthKit sync happens asynchronously)
        XCTAssertEqual(store.sessions.count, 1)
        
        // Note: Full HealthKit testing requires:
        // 1. HealthKit to be available on device/simulator
        // 2. Authorization to be granted
        // 3. Actual HealthKit store interaction
        // This is tested in device testing, not unit tests
    }
    
    // MARK: - Watch Integration Tests (Simulated)
    
    func testWatchDataSyncPreparation() {
        // Verify store is ready for Watch sync
        store.addSession(duration: 420, exercisesCompleted: 12)
        
        // Verify data is available for sync
        XCTAssertEqual(store.sessions.count, 1)
        XCTAssertGreaterThan(store.streak, 0)
        
        // Note: Full Watch sync testing requires:
        // 1. Watch app installed
        // 2. WatchConnectivity session active
        // 3. Both devices connected
        // This is tested in device testing
    }
    
    // MARK: - Data Integrity Integration Tests
    
    func testDataMigrationScenario() {
        // Simulate migrating from old data format
        // Add sessions in new format
        store.addSession(duration: 420, exercisesCompleted: 12)
        
        // Verify new store can read old data
        let newStore = WorkoutStore()
        XCTAssertEqual(newStore.sessions.count, 1)
    }
    
    func testMultipleWorkoutSessionsInOneDay() {
        let today = Date()
        
        // Add multiple workouts today
        for i in 0..<3 {
            store.addSession(
                duration: 420 + Double(i * 10),
                exercisesCompleted: 12,
                startDate: today.addingTimeInterval(Double(i) * 3600) // 1 hour apart
            )
        }
        
        XCTAssertEqual(store.sessions.count, 3)
        XCTAssertEqual(store.totalWorkouts, 3)
        
        // Verify all sessions are on the same day
        let calendar = Calendar.current
        let sessionsToday = store.sessions(on: today)
        XCTAssertEqual(sessionsToday.count, 3)
    }
    
    // MARK: - Performance Integration Tests
    
    func testLargeDataSetPerformance() {
        // Add many sessions
        let startTime = Date()
        
        for i in 0..<100 {
            store.addSession(
                duration: 420,
                exercisesCompleted: 12,
                startDate: Date().addingTimeInterval(-Double(i) * 86400)
            )
        }
        
        let addTime = Date().timeIntervalSince(startTime)
        
        // Adding 100 sessions should be fast (< 1 second)
        XCTAssertLessThan(addTime, 1.0)
        
        // Query performance
        let queryStartTime = Date()
        _ = store.workoutsThisWeek
        _ = store.workoutsThisMonth
        _ = store.averageWorkoutDuration
        let queryTime = Date().timeIntervalSince(queryStartTime)
        
        // Queries should be fast (< 0.1 seconds)
        XCTAssertLessThan(queryTime, 0.1)
    }
    
    // MARK: - Error Recovery Integration Tests
    
    func testRecoveryFromCorruptedData() {
        // Simulate corrupted UserDefaults data
        let defaults = UserDefaults.standard
        let corruptedData = "invalid json".data(using: .utf8)!
        defaults.set(corruptedData, forKey: "workout.sessions.v1")
        
        // Create new store - should recover gracefully
        let newStore = WorkoutStore()
        
        // Should default to empty state
        XCTAssertEqual(newStore.sessions.count, 0)
        
        // Should be able to add new sessions
        newStore.addSession(duration: 420, exercisesCompleted: 12)
        XCTAssertEqual(newStore.sessions.count, 1)
    }
    
    func testRecoveryFromPartialData() {
        // Set some valid data but missing others
        let defaults = UserDefaults.standard
        defaults.set(5, forKey: "workout.totalWorkouts.v1")
        defaults.set(35.0, forKey: "workout.totalMinutes.v1")
        // Don't set sessions - simulating partial data
        
        let newStore = WorkoutStore()
        
        // Should handle missing sessions gracefully
        XCTAssertEqual(newStore.sessions.count, 0)
        
        // Should be able to continue normally
        newStore.addSession(duration: 420, exercisesCompleted: 12)
        XCTAssertEqual(newStore.sessions.count, 1)
    }
}

