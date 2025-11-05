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
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                        .stroke(Theme.strokeOuter, lineWidth: DesignSystem.Border.subtle)
                )
        )
        .shadow(color: Theme.enhancedShadow.opacity(DesignSystem.Opacity.subtle * 0.5), 
               radius: DesignSystem.Shadow.small.radius * 0.5, 
               y: DesignSystem.Shadow.small.y * 0.5)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

