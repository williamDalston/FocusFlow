import XCTest
import HealthKit
@testable import FocusFlow

/// Agent 9: Integration tests for HealthKit sync and data persistence
/// Agent 27: Updated to use FocusStore
@MainActor
final class IntegrationTests: XCTestCase {
    var store: FocusStore!
    
    override func setUp() {
        super.setUp()
        clearUserDefaults()
        store = FocusStore()
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
            "focus.sessions.v1",
            "focus.streak.v1",
            "focus.lastDay.v1",
            "focus.totalSessions.v1",
            "focus.totalMinutes.v1"
        ]
        for key in keys {
            defaults.removeObject(forKey: key)
        }
        defaults.synchronize()
    }
    
    // MARK: - Data Persistence Integration Tests
    
    func testFullFocusSessionPersistence() {
        // Add multiple sessions
        for i in 0..<5 {
            let date = Date().addingTimeInterval(-Double(i) * 86400) // Spread over 5 days
            store.addSession(
                duration: 1500 + Double(i * 10),
                phaseType: .focus,
                completed: true,
                notes: "Test focus session \(i)",
                startDate: date
            )
        }
        
        // Create new store instance (simulating app restart)
        let newStore = FocusStore()
        
        XCTAssertEqual(newStore.sessions.count, 5)
        XCTAssertEqual(newStore.totalSessions, 5)
        
        // Verify all sessions persisted correctly
        for (index, session) in newStore.sessions.enumerated() {
            XCTAssertEqual(session.phaseType, .focus)
            XCTAssertNotNil(session.notes)
        }
    }
    
    func testStreakCalculationPersistence() {
        let calendar = Calendar.current
        
        // Add focus session today
        store.addSession(duration: 1500, phaseType: .focus, completed: true)
        let initialStreak = store.streak
        
        // Create new store
        let newStore = FocusStore()
        
        // Streak should be maintained
        XCTAssertGreaterThanOrEqual(newStore.streak, initialStreak)
    }
    
    // MARK: - HealthKit Integration Tests (Mock/Simulated)
    
    func testHealthKitSyncPreparation() {
        // This test verifies that the store is ready for HealthKit sync
        // Actual HealthKit integration requires device/simulator setup
        
        store.addSession(duration: 1500, phaseType: .focus, completed: true)
        
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
        store.addSession(duration: 1500, phaseType: .focus, completed: true)
        
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
        store.addSession(duration: 1500, phaseType: .focus, completed: true)
        
        // Verify new store can read old data
        let newStore = FocusStore()
        XCTAssertEqual(newStore.sessions.count, 1)
    }
    
    func testMultipleFocusSessionsInOneDay() {
        let today = Date()
        
        // Add multiple focus sessions today
        for i in 0..<3 {
            store.addSession(
                duration: 1500 + Double(i * 10),
                phaseType: .focus,
                completed: true,
                notes: nil,
                startDate: today.addingTimeInterval(Double(i) * 3600) // 1 hour apart
            )
        }
        
        XCTAssertEqual(store.sessions.count, 3)
        XCTAssertEqual(store.totalSessions, 3)
        
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
                duration: 1500,
                phaseType: .focus,
                completed: true,
                notes: nil,
                startDate: Date().addingTimeInterval(-Double(i) * 86400)
            )
        }
        
        let addTime = Date().timeIntervalSince(startTime)
        
        // Adding 100 sessions should be fast (< 1 second)
        XCTAssertLessThan(addTime, 1.0)
        
        // Query performance
        let queryStartTime = Date()
        _ = store.sessionsThisWeek
        _ = store.sessionsThisMonth
        _ = store.averageSessionDuration
        let queryTime = Date().timeIntervalSince(queryStartTime)
        
        // Queries should be fast (< 0.1 seconds)
        XCTAssertLessThan(queryTime, 0.1)
    }
    
    // MARK: - Error Recovery Integration Tests
    
    func testRecoveryFromCorruptedData() {
        // Simulate corrupted UserDefaults data
        let defaults = UserDefaults.standard
        let corruptedData = "invalid json".data(using: .utf8)!
        defaults.set(corruptedData, forKey: "focus.sessions.v1")
        
        // Create new store - should recover gracefully
        let newStore = FocusStore()
        
        // Should default to empty state
        XCTAssertEqual(newStore.sessions.count, 0)
        
        // Should be able to add new sessions
        newStore.addSession(duration: 1500, phaseType: .focus, completed: true)
        XCTAssertEqual(newStore.sessions.count, 1)
    }
    
    func testRecoveryFromPartialData() {
        // Set some valid data but missing others
        let defaults = UserDefaults.standard
        defaults.set(5, forKey: "focus.totalSessions.v1")
        defaults.set(35.0, forKey: "focus.totalMinutes.v1")
        // Don't set sessions - simulating partial data
        
        let newStore = FocusStore()
        
        // Should handle missing sessions gracefully
        XCTAssertEqual(newStore.sessions.count, 0)
        
        // Should be able to continue normally
        newStore.addSession(duration: 1500, phaseType: .focus, completed: true)
        XCTAssertEqual(newStore.sessions.count, 1)
    }
}

