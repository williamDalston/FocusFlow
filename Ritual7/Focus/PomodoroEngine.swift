import Foundation
import Combine
import os.log

/// Errors that can occur during Pomodoro operations
enum PomodoroError: LocalizedError {
    case invalidPhase
    case timerCreationFailed
    case sessionAlreadyInProgress
    
    var errorDescription: String? {
        switch self {
        case .invalidPhase:
            return "Pomodoro is in an invalid state for this operation"
        case .timerCreationFailed:
            return "Failed to create Pomodoro timer"
        case .sessionAlreadyInProgress:
            return "A Pomodoro session is already in progress"
        }
    }
}

/// Represents the current phase of a Pomodoro session
enum PomodoroPhase: Equatable {
    case idle
    case focus
    case shortBreak
    case longBreak
    case completed
}

/// Protocol for haptic feedback during Pomodoro sessions
protocol HapticFeedbackProvider {
    func tap()
    func gentle()
    func success()
}

/// Protocol for sound and vibration feedback during Pomodoro sessions
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

/// Core Pomodoro engine that manages focus/break sequencing and timing
/// 
/// This class orchestrates the Pomodoro timer by:
/// - Managing focus and break phases
/// - Handling Pomodoro cycle logic (4 sessions = long break)
/// - Providing state updates for UI components
/// - Supporting pause/resume functionality
/// - Tracking session progress and statistics
///
/// Example usage:
/// ```swift
/// let engine = PomodoroEngine(
///     timer: FocusTimer(),
///     haptics: DefaultHapticFeedback(),
///     sound: DefaultSoundFeedback()
/// )
/// engine.start()
/// ```
@MainActor
final class PomodoroEngine: ObservableObject {
    // MARK: - Published Properties
    
    /// Current phase of the Pomodoro session
    @Published private(set) var phase: PomodoroPhase = .idle
    
    /// Time remaining in the current phase (seconds)
    @Published private(set) var timeRemaining: TimeInterval = 0
    
    /// Whether the session is currently paused
    @Published private(set) var isPaused: Bool = false
    
    /// Current session number in the cycle (1-4)
    @Published private(set) var currentSessionNumber: Int = 1
    
    /// Total sessions completed in current cycle
    @Published private(set) var sessionsCompletedInCycle: Int = 0
    
    // MARK: - Configuration
    
    /// Duration of focus sessions (seconds)
    var focusDuration: TimeInterval = AppConstants.TimingConstants.defaultFocusDuration
    
    /// Duration of short breaks (seconds)
    var shortBreakDuration: TimeInterval = AppConstants.TimingConstants.defaultShortBreakDuration
    
    /// Duration of long breaks (seconds)
    var longBreakDuration: TimeInterval = AppConstants.TimingConstants.defaultLongBreakDuration
    
    /// Number of sessions before long break
    var cycleLength: Int = AppConstants.TimingConstants.defaultPomodoroCycleLength
    
    // MARK: - Dependencies
    
    /// Timer provider for Pomodoro phases
    private let timer: FocusTimerProtocol
    
    /// Haptic feedback provider
    private let haptics: HapticFeedbackProvider
    
    /// Sound and vibration feedback provider
    private let sound: SoundFeedbackProvider
    
    /// Cycle manager for Pomodoro cycles
    private let cycleManager: PomodoroCycleManager
    
    // MARK: - Private State
    
    /// Time when the current session started
    private var sessionStartTime: Date?
    
    /// Total time spent paused during this session
    private var totalPausedTime: TimeInterval = 0
    
    /// Time when the session was paused
    private var pauseStartTime: Date?
    
    // MARK: - Initialization
    
    /// Creates a new Pomodoro engine
    /// - Parameters:
    ///   - timer: Timer implementation (defaults to FocusTimer)
    ///   - haptics: Haptic feedback provider (defaults to system haptics)
    ///   - sound: Sound feedback provider (defaults to SoundManager)
    ///   - cycleManager: Cycle manager (defaults to new instance)
    init(
        timer: FocusTimerProtocol? = nil,
        haptics: HapticFeedbackProvider = DefaultHapticFeedback(),
        sound: SoundFeedbackProvider = DefaultSoundFeedback(),
        cycleManager: PomodoroCycleManager? = nil
    ) {
        // Initialize timer on main actor if not provided
        if let timer = timer {
            self.timer = timer
        } else {
            self.timer = FocusTimer()
        }
        self.haptics = haptics
        self.sound = sound
        
        // Initialize cycle manager
        if let cycleManager = cycleManager {
            self.cycleManager = cycleManager
        } else {
            self.cycleManager = PomodoroCycleManager(cycleLength: AppConstants.TimingConstants.defaultPomodoroCycleLength)
        }
        
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
            DispatchQueue.main.sync {
                timerToStop.stop()
            }
        }
    }
    
    // MARK: - Public API
    
    /// Starts a focus session
    /// - Note: If session is already in progress, this method does nothing
    func start() {
        guard phase == .idle || phase == .completed else {
            ErrorHandling.handleError(ErrorHandling.WorkoutError.workoutInProgress, context: "PomodoroEngine.start()")
            return
        }
        
        // Reset if starting a new session
        if phase == .completed {
            reset()
        }
        
        sessionStartTime = Date()
        totalPausedTime = 0
        phase = .focus
        currentSessionNumber = cycleManager.currentSessionNumber
        timeRemaining = focusDuration
        
        startFocusPhase()
    }
    
    /// Pauses the current session
    /// - Note: If session cannot be paused, this method does nothing
    func pause() {
        guard !isPaused && canPause else {
            ErrorHandling.handleError(ErrorHandling.WorkoutError.invalidState, context: "PomodoroEngine.pause() - phase: \(String(describing: phase))")
            return
        }
        
        isPaused = true
        pauseStartTime = Date()
        timer.pause()
    }
    
    /// Resumes the paused session
    /// - Note: If session is not paused, this method does nothing
    func resume() {
        guard isPaused else {
            ErrorHandling.handleError(ErrorHandling.WorkoutError.invalidState, context: "PomodoroEngine.resume() - session not paused")
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
    
    /// Stops the session and resets all state
    func stop() {
        timer.stop()
        reset()
    }
    
    /// Skips the current break and moves to the next focus session
    /// - Note: If not in break phase, this method does nothing
    func skipBreak() {
        guard phase == .shortBreak || phase == .longBreak else {
            ErrorHandling.handleError(ErrorHandling.WorkoutError.invalidState, context: "PomodoroEngine.skipBreak() - not in break phase")
            return
        }
        
        timer.stop()
        moveToNextSession()
    }
    
    /// Resets the engine to idle state
    func reset() {
        timer.stop()
        phase = .idle
        timeRemaining = 0
        isPaused = false
        sessionStartTime = nil
        totalPausedTime = 0
        pauseStartTime = nil
        currentSessionNumber = 1
        sessionsCompletedInCycle = 0
        cycleManager.reset()
    }
    
    /// Configures the engine with custom durations
    /// - Parameters:
    ///   - focusDuration: Duration of focus sessions (seconds)
    ///   - shortBreakDuration: Duration of short breaks (seconds)
    ///   - longBreakDuration: Duration of long breaks (seconds)
    ///   - cycleLength: Number of sessions before long break
    func configureDurations(
        focusDuration: TimeInterval? = nil,
        shortBreakDuration: TimeInterval? = nil,
        longBreakDuration: TimeInterval? = nil,
        cycleLength: Int? = nil
    ) {
        if let focusDuration = focusDuration {
            self.focusDuration = focusDuration
        }
        if let shortBreakDuration = shortBreakDuration {
            self.shortBreakDuration = shortBreakDuration
        }
        if let longBreakDuration = longBreakDuration {
            self.longBreakDuration = longBreakDuration
        }
        if let cycleLength = cycleLength {
            self.cycleLength = cycleLength
            cycleManager.updateCycleLength(cycleLength)
        }
    }
    
    // MARK: - Computed Properties
    
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
    
    /// Progress through the current phase (0.0 to 1.0)
    var progress: Double {
        guard phase != .idle && phase != .completed else { return 0 }
        
        let phaseDuration: TimeInterval
        switch phase {
        case .focus:
            phaseDuration = focusDuration
        case .shortBreak:
            phaseDuration = shortBreakDuration
        case .longBreak:
            phaseDuration = longBreakDuration
        default:
            return 0
        }
        
        guard phaseDuration > 0 else { return 0 }
        return 1.0 - (timeRemaining / phaseDuration)
    }
    
    /// Whether the session can be paused in the current phase
    private var canPause: Bool {
        phase == .focus || phase == .shortBreak || phase == .longBreak
    }
    
    /// Whether it's time for a long break (4 sessions completed)
    private var shouldTakeLongBreak: Bool {
        cycleManager.shouldTakeLongBreak()
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
    }
    
    /// Handles timer completion events
    private func handleTimerComplete() {
        switch phase {
        case .focus:
            completeFocusSession()
        case .shortBreak, .longBreak:
            moveToNextSession()
        default:
            break
        }
    }
    
    /// Starts a focus phase
    private func startFocusPhase() {
        phase = .focus
        timeRemaining = focusDuration
        timer.start(duration: focusDuration)
        
        // Enhanced haptic and sound feedback for focus start
        Haptics.exerciseStart()
        Task {
            await sound.playSound(.start)
            await sound.vibrate(.double)
        }
    }
    
    /// Completes a focus session
    private func completeFocusSession() {
        cycleManager.completeSession()
        sessionsCompletedInCycle = cycleManager.sessionsCompleted
        
        // Enhanced success haptics and sound for focus completion
        Haptics.workoutComplete()
        Task {
            await sound.playSound(.complete)
            await sound.vibrate(.triple)
        }
        
        // Start break (short or long)
        if shouldTakeLongBreak {
            startLongBreak()
        } else {
            startShortBreak()
        }
    }
    
    /// Starts a short break
    private func startShortBreak() {
        phase = .shortBreak
        timeRemaining = shortBreakDuration
        timer.start(duration: shortBreakDuration)
        
        // Enhanced haptic and sound feedback for break start (lighter)
        Haptics.restStart()
        Task {
            await sound.playSound(.rest)
            await sound.vibrate(.single)
        }
    }
    
    /// Starts a long break
    private func startLongBreak() {
        phase = .longBreak
        timeRemaining = longBreakDuration
        timer.start(duration: longBreakDuration)
        
        // Enhanced haptic and sound feedback for long break
        Haptics.restStart()
        Task {
            await sound.playSound(.rest)
            await sound.vibrate(.single)
        }
    }
    
    /// Moves to the next focus session
    private func moveToNextSession() {
        if phase == .longBreak {
            // After long break, start new cycle
            cycleManager.startNewCycle()
        }
        
        cycleManager.prepareNextSession()
        currentSessionNumber = cycleManager.currentSessionNumber
        startFocusPhase()
    }
    
    /// Handles session interruption (phone call, notification, etc.)
    func handleInterruption() {
        guard phase != .idle && phase != .completed else { return }
        
        // Pause the session if it's not already paused
        if !isPaused {
            pause()
        }
        
        ErrorHandling.handleError(ErrorHandling.WorkoutError.workoutInterrupted, context: "PomodoroEngine.handleInterruption")
    }
    
    /// Handles background transition
    func handleBackgroundTransition() {
        guard phase != .idle && phase != .completed else { return }
        
        // Save current state for resume
        saveSessionState()
        
        // Pause the session
        if !isPaused {
            pause()
        }
    }
    
    /// Handles foreground transition
    func handleForegroundTransition() {
        guard phase != .idle && phase != .completed else { return }
        
        // User can resume if they want
        // State is already saved, no need to log
    }
    
    /// Saves current session state for recovery
    private func saveSessionState() {
        let state: [String: Any] = [
            "phase": String(describing: phase),
            "timeRemaining": timeRemaining,
            "sessionStartTime": sessionStartTime?.timeIntervalSince1970 ?? 0,
            "totalPausedTime": totalPausedTime,
            "currentSessionNumber": currentSessionNumber,
            "sessionsCompletedInCycle": sessionsCompletedInCycle,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        UserDefaults.standard.set(state, forKey: "pomodoro.session.recovery")
    }
    
    /// Attempts to restore session state after interruption
    func restoreSessionState() -> Bool {
        guard let state = UserDefaults.standard.dictionary(forKey: "pomodoro.session.recovery") else {
            return false
        }
        
        // Check if state is recent (within 2 hours)
        if let timestamp = state["timestamp"] as? TimeInterval {
            let stateDate = Date(timeIntervalSince1970: timestamp)
            if Date().timeIntervalSince(stateDate) > 7200 { // 2 hours
                UserDefaults.standard.removeObject(forKey: "pomodoro.session.recovery")
                return false
            }
        }
        
        // Restore state
        if let _ = state["phase"] as? String,
           let timeRemaining = state["timeRemaining"] as? TimeInterval {
            
            self.timeRemaining = timeRemaining
            
            if let sessionNumber = state["currentSessionNumber"] as? Int {
                self.currentSessionNumber = sessionNumber
            }
            if let sessionsCompleted = state["sessionsCompletedInCycle"] as? Int {
                self.sessionsCompletedInCycle = sessionsCompleted
            }
            
            return true
        }
        
        return false
    }
}

