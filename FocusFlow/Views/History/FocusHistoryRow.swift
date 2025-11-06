import SwiftUI

/// Agent 13: Focus History Row - Focus history row component for displaying individual focus sessions
/// Refactored from WorkoutHistoryRow for Pomodoro Timer app
struct FocusHistoryRow: View {
    let session: FocusSession
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            // Icon
            Circle()
                .fill(phaseColor.opacity(DesignSystem.Opacity.subtle))
                .frame(width: DesignSystem.IconSize.xlarge, height: DesignSystem.IconSize.xlarge)
                .overlay(
                    Image(systemName: phaseIcon)
                        .font(Theme.title3)
                        .foregroundStyle(phaseColor)
                )
            
            // Content
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                HStack {
                    Text(session.phaseType.displayName)
                        .font(Theme.headline)
                        .foregroundStyle(Theme.textPrimary)
                    
                    Spacer()
                    
                    Text(formatDuration(session.duration))
                        .font(Theme.subheadline)
                        .foregroundStyle(phaseColor)
                        .monospacedDigit()
                }
                
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Label {
                        Text(session.date.formatted(date: .abbreviated, time: .shortened))
                            .font(Theme.caption)
                            .foregroundStyle(.secondary)
                    } icon: {
                        Image(systemName: "calendar")
                            .font(Theme.caption2)
                            .foregroundStyle(.secondary)
                    }
                    
                    if let notes = session.notes, !notes.isEmpty {
                        Label {
                            Text("Has notes")
                                .font(Theme.caption)
                                .foregroundStyle(.secondary)
                        } icon: {
                            Image(systemName: "note.text")
                                .font(Theme.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(Theme.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.md)
        .background(
            ZStack {
                // Base material
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                    .fill(.ultraThinMaterial)
                
                // Subtle gradient overlay
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                phaseColor.opacity(DesignSystem.Opacity.highlight * 0.2),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .blendMode(.overlay)
            }
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle * 1.5),
                                phaseColor.opacity(DesignSystem.Opacity.light * 0.3),
                                Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle * 1.5)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: DesignSystem.Border.subtle
                    )
            )
        )
        .softShadow()
    }
    
    private var phaseColor: Color {
        switch session.phaseType {
        case .focus:
            return Theme.ringFocus
        case .shortBreak:
            return Theme.ringBreakShort
        case .longBreak:
            return Theme.ringBreakLong
        }
    }
    
    private var phaseIcon: String {
        switch session.phaseType {
        case .focus:
            return "brain.head.profile"
        case .shortBreak:
            return "cup.and.saucer"
        case .longBreak:
            return "bed.double"
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

