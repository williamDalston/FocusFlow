import SwiftUI

/// Agent 1: Missing Views - Workout history row component for displaying individual workout sessions
struct WorkoutHistoryRow: View {
    let session: WorkoutSession
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            // Icon
            Circle()
                .fill(Theme.accentA.opacity(DesignSystem.Opacity.subtle))
                .frame(width: DesignSystem.IconSize.xlarge, height: DesignSystem.IconSize.xlarge)
                .overlay(
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Theme.accentA)
                )
            
            // Content
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                HStack {
                    Text("\(session.exercisesCompleted) exercises completed")
                        .font(Theme.headline)
                        .foregroundStyle(Theme.textPrimary)
                    
                    Spacer()
                    
                    Text(formatDuration(session.duration))
                        .font(Theme.subheadline)
                        .foregroundStyle(Theme.accentA)
                        .monospacedDigit()
                }
                
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Label {
                        Text(session.date.formatted(date: .abbreviated, time: .shortened))
                            .font(Theme.caption)
                            .foregroundStyle(.secondary)
                    } icon: {
                        Image(systemName: "calendar")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    
                    if session.notes != nil && !session.notes!.isEmpty {
                        Label {
                            Text("Has notes")
                                .font(Theme.caption2)
                                .foregroundStyle(.secondary)
                        } icon: {
                            Image(systemName: "note.text")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.caption)
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
                                Theme.accentA.opacity(DesignSystem.Opacity.highlight * 0.2),
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
                                Theme.accentA.opacity(DesignSystem.Opacity.light * 0.3),
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
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

