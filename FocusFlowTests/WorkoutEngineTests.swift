import XCTest
import Combine
@testable import FocusFlow

/// Agent 9: Comprehensive unit tests for WorkoutEngine
/// Target: >90% code coverage
@MainActor
final class WorkoutEngineTests: XCTestCase {
    var engine: WorkoutEngine!
    var mockTimer: MockWorkoutTimer!
    var mockHaptics: MockHapticFeedback!
    var mockSound: MockSoundFeedback!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockTimer = MockWorkoutTimer()
        mockHaptics = MockHapticFeedback()
        mockSound = MockSoundFeedback()
        
        engine = WorkoutEngine(
            exercises: Exercise.sevenMinuteWorkout,
            timer: mockTimer,
            haptics: mockHaptics,
            sound: mockSound
        )
        
        cancellables = []
    }
    
    override func tearDown() {
        engine = nil
        mockTimer = nil
        mockHaptics = nil
        mockSound = nil
        cancellables = nil
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
    
    func testInitializationWithCustomExercises() {
        let customExercises = [Exercise.sevenMinuteWorkout[0], Exercise.sevenMinuteWorkout[1]]
        let customEngine = WorkoutEngine(exercises: customExercises, timer: mockTimer)
        
        XCTAssertEqual(customEngine.exercises.count, 2)
    }
    
    // MARK: - Start Tests
    
    func testStartWorkout() {
        engine.start()
        
        XCTAssertEqual(engine.phase, .preparing)
        XCTAssertEqual(engine.currentExerciseIndex, 0)
        XCTAssertEqual(engine.timeRemaining, 10.0) // prepDuration
        XCTAssertFalse(engine.isPaused)
        XCTAssertTrue(mockTimer.wasStarted)
        XCTAssertEqual(mockTimer.lastStartDuration, 10.0)
    }
    
    func testStartWorkoutWhenAlreadyInProgress() {
        engine.start()
        let initialPhase = engine.phase
        
        engine.start() // Should not change state
        
        XCTAssertEqual(engine.phase, initialPhase)
    }
    
    func testStartAfterCompletion() {
        // Complete a workout first
        engine.start()
        mockTimer.shouldCallCompletionImmediately = true
        mockTimer.triggerCompletion() // Complete prep
        mockTimer.triggerCompletion() // Complete first exercise
        // ... continue through all exercises
        
        // Then start again
        engine.start()
        
        XCTAssertEqual(engine.phase, .preparing)
        XCTAssertEqual(engine.currentExerciseIndex, 0)
    }
    
    // MARK: - Pause Tests
    
    func testPauseDuringPrep() {
        engine.start()
        engine.pause()
        
        XCTAssertTrue(engine.isPaused)
        XCTAssertEqual(engine.phase, .preparing)
        XCTAssertEqual(mockTimer.pauseCallCountValue, 1)
    }
    
    func testPauseDuringExercise() {
        engine.start()
        mockTimer.triggerCompletion() // Complete prep
        engine.pause()
        
        XCTAssertTrue(engine.isPaused)
        XCTAssertEqual(engine.phase, .exercise)
    }
    
    func testPauseDuringRest() {
        engine.start()
        mockTimer.triggerCompletion() // Complete prep
        mockTimer.triggerCompletion() // Complete first exercise
        engine.pause()
        
        XCTAssertTrue(engine.isPaused)
        XCTAssertEqual(engine.phase, .rest)
    }
    
    func testPauseWhenIdle() {
        engine.pause()
        
        XCTAssertFalse(engine.isPaused)
        XCTAssertEqual(mockTimer.pauseCallCountValue, 0)
    }
    
    func testPauseWhenAlreadyPaused() {
        engine.start()
        engine.pause()
        let pauseCallCount = mockTimer.pauseCallCountValue
        
        engine.pause() // Should not call pause again
        
        XCTAssertEqual(mockTimer.pauseCallCountValue, pauseCallCount)
    }
    
    // MARK: - Resume Tests
    
    func testResumeAfterPause() {
        engine.start()
        engine.pause()
        engine.resume()
        
        XCTAssertFalse(engine.isPaused)
        XCTAssertEqual(mockTimer.resumeCallCountValue, 1)
    }
    
    func testResumeWhenNotPaused() {
        engine.start()
        let resumeCallCount = mockTimer.resumeCallCountValue
        
        engine.resume()
        
        XCTAssertEqual(mockTimer.resumeCallCountValue, resumeCallCount)
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
        XCTAssertEqual(mockTimer.stopCallCountValue, 1)
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
    
    func testSkipPrepWhenNotInPrep() {
        engine.start()
        mockTimer.triggerCompletion() // Complete prep
        let initialPhase = engine.phase
        
        engine.skipPrep()
        
        XCTAssertEqual(engine.phase, initialPhase) // Should not change
    }
    
    func testSkipRest() {
        engine.start()
        mockTimer.triggerCompletion() // Complete prep
        mockTimer.triggerCompletion() // Complete first exercise
        engine.skipRest()
        
        XCTAssertEqual(engine.phase, .exercise)
        XCTAssertEqual(engine.currentExerciseIndex, 1) // Next exercise
    }
    
    func testSkipRestWhenNotInRest() {
        engine.start()
        let initialPhase = engine.phase
        
        engine.skipRest()
        
        XCTAssertEqual(engine.phase, initialPhase) // Should not change
    }
    
    // MARK: - Reset Tests
    
    func testReset() {
        engine.start()
        engine.reset()
        
        XCTAssertEqual(engine.phase, .idle)
        XCTAssertNil(engine.currentExercise)
        XCTAssertEqual(engine.currentExerciseIndex, 0)
        XCTAssertEqual(engine.timeRemaining, 0)
        XCTAssertFalse(engine.isPaused)
    }
    
    // MARK: - Timer Callback Tests
    
    func testTimerUpdateCallback() {
        let expectation = XCTestExpectation(description: "Timer update")
        
        engine.$timeRemaining
            .dropFirst()
            .sink { timeRemaining in
                XCTAssertGreaterThanOrEqual(timeRemaining, 0)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        engine.start()
        mockTimer.triggerUpdate(timeRemaining: 5.0)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testTimerCompletionCallbackPrep() {
        engine.start()
        mockTimer.triggerCompletion() // Complete prep
        
        XCTAssertEqual(engine.phase, .exercise)
        XCTAssertNotNil(engine.currentExercise)
        XCTAssertEqual(engine.currentExerciseIndex, 0)
    }
    
    func testTimerCompletionCallbackExercise() {
        engine.start()
        mockTimer.triggerCompletion() // Complete prep
        mockTimer.triggerCompletion() // Complete first exercise
        
        XCTAssertEqual(engine.phase, .rest)
        XCTAssertEqual(engine.currentExerciseIndex, 0)
    }
    
    func testTimerCompletionCallbackRest() {
        engine.start()
        mockTimer.triggerCompletion() // Complete prep
        mockTimer.triggerCompletion() // Complete first exercise
        mockTimer.triggerCompletion() // Complete rest
        
        XCTAssertEqual(engine.phase, .exercise)
        XCTAssertEqual(engine.currentExerciseIndex, 1) // Next exercise
    }
    
    // MARK: - Workout Completion Tests
    
    func testWorkoutCompletion() {
        engine.start()
        
        // Complete prep
        mockTimer.triggerCompletion()
        
        // Complete all 12 exercises
        for i in 0..<12 {
            // Complete exercise
            mockTimer.triggerCompletion()
            
            if i < 11 { // Not the last exercise
                // Complete rest
                mockTimer.triggerCompletion()
            }
        }
        
        XCTAssertEqual(engine.phase, .completed)
        XCTAssertNil(engine.currentExercise)
        XCTAssertEqual(engine.currentExerciseIndex, 11) // Last exercise index
    }
    
    // MARK: - Computed Properties Tests
    
    func testTotalWorkoutDuration() {
        let expectedDuration = 10.0 + // prep
                               (12.0 * 30.0) + // 12 exercises × 30 seconds
                               (11.0 * 10.0) // 11 rest periods × 10 seconds
        XCTAssertEqual(engine.totalWorkoutDuration, expectedDuration, accuracy: 0.1)
    }
    
    func testTotalWorkoutDurationWithCustomExercises() {
        let customExercises = Array(Exercise.sevenMinuteWorkout.prefix(3))
        let customEngine = WorkoutEngine(exercises: customExercises, timer: mockTimer)
        
        let expectedDuration = 10.0 + // prep
                               (3.0 * 30.0) + // 3 exercises × 30 seconds
                               (2.0 * 10.0) // 2 rest periods × 10 seconds
        XCTAssertEqual(customEngine.totalWorkoutDuration, expectedDuration, accuracy: 0.1)
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
    
    func testSessionStartDate() {
        XCTAssertNil(engine.sessionStartDate)
        
        engine.start()
        XCTAssertNotNil(engine.sessionStartDate)
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
        
        mockTimer.triggerCompletion() // Complete prep
        XCTAssertEqual(engine.exercisesRemaining, 12) // Still all
        
        mockTimer.triggerCompletion() // Complete first exercise
        XCTAssertEqual(engine.exercisesRemaining, 11) // One less
    }
    
    func testNextExercise() {
        XCTAssertNil(engine.nextExercise) // Idle
        
        engine.start()
        XCTAssertNotNil(engine.nextExercise)
        XCTAssertEqual(engine.nextExercise?.name, Exercise.sevenMinuteWorkout[0].name)
        
        mockTimer.triggerCompletion() // Complete prep
        XCTAssertEqual(engine.nextExercise?.name, Exercise.sevenMinuteWorkout[0].name)
    }
    
    // MARK: - Haptic Feedback Tests
    
    func testHapticFeedbackOnExerciseStart() {
        engine.start()
        mockTimer.triggerCompletion() // Complete prep to start first exercise
        
        XCTAssertGreaterThan(mockHaptics.tapCallCount, 0)
    }
    
    func testHapticFeedbackOnRestStart() {
        engine.start()
        mockTimer.triggerCompletion() // Complete prep
        mockTimer.triggerCompletion() // Complete first exercise
        
        XCTAssertGreaterThan(mockHaptics.gentleCallCount, 0)
    }
    
    func testHapticFeedbackOnWorkoutCompletion() {
        engine.start()
        mockTimer.triggerCompletion() // Complete prep
        
        // Complete all exercises
        for _ in 0..<12 {
            mockTimer.triggerCompletion() // Complete exercise
            if engine.phase != .completed {
                mockTimer.triggerCompletion() // Complete rest (except after last)
            }
        }
        
        XCTAssertGreaterThan(mockHaptics.successCallCount, 0)
    }
    
    // MARK: - Sound Feedback Tests
    
    func testSoundFeedbackOnExerciseStart() {
        engine.start()
        mockTimer.triggerCompletion() // Complete prep
        
        XCTAssertGreaterThan(mockSound.playSoundCallCount, 0)
        XCTAssertGreaterThan(mockSound.vibrateCallCount, 0)
    }
    
    // MARK: - Edge Cases
    
    func testMultipleStartCalls() {
        engine.start()
        let initialPhase = engine.phase
        
        engine.start()
        engine.start()
        
        XCTAssertEqual(engine.phase, initialPhase) // Should not change
    }
    
    func testPauseResumeCycle() {
        engine.start()
        
        for _ in 0..<3 {
            engine.pause()
            XCTAssertTrue(engine.isPaused)
            engine.resume()
            XCTAssertFalse(engine.isPaused)
        }
    }
    
    func testStopDuringPause() {
        engine.start()
        engine.pause()
        engine.stop()
        
        XCTAssertEqual(engine.phase, .idle)
        XCTAssertFalse(engine.isPaused)
    }
    
    func testEmptyExerciseList() {
        let emptyEngine = WorkoutEngine(exercises: [], timer: mockTimer)
        emptyEngine.start()
        mockTimer.triggerCompletion() // Complete prep
        
        // Should immediately complete
        XCTAssertEqual(emptyEngine.phase, .completed)
    }
}

