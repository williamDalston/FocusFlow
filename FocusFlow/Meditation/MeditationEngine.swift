import Foundation
import AVFoundation
import Combine

/// Meditation timer engine with background sounds and completion sound
@MainActor
final class MeditationEngine: ObservableObject {
    // MARK: - Published Properties
    
    @Published private(set) var timeRemaining: TimeInterval = 0
    @Published private(set) var phase: MeditationPhase = .idle
    @Published private(set) var isPaused: Bool = false
    @Published var selectedDuration: TimeInterval = 60 // 1 minute default
    @Published private(set) var backgroundSoundEnabled: Bool = true
    
    // MARK: - Audio
    
    private var backgroundSoundEngine: AVAudioEngine?
    private var backgroundSoundPlayer: AVAudioPlayerNode?
    
    // Ad audio handling: Track paused state for ad audio best practices
    private var wasPlayingBeforeAd = false
    
    // Notification observers for ad audio events
    private var adAudioObservers: [NSObjectProtocol] = []
    
    // MARK: - Timer
    
    private var timer: Timer?
    private var sessionStartTime: Date?
    private var totalPausedTime: TimeInterval = 0
    private var pauseStartTime: Date?
    
    // MARK: - Phase
    
    enum MeditationPhase: Equatable {
        case idle
        case active
        case completed
    }
    
    // MARK: - Initialization
    
    init() {
        setupAudioSession()
        setupAdAudioNotifications()
    }
    
    private func setupAdAudioNotifications() {
        // Observe ad audio events to pause/resume meditation audio
        // Use closure-based observer to work with @MainActor
        let willPlayObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("AdAudioWillPlay"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.pauseAudioForAd()
            }
        }
        let didStopObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("AdAudioDidStop"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.resumeAudioAfterAd()
            }
        }
        adAudioObservers = [willPlayObserver, didStopObserver]
    }
    
    deinit {
        // Clean up resources directly in deinit (nonisolated)
        timer?.invalidate()
        backgroundSoundPlayer?.stop()
        backgroundSoundEngine?.stop()
        backgroundSoundEngine = nil
        backgroundSoundPlayer = nil
        // Remove notification observers
        adAudioObservers.forEach { NotificationCenter.default.removeObserver($0) }
        adAudioObservers.removeAll()
    }
    
    // MARK: - Public API
    
    func start(duration: TimeInterval) {
        guard phase == .idle || phase == .completed else { return }
        
        if phase == .completed {
            reset()
        }
        
        // Ensure audio session is ready
        setupAudioSession()
        
        selectedDuration = duration
        timeRemaining = duration
        phase = .active
        sessionStartTime = Date()
        totalPausedTime = 0
        
        startTimer()
        playBackgroundSound()
    }
    
    func pause() {
        guard !isPaused && phase == .active else { return }
        
        isPaused = true
        pauseStartTime = Date()
        timer?.invalidate()
        backgroundSoundPlayer?.pause()
    }
    
    func resume() {
        guard isPaused && phase == .active else { return }
        
        isPaused = false
        
        if let pauseStart = pauseStartTime {
            totalPausedTime += Date().timeIntervalSince(pauseStart)
            pauseStartTime = nil
        }
        
        startTimer()
        if backgroundSoundEnabled {
            backgroundSoundPlayer?.play()
        }
    }
    
    func stop() {
        timer?.invalidate()
        stopBackgroundSound()
        reset()
    }
    
    func reset() {
        timer?.invalidate()
        stopBackgroundSound()
        phase = .idle
        timeRemaining = 0
        isPaused = false
        sessionStartTime = nil
        totalPausedTime = 0
        pauseStartTime = nil
    }
    
    private func stopBackgroundSound() {
        // Stop player first
        backgroundSoundPlayer?.stop()
        backgroundSoundPlayer = nil
        
        // Then stop and detach engine
        if let engine = backgroundSoundEngine {
            engine.stop()
            // Clean up all nodes
            engine.attachedNodes.forEach { node in
                engine.detach(node)
            }
            backgroundSoundEngine = nil
        }
    }
    
    func toggleBackgroundSound() {
        backgroundSoundEnabled.toggle()
        if backgroundSoundEnabled {
            if phase == .active {
                playBackgroundSound()
            }
        } else {
            stopBackgroundSound()
        }
    }
    
    // MARK: - Computed Properties
    
    var progress: Double {
        guard phase == .active && selectedDuration > 0 else { return 0 }
        return 1.0 - (timeRemaining / selectedDuration)
    }
    
    // MARK: - Private Methods
    
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true, options: [])
        } catch {
            print("Failed to setup audio session: \(error.localizedDescription)")
            // Don't crash if audio setup fails - meditation can still work without sound
        }
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = nil
        
        // Ensure we're on the main run loop
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            Task { @MainActor in
                guard let self = self, !self.isPaused else { return }
                
                self.timeRemaining -= 0.1
                
                if self.timeRemaining <= 0 {
                    timer.invalidate()
                    self.timer = nil
                    self.completeMeditation()
                }
            }
        }
        
        if let timer = timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    private func completeMeditation() {
        phase = .completed
        stopBackgroundSound()
        playCompletionSound()
        Haptics.success()
    }
    
    private func playBackgroundSound() {
        guard backgroundSoundEnabled else { return }
        
        // Stop existing sound if playing
        stopBackgroundSound()
        
        // Generate ambient rain-like sound using AVAudioEngine
        let sampleRate: Double = 44100
        let duration: TimeInterval = 10 // 10 second loop
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1) else {
            return
        }
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            return
        }
        
        buffer.frameLength = frameCount
        
        // Generate filtered noise (rain-like ambient sound)
        if let channelData = buffer.floatChannelData {
            let samples = channelData[0]
            var previousSample: Float = 0.0
            let volumeMultiplier: Float = 0.35 // Reduced volume for subtle background sound
            
            for frame in 0..<Int(frameCount) {
                let time = Double(frame) / sampleRate
                // Generate low-frequency filtered noise (rain-like) - reduced range
                let noise = Float.random(in: -0.10...0.10)
                // Apply simple low-pass filter (moving average)
                let filtered = previousSample * 0.7 + noise * 0.3
                previousSample = filtered
                
                // Apply gentle envelope
                let envelope = sin(time * .pi / duration) * 0.8 + 0.2
                // Apply volume multiplier to reduce overall volume
                samples[frame] = filtered * Float(envelope) * volumeMultiplier
            }
        }
        
        // Use AVAudioEngine to play looping sound
        let engine = AVAudioEngine()
        let playerNode = AVAudioPlayerNode()
        
        do {
            engine.attach(playerNode)
            engine.connect(playerNode, to: engine.mainMixerNode, format: format)
            
            // Prepare engine before starting
            engine.prepare()
            try engine.start()
            
            // Store references only after successful start
            self.backgroundSoundEngine = engine
            self.backgroundSoundPlayer = playerNode
            
            // Schedule buffer to loop
            // Use a weak reference and MainActor context to avoid concurrency issues
            func scheduleLoop() {
                guard let playerNode = self.backgroundSoundPlayer,
                      let engine = self.backgroundSoundEngine,
                      engine.isRunning else {
                    return
                }
                
                playerNode.scheduleBuffer(buffer, at: nil, options: []) { [weak self] in
                    // Re-schedule when buffer finishes to create loop
                    // Use Task with MainActor to safely access main actor-isolated properties
                    Task { @MainActor in
                        guard let self = self else { return }
                        // Check if engine is still running and we're still active
                        if self.backgroundSoundEnabled && 
                           self.phase == .active &&
                           self.backgroundSoundEngine?.isRunning == true {
                            scheduleLoop()
                        }
                    }
                }
            }
            
            scheduleLoop()
            playerNode.play()
            
        } catch {
            print("Failed to play background sound: \(error.localizedDescription)")
            // Clean up on failure
            engine.stop()
            engine.attachedNodes.forEach { node in
                engine.detach(node)
            }
        }
    }
    
    private func playCompletionSound() {
        // Play a gentle completion sound
        Task {
            await SoundManager.shared.playSound(.complete)
        }
    }
    
    // MARK: - Ad Audio Management
    
    /// Pause meditation audio when ad audio starts playing
    /// Best practice: Respect ad audio by pausing app audio
    func pauseAudioForAd() {
        // Only pause if currently playing
        guard phase == .active && !isPaused else { return }
        
        wasPlayingBeforeAd = true
        // Pause meditation audio (background sound will be paused)
        pause()
    }
    
    /// Resume meditation audio after ad audio finishes
    /// Best practice: Resume app audio when ad audio stops
    func resumeAudioAfterAd() {
        // Only resume if we were playing before ad
        guard wasPlayingBeforeAd && phase == .active && isPaused else {
            wasPlayingBeforeAd = false
            return
        }
        
        wasPlayingBeforeAd = false
        // Resume meditation audio
        resume()
    }
}

