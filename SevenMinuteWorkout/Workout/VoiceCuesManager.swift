import Foundation
import AVFoundation

/// Agent 11: Voice Cues Manager - Provides voice guidance during workouts
/// Manages text-to-speech for exercise transitions and motivational messages

@MainActor
class VoiceCuesManager: ObservableObject {
    static let shared = VoiceCuesManager()
    
    @Published var voiceEnabled: Bool = true
    @Published var voiceVolume: Float = 0.8
    
    private let synthesizer = AVSpeechSynthesizer()
    private var currentUtterance: AVSpeechUtterance?
    
    private let voiceEnabledKey = "workout.voiceEnabled"
    private let voiceVolumeKey = "workout.voiceVolume"
    
    private init() {
        loadSettings()
    }
    
    // MARK: - Settings
    
    private func loadSettings() {
        let defaults = UserDefaults.standard
        voiceEnabled = defaults.object(forKey: voiceEnabledKey) as? Bool ?? true
        voiceVolume = defaults.object(forKey: voiceVolumeKey) as? Float ?? 0.8
    }
    
    func saveSettings() {
        let defaults = UserDefaults.standard
        defaults.set(voiceEnabled, forKey: voiceEnabledKey)
        defaults.set(voiceVolume, forKey: voiceVolumeKey)
    }
    
    // MARK: - Voice Cues
    
    /// Speaks a text message using text-to-speech
    func speak(_ text: String, priority: VoicePriority = .normal) {
        guard voiceEnabled else { return }
        
        // Stop any current speech if higher priority
        if priority == .high {
            synthesizer.stopSpeaking(at: .immediate)
        } else if synthesizer.isSpeaking {
            return // Don't interrupt normal priority messages
        }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.9 // Slightly slower for clarity
        utterance.volume = voiceVolume
        utterance.pitchMultiplier = 1.0
        
        currentUtterance = utterance
        synthesizer.speak(utterance)
    }
    
    /// Speaks exercise transition cues
    func speakExerciseTransition(to exercise: Exercise, phase: WorkoutPhase) {
        guard voiceEnabled else { return }
        
        switch phase {
        case .preparing:
            speak("Prepare to start. First exercise: \(exercise.name)", priority: .high)
        case .exercise:
            speak("\(exercise.name). Go!", priority: .high)
        case .rest:
            speak("Rest. Next exercise: \(exercise.name)", priority: .normal)
        default:
            break
        }
    }
    
    /// Speaks countdown cues
    func speakCountdown(_ seconds: Int) {
        guard seconds > 0 && seconds <= 3 else { return }
        speak("\(seconds)", priority: .high)
    }
    
    /// Speaks motivational messages during workout
    func speakMotivationalMessage() {
        let messages = [
            "You're doing great!",
            "Keep it up!",
            "You've got this!",
            "Stay strong!",
            "Almost there!",
            "You're crushing it!",
            "Keep going!",
            "You're amazing!"
        ]
        
        if let message = messages.randomElement() {
            speak(message, priority: .low)
        }
    }
    
    /// Speaks form guidance cues
    func speakFormGuidance(for exercise: Exercise) {
        let guidance = getFormGuidance(for: exercise)
        if !guidance.isEmpty {
            speak(guidance, priority: .normal)
        }
    }
    
    /// Speaks completion message
    func speakCompletion(stats: WorkoutStats) {
        let message = "Workout complete! You finished \(stats.exercisesCompleted) exercises in \(formatDuration(stats.duration)). Great job!"
        speak(message, priority: .high)
    }
    
    /// Stops any current speech
    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
    }
    
    // MARK: - Helpers
    
    private func getFormGuidance(for exercise: Exercise) -> String {
        switch exercise.name {
        case "Jumping Jacks":
            return "Land softly on your toes"
        case "Wall Sit":
            return "Keep your back flat against the wall"
        case "Push-up":
            return "Keep your core engaged throughout"
        case "Squat":
            return "Keep your weight in your heels"
        case "Plank":
            return "Keep your body in a straight line"
        case "Lunge":
            return "Keep your front knee over your ankle"
        default:
            return ""
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        if minutes > 0 {
            return "\(minutes) minute\(minutes == 1 ? "" : "s") \(seconds) second\(seconds == 1 ? "" : "s")"
        } else {
            return "\(seconds) second\(seconds == 1 ? "" : "s")"
        }
    }
}

// MARK: - Supporting Types

enum VoicePriority {
    case low
    case normal
    case high
}

struct WorkoutStats {
    let exercisesCompleted: Int
    let duration: TimeInterval
}

