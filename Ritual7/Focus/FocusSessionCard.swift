import SwiftUI

/// Agent 3: Focus Session Card - Displays a focus session in history
/// Shows session details: duration, phase type, completion status, and date

struct FocusSessionCard: View {
    let sessionDate: Date
    let duration: TimeInterval
    let phaseType: FocusPhase
    let isCompleted: Bool
    let cycleNumber: Int? // Optional cycle number if part of a Pomodoro cycle
    
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Phase indicator icon
            ZStack {
                Circle()
                    .fill(phaseType.color.opacity(0.2))
                    .frame(width: 48, height: 48)
                
                Image(systemName: phaseType.icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(phaseType.color)
            }
            
            // Session info
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                HStack {
                    Text(phaseType.displayName)
                        .font(Theme.headline)
                        .foregroundStyle(Theme.textPrimary)
                    
                    if let cycleNumber = cycleNumber {
                        Text("• Cycle \(cycleNumber)")
                            .font(Theme.caption)
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
                
                HStack(spacing: DesignSystem.Spacing.md) {
                    Label(formattedDuration, systemImage: "clock.fill")
                        .font(Theme.caption)
                        .foregroundStyle(Theme.textSecondary)
                    
                    if isCompleted {
                        Label("Completed", systemImage: "checkmark.circle.fill")
                            .font(Theme.caption)
                            .foregroundStyle(Theme.success)
                    } else {
                        Label("Incomplete", systemImage: "xmark.circle.fill")
                            .font(Theme.caption)
                            .foregroundStyle(Theme.error)
                    }
                }
                
                Text(sessionDate.formatted(date: .abbreviated, time: .shortened))
                    .font(Theme.caption2)
                    .foregroundStyle(Theme.textSecondary.opacity(0.8))
            }
            
            Spacer()
            
            // Completion checkmark
            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(Theme.success)
            }
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
                                    phaseType.color.opacity(0.3),
                                    Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: DesignSystem.Border.subtle
                        )
                )
        )
        .softShadow()
    }
}

#Preview {
    VStack(spacing: DesignSystem.Spacing.md) {
        FocusSessionCard(
            sessionDate: Date(),
            duration: 1500, // 25 minutes
            phaseType: .focus,
            isCompleted: true,
            cycleNumber: 2
        )
        
        FocusSessionCard(
            sessionDate: Date().addingTimeInterval(-3600),
            duration: 300, // 5 minutes
            phaseType: .shortBreak,
            isCompleted: true,
            cycleNumber: nil
        )
        
        FocusSessionCard(
            sessionDate: Date().addingTimeInterval(-7200),
            duration: 900, // 15 minutes
            phaseType: .longBreak,
            isCompleted: true,
            cycleNumber: nil
        )
    }
    .padding()
    .background(ThemeBackground())
}

