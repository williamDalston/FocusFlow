import SwiftUI

struct WatchFocusHeaderView: View {
    @EnvironmentObject private var focusStore: WatchFocusStore
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.tight) {
            // App icon and title
            HStack(spacing: DesignSystem.Spacing.iconSpacing) {
                Image(systemName: "brain.head.profile")
                    .font(.title3)
                    .foregroundStyle(.blue)
                
                Text("Pomodoro")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.primary)
            }
            
            // Streak display
            HStack(spacing: DesignSystem.Spacing.xs) {
                VStack(spacing: DesignSystem.Spacing.tight) {
                    Text("\(focusStore.streak)")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.orange)
                    
                    Text("Day Streak")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                // Today's focus sessions count
                VStack(spacing: DesignSystem.Spacing.tight) {
                    Text("\(todaysSessions)")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.blue)
                    
                    Text("Today")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, DesignSystem.Spacing.xs)
        .padding(.horizontal, DesignSystem.Spacing.comfortable)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private var todaysSessions: Int {
        let calendar = Calendar.current
        let today = Date()
        return focusStore.sessions.filter { session in
            calendar.isDate(session.date, inSameDayAs: today) && session.phaseType == .focus
        }.count
    }
}

#Preview {
    WatchFocusHeaderView()
        .environmentObject(WatchFocusStore())
}

