import Foundation
import AVFoundation

/// Agent 11: Voice Cues Manager - Provides voice guidance during workouts
/// Manages text-to-speech for exercise transitions and motivational messages

@MainActor
class VoiceCuesManager: NSObject, ObservableObject {
    static let shared = VoiceCuesManager()
    
    @Published var voiceEnabled: Bool = true
    @Published var voiceVolume: Float = 0.8
    
    private let synthesizer: AVSpeechSynthesizer
    private var currentUtterance: AVSpeechUtterance?
    private var selectedVoice: AVSpeechSynthesisVoice?
    private var completionCallbacks: [ObjectIdentifier: () -> Void] = [:]
    
    private let voiceEnabledKey = "workout.voiceEnabled"
    private let voiceVolumeKey = "workout.voiceVolume"
    
    override private init() {
        synthesizer = AVSpeechSynthesizer()
        super.init()
        synthesizer.delegate = VoiceCuesManager.shared
        loadSettings()
        selectBestVoice()
    }
    
    /// Selects the best available voice for optimal sound quality
    private func selectBestVoice() {
        let availableVoices = AVSpeechSynthesisVoice.speechVoices()
        
        // Try to find enhanced/premium voices first
        if let enhancedVoice = availableVoices.first(where: { voice in
            voice.language == "en-US" && 
            (voice.identifier.contains("premium") || 
             voice.identifier.contains("enhanced") ||
             voice.name.lowercased().contains("premium") ||
             voice.name.lowercased().contains("enhanced"))
        }) {
            selectedVoice = enhancedVoice
        } 
        // Fall back to default en-US voice
        else if let defaultVoice = AVSpeechSynthesisVoice(language: "en-US") {
            selectedVoice = defaultVoice
        }
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
    /// - Parameters:
    ///   - text: The text to speak
    ///   - priority: Priority level (high interrupts current speech)
    ///   - completion: Optional callback when speech finishes
    func speak(_ text: String, priority: VoicePriority = .normal, completion: (() -> Void)? = nil) {
        guard voiceEnabled else {
            completion?()
            return
        }
        
        // Stop any current speech if higher priority
        if priority == .high {
            synthesizer.stopSpeaking(at: .immediate)
        } else if synthesizer.isSpeaking {
            return // Don't interrupt normal priority messages
        }
        
        let utterance = AVSpeechUtterance(string: text)
        
        // Use the pre-selected best quality voice (cached for performance)
        if let voice = selectedVoice {
            utterance.voice = voice
        } else if let defaultVoice = AVSpeechSynthesisVoice(language: "en-US") {
            utterance.voice = defaultVoice
        }
        
        // Optimized speech parameters for clarity and naturalness
        // Rate: Slightly slower for better clarity and comprehension during workouts
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.85
        
        // Volume: User-controlled
        utterance.volume = voiceVolume
        
        // Pitch: Slightly higher for a more pleasant, energetic tone that fits workout context
        utterance.pitchMultiplier = 1.05
        
        // Pre-utterance delay: Small delay for better timing and natural flow
        utterance.preUtteranceDelay = 0.1
        
        // Post-utterance delay: Small pause after speaking for better clarity
        utterance.postUtteranceDelay = 0.15
        
        // Store completion callback using utterance's object identifier
        if let completion = completion {
            let utteranceId = ObjectIdentifier(utterance)
            completionCallbacks[utteranceId] = completion
        }
        
        currentUtterance = utterance
        synthesizer.speak(utterance)
    }
    
    /// Estimates speaking duration for a given text
    /// - Parameter text: The text to estimate
    /// - Returns: Estimated duration in seconds
    func estimateSpeakingDuration(for text: String) -> TimeInterval {
        // Base rate: AVSpeechUtteranceDefaultSpeechRate * 0.85 (slower for clarity)
        // AVSpeechUtteranceDefaultSpeechRate is typically 0.5 (normalized)
        // With 0.85 multiplier: actual rate is ~0.425
        // Average speaking rate: ~150 words per minute = ~2.5 words per second at normal rate
        // With 0.85 rate: ~2.125 words per second
        
        let wordsPerSecond = 2.125 // Words per second at 0.85 rate
        let wordCount = Double(text.split(separator: " ").count)
        let estimatedDuration = wordCount / wordsPerSecond
        
        // Add pre-utterance delay (0.1s), post-utterance delay (0.15s), and safety buffer (0.3s)
        return estimatedDuration + 0.1 + 0.15 + 0.3
    }
    
    /// Speaks exercise transition cues
    /// - Parameters:
    ///   - exercise: The exercise to announce
    ///   - phase: The workout phase
    ///   - completion: Optional callback when speech finishes
    func speakExerciseTransition(to exercise: Exercise, phase: WorkoutPhase, completion: (() -> Void)? = nil) {
        guard voiceEnabled else {
            completion?()
            return
        }
        
        switch phase {
        case .preparing:
            speak("Prepare to start. First exercise: \(exercise.name)", priority: .high, completion: completion)
        case .exercise:
            speak("\(exercise.name). Go!", priority: .high, completion: completion)
        case .rest:
            speak("Rest. Next exercise: \(exercise.name)", priority: .normal, completion: completion)
        default:
            completion?()
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

// MARK: - AVSpeechSynthesizerDelegate

extension VoiceCuesManager: AVSpeechSynthesizerDelegate {
    // AVFoundation delegate methods are called on the main thread
    // We mark them as nonisolated to satisfy the protocol, but access main actor properties safely
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        // Access main actor properties safely using Task
        Task { @MainActor in
            let utteranceId = ObjectIdentifier(utterance)
            if let completion = self.completionCallbacks[utteranceId] {
                completion()
                self.completionCallbacks.removeValue(forKey: utteranceId)
            }
        }
    }
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        // Access main actor properties safely using Task
        Task { @MainActor in
            let utteranceId = ObjectIdentifier(utterance)
            self.completionCallbacks.removeValue(forKey: utteranceId)
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

