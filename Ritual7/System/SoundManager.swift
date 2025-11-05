import Foundation
import AVFoundation
import Combine
import UIKit
import os.log

/// Agent 8 & 11: Manages sound effects and voice cues for the workout app
/// Enhanced with voice cues integration and audio preferences
@MainActor
class SoundManager: ObservableObject {
    static let shared = SoundManager()
    
    @Published var soundEnabled: Bool = true
    @Published var vibrationEnabled: Bool = true
    
    // Agent 11: Voice cues integration
    private let voiceCuesManager = VoiceCuesManager.shared
    
    private var audioPlayer: AVAudioPlayer?
    private let soundEnabledKey = "workout.soundEnabled"
    private let vibrationEnabledKey = "workout.vibrationEnabled"
    
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
        
        switch type {
        case .start:
            await playTone(frequency: 440.0, duration: 0.3)
            // Agent 11: Voice cues are handled separately in VoiceCuesManager
        case .rest:
            await playTone(frequency: 523.25, duration: 0.3)
        case .tick:
            await playTone(frequency: 880.0, duration: 0.1)
            // Agent 11: Optional voice countdown (handled by VoiceCuesManager)
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
        
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1) else { return }
        
        engine.attach(playerNode)
        engine.connect(playerNode, to: engine.mainMixerNode, format: format)
        
        do {
            try engine.start()
            
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
            
            // Buffer has finished playing, clean up
            playerNode.stop()
            engine.stop()
        } catch {
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

