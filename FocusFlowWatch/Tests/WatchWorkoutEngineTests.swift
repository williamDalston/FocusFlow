import XCTest
@testable import FocusFlowWatch

/// Agent 4: Unit tests for WorkoutEngineWatch
/// Tests workout timer logic on Apple Watch
@MainActor
final class WatchWorkoutEngineTests: XCTestCase {
    var engine: WorkoutEngineWatch!
    
    override func setUp() {
        super.setUp()
        engine = WorkoutEngineWatch()
    }
    
    override func tearDown() {
        engine = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        XCTAssertEqual(engine.phase, .idle)
        XCTAssertNil(engine.currentExercise)
        XCTAssertEqual(engine.currentExerciseIndex, 0)
        XCTAssertEqual(engine.timeRemaining, 0)
        XCTAssertFalse(engine.isPaused)
        XCTAssertEqual(engine.exercises.count, 12)
    }
    
    // MARK: - Start Tests
    
    func testStartWorkout() {
        engine.start()
        
        XCTAssertEqual(engine.phase, .preparing)
        XCTAssertEqual(engine.currentExerciseIndex, 0)
        XCTAssertEqual(engine.timeRemaining, 10.0) // prepDuration
        XCTAssertFalse(engine.isPaused)
    }
    
    func testStartWorkoutWhenAlreadyInProgress() {
        engine.start()
        let initialPhase = engine.phase
        
        engine.start() // Should not change state
        
        XCTAssertEqual(engine.phase, initialPhase)
    }
    
    // MARK: - Pause Tests
    
    func testPauseDuringPrep() {
        engine.start()
        engine.pause()
        
        XCTAssertTrue(engine.isPaused)
        XCTAssertEqual(engine.phase, .preparing)
    }
    
    func testPauseWhenIdle() {
        engine.pause()
        
        XCTAssertFalse(engine.isPaused)
    }
    
    // MARK: - Resume Tests
    
    func testResumeAfterPause() {
        engine.start()
        engine.pause()
        engine.resume()
        
        XCTAssertFalse(engine.isPaused)
    }
    
    func testResumeWhenNotPaused() {
        engine.start()
        let initialPausedState = engine.isPaused
        
        engine.resume()
        
        XCTAssertEqual(engine.isPaused, initialPausedState)
    }
    
    // MARK: - Stop Tests
    
    func testStopWorkout() {
        engine.start()
        engine.stop()
        
        XCTAssertEqual(engine.phase, .idle)
        XCTAssertNil(engine.currentExercise)
        XCTAssertEqual(engine.currentExerciseIndex, 0)
        XCTAssertEqual(engine.timeRemaining, 0)
        XCTAssertFalse(engine.isPaused)
    }
    
    // MARK: - Skip Tests
    
    func testSkipPrep() {
        engine.start()
        engine.skipPrep()
        
        XCTAssertEqual(engine.phase, .exercise)
        XCTAssertNotNil(engine.currentExercise)
        XCTAssertEqual(engine.currentExerciseIndex, 0)
        XCTAssertEqual(engine.timeRemaining, 30.0) // exerciseDuration
    }
    
    func testSkipRest() {
        engine.start()
        engine.skipPrep() // Skip to first exercise
        // Wait for exercise to complete (simulated)
        engine.timeRemaining = 0
        // Manually trigger rest phase
        engine.skipRest()
        
        // Should move to next exercise
        XCTAssertEqual(engine.currentExerciseIndex, 1)
    }
    
    // MARK: - Computed Properties Tests
    
    func testTotalWorkoutDuration() {
        let expectedDuration = 10.0 + // prep
                               (12.0 * 30.0) + // 12 exercises × 30 seconds
                               (11.0 * 10.0) // 11 rest periods × 10 seconds
        XCTAssertEqual(engine.totalWorkoutDuration, expectedDuration, accuracy: 0.1)
    }
    
    func testCurrentSessionDuration() {
        XCTAssertNil(engine.currentSessionDuration) // Not started
        
        engine.start()
        guard let sessionDuration = engine.currentSessionDuration else {
            XCTFail("Expected currentSessionDuration to exist after starting")
            return
        }
        XCTAssertGreaterThanOrEqual(sessionDuration, 0)
    }
    
    func testProgress() {
        XCTAssertEqual(engine.progress, 0.0) // Idle
        
        engine.start()
        XCTAssertGreaterThanOrEqual(engine.progress, 0.0)
        XCTAssertLessThanOrEqual(engine.progress, 1.0)
    }
    
    func testExercisesRemaining() {
        XCTAssertEqual(engine.exercisesRemaining, 0) // Idle
        
        engine.start()
        XCTAssertEqual(engine.exercisesRemaining, 12) // All exercises remaining
    }
    
    func testNextExercise() {
        XCTAssertNil(engine.nextExercise) // Idle
        
        engine.start()
        XCTAssertNotNil(engine.nextExercise)
        XCTAssertEqual(engine.nextExercise?.name, Exercise.sevenMinuteWorkout[0].name)
    }
}

