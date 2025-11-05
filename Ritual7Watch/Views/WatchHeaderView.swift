import SwiftUI

struct WatchHeaderView: View {
    @EnvironmentObject private var workoutStore: WatchWorkoutStore
    
    var body: some View {
        VStack(spacing: 4) {
            // App icon and title
            HStack(spacing: 6) {
                Image(systemName: "figure.run")
                    .font(.title3)
                    .foregroundStyle(.green)
                
                Text("7 Min Workout")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.primary)
            }
            
            // Streak display
            HStack(spacing: 8) {
                VStack(spacing: 2) {
                    Text("\(workoutStore.streak)")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.orange)
                    
                    Text("Day Streak")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                // Today's workouts count
                VStack(spacing: 2) {
                    Text("\(todaysWorkouts)")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.green)
                    
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
                        .stroke(Color.green.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private var todaysWorkouts: Int {
        let calendar = Calendar.current
        let today = Date()
        return workoutStore.sessions.filter { session in
            calendar.isDate(session.date, inSameDayAs: today)
        }.count
    }
}

#Preview {
    WatchHeaderView()
        .environmentObject(WatchWorkoutStore())
}
