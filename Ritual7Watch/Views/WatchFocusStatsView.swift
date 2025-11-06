import SwiftUI

struct WatchFocusStatsView: View {
    @EnvironmentObject private var focusStore: WatchFocusStore
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Text("This Week")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            
            // Weekly progress
            HStack(spacing: DesignSystem.Spacing.comfortable) {
                ForEach(weekDays, id: \.self) { day in
                    VStack(spacing: DesignSystem.Spacing.tight) {
                        Circle()
                            .fill(dayHasFocusSession(day) ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                        
                        Text(dayLabel(for: day))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            // Weekly total
            Text("\(weeklySessions) sessions this week")
                .font(.caption2)
                .foregroundStyle(.blue)
        }
        .padding(.vertical, DesignSystem.Spacing.xs)
        .padding(.horizontal, DesignSystem.Spacing.comfortable)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.button)
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
    
    private func dayHasFocusSession(_ date: Date) -> Bool {
        let calendar = Calendar.current
        return focusStore.sessions.contains { session in
            calendar.isDate(session.date, inSameDayAs: date) && session.phaseType == .focus
        }
    }
    
    private var weeklySessions: Int {
        let calendar = Calendar.current
        let today = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        let endOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.end ?? today
        
        return focusStore.sessions.filter { session in
            session.date >= startOfWeek && session.date < endOfWeek && session.phaseType == .focus
        }.count
    }
}

#Preview {
    WatchFocusStatsView()
        .environmentObject(WatchFocusStore())
}

