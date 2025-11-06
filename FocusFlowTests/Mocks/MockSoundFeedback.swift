import Foundation
@testable import Ritual7

/// Mock implementation of SoundFeedbackProvider for testing
final class MockSoundFeedback: SoundFeedbackProvider {
    private(set) var playedSounds: [SoundType] = []
    private(set) var vibrationPatterns: [VibrationPattern] = []
    
    func playSound(_ type: SoundType) async {
        playedSounds.append(type)
    }
    
    func vibrate(_ pattern: VibrationPattern) async {
        vibrationPatterns.append(pattern)
    }
    
    var playSoundCallCount: Int {
        playedSounds.count
    }
    
    var vibrateCallCount: Int {
        vibrationPatterns.count
    }
    
    func reset() {
        playedSounds.removeAll()
        vibrationPatterns.removeAll()
    }
}

