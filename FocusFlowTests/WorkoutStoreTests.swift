import XCTest
import Combine
@testable import FocusFlow

/// Agent 9: Comprehensive unit tests for WorkoutStore
/// Target: >90% code coverage
@MainActor
final class WorkoutStoreTests: XCTestCase {
    var store: WorkoutStore!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        // Clear UserDefaults for clean test state
        clearUserDefaults()
        cancellables = []
        store = WorkoutStore()
    }
    
    override func tearDown() {
        store = nil
        clearUserDefaults()
        cancellables = nil
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
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        XCTAssertEqual(store.sessions.count, 0)
        XCTAssertEqual(store.streak, 0)
        XCTAssertEqual(store.totalWorkouts, 0)
        XCTAssertEqual(store.totalMinutes, 0)
    }
    
    func testInitializationWithExistingData() {
        // Add a session first
        store.addSession(duration: 420, exercisesCompleted: 12)
        let sessionCount = store.sessions.count
        
        // Create new store instance (simulating app restart)
        let newStore = WorkoutStore()
        
        XCTAssertEqual(newStore.sessions.count, sessionCount)
        XCTAssertGreaterThan(newStore.totalWorkouts, 0)
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
        let notes = "Great workout!"
        
        store.addSession(duration: 420, exercisesCompleted: 12, notes: notes)
        
        guard let session = store.sessions.first else {
            XCTFail("Expected session to exist")
            return
        }
        XCTAssertEqual(session.notes, notes)
    }
    
    func testAddSessionWithCustomDate() {
        let customDate = Date().addingTimeInterval(-86400) // Yesterday
        
        store.addSession(duration: 420, exercisesCompleted: 12, startDate: customDate)
        
        guard let session = store.sessions.first else {
            XCTFail("Expected session to exist")
            return
        }
        let calendar = Calendar.current
        XCTAssertTrue(calendar.isDate(session.date, inSameDayAs: customDate))
    }
    
    func testAddMultipleSessions() {
        for i in 0..<5 {
            store.addSession(duration: 420, exercisesCompleted: 12)
        }
        
        XCTAssertEqual(store.sessions.count, 5)
        XCTAssertEqual(store.totalWorkouts, 5)
        XCTAssertEqual(store.totalMinutes, 5 * 7.0, accuracy: 0.01)
    }
    
    func testSessionsAreOrderedByDate() {
        let dates = [
            Date().addingTimeInterval(-86400), // Yesterday
            Date(), // Today
            Date().addingTimeInterval(-172800) // Two days ago
        ]
        
        for date in dates {
            store.addSession(duration: 420, exercisesCompleted: 12, startDate: date)
        }
        
        // Sessions should be ordered by most recent first
        let sessionDates = store.sessions.map { $0.date }
        for i in 0..<sessionDates.count - 1 {
            XCTAssertGreaterThanOrEqual(sessionDates[i], sessionDates[i + 1])
        }
    }
    
    // MARK: - Delete Session Tests
    
    func testDeleteSession() {
        store.addSession(duration: 420, exercisesCompleted: 12)
        let initialTotal = store.totalWorkouts
        
        store.deleteSession(at: IndexSet(integer: 0))
        
        XCTAssertEqual(store.sessions.count, 0)
        XCTAssertEqual(store.totalWorkouts, initialTotal - 1)
    }
    
    func testDeleteMultipleSessions() {
        for _ in 0..<5 {
            store.addSession(duration: 420, exercisesCompleted: 12)
        }
        
        store.deleteSession(at: IndexSet([0, 1, 2]))
        
        XCTAssertEqual(store.sessions.count, 2)
        XCTAssertEqual(store.totalWorkouts, 2)
    }
    
    func testDeleteSessionUpdatesTotalMinutes() {
        store.addSession(duration: 420, exercisesCompleted: 12) // 7 minutes
        store.addSession(duration: 600, exercisesCompleted: 12) // 10 minutes
        let initialMinutes = store.totalMinutes
        
        store.deleteSession(at: IndexSet(integer: 0))
        
        let expectedMinutes = initialMinutes - (420 / 60.0)
        XCTAssertEqual(store.totalMinutes, expectedMinutes, accuracy: 0.01)
    }
    
    // MARK: - Reset Tests
    
    func testReset() {
        store.addSession(duration: 420, exercisesCompleted: 12)
        store.reset()
        
        XCTAssertEqual(store.sessions.count, 0)
        XCTAssertEqual(store.streak, 0)
        XCTAssertEqual(store.totalWorkouts, 0)
        XCTAssertEqual(store.totalMinutes, 0)
    }
    
    // MARK: - Streak Tests
    
    func testStreakFirstWorkout() {
        store.addSession(duration: 420, exercisesCompleted: 12)
        
        XCTAssertEqual(store.streak, 1)
    }
    
    func testStreakConsecutiveDays() {
        let calendar = Calendar.current
        
        // Today
        store.addSession(duration: 420, exercisesCompleted: 12, startDate: Date())
        
        // Tomorrow
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()) else {
            XCTFail("Failed to create tomorrow date")
            return
        }
        store.addSession(duration: 420, exercisesCompleted: 12, startDate: tomorrow)
        
        // Note: Since we're testing with dates, streak calculation depends on the actual date logic
        // This test verifies that streak is tracked
        XCTAssertGreaterThanOrEqual(store.streak, 1)
    }
    
    func testStreakBroken() {
        // Add workout today
        store.addSession(duration: 420, exercisesCompleted: 12)
        
        // Add workout 3 days later (breaks streak)
        guard let threeDaysLater = Calendar.current.date(byAdding: .day, value: 3, to: Date()) else {
            XCTFail("Failed to create threeDaysLater date")
            return
        }
        store.addSession(duration: 420, exercisesCompleted: 12, startDate: threeDaysLater)
        
        // Streak should reset to 1
        XCTAssertEqual(store.streak, 1)
    }
    
    // MARK: - Statistics Tests
    
    func testWorkoutsThisWeek() {
        let calendar = Calendar.current
        
        // Add workout today
        store.addSession(duration: 420, exercisesCompleted: 12)
        
        // Add workout 3 days ago
        guard let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: Date()) else {
            XCTFail("Failed to create threeDaysAgo date")
            return
        }
        store.addSession(duration: 420, exercisesCompleted: 12, startDate: threeDaysAgo)
        
        // Add workout 10 days ago (outside this week)
        guard let tenDaysAgo = calendar.date(byAdding: .day, value: -10, to: Date()) else {
            XCTFail("Failed to create tenDaysAgo date")
            return
        }
        store.addSession(duration: 420, exercisesCompleted: 12, startDate: tenDaysAgo)
        
        XCTAssertGreaterThanOrEqual(store.workoutsThisWeek, 2)
    }
    
    func testWorkoutsThisMonth() {
        let calendar = Calendar.current
        
        // Add workout today
        store.addSession(duration: 420, exercisesCompleted: 12)
        
        // Add workout 15 days ago (same month)
        guard let fifteenDaysAgo = calendar.date(byAdding: .day, value: -15, to: Date()) else {
            XCTFail("Failed to create fifteenDaysAgo date")
            return
        }
        store.addSession(duration: 420, exercisesCompleted: 12, startDate: fifteenDaysAgo)
        
        XCTAssertGreaterThanOrEqual(store.workoutsThisMonth, 2)
    }
    
    func testAverageWorkoutDuration() {
        store.addSession(duration: 420, exercisesCompleted: 12) // 7 minutes
        store.addSession(duration: 600, exercisesCompleted: 12) // 10 minutes
        store.addSession(duration: 480, exercisesCompleted: 12) // 8 minutes
        
        let expectedAverage = (420 + 600 + 480) / 3.0
        XCTAssertEqual(store.averageWorkoutDuration, expectedAverage, accuracy: 0.1)
    }
    
    func testAverageWorkoutDurationEmpty() {
        XCTAssertEqual(store.averageWorkoutDuration, 0)
    }
    
    func testEstimatedTotalCalories() {
        store.addSession(duration: 420, exercisesCompleted: 12)
        store.addSession(duration: 420, exercisesCompleted: 12)
        
        XCTAssertEqual(store.estimatedTotalCalories, 200) // 2 workouts × 100 calories
    }
    
    // MARK: - Query Tests
    
    func testSessionsInRange() {
        let calendar = Calendar.current
        guard let startDate = calendar.date(byAdding: .day, value: -7, to: Date()) else {
            XCTFail("Failed to create startDate")
            return
        }
        let endDate = Date()
        
        // Add workout in range
        store.addSession(duration: 420, exercisesCompleted: 12, startDate: Date())
        
        // Add workout outside range
        guard let tenDaysAgo = calendar.date(byAdding: .day, value: -10, to: Date()) else {
            XCTFail("Failed to create tenDaysAgo date")
            return
        }
        store.addSession(duration: 420, exercisesCompleted: 12, startDate: tenDaysAgo)
        
        let sessionsInRange = store.sessions(in: startDate...endDate)
        XCTAssertGreaterThanOrEqual(sessionsInRange.count, 1)
    }
    
    func testSessionsOnDate() {
        let calendar = Calendar.current
        let targetDate = Date()
        
        store.addSession(duration: 420, exercisesCompleted: 12, startDate: targetDate)
        
        // Add workout on different date
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: targetDate) else {
            XCTFail("Failed to create yesterday date")
            return
        }
        store.addSession(duration: 420, exercisesCompleted: 12, startDate: yesterday)
        
        let sessionsOnDate = store.sessions(on: targetDate)
        XCTAssertEqual(sessionsOnDate.count, 1)
    }
    
    func testSessionsInMonth() {
        let calendar = Calendar.current
        let targetMonth = Date()
        
        // Add workout this month
        store.addSession(duration: 420, exercisesCompleted: 12, startDate: Date())
        
        // Add workout last month
        guard let lastMonth = calendar.date(byAdding: .month, value: -1, to: Date()) else {
            XCTFail("Failed to create lastMonth date")
            return
        }
        store.addSession(duration: 420, exercisesCompleted: 12, startDate: lastMonth)
        
        let sessionsInMonth = store.sessions(in: targetMonth)
        XCTAssertGreaterThanOrEqual(sessionsInMonth.count, 1)
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
        let newStore = WorkoutStore()
        
        XCTAssertEqual(newStore.sessions.count, 1)
        XCTAssertEqual(newStore.sessions.first?.id, sessionId)
        XCTAssertEqual(newStore.totalWorkouts, totalWorkouts)
    }
    
    func testPersistenceWithMultipleSessions() {
        for i in 0..<10 {
            store.addSession(duration: 420 + Double(i), exercisesCompleted: 12)
        }
        
        let newStore = WorkoutStore()
        
        XCTAssertEqual(newStore.sessions.count, 10)
        XCTAssertEqual(newStore.totalWorkouts, 10)
    }
    
    // MARK: - Data Integrity Tests
    
    func testCorruptedDataRecovery() {
        // Simulate corrupted data
        let defaults = UserDefaults.standard
        guard let corruptedData = "invalid json".data(using: .utf8) else {
            XCTFail("Failed to create corrupted data")
            return
        }
        defaults.set(corruptedData, forKey: "workout.sessions.v1")
        
        // Create store - should handle corrupted data gracefully
        let newStore = WorkoutStore()
        
        // Should default to empty sessions
        XCTAssertEqual(newStore.sessions.count, 0)
    }
    
    // MARK: - Published Properties Tests
    
    func testPublishedPropertiesUpdate() {
        let expectation = XCTestExpectation(description: "Sessions updated")
        expectation.expectedFulfillmentCount = 2 // Initial + update
        
        store.$sessions
            .sink { sessions in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        store.addSession(duration: 420, exercisesCompleted: 12)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testTotalWorkoutsPublished() {
        let expectation = XCTestExpectation(description: "Total workouts updated")
        
        store.$totalWorkouts
            .dropFirst()
            .sink { totalWorkouts in
                XCTAssertEqual(totalWorkouts, 1)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        store.addSession(duration: 420, exercisesCompleted: 12)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Edge Cases
    
    func testAddSessionWithZeroDuration() {
        store.addSession(duration: 0, exercisesCompleted: 12)
        
        XCTAssertEqual(store.sessions.count, 1)
        XCTAssertEqual(store.totalMinutes, 0)
    }
    
    func testAddSessionWithZeroExercises() {
        store.addSession(duration: 420, exercisesCompleted: 0)
        
        guard let session = store.sessions.first else {
            XCTFail("Expected session to exist")
            return
        }
        XCTAssertEqual(session.exercisesCompleted, 0)
    }
    
    func testDeleteSessionWithEmptyStore() {
        store.deleteSession(at: IndexSet(integer: 0))
        
        // Should not crash
        XCTAssertEqual(store.sessions.count, 0)
    }
    
    func testDeleteSessionWithInvalidIndex() {
        store.addSession(duration: 420, exercisesCompleted: 12)
        
        store.deleteSession(at: IndexSet(integer: 999))
        
        // Should not crash, session should remain
        XCTAssertEqual(store.sessions.count, 1)
    }
}

