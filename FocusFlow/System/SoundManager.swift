import Foundation
import AVFoundation
import Combine
import UIKit
import os.log

/// Manages sound effects and audio preferences for the FocusFlow app
@MainActor
class SoundManager: ObservableObject {
    static let shared = SoundManager()
    
    @Published var soundEnabled: Bool = true
    @Published var vibrationEnabled: Bool = true
    
    private var audioPlayer: AVAudioPlayer?
    private let soundEnabledKey = AppConstants.UserDefaultsKeys.soundEnabled
    private let vibrationEnabledKey = AppConstants.UserDefaultsKeys.vibrationEnabled
    
    // Ad audio handling: Track paused state for ad audio best practices
    private var isPausedForAd = false
    
    private init() {
        loadSettings()
    }
    
    // MARK: - Settings
    
    private func loadSettings() {
        let defaults = UserDefaults.standard
        soundEnabled = defaults.object(forKey: soundEnabledKey) as? Bool ?? true
        vibrationEnabled = defaults.object(forKey: vibrationEnabledKey) as? Bool ?? true
    }
    
    func saveSettings() {
        let defaults = UserDefaults.standard
        defaults.set(soundEnabled, forKey: soundEnabledKey)
        defaults.set(vibrationEnabled, forKey: vibrationEnabledKey)
    }
    
    // MARK: - Sound Effects
    
    func playSound(_ type: SoundType) async {
        guard soundEnabled else { return }
        // Respect ad audio: Don't play app audio when paused for ad
        guard !isPausedForAd else { return }
        
        switch type {
        case .start:
            await playTone(frequency: 440.0, duration: 0.3)
        case .rest:
            await playTone(frequency: 523.25, duration: 0.3)
        case .tick:
            await playTone(frequency: 880.0, duration: 0.1)
        case .complete:
            await playTone(frequency: 523.25, duration: 0.15)
            try? await Task.sleep(nanoseconds: 50_000_000) // 0.05 second pause
            await playTone(frequency: 1046.50, duration: 0.15)
        }
    }
    
    private func playTone(frequency: Double, duration: TimeInterval) async {
        // Create a simple tone using AVAudioEngine
        let engine = AVAudioEngine()
        let playerNode = AVAudioPlayerNode()
        let sampleRate = 44100.0
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1) else {
            // Clean up on failure
            engine.stop()
            return
        }
        
        engine.attach(playerNode)
        engine.connect(playerNode, to: engine.mainMixerNode, format: format)
        
        do {
            try engine.start()
            
            defer {
                // Ensure cleanup happens in all code paths
                playerNode.stop()
                engine.stop()
                engine.reset()
                engine.detach(playerNode)
            }
            
            guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
                throw SoundError.failedToCreateBuffer
            }
            buffer.frameLength = frameCount
            
            guard let channelData = buffer.floatChannelData?[0] else {
                throw SoundError.failedToCreateBuffer
            }
            
            for frame in 0..<Int(frameCount) {
                let time = Double(frame) / sampleRate
                let sample = sin(2.0 * .pi * frequency * time)
                // Apply envelope to prevent clicks
                let envelope = min(1.0, min(time * 10.0, (duration - time) * 10.0))
                channelData[frame] = Float(sample * envelope * 0.3)
            }
            
            // Use async completion handler to know when playback finishes
            await withCheckedContinuation { continuation in
                playerNode.scheduleBuffer(buffer, at: nil, options: []) {
                    continuation.resume()
                }
                playerNode.play()
            }
            
            // Buffer has finished playing, cleanup handled by defer
        } catch {
            // Cleanup already handled by defer
            os_log("Sound playback error: %{public}@", log: .default, type: .error, error.localizedDescription)
            CrashReporter.logError(error, context: ["action": "sound_playback", "frequency": frequency, "duration": duration])
        }
    }
    
    // MARK: - Vibration
    
    func vibrate(_ pattern: VibrationPattern) async {
        guard vibrationEnabled else { return }
        
        switch pattern {
        case .single:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .double:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .triple:
            for i in 0..<3 {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                if i < 2 {
                    try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second between
                }
            }
        case .long:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }
    
    // MARK: - Ad Audio Management
    
    /// Pause app audio when ad audio starts playing
    /// Best practice: Respect ad audio by pausing app audio
    func pauseAudioForAd() {
        guard !isPausedForAd else { return }
        isPausedForAd = true
        
        // Stop any currently playing audio
        audioPlayer?.stop()
        audioPlayer = nil
        
        // Note: AVAudioEngine tones are short-lived and will complete naturally
        // No need to actively stop them as they finish quickly
    }
    
    /// Resume app audio after ad audio finishes
    /// Best practice: Resume app audio when ad audio stops
    func resumeAudioAfterAd() {
        guard isPausedForAd else { return }
        isPausedForAd = false
        
        // Audio will resume naturally when next sound is requested
        // This flag ensures we don't block future audio playback
    }
}

enum SoundType {
    case start
    case rest
    case tick
    case complete
}

enum VibrationPattern {
    case single
    case double
    case triple
    case long
}

enum SoundError: LocalizedError {
    case failedToCreateBuffer
    
    var errorDescription: String? {
        switch self {
        case .failedToCreateBuffer:
            return "Failed to create audio buffer"
        }
    }
}

