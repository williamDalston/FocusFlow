import Foundation
import Combine
import os.log

/// Errors that can occur during workout operations
/// 
/// Note: These errors are primarily used for logging and debugging.
/// The public API methods are non-throwing for backward compatibility.
enum WorkoutError: LocalizedError {
    case invalidPhase
    case exerciseNotFound(Int)
    case timerCreationFailed
    case workoutAlreadyInProgress
    
    var errorDescription: String? {
        switch self {
        case .invalidPhase:
            return "Workout is in an invalid state for this operation"
        case .exerciseNotFound(let index):
            return "Exercise at index \(index) not found"
        case .timerCreationFailed:
            return "Failed to create workout timer"
        case .workoutAlreadyInProgress:
            return "Workout is already in progress"
        }
    }
}

/// Represents the current phase of a workout session
enum WorkoutPhase: Equatable {
    case idle
    case preparing
    case exercise
    case rest
    case completed
}

/// Protocol for haptic feedback during workouts
protocol HapticFeedbackProvider {
    func tap()
    func gentle()
    func success()
}

/// Protocol for sound and vibration feedback during workouts
protocol SoundFeedbackProvider {
    func playSound(_ type: SoundType) async
    func vibrate(_ pattern: VibrationPattern) async
}

/// Default haptic feedback implementation using system Haptics
struct DefaultHapticFeedback: HapticFeedbackProvider {
    func tap() { Haptics.tap() }
    func gentle() { Haptics.gentle() }
    func success() { Haptics.success() }
}

/// Default sound feedback implementation using SoundManager
struct DefaultSoundFeedback: SoundFeedbackProvider {
    func playSound(_ type: SoundType) async {
        await SoundManager.shared.playSound(type)
    }
    
    func vibrate(_ pattern: VibrationPattern) async {
        await SoundManager.shared.vibrate(pattern)
    }
}

/// Core workout engine that manages exercise sequencing and timing
/// 
/// This class orchestrates the 7-minute workout by:
/// - Managing exercise progression through 12 exercises
/// - Handling timing for prep, exercise, and rest phases
/// - Providing state updates for UI components
/// - Supporting pause/resume functionality
/// - Tracking workout progress and statistics
///
/// Example usage:
/// ```swift
/// let engine = WorkoutEngine(
///     timer: WorkoutTimer(),
///     haptics: DefaultHapticFeedback(),
///     sound: DefaultSoundFeedback()
/// )
/// engine.start()
/// ```
@MainActor
final class WorkoutEngine: ObservableObject {
    // MARK: - Published Properties
    
    /// Current exercise being performed, nil during prep or rest
    @Published private(set) var currentExercise: Exercise?
    
    /// Index of the current exercise (0-based)
    @Published private(set) var currentExerciseIndex: Int = 0
    
    /// Time remaining in the current phase (seconds)
    @Published private(set) var timeRemaining: TimeInterval = 0
    
    /// Current phase of the workout
    @Published private(set) var phase: WorkoutPhase = .idle
    
    /// Whether the workout is currently paused
    @Published private(set) var isPaused: Bool = false
    
    // MARK: - Configuration
    
    /// Duration of the preparation phase before workout starts (seconds)
    var prepDuration: TimeInterval = AppConstants.TimingConstants.defaultPrepDuration
    
    /// Duration of each exercise phase (seconds)
    var exerciseDuration: TimeInterval = AppConstants.TimingConstants.defaultExerciseDuration
    
    /// Duration of rest periods between exercises (seconds)
    var restDuration: TimeInterval = AppConstants.TimingConstants.defaultRestDuration
    
    /// List of exercises in the workout
    private(set) var exercises: [Exercise]
    
    // MARK: - Dependencies
    
    /// Timer provider for workout phases
    private let timer: WorkoutTimerProtocol
    
    /// Haptic feedback provider
    private let haptics: HapticFeedbackProvider
    
    /// Sound and vibration feedback provider
    private let sound: SoundFeedbackProvider
    
    // MARK: - Private State
    
    /// Time when the current workout session started
    private var sessionStartTime: Date?
    
    /// Total time spent paused during this session
    private var totalPausedTime: TimeInterval = 0
    
    /// Time when the workout was paused
    private var pauseStartTime: Date?
    
    /// Current phase timer callback to handle updates
    private var currentPhaseUpdateHandler: ((TimeInterval) -> Void)?
    
    // MARK: - Initialization
    
    /// Creates a new workout engine
    /// - Parameters:
    ///   - exercises: List of exercises to perform (defaults to standard 7-minute workout)
    ///   - timer: Timer implementation (defaults to WorkoutTimer)
    ///   - haptics: Haptic feedback provider (defaults to system haptics)
    ///   - sound: Sound feedback provider (defaults to SoundManager)
    init(
        exercises: [Exercise] = Exercise.sevenMinuteWorkout,
        timer: WorkoutTimerProtocol? = nil,
        haptics: HapticFeedbackProvider = DefaultHapticFeedback(),
        sound: SoundFeedbackProvider = DefaultSoundFeedback()
    ) {
        // Ensure exercises array is not empty
        if exercises.isEmpty {
            ErrorHandling.handleError(ErrorHandling.WorkoutError.invalidData(description: "Empty exercises array provided, using default workout"), context: "WorkoutEngine.init")
            self.exercises = Exercise.sevenMinuteWorkout
        } else {
            self.exercises = exercises
        }
        
        // Initialize timer on main actor if not provided
        if let timer = timer {
            self.timer = timer
        } else {
            self.timer = WorkoutTimer()
        }
        self.haptics = haptics
        self.sound = sound
        
        setupTimerCallbacks()
        reset()
    }
    
    deinit {
        // Stop timer - ensure we're on main actor
        let timerToStop = timer
        if Thread.isMainThread {
            MainActor.assumeIsolated {
                timerToStop.stop()
            }
        } else {
            // If not on main thread, dispatch synchronously to avoid Task creation in deinit
            // Creating a Task in deinit can cause crashes if the object is deallocated before the task completes
            DispatchQueue.main.sync {
                timerToStop.stop()
            }
        }
    }
    
    // MARK: - Public API
    
    /// Starts the workout from the beginning
    /// - Note: If workout is already in progress, this method does nothing
    func start() {
        guard phase == .idle || phase == .completed else {
            // Workout already in progress
            ErrorHandling.handleError(ErrorHandling.WorkoutError.workoutInProgress, context: "WorkoutEngine.start()")
            return
        }
        
        // Reset if starting a new workout
        if phase == .completed {
            reset()
        }
        
        sessionStartTime = Date()
        totalPausedTime = 0
        phase = .preparing
        currentExerciseIndex = 0
        timeRemaining = prepDuration
        
        startPrepPhase()
    }
    
    /// Pauses the current workout phase
    /// - Note: If workout cannot be paused, this method does nothing
    func pause() {
        guard !isPaused && canPause else {
            ErrorHandling.handleError(ErrorHandling.WorkoutError.invalidState, context: "WorkoutEngine.pause() - phase: \(String(describing: phase))")
            return
        }
        
        isPaused = true
        pauseStartTime = Date()
        timer.pause()
    }
    
    /// Resumes the paused workout
    /// - Note: If workout is not paused, this method does nothing
    func resume() {
        guard isPaused else {
            ErrorHandling.handleError(ErrorHandling.WorkoutError.invalidState, context: "WorkoutEngine.resume() - workout not paused")
            return
        }
        
        isPaused = false
        
        // Accumulate paused time
        if let pauseStart = pauseStartTime {
            totalPausedTime += Date().timeIntervalSince(pauseStart)
            pauseStartTime = nil
        }
        
        timer.resume()
    }
    
    /// Stops the workout and resets all state
    func stop() {
        timer.stop()
        
        // Stop Live Activity if available (iOS 16.2+)
        if #available(iOS 16.2, *) {
            LiveActivityManager.shared.stopWorkoutActivity()
        }
        
        reset()
    }
    
    /// Skips the current rest period and moves to the next exercise
    /// - Note: If not in rest phase, this method does nothing
    func skipRest() {
        guard phase == .rest else {
            ErrorHandling.handleError(ErrorHandling.WorkoutError.invalidState, context: "WorkoutEngine.skipRest() - not in rest phase")
            return
        }
        
        timer.stop()
        moveToNextExercise()
    }
    
    /// Skips the preparation phase and starts the first exercise immediately
    /// - Note: If not in prep phase, this method does nothing
    func skipPrep() {
        guard phase == .preparing else {
            ErrorHandling.handleError(ErrorHandling.WorkoutError.invalidState, context: "WorkoutEngine.skipPrep() - not in prep phase")
            return
        }
        
        timer.stop()
        startExercise(at: 0)
    }
    
    /// Resets the engine to idle state
    func reset() {
        timer.stop()
        phase = .idle
        currentExercise = nil
        currentExerciseIndex = 0
        timeRemaining = 0
        isPaused = false
        sessionStartTime = nil
        totalPausedTime = 0
        pauseStartTime = nil
    }
    
    /// Configures the engine with custom durations
    /// - Parameters:
    ///   - exerciseDuration: Duration of each exercise phase (seconds)
    ///   - restDuration: Duration of rest periods between exercises (seconds)
    ///   - prepDuration: Duration of the preparation phase (seconds)
    func configureDurations(
        exerciseDuration: TimeInterval? = nil,
        restDuration: TimeInterval? = nil,
        prepDuration: TimeInterval? = nil
    ) {
        if let exerciseDuration = exerciseDuration {
            self.exerciseDuration = exerciseDuration
        }
        if let restDuration = restDuration {
            self.restDuration = restDuration
        }
        if let prepDuration = prepDuration {
            self.prepDuration = prepDuration
        }
    }
    
    // MARK: - Computed Properties
    
    /// Total expected duration of the workout (seconds)
    var totalWorkoutDuration: TimeInterval {
        let prepTime = prepDuration
        let exercisesTime = Double(exercises.count) * exerciseDuration
        let restTime = Double(exercises.count - 1) * restDuration // No rest after last exercise
        return prepTime + exercisesTime + restTime
    }
    
    /// Actual duration of the current session, accounting for pauses (seconds)
    var currentSessionDuration: TimeInterval? {
        guard let startTime = sessionStartTime else { return nil }
        let elapsed = Date().timeIntervalSince(startTime)
        return elapsed - totalPausedTime
    }
    
    /// Date when the current session started
    var sessionStartDate: Date? {
        sessionStartTime
    }
    
    /// Progress through the workout (0.0 to 1.0)
    var progress: Double {
        guard phase != .idle && phase != .completed else { return 0 }
        
        let totalTime = totalWorkoutDuration
        guard let sessionDuration = currentSessionDuration, totalTime > 0 else { return 0 }
        
        return min(sessionDuration / totalTime, 1.0)
    }
    
    /// Number of exercises remaining in the workout
    var exercisesRemaining: Int {
        if phase == .preparing {
            return exercises.count
        }
        return max(0, exercises.count - currentExerciseIndex - (phase == .rest ? 0 : 1))
    }
    
    /// Next exercise to be performed, if any
    var nextExercise: Exercise? {
        if phase == .preparing {
            return exercises.first
        } else if phase == .rest || phase == .exercise {
            let nextIndex = currentExerciseIndex + 1
            return nextIndex < exercises.count ? exercises[nextIndex] : nil
        }
        return nil
    }
    
    /// Whether the workout can be paused in the current phase
    private var canPause: Bool {
        phase == .preparing || phase == .exercise || phase == .rest
    }
    
    // MARK: - Private Methods
    
    /// Sets up timer callbacks for phase updates
    private func setupTimerCallbacks() {
        timer.onUpdate = { [weak self] timeRemaining in
            Task { @MainActor in
                self?.handleTimerUpdate(timeRemaining: timeRemaining)
            }
        }
        
        timer.onComplete = { [weak self] in
            Task { @MainActor in
                self?.handleTimerComplete()
            }
        }
    }
    
    /// Handles timer update events
    private func handleTimerUpdate(timeRemaining: TimeInterval) {
        guard !isPaused else { return }
        
        self.timeRemaining = timeRemaining
        
        // Enhanced feedback for countdown (last 3 seconds)
        if timeRemaining <= 3.0 && timeRemaining > 0 {
            let wholeSeconds = Int(timeRemaining)
            if abs(timeRemaining - Double(wholeSeconds)) < 0.15 && wholeSeconds > 0 {
                Haptics.countdownTick()
                Task {
                    await sound.playSound(.tick)
                }
            }
        }
        
        // Update Live Activity if available (iOS 16.2+)
        if #available(iOS 16.2, *), let exercise = currentExercise {
            let phaseString = phase == .exercise ? "Exercise" : (phase == .rest ? "Rest" : "Preparing")
            LiveActivityManager.shared.updateWorkoutActivity(
                exerciseName: exercise.name,
                currentExercise: currentExerciseIndex + 1,
                timeRemaining: timeRemaining,
                phase: phaseString
            )
        }
    }
    
    /// Handles timer completion events
    private func handleTimerComplete() {
        switch phase {
        case .preparing:
            startExercise(at: 0)
        case .exercise:
            startRest()
        case .rest:
            moveToNextExercise()
        default:
            break
        }
    }
    
    /// Starts the preparation phase
    private func startPrepPhase() {
        phase = .preparing
        timeRemaining = prepDuration
        timer.start(duration: prepDuration)
    }
    
    /// Starts an exercise at the given index
    /// - Parameter index: Zero-based index of the exercise to start
    private func startExercise(at index: Int) {
        guard index < exercises.count else {
            completeWorkout()
            return
        }
        
        currentExerciseIndex = index
        currentExercise = exercises[index]
        phase = .exercise
        timeRemaining = exerciseDuration
        
        timer.start(duration: exerciseDuration)
        
        // Enhanced haptic and sound feedback for exercise start
        Haptics.exerciseStart()
        Task {
            await sound.playSound(.start)
            await sound.vibrate(.double)
        }
        
        // Start Live Activity if available (iOS 16.2+)
        if #available(iOS 16.2, *) {
            if let exercise = currentExercise {
                LiveActivityManager.shared.startWorkoutActivity(
                    exerciseName: exercise.name,
                    currentExercise: index + 1,
                    totalExercises: exercises.count,
                    timeRemaining: timeRemaining,
                    phase: "Exercise"
                )
            }
        }
    }
    
    /// Starts a rest period after the current exercise
    private func startRest() {
        guard currentExerciseIndex < exercises.count - 1 else {
            // Last exercise completed
            completeWorkout()
            return
        }
        
        phase = .rest
        timeRemaining = restDuration
        
        timer.start(duration: restDuration)
        
        // Enhanced haptic and sound feedback for rest start (lighter)
        Haptics.restStart()
        Task {
            await sound.playSound(.rest)
            await sound.vibrate(.single)
        }
    }
    
    /// Moves to the next exercise in the sequence
    private func moveToNextExercise() {
        let nextIndex = currentExerciseIndex + 1
        startExercise(at: nextIndex)
    }
    
    /// Completes the workout
    private func completeWorkout() {
        timer.stop()
        phase = .completed
        currentExercise = nil
        timeRemaining = 0
        
        // Enhanced success haptics and sound for workout completion
        Haptics.workoutComplete()
        Task {
            await sound.playSound(.complete)
            await sound.vibrate(.triple)
        }
        
        // End Live Activity if available (iOS 16.2+)
        if #available(iOS 16.2, *) {
            LiveActivityManager.shared.endWorkoutActivity(isCompleted: true)
        }
    }
    
    // MARK: - Edge Case Handling
    
    /// Handles workout interruption (phone call, notification, etc.)
    func handleInterruption() {
        guard phase != .idle && phase != .completed else { return }
        
        // Pause the workout if it's not already paused
        if !isPaused {
            pause()
        }
        
        // Handle the interruption
        ErrorHandling.handleError(ErrorHandling.WorkoutError.workoutInterrupted, context: "WorkoutEngine.handleInterruption")
    }
    
    /// Handles background transition
    func handleBackgroundTransition() {
        guard phase != .idle && phase != .completed else { return }
        
        // Save current state for resume
        saveWorkoutState()
        
        // Pause the workout
        if !isPaused {
            pause()
        }
    }
    
    /// Handles foreground transition
    func handleForegroundTransition() {
        guard phase != .idle && phase != .completed else { return }
        
        // Restore workout state if needed
        if isPaused {
            // User can resume if they want
            // State is already saved, no need to log
        }
    }
    
    /// Saves current workout state for recovery
    private func saveWorkoutState() {
        let state: [String: Any] = [
            "phase": String(describing: phase),
            "currentExerciseIndex": currentExerciseIndex,
            "timeRemaining": timeRemaining,
            "sessionStartTime": sessionStartTime?.timeIntervalSince1970 ?? 0,
            "totalPausedTime": totalPausedTime,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        UserDefaults.standard.set(state, forKey: AppConstants.UserDefaultsKeys.workoutStateRecovery)
    }
    
    /// Attempts to restore workout state after interruption
    func restoreWorkoutState() -> Bool {
        guard let state = UserDefaults.standard.dictionary(forKey: AppConstants.UserDefaultsKeys.workoutStateRecovery) else {
            return false
        }
        
        // Check if state is recent (within 1 hour)
        if let timestamp = state["timestamp"] as? TimeInterval {
            let stateDate = Date(timeIntervalSince1970: timestamp)
            if Date().timeIntervalSince(stateDate) > AppConstants.TimingConstants.defaultWorkoutDuration * 6 {
                // State is too old, don't restore
                UserDefaults.standard.removeObject(forKey: AppConstants.UserDefaultsKeys.workoutStateRecovery)
                return false
            }
        }
        
        // Restore state
        if let _ = state["phase"] as? String,
           let index = state["currentExerciseIndex"] as? Int,
           let timeRemaining = state["timeRemaining"] as? TimeInterval {
            
            // Restore basic state
            currentExerciseIndex = index
            self.timeRemaining = timeRemaining
            
            // Restore exercise if valid
            if index < exercises.count {
                currentExercise = exercises[index]
            }
            
            // State restored successfully
            return true
        }
        
        return false
    }
}
