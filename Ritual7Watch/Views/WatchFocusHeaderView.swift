import SwiftUI

struct WatchFocusHeaderView: View {
    @EnvironmentObject private var focusStore: WatchFocusStore
    
    var body: some View {
        VStack(spacing: 4) {
            // App icon and title
            HStack(spacing: 6) {
                Image(systemName: "brain.head.profile")
                    .font(.title3)
                    .foregroundStyle(.blue)
                
                Text("Pomodoro")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.primary)
            }
            
            // Streak display
            HStack(spacing: 8) {
                VStack(spacing: 2) {
                    Text("\(focusStore.streak)")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.orange)
                    
                    Text("Day Streak")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                // Today's focus sessions count
                VStack(spacing: 2) {
                    Text("\(todaysSessions)")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.blue)
                    
                    Text("Today")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
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

