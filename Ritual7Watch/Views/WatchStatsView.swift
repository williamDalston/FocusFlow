import SwiftUI

struct WatchStatsView: View {
    @EnvironmentObject private var workoutStore: WatchWorkoutStore
    
    var body: some View {
        VStack(spacing: 8) {
            Text("This Week")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            
            // Weekly progress
            HStack(spacing: 12) {
                ForEach(weekDays, id: \.self) { day in
                    VStack(spacing: 2) {
                        Circle()
                            .fill(dayHasWorkout(day) ? Color.green : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                        
                        Text(dayLabel(for: day))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            // Weekly total
            Text("\(weeklyWorkouts) workouts this week")
                .font(.caption2)
                .foregroundStyle(.green)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
    
    private var weekDays: [Date] {
        let calendar = Calendar.current
        let today = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        
        return (0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek)
        }
    }
    
    private func dayLabel(for date: Date) -> String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
    
    private func dayHasWorkout(_ date: Date) -> Bool {
        let calendar = Calendar.current
        return workoutStore.sessions.contains { session in
            calendar.isDate(session.date, inSameDayAs: date)
        }
    }
    
    private var weeklyWorkouts: Int {
        let calendar = Calendar.current
        let today = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        let endOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.end ?? today
        
        return workoutStore.sessions.filter { session in
            session.date >= startOfWeek && session.date < endOfWeek
        }.count
    }
}

#Preview {
    WatchStatsView()
        .environmentObject(WatchWorkoutStore())
}
