import Foundation
import Combine
import AVFoundation

/// Agent 1: Workout Engine - Core workout timer logic with exercise sequencing
@MainActor
class WorkoutEngine: ObservableObject {
    // Workout state
    @Published var currentExercise: Exercise?
    @Published var currentExerciseIndex: Int = 0
    @Published var timeRemaining: TimeInterval = 0
    @Published var phase: WorkoutPhase = .idle
    @Published var isPaused: Bool = false
    
    // Configuration
    let prepDuration: TimeInterval = 10.0 // 10 seconds prep time before starting
    let exerciseDuration: TimeInterval = 30.0 // 30 seconds per exercise
    let restDuration: TimeInterval = 10.0 // 10 seconds rest between exercises
    
    // Exercises
    private(set) var exercises: [Exercise] = Exercise.sevenMinuteWorkout
    private var timer: Timer?
    private var sessionStartTime: Date?
    private var totalPausedTime: TimeInterval = 0
    private var pauseStartTime: Date?
    
    enum WorkoutPhase {
        case idle
        case preparing
        case exercise
        case rest
        case completed
    }
    
    init() {
        reset()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    // MARK: - Public API
    
    func start() {
        guard phase == .idle || phase == .completed else { return }
        
        // Reset if starting a new workout
        if phase == .completed {
            reset()
        }
        
        sessionStartTime = Date()
        totalPausedTime = 0
        phase = .preparing
        currentExerciseIndex = 0
        timeRemaining = prepDuration
        startPrepTimer()
    }
    
    func pause() {
        guard !isPaused && (phase == .preparing || phase == .exercise || phase == .rest) else { return }
        isPaused = true
        pauseStartTime = Date()
        timer?.invalidate()
    }
    
    func resume() {
        guard isPaused else { return }
        isPaused = false
        
        if let pauseStart = pauseStartTime {
            totalPausedTime += Date().timeIntervalSince(pauseStart)
            pauseStartTime = nil
        }
        
        // Resume the current phase
        if phase == .preparing {
            startPrepTimer()
        } else if phase == .exercise {
            startExerciseTimer()
        } else if phase == .rest {
            startRestTimer()
        }
    }
    
    func stop() {
        timer?.invalidate()
        reset()
    }
    
    func skipRest() {
        guard phase == .rest else { return }
        timer?.invalidate()
        moveToNextExercise()
    }
    
    func skipPrep() {
        guard phase == .preparing else { return }
        timer?.invalidate()
        startExercise(at: 0)
    }
    
    // MARK: - Private Methods
    
    private func reset() {
        timer?.invalidate()
        phase = .idle
        currentExercise = nil
        currentExerciseIndex = 0
        timeRemaining = 0
        isPaused = false
        sessionStartTime = nil
        totalPausedTime = 0
        pauseStartTime = nil
    }
    
    private func startPrepTimer() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self, !self.isPaused else { return }
                
                self.timeRemaining -= 0.1
                
                // Countdown haptics and sounds for last 3 seconds
                if self.timeRemaining <= 3.0 && self.timeRemaining > 0 {
                    let wholeSeconds = Int(self.timeRemaining)
                    if abs(self.timeRemaining - Double(wholeSeconds)) < 0.15 && wholeSeconds > 0 {
                        Haptics.gentle()
                        Task { @MainActor in
                            await SoundManager.shared.playSound(.tick)
                        }
                    }
                }
                
                if self.timeRemaining <= 0 {
                    self.timer?.invalidate()
                    self.startExercise(at: 0)
                }
            }
        }
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    private func startExercise(at index: Int) {
        guard index < exercises.count else {
            completeWorkout()
            return
        }
        
        currentExerciseIndex = index
        currentExercise = exercises[index]
        phase = .exercise
        timeRemaining = exerciseDuration
        startExerciseTimer()
        
        // Haptic and sound feedback for exercise start
        Haptics.tap()
        Task { @MainActor in
            await SoundManager.shared.playSound(.start)
            await SoundManager.shared.vibrate(.single)
        }
    }
    
    private func startExerciseTimer() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self, !self.isPaused else { return }
                
                self.timeRemaining -= 0.1
                
                // Countdown haptics and sounds for last 3 seconds
                if self.timeRemaining <= 3.0 && self.timeRemaining > 0 {
                    let wholeSeconds = Int(self.timeRemaining)
                    if abs(self.timeRemaining - Double(wholeSeconds)) < 0.15 && wholeSeconds > 0 {
                        Haptics.gentle()
                        Task { @MainActor in
                            await SoundManager.shared.playSound(.tick)
                        }
                    }
                }
                
                if self.timeRemaining <= 0 {
                    self.timer?.invalidate()
                    self.startRest()
                }
            }
        }
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    private func startRest() {
        guard currentExerciseIndex < exercises.count - 1 else {
            // Last exercise completed, go to final rest or complete
            completeWorkout()
            return
        }
        
        phase = .rest
        timeRemaining = restDuration
        startRestTimer()
        
        // Haptic and sound feedback for rest start
        Haptics.gentle()
        Task { @MainActor in
            await SoundManager.shared.playSound(.rest)
            await SoundManager.shared.vibrate(.single)
        }
    }
    
    private func startRestTimer() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self, !self.isPaused else { return }
                
                self.timeRemaining -= 0.1
                
                // Haptic and sound feedback for rest countdown
                if self.timeRemaining <= 3.0 && self.timeRemaining > 0 {
                    let wholeSeconds = Int(self.timeRemaining)
                    if abs(self.timeRemaining - Double(wholeSeconds)) < 0.15 && wholeSeconds > 0 {
                        Haptics.gentle()
                        Task { @MainActor in
                            await SoundManager.shared.playSound(.tick)
                        }
                    }
                }
                
                if self.timeRemaining <= 0 {
                    self.timer?.invalidate()
                    self.moveToNextExercise()
                }
            }
        }
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    private func moveToNextExercise() {
        let nextIndex = currentExerciseIndex + 1
        startExercise(at: nextIndex)
    }
    
    private func completeWorkout() {
        timer?.invalidate()
        phase = .completed
        currentExercise = nil
        timeRemaining = 0
        
        // Success haptics and sound
        Haptics.success()
        Task { @MainActor in
            await SoundManager.shared.playSound(.complete)
            await SoundManager.shared.vibrate(.long)
        }
    }
    
    // MARK: - Computed Properties
    
    var totalWorkoutDuration: TimeInterval {
        let prepTime = prepDuration
        let exercisesTime = Double(exercises.count) * exerciseDuration
        let restTime = Double(exercises.count - 1) * restDuration // No rest after last exercise
        return prepTime + exercisesTime + restTime
    }
    
    var currentSessionDuration: TimeInterval? {
        guard let startTime = sessionStartTime else { return nil }
        let elapsed = Date().timeIntervalSince(startTime)
        return elapsed - totalPausedTime
    }
    
    var progress: Double {
        guard phase != .idle && phase != .completed else { return 0 }
        
        let totalTime = totalWorkoutDuration
        guard let sessionDuration = currentSessionDuration, totalTime > 0 else { return 0 }
        
        return min(sessionDuration / totalTime, 1.0)
    }
    
    var exercisesRemaining: Int {
        if phase == .preparing {
            return exercises.count
        }
        return max(0, exercises.count - currentExerciseIndex - (phase == .rest ? 0 : 1))
    }
    
    var nextExercise: Exercise? {
        if phase == .preparing {
            return exercises.first
        } else if phase == .rest || phase == .exercise {
            let nextIndex = currentExerciseIndex + 1
            return nextIndex < exercises.count ? exercises[nextIndex] : nil
        }
        return nil
    }
}

