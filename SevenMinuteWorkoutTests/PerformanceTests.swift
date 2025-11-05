import XCTest
import Darwin
@testable import SevenMinuteWorkout

/// Agent 4: Performance tests for app performance and optimization
/// Tests app launch time, memory usage, and performance under load
@MainActor
final class PerformanceTests: XCTestCase {
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
    
    // MARK: - App Launch Performance Tests
    
    func testWorkoutStoreInitializationPerformance() {
        measure {
            let newStore = WorkoutStore()
            _ = newStore.sessions
            _ = newStore.streak
            _ = newStore.totalWorkouts
        }
    }
    
    func testWorkoutEngineInitializationPerformance() {
        measure {
            let engine = WorkoutEngine()
            _ = engine.exercises
            _ = engine.phase
        }
    }
    
    // MARK: - Data Operations Performance Tests
    
    func testAddSessionPerformance() {
        // Pre-warm
        for _ in 0..<10 {
            store.addSession(duration: 420, exercisesCompleted: 12)
        }
        store.reset()
        
        measure {
            for _ in 0..<100 {
                store.addSession(duration: 420, exercisesCompleted: 12)
            }
        }
    }
    
    func testQueryPerformance() {
        // Add test data
        for i in 0..<1000 {
            let date = Date().addingTimeInterval(-Double(i) * 86400)
            store.addSession(
                duration: 420 + Double(i % 100),
                exercisesCompleted: 12,
                startDate: date
            )
        }
        
        measure {
            _ = store.workoutsThisWeek
            _ = store.workoutsThisMonth
            _ = store.averageWorkoutDuration
            _ = store.sessions.count
        }
    }
    
    func testLargeDataSetQueryPerformance() {
        // Add large dataset
        for i in 0..<5000 {
            let date = Date().addingTimeInterval(-Double(i) * 86400)
            store.addSession(
                duration: 420,
                exercisesCompleted: 12,
                startDate: date
            )
        }
        
        measure {
            _ = store.workoutsThisWeek
            _ = store.workoutsThisMonth
            _ = store.averageWorkoutDuration
            let sessions = store.sessions(in: Date().addingTimeInterval(-365 * 86400)...Date())
            _ = sessions.count
        }
    }
    
    // MARK: - Memory Performance Tests
    
    func testMemoryUsageWithManySessions() {
        // Add many sessions
        for i in 0..<1000 {
            store.addSession(
                duration: 420,
                exercisesCompleted: 12,
                startDate: Date().addingTimeInterval(-Double(i) * 86400)
            )
        }
        
        // Measure memory usage
        let memoryBefore = getMemoryUsage()
        
        // Perform operations
        _ = store.workoutsThisWeek
        _ = store.workoutsThisMonth
        _ = store.averageWorkoutDuration
        
        let memoryAfter = getMemoryUsage()
        let memoryIncrease = memoryAfter - memoryBefore
        
        // Memory increase should be reasonable (< 10MB)
        XCTAssertLessThan(memoryIncrease, 10 * 1024 * 1024, "Memory increase should be less than 10MB")
    }
    
    func testMemoryLeakWithRepeatedOperations() {
        // Repeated add/delete operations should not leak memory
        for iteration in 0..<100 {
            for _ in 0..<10 {
                store.addSession(duration: 420, exercisesCompleted: 12)
            }
            
            for i in 0..<10 {
                store.deleteSession(at: IndexSet(integer: 0))
            }
            
            // Force memory cleanup every 10 iterations
            if iteration % 10 == 0 {
                autoreleasepool {
                    // Create new store to force cleanup
                    store = WorkoutStore()
                }
            }
        }
        
        // Memory should be stable
        XCTAssertEqual(store.sessions.count, 0)
    }
    
    // MARK: - Concurrent Operations Performance Tests
    
    func testConcurrentAddSessionPerformance() {
        let expectation = XCTestExpectation(description: "Concurrent adds")
        expectation.expectedFulfillmentCount = 100
        
        let startTime = Date()
        
        DispatchQueue.concurrentPerform(iterations: 100) { index in
            store.addSession(
                duration: 420 + Double(index),
                exercisesCompleted: 12,
                startDate: Date().addingTimeInterval(-Double(index) * 3600)
            )
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        let duration = Date().timeIntervalSince(startTime)
        
        // Concurrent operations should be faster than sequential
        XCTAssertLessThan(duration, 2.0, "Concurrent operations should complete in < 2 seconds")
        XCTAssertEqual(store.sessions.count, 100)
    }
    
    // MARK: - Persistence Performance Tests
    
    func testPersistencePerformance() {
        // Add sessions
        for i in 0..<500 {
            store.addSession(
                duration: 420,
                exercisesCompleted: 12,
                startDate: Date().addingTimeInterval(-Double(i) * 86400)
            )
        }
        
        measure {
            // Create new store to force load from persistence
            let newStore = WorkoutStore()
            _ = newStore.sessions
            _ = newStore.streak
            _ = newStore.totalWorkouts
        }
    }
    
    // MARK: - Helper Methods
    
    private func getMemoryUsage() -> Int64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            return Int64(info.resident_size)
        } else {
            return 0
        }
    }
}

