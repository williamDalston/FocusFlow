import SwiftUI

/// Agent 11: Breathing Guide View - Visual breathing guide during rest periods
/// Provides animated breathing cues to help users recover and prepare for next exercise

// Coordinator class to manage timer for struct-based view
class BreathingAnimationCoordinator: ObservableObject {
    @Published var breathingPhase: BreathingPhase = .inhale
    @Published var scale: CGFloat = 1.0
    
    private var timer: Timer?
    private let inhaleDuration: TimeInterval = 4.0
    private let exhaleDuration: TimeInterval = 4.0
    
    func startAnimation() {
        stopAnimation()
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                let cycleTime = Date().timeIntervalSince1970.truncatingRemainder(dividingBy: self.inhaleDuration + self.exhaleDuration)
                
                if cycleTime < self.inhaleDuration {
                    // Inhale phase
                    if self.breathingPhase != .inhale {
                        self.breathingPhase = .inhale
                    }
                    let progress = cycleTime / self.inhaleDuration
                    self.scale = 1.0 + (progress * 0.4) // Scale from 1.0 to 1.4
                } else {
                    // Exhale phase
                    if self.breathingPhase != .exhale {
                        self.breathingPhase = .exhale
                    }
                    let progress = (cycleTime - self.inhaleDuration) / self.exhaleDuration
                    self.scale = 1.4 - (progress * 0.4) // Scale from 1.4 to 1.0
                }
            }
        }
    }
    
    func stopAnimation() {
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
        stopAnimation()
    }
}

struct BreathingGuideView: View {
    @StateObject private var coordinator = BreathingAnimationCoordinator()
    
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
                            colors: coordinator.breathingPhase == .inhale 
                                ? [Theme.accentB.opacity(0.6), Theme.accentB.opacity(0.3)]
                                : [Theme.accentB.opacity(0.3), Theme.accentB.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .scaleEffect(coordinator.scale)
            }
            
            // Breathing instruction
            VStack(spacing: 8) {
                Text(coordinator.breathingPhase == .inhale ? "Breathe In" : "Breathe Out")
                    .font(Theme.title2)
                    .foregroundStyle(.white)
                    .transition(.opacity)
                
                Text(breathingInstruction)
                    .font(Theme.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            
            // Next exercise preview
            if let nextExercise = exercise {
                VStack(spacing: 8) {
                    Text("Next: \(nextExercise.name)")
                        .font(Theme.headline)
                        .foregroundStyle(.white.opacity(0.9))
                    
                    Image(systemName: nextExercise.icon)
                        .font(Theme.title2)
                        .foregroundStyle(Theme.accentA)
                }
                .padding(DesignSystem.Spacing.lg)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous)
                        .fill(.white.opacity(DesignSystem.Opacity.subtle))
                )
            }
        }
        .onAppear {
            coordinator.startAnimation()
        }
        .onDisappear {
            coordinator.stopAnimation()
        }
    }
    
    private var breathingInstruction: String {
        if let exercise = exercise {
            return exercise.breathingCues
        }
        return "Breathe deeply and steadily. Inhale through your nose, exhale through your mouth."
    }
}

enum BreathingPhase {
    case inhale
    case exhale
}

