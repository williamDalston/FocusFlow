import Foundation
import WatchKit

/// Pomodoro engine optimized for Apple Watch
/// Refactored from WorkoutEngineWatch for Pomodoro Timer app
@MainActor
class PomodoroEngineWatch: ObservableObject {
    // Pomodoro state
    @Published var timeRemaining: TimeInterval = 0
    @Published var phase: PomodoroPhase = .idle
    @Published var isPaused: Bool = false
    @Published var currentSessionNumber: Int = 1
    @Published var sessionsCompletedInCycle: Int = 0
    
    // Configuration
    var focusDuration: TimeInterval = WatchConstants.TimingConstants.defaultFocusDuration
    var shortBreakDuration: TimeInterval = WatchConstants.TimingConstants.defaultShortBreakDuration
    var longBreakDuration: TimeInterval = WatchConstants.TimingConstants.defaultLongBreakDuration
    var cycleLength: Int = WatchConstants.TimingConstants.defaultPomodoroCycleLength
    
    // Private state
    private var timer: Timer?
    private var sessionStartTime: Date?
    private var totalPausedTime: TimeInterval = 0
    private var pauseStartTime: Date?
    private var sessionsInCycle: Int = 0
    
    init() {
        reset()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    // MARK: - Public API
    
    func start() {
        guard phase == .idle || phase == .completed else { return }
        
        if phase == .completed {
            reset()
        }
        
        sessionStartTime = Date()
        totalPausedTime = 0
        phase = .focus
        currentSessionNumber = 1
        timeRemaining = focusDuration
        startFocusTimer()
        
        // Haptic feedback for Watch
        WKInterfaceDevice.current().play(.start)
    }
    
    func pause() {
        guard !isPaused && (phase == .focus || phase == .shortBreak || phase == .longBreak) else { return }
        isPaused = true
        pauseStartTime = Date()
        timer?.invalidate()
        WKInterfaceDevice.current().play(.click)
    }
    
    func resume() {
        guard isPaused else { return }
        isPaused = false
        
        if let pauseStart = pauseStartTime {
            totalPausedTime += Date().timeIntervalSince(pauseStart)
            pauseStartTime = nil
        }
        
        if phase == .focus {
            startFocusTimer()
        } else if phase == .shortBreak {
            startShortBreakTimer()
        } else if phase == .longBreak {
            startLongBreakTimer()
        }
        
        WKInterfaceDevice.current().play(.click)
    }
    
    func stop() {
        timer?.invalidate()
        reset()
        WKInterfaceDevice.current().play(.stop)
    }
    
    func skipBreak() {
        guard phase == .shortBreak || phase == .longBreak else { return }
        timer?.invalidate()
        moveToNextSession()
    }
    
    // MARK: - Private Methods
    
    private func reset() {
        timer?.invalidate()
        phase = .idle
        timeRemaining = 0
        isPaused = false
        sessionStartTime = nil
        totalPausedTime = 0
        pauseStartTime = nil
        currentSessionNumber = 1
        sessionsCompletedInCycle = 0
        sessionsInCycle = 0
    }
    
    private func startFocusTimer() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self, !self.isPaused else { return }
                
                self.timeRemaining -= 0.1
                
                // Haptic feedback for last 3 seconds
                if self.timeRemaining <= 3.0 && self.timeRemaining > 0 {
                    let wholeSeconds = Int(self.timeRemaining)
                    if abs(self.timeRemaining - Double(wholeSeconds)) < 0.15 && wholeSeconds > 0 {
                        WKInterfaceDevice.current().play(.click)
                    }
                }
                
                if self.timeRemaining <= 0 {
                    self.timer?.invalidate()
                    self.completeFocusSession()
                }
            }
        }
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    private func startShortBreakTimer() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self, !self.isPaused else { return }
                
                self.timeRemaining -= 0.1
                
                // Haptic feedback for last 3 seconds
                if self.timeRemaining <= 3.0 && self.timeRemaining > 0 {
                    let wholeSeconds = Int(self.timeRemaining)
                    if abs(self.timeRemaining - Double(wholeSeconds)) < 0.15 && wholeSeconds > 0 {
                        WKInterfaceDevice.current().play(.click)
                    }
                }
                
                if self.timeRemaining <= 0 {
                    self.timer?.invalidate()
                    self.moveToNextSession()
                }
            }
        }
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    private func startLongBreakTimer() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self, !self.isPaused else { return }
                
                self.timeRemaining -= 0.1
                
                // Haptic feedback for last 3 seconds
                if self.timeRemaining <= 3.0 && self.timeRemaining > 0 {
                    let wholeSeconds = Int(self.timeRemaining)
                    if abs(self.timeRemaining - Double(wholeSeconds)) < 0.15 && wholeSeconds > 0 {
                        WKInterfaceDevice.current().play(.click)
                    }
                }
                
                if self.timeRemaining <= 0 {
                    self.timer?.invalidate()
                    self.moveToNextSession()
                }
            }
        }
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    private func completeFocusSession() {
        sessionsInCycle += 1
        sessionsCompletedInCycle = sessionsInCycle
        
        // Success haptics
        WKInterfaceDevice.current().play(.success)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            WKInterfaceDevice.current().play(.success)
        }
        
        // Start break (short or long)
        if shouldTakeLongBreak {
            startLongBreak()
        } else {
            startShortBreak()
        }
    }
    
    private func startShortBreak() {
        phase = .shortBreak
        timeRemaining = shortBreakDuration
        startShortBreakTimer()
        
        // Haptic feedback for break start
        WKInterfaceDevice.current().play(.click)
    }
    
    private func startLongBreak() {
        phase = .longBreak
        timeRemaining = longBreakDuration
        startLongBreakTimer()
        
        // Haptic feedback for long break start
        WKInterfaceDevice.current().play(.notification)
    }
    
    private func moveToNextSession() {
        if phase == .longBreak {
            // After long break, start new cycle
            sessionsInCycle = 0
            currentSessionNumber = 1
        } else {
            // Next session in cycle
            currentSessionNumber += 1
        }
        
        phase = .focus
        timeRemaining = focusDuration
        startFocusTimer()
    }
    
    private var shouldTakeLongBreak: Bool {
        sessionsInCycle >= cycleLength
    }
    
    // MARK: - Computed Properties
    
    var currentSessionDuration: TimeInterval? {
        guard let startTime = sessionStartTime else { return nil }
        let elapsed = Date().timeIntervalSince(startTime)
        return elapsed - totalPausedTime
    }
    
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
}

