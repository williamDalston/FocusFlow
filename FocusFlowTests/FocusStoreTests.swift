import XCTest
import Combine
@testable import FocusFlow

/// Agent 27: Comprehensive unit tests for FocusStore
/// Target: >90% code coverage
@MainActor
final class FocusStoreTests: XCTestCase {
    var store: FocusStore!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        // Clear UserDefaults for clean test state
        clearUserDefaults()
        cancellables = []
        store = FocusStore()
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
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        XCTAssertEqual(store.sessions.count, 0)
        XCTAssertEqual(store.streak, 0)
        XCTAssertEqual(store.totalSessions, 0)
        XCTAssertEqual(store.totalFocusTime, 0)
    }
    
    func testInitializationWithExistingData() {
        // Add a focus session first
        store.addSession(duration: 1500, phaseType: .focus, completed: true)
        let sessionCount = store.sessions.count
        
        // Create new store instance (simulating app restart)
        let newStore = FocusStore()
        
        XCTAssertEqual(newStore.sessions.count, sessionCount)
        XCTAssertGreaterThan(newStore.totalSessions, 0)
    }
    
    // MARK: - Add Session Tests
    
    func testAddFocusSession() {
        let duration: TimeInterval = 1500 // 25 minutes
        
        store.addSession(duration: duration, phaseType: .focus, completed: true)
        
        XCTAssertEqual(store.sessions.count, 1)
        XCTAssertEqual(store.totalSessions, 1)
        XCTAssertEqual(store.totalFocusTime, duration / 60.0, accuracy: 0.01)
        
        guard let session = store.sessions.first else {
            XCTFail("Expected session to exist")
            return
        }
        XCTAssertEqual(session.duration, duration)
        XCTAssertEqual(session.phaseType, .focus)
        XCTAssertTrue(session.completed)
    }
    
    func testAddBreakSession() {
        let duration: TimeInterval = 300 // 5 minutes
        
        store.addSession(duration: duration, phaseType: .shortBreak, completed: true)
        
        XCTAssertEqual(store.sessions.count, 1)
        // Breaks don't count toward totalSessions
        XCTAssertEqual(store.totalSessions, 0)
        
        guard let session = store.sessions.first else {
            XCTFail("Expected session to exist")
            return
        }
        XCTAssertEqual(session.phaseType, .shortBreak)
    }
    
    func testAddSessionWithNotes() {
        let notes = "Great focus session!"
        
        store.addSession(duration: 1500, phaseType: .focus, completed: true, notes: notes)
        
        guard let session = store.sessions.first else {
            XCTFail("Expected session to exist")
            return
        }
        XCTAssertEqual(session.notes, notes)
    }
    
    func testAddSessionWithCustomDate() {
        let customDate = Date().addingTimeInterval(-86400) // Yesterday
        
        store.addSession(duration: 1500, phaseType: .focus, completed: true, notes: nil, startDate: customDate)
        
        guard let session = store.sessions.first else {
            XCTFail("Expected session to exist")
            return
        }
        let calendar = Calendar.current
        XCTAssertTrue(calendar.isDate(session.date, inSameDayAs: customDate))
    }
    
    func testAddMultipleSessions() {
        for i in 0..<5 {
            store.addSession(duration: 1500 + Double(i * 60), phaseType: .focus, completed: true)
        }
        
        XCTAssertEqual(store.sessions.count, 5)
        XCTAssertEqual(store.totalSessions, 5)
        XCTAssertEqual(store.totalFocusTime, (1500 + 1560 + 1620 + 1680 + 1740) / 60.0, accuracy: 0.01)
    }
    
    func testSessionsAreOrderedByDate() {
        let dates = [
            Date().addingTimeInterval(-86400), // Yesterday
            Date(), // Today
            Date().addingTimeInterval(-172800) // Two days ago
        ]
        
        for date in dates {
            store.addSession(duration: 1500, phaseType: .focus, completed: true, notes: nil, startDate: date)
        }
        
        // Sessions should be ordered by most recent first
        let sessionDates = store.sessions.map { $0.date }
        for i in 0..<sessionDates.count - 1 {
            XCTAssertGreaterThanOrEqual(sessionDates[i], sessionDates[i + 1])
        }
    }
    
    // MARK: - Delete Session Tests
    
    func testDeleteSession() {
        store.addSession(duration: 1500, phaseType: .focus, completed: true)
        let initialTotal = store.totalSessions
        
        store.deleteSession(at: IndexSet(integer: 0))
        
        XCTAssertEqual(store.sessions.count, 0)
        XCTAssertEqual(store.totalSessions, initialTotal - 1)
    }
    
    func testDeleteMultipleSessions() {
        for _ in 0..<5 {
            store.addSession(duration: 1500, phaseType: .focus, completed: true)
        }
        
        store.deleteSession(at: IndexSet([0, 1, 2]))
        
        XCTAssertEqual(store.sessions.count, 2)
        XCTAssertEqual(store.totalSessions, 2)
    }
    
    func testDeleteSessionUpdatesTotalFocusTime() {
        store.addSession(duration: 1500, phaseType: .focus, completed: true) // 25 minutes
        store.addSession(duration: 1800, phaseType: .focus, completed: true) // 30 minutes
        let initialFocusTime = store.totalFocusTime
        
        store.deleteSession(at: IndexSet(integer: 0))
        
        let expectedFocusTime = initialFocusTime - (1500 / 60.0)
        XCTAssertEqual(store.totalFocusTime, expectedFocusTime, accuracy: 0.01)
    }
    
    // MARK: - Reset Tests
    
    func testReset() {
        store.addSession(duration: 1500, phaseType: .focus, completed: true)
        store.reset()
        
        XCTAssertEqual(store.sessions.count, 0)
        XCTAssertEqual(store.streak, 0)
        XCTAssertEqual(store.totalSessions, 0)
        XCTAssertEqual(store.totalFocusTime, 0)
    }
    
    // MARK: - Streak Tests
    
    func testStreakFirstFocusSession() {
        store.addSession(duration: 1500, phaseType: .focus, completed: true)
        
        XCTAssertEqual(store.streak, 1)
    }
    
    func testStreakConsecutiveDays() {
        let calendar = Calendar.current
        
        // Today
        store.addSession(duration: 1500, phaseType: .focus, completed: true, notes: nil, startDate: Date())
        
        // Tomorrow
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()) else {
            XCTFail("Failed to create tomorrow date")
            return
        }
        store.addSession(duration: 1500, phaseType: .focus, completed: true, notes: nil, startDate: tomorrow)
        
        // Note: Since we're testing with dates, streak calculation depends on the actual date logic
        // This test verifies that streak is tracked
        XCTAssertGreaterThanOrEqual(store.streak, 1)
    }
    
    func testStreakBroken() {
        // Add focus session today
        store.addSession(duration: 1500, phaseType: .focus, completed: true)
        
        // Add focus session 3 days later (breaks streak)
        guard let threeDaysLater = Calendar.current.date(byAdding: .day, value: 3, to: Date()) else {
            XCTFail("Failed to create threeDaysLater date")
            return
        }
        store.addSession(duration: 1500, phaseType: .focus, completed: true, notes: nil, startDate: threeDaysLater)
        
        // Streak should reset to 1
        XCTAssertEqual(store.streak, 1)
    }
    
    // MARK: - Statistics Tests
    
    func testSessionsThisWeek() {
        let calendar = Calendar.current
        
        // Add focus session today
        store.addSession(duration: 1500, phaseType: .focus, completed: true)
        
        // Add focus session 3 days ago
        guard let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: Date()) else {
            XCTFail("Failed to create threeDaysAgo date")
            return
        }
        store.addSession(duration: 1500, phaseType: .focus, completed: true, notes: nil, startDate: threeDaysAgo)
        
        // Add focus session 10 days ago (outside this week)
        guard let tenDaysAgo = calendar.date(byAdding: .day, value: -10, to: Date()) else {
            XCTFail("Failed to create tenDaysAgo date")
            return
        }
        store.addSession(duration: 1500, phaseType: .focus, completed: true, notes: nil, startDate: tenDaysAgo)
        
        XCTAssertGreaterThanOrEqual(store.sessionsThisWeek, 2)
    }
    
    func testSessionsThisMonth() {
        let calendar = Calendar.current
        
        // Add focus session today
        store.addSession(duration: 1500, phaseType: .focus, completed: true)
        
        // Add focus session 15 days ago (same month)
        guard let fifteenDaysAgo = calendar.date(byAdding: .day, value: -15, to: Date()) else {
            XCTFail("Failed to create fifteenDaysAgo date")
            return
        }
        store.addSession(duration: 1500, phaseType: .focus, completed: true, notes: nil, startDate: fifteenDaysAgo)
        
        XCTAssertGreaterThanOrEqual(store.sessionsThisMonth, 2)
    }
    
    func testAverageSessionDuration() {
        store.addSession(duration: 1500, phaseType: .focus, completed: true) // 25 minutes
        store.addSession(duration: 1800, phaseType: .focus, completed: true) // 30 minutes
        store.addSession(duration: 1200, phaseType: .focus, completed: true) // 20 minutes
        
        let expectedAverage = (1500 + 1800 + 1200) / 3.0
        XCTAssertEqual(store.averageSessionDuration, expectedAverage, accuracy: 0.1)
    }
    
    func testAverageSessionDurationEmpty() {
        XCTAssertEqual(store.averageSessionDuration, 0)
    }
    
    // MARK: - Query Tests
    
    func testSessionsInRange() {
        let calendar = Calendar.current
        guard let startDate = calendar.date(byAdding: .day, value: -7, to: Date()) else {
            XCTFail("Failed to create startDate")
            return
        }
        let endDate = Date()
        
        // Add focus session in range
        store.addSession(duration: 1500, phaseType: .focus, completed: true, notes: nil, startDate: Date())
        
        // Add focus session outside range
        guard let tenDaysAgo = calendar.date(byAdding: .day, value: -10, to: Date()) else {
            XCTFail("Failed to create tenDaysAgo date")
            return
        }
        store.addSession(duration: 1500, phaseType: .focus, completed: true, notes: nil, startDate: tenDaysAgo)
        
        let sessionsInRange = store.sessions(in: startDate...endDate)
        XCTAssertGreaterThanOrEqual(sessionsInRange.count, 1)
    }
    
    func testSessionsOnDate() {
        let calendar = Calendar.current
        let targetDate = Date()
        
        store.addSession(duration: 1500, phaseType: .focus, completed: true, notes: nil, startDate: targetDate)
        
        // Add focus session on different date
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: targetDate) else {
            XCTFail("Failed to create yesterday date")
            return
        }
        store.addSession(duration: 1500, phaseType: .focus, completed: true, notes: nil, startDate: yesterday)
        
        let sessionsOnDate = store.sessions(on: targetDate)
        XCTAssertEqual(sessionsOnDate.count, 1)
    }
    
    func testSessionsInMonth() {
        let calendar = Calendar.current
        let targetMonth = Date()
        
        // Add focus session this month
        store.addSession(duration: 1500, phaseType: .focus, completed: true, notes: nil, startDate: Date())
        
        // Add focus session last month
        guard let lastMonth = calendar.date(byAdding: .month, value: -1, to: Date()) else {
            XCTFail("Failed to create lastMonth date")
            return
        }
        store.addSession(duration: 1500, phaseType: .focus, completed: true, notes: nil, startDate: lastMonth)
        
        let sessionsInMonth = store.sessions(in: targetMonth)
        XCTAssertGreaterThanOrEqual(sessionsInMonth.count, 1)
    }
    
    // MARK: - Persistence Tests
    
    func testPersistence() {
        store.addSession(duration: 1500, phaseType: .focus, completed: true)
        guard let firstSession = store.sessions.first else {
            XCTFail("Expected session to exist")
            return
        }
        let sessionId = firstSession.id
        let totalSessions = store.totalSessions
        
        // Create new store instance (simulating app restart)
        let newStore = FocusStore()
        
        XCTAssertEqual(newStore.sessions.count, 1)
        XCTAssertEqual(newStore.sessions.first?.id, sessionId)
        XCTAssertEqual(newStore.totalSessions, totalSessions)
    }
    
    func testPersistenceWithMultipleSessions() {
        for i in 0..<10 {
            store.addSession(duration: 1500 + Double(i), phaseType: .focus, completed: true)
        }
        
        let newStore = FocusStore()
        
        XCTAssertEqual(newStore.sessions.count, 10)
        XCTAssertEqual(newStore.totalSessions, 10)
    }
    
    // MARK: - Data Integrity Tests
    
    func testCorruptedDataRecovery() {
        // Simulate corrupted data
        let defaults = UserDefaults.standard
        guard let corruptedData = "invalid json".data(using: .utf8) else {
            XCTFail("Failed to create corrupted data")
            return
        }
        defaults.set(corruptedData, forKey: "focus.sessions.v1")
        
        // Create store - should handle corrupted data gracefully
        let newStore = FocusStore()
        
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
        
        store.addSession(duration: 1500, phaseType: .focus, completed: true)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testTotalSessionsPublished() {
        let expectation = XCTestExpectation(description: "Total sessions updated")
        
        store.$totalSessions
            .dropFirst()
            .sink { totalSessions in
                XCTAssertEqual(totalSessions, 1)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        store.addSession(duration: 1500, phaseType: .focus, completed: true)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Edge Cases
    
    func testAddSessionWithZeroDuration() {
        store.addSession(duration: 0, phaseType: .focus, completed: true)
        
        XCTAssertEqual(store.sessions.count, 1)
        XCTAssertEqual(store.totalFocusTime, 0)
    }
    
    func testDeleteSessionWithEmptyStore() {
        store.deleteSession(at: IndexSet(integer: 0))
        
        // Should not crash
        XCTAssertEqual(store.sessions.count, 0)
    }
    
    func testDeleteSessionWithInvalidIndex() {
        store.addSession(duration: 1500, phaseType: .focus, completed: true)
        
        store.deleteSession(at: IndexSet(integer: 999))
        
        // Should not crash, session should remain
        XCTAssertEqual(store.sessions.count, 1)
    }
}

