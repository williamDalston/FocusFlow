import Foundation
import WatchKit

/// Workout engine optimized for Apple Watch
@MainActor
class WorkoutEngineWatch: ObservableObject {
    // Workout state
    @Published var currentExercise: Exercise?
    @Published var currentExerciseIndex: Int = 0
    @Published var timeRemaining: TimeInterval = 0
    @Published var phase: WorkoutPhase = .idle
    @Published var isPaused: Bool = false
    
    // Configuration
    let prepDuration: TimeInterval = 10.0
    let exerciseDuration: TimeInterval = 30.0
    let restDuration: TimeInterval = 10.0
    
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
        
        if phase == .completed {
            reset()
        }
        
        sessionStartTime = Date()
        totalPausedTime = 0
        phase = .preparing
        currentExerciseIndex = 0
        timeRemaining = prepDuration
        startPrepTimer()
        
        // Haptic feedback for Watch
        WKInterfaceDevice.current().play(.start)
    }
    
    func pause() {
        guard !isPaused && (phase == .preparing || phase == .exercise || phase == .rest) else { return }
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
        
        if phase == .preparing {
            startPrepTimer()
        } else if phase == .exercise {
            startExerciseTimer()
        } else if phase == .rest {
            startRestTimer()
        }
        
        WKInterfaceDevice.current().play(.click)
    }
    
    func stop() {
        timer?.invalidate()
        reset()
        WKInterfaceDevice.current().play(.stop)
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
                
                // Haptic feedback for last 3 seconds
                if self.timeRemaining <= 3.0 && self.timeRemaining > 0 {
                    let wholeSeconds = Int(self.timeRemaining)
                    if abs(self.timeRemaining - Double(wholeSeconds)) < 0.15 && wholeSeconds > 0 {
                        WKInterfaceDevice.current().play(.click)
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
        
        // Haptic feedback for exercise start
        WKInterfaceDevice.current().play(.notification)
    }
    
    private func startExerciseTimer() {
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
                    self.startRest()
                }
            }
        }
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    private func startRest() {
        guard currentExerciseIndex < exercises.count - 1 else {
            completeWorkout()
            return
        }
        
        phase = .rest
        timeRemaining = restDuration
        startRestTimer()
        
        // Haptic feedback for rest start
        WKInterfaceDevice.current().play(.click)
    }
    
    private func startRestTimer() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self, !self.isPaused else { return }
                
                self.timeRemaining -= 0.1
                
                // Haptic feedback for rest countdown
                if self.timeRemaining <= 3.0 && self.timeRemaining > 0 {
                    let wholeSeconds = Int(self.timeRemaining)
                    if abs(self.timeRemaining - Double(wholeSeconds)) < 0.15 && wholeSeconds > 0 {
                        WKInterfaceDevice.current().play(.click)
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
        
        // Success haptics
        WKInterfaceDevice.current().play(.success)
        // Play success pattern
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            WKInterfaceDevice.current().play(.success)
        }
    }
    
    // MARK: - Computed Properties
    
    var totalWorkoutDuration: TimeInterval {
        let prepTime = prepDuration
        let exercisesTime = Double(exercises.count) * exerciseDuration
        let restTime = Double(exercises.count - 1) * restDuration
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


