import Foundation
import AVFoundation
import SwiftUI

/// Agent 6: Ambient Sounds Manager - Manages white noise and ambient sounds during focus sessions
/// Provides background audio for enhanced focus and concentration
@MainActor
final class AmbientSoundsManager: ObservableObject {
    @Published var isPlaying: Bool = false
    @Published var currentSound: AmbientSoundType = .none
    @Published var volume: Float = 0.5
    
    private var audioPlayer: AVAudioPlayer?
    private var audioSession: AVAudioSession?
    
    init() {
        setupAudioSession()
    }
    
    /// Setup audio session for background playback
    private func setupAudioSession() {
        do {
            audioSession = AVAudioSession.sharedInstance()
            try audioSession?.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try audioSession?.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error.localizedDescription)")
        }
    }
    
    /// Play ambient sound
    func playSound(_ soundType: AmbientSoundType) {
        guard soundType != .none else {
            stopSound()
            return
        }
        
        // Get sound file path
        guard let soundURL = getSoundURL(for: soundType) else {
            print("Sound file not found for type: \(soundType)")
            return
        }
        
        do {
            // Stop current sound if playing
            stopSound()
            
            // Create audio player
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.numberOfLoops = -1 // Loop indefinitely
            audioPlayer?.volume = volume
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            
            isPlaying = true
            currentSound = soundType
        } catch {
            print("Failed to play ambient sound: \(error.localizedDescription)")
        }
    }
    
    /// Stop ambient sound
    func stopSound() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        currentSound = .none
    }
    
    /// Set volume (0.0 to 1.0)
    func setVolume(_ newVolume: Float) {
        volume = max(0.0, min(1.0, newVolume))
        audioPlayer?.volume = volume
    }
    
    /// Get sound file URL for ambient sound type
    private func getSoundURL(for soundType: AmbientSoundType) -> URL? {
        // Note: In a real implementation, you would have actual sound files in the bundle
        // For now, this is a placeholder structure
        
        let fileName: String
        switch soundType {
        case .none:
            return nil
        case .whiteNoise:
            fileName = "white_noise"
        case .rain:
            fileName = "rain"
        case .forest:
            fileName = "forest"
        case .ocean:
            fileName = "ocean"
        case .cafe:
            fileName = "cafe"
        }
        
        // Try to find sound file in bundle
        if let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") {
            return url
        }
        
        // Fallback: return nil if file not found
        // In production, you would either:
        // 1. Include sound files in the app bundle
        // 2. Generate sounds programmatically
        // 3. Use a streaming service
        
        print("Sound file not found: \(fileName).mp3")
        return nil
    }
    
    /// Generate white noise programmatically (fallback)
    private func generateWhiteNoise() -> Data? {
        // This would generate white noise programmatically
        // For now, return nil - requires actual implementation
        return nil
    }
}

/// Ambient Sound Type - Available ambient sounds for focus sessions
enum AmbientSoundType: String, Codable, CaseIterable {
    case none = "none"
    case whiteNoise = "whiteNoise"
    case rain = "rain"
    case forest = "forest"
    case ocean = "ocean"
    case cafe = "cafe"
    
    var displayName: String {
        switch self {
        case .none: return "None"
        case .whiteNoise: return "White Noise"
        case .rain: return "Rain"
        case .forest: return "Forest"
        case .ocean: return "Ocean"
        case .cafe: return "Café"
        }
    }
    
    var icon: String {
        switch self {
        case .none: return "speaker.slash"
        case .whiteNoise: return "waveform"
        case .rain: return "cloud.rain"
        case .forest: return "leaf"
        case .ocean: return "water.waves"
        case .cafe: return "cup.and.saucer"
        }
    }
    
    var description: String {
        switch self {
        case .none: return "No ambient sound"
        case .whiteNoise: return "Constant white noise for focus"
        case .rain: return "Gentle rain sounds"
        case .forest: return "Nature sounds from the forest"
        case .ocean: return "Ocean waves"
        case .cafe: return "Café ambiance"
        }
    }
}

