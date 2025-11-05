import SwiftUI

/// Agent 11: Breathing Guide View - Visual breathing guide during rest periods
/// Provides animated breathing cues to help users recover and prepare for next exercise

struct BreathingGuideView: View {
    @State private var breathingPhase: BreathingPhase = .inhale
    @State private var scale: CGFloat = 1.0
    @State private var timer: Timer?
    
    let exercise: Exercise?
    let duration: TimeInterval
    
    var body: some View {
        VStack(spacing: 24) {
            // Breathing circle animation
            ZStack {
                // Outer circle
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 3)
                    .frame(width: 120, height: 120)
                
                // Animated breathing circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: breathingPhase == .inhale 
                                ? [Theme.accentB.opacity(0.6), Theme.accentB.opacity(0.3)]
                                : [Theme.accentB.opacity(0.3), Theme.accentB.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .scaleEffect(scale)
            }
            
            // Breathing instruction
            VStack(spacing: 8) {
                Text(breathingPhase == .inhale ? "Breathe In" : "Breathe Out")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                    .transition(.opacity)
                
                Text(breathingInstruction)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            
            // Next exercise preview
            if let nextExercise = exercise {
                VStack(spacing: 8) {
                    Text("Next: \(nextExercise.name)")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.9))
                    
                    Image(systemName: nextExercise.icon)
                        .font(.title2)
                        .foregroundStyle(Theme.accentA)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.white.opacity(0.1))
                )
            }
        }
        .onAppear {
            startBreathingAnimation()
        }
        .onDisappear {
            stopBreathingAnimation()
        }
    }
    
    private var breathingInstruction: String {
        if let exercise = exercise {
            return exercise.breathingCues
        }
        return "Breathe deeply and steadily. Inhale through your nose, exhale through your mouth."
    }
    
    private func startBreathingAnimation() {
        let inhaleDuration = 4.0 // 4 seconds to inhale
        let exhaleDuration = 4.0 // 4 seconds to exhale
        
        // Ensure timer is created on main thread
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                let cycleTime = Date().timeIntervalSince1970.truncatingRemainder(dividingBy: inhaleDuration + exhaleDuration)
                
                if cycleTime < inhaleDuration {
                    // Inhale phase
                    if self.breathingPhase != .inhale {
                        self.breathingPhase = .inhale
                    }
                    let progress = cycleTime / inhaleDuration
                    self.scale = 1.0 + (progress * 0.4) // Scale from 1.0 to 1.4
                } else {
                    // Exhale phase
                    if self.breathingPhase != .exhale {
                        self.breathingPhase = .exhale
                    }
                    let progress = (cycleTime - inhaleDuration) / exhaleDuration
                    self.scale = 1.4 - (progress * 0.4) // Scale from 1.4 to 1.0
                }
            }
        }
    }
    
    private func stopBreathingAnimation() {
        timer?.invalidate()
        timer = nil
    }
}

enum BreathingPhase {
    case inhale
    case exhale
}

