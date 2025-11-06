import SwiftUI

/// Agent 3: Focus Phase Indicator - Shows current Pomodoro phase (Focus/Break/Long Break)
/// Displays the current phase with clear visual distinction and smooth transitions

enum FocusPhase {
    case focus
    case shortBreak
    case longBreak
    
    var displayName: String {
        switch self {
        case .focus: return "Focus"
        case .shortBreak: return "Short Break"
        case .longBreak: return "Long Break"
        }
    }
    
    var icon: String {
        switch self {
        case .focus: return "brain.head.profile"
        case .shortBreak: return "cup.and.saucer.fill"
        case .longBreak: return "leaf.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .focus: return Theme.ringFocus
        case .shortBreak: return Theme.ringBreakShort
        case .longBreak: return Theme.ringBreakLong
        }
    }
    
    var description: String {
        switch self {
        case .focus: return "Time to focus and get things done"
        case .shortBreak: return "Take a short rest before your next session"
        case .longBreak: return "You've earned a longer break!"
        }
    }
}

struct FocusPhaseIndicator: View {
    let phase: FocusPhase
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Phase icon with subtle pulse animation
            ZStack {
                Circle()
                    .fill(phase.color.opacity(0.2))
                    .frame(width: 48, height: 48)
                
                Image(systemName: phase.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(phase.color)
            }
            .scaleEffect(pulseScale)
            
            // Phase info
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(phase.displayName)
                    .font(Theme.headline)
                    .foregroundStyle(Theme.textPrimary)
                
                Text(phase.description)
                    .font(Theme.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
            
            Spacer()
        }
        .padding(DesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    phase.color.opacity(0.6),
                                    phase.color.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: DesignSystem.Border.standard
                        )
                )
        )
        .softShadow()
        .onAppear {
            // Subtle pulse animation for focus phase
            if phase == .focus {
                withAnimation(Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    pulseScale = 1.05
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: DesignSystem.Spacing.lg) {
        FocusPhaseIndicator(phase: .focus)
        FocusPhaseIndicator(phase: .shortBreak)
        FocusPhaseIndicator(phase: .longBreak)
    }
    .padding()
    .background(ThemeBackground())
}

