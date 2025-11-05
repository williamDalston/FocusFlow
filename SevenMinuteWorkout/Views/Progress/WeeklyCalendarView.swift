import SwiftUI

/// Agent 2: Weekly Calendar - Beautiful heatmap calendar showing workout days
struct WeeklyCalendarView: View {
    @ObservedObject var analytics: WorkoutAnalytics
    @EnvironmentObject private var theme: ThemeStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            Text("Workout Calendar")
                .font(Theme.headline)
                .foregroundStyle(Theme.textPrimary)
            
            // Last 8 weeks
            VStack(spacing: DesignSystem.Spacing.md) {
                // Week labels
                HStack(spacing: 0) {
                    Text("")
                        .frame(width: 60)
                    
                    ForEach(DayOfWeek.allCases, id: \.rawValue) { day in
                        Text(day.shortName)
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }
                
                // Calendar grid
                ForEach(0..<8, id: \.self) { weekOffset in
                    HStack(spacing: 0) {
                        // Week label
                        Text(weekLabel(for: weekOffset))
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(.secondary)
                            .frame(width: 60, alignment: .trailing)
                            .padding(.trailing, 8)
                        
                        // Days
                        ForEach(DayOfWeek.allCases, id: \.rawValue) { day in
                            dayCell(for: day, weekOffset: weekOffset)
                        }
                    }
                }
            }
            
            // Legend
            HStack(spacing: DesignSystem.Spacing.lg) {
                legendItem(color: .gray.opacity(DesignSystem.Opacity.subtle), label: "No workout")
                legendItem(color: Theme.accentA.opacity(DesignSystem.Opacity.medium), label: "1 workout")
                legendItem(color: Theme.accentA.opacity(DesignSystem.Opacity.strong), label: "2 workouts")
                legendItem(color: Theme.accentA, label: "3+ workouts")
            }
            .font(Theme.caption2)
            .padding(.top, DesignSystem.Spacing.sm)
        }
        .cardPadding()
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                        .stroke(Theme.strokeOuter, lineWidth: DesignSystem.Border.subtle)
                )
        )
        .cardShadow()
    }
    
    // MARK: - Day Cell
    
    private func dayCell(for day: DayOfWeek, weekOffset: Int) -> some View {
        let calendar = Calendar.current
        let today = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        let targetWeek = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: startOfWeek) ?? today
        let targetDate = calendar.date(byAdding: .day, value: day.rawValue - 1, to: targetWeek) ?? today
        
        let workoutCount = workoutCount(for: targetDate)
        let intensity = min(workoutCount, 3)
        
        let backgroundColor: Color = {
            switch intensity {
            case 0: return .gray.opacity(0.2)
            case 1: return Theme.accentA.opacity(0.5)
            case 2: return Theme.accentA.opacity(0.7)
            default: return Theme.accentA
            }
        }()
        
        return Rectangle()
            .fill(backgroundColor)
            .cornerRadius(DesignSystem.CornerRadius.small * 0.5)
            .frame(height: DesignSystem.Spacing.xxl)
            .overlay(
                Group {
                    if workoutCount > 0 {
                        Text("\(workoutCount)")
                            .font(Theme.caption2)
                            .foregroundStyle(workoutCount >= 3 ? .white : Theme.textPrimary)
                            .monospacedDigit()
                    }
                }
            )
            .padding(DesignSystem.Spacing.xs * 0.5)
    }
    
    private func workoutCount(for date: Date) -> Int {
        let calendar = Calendar.current
        return analytics.store.sessions.filter { session in
            calendar.isDate(session.date, inSameDayAs: date)
        }.count
    }
    
    private func weekLabel(for weekOffset: Int) -> String {
        let calendar = Calendar.current
        let today = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        let targetWeek = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: startOfWeek) ?? today
        
        if weekOffset == 0 {
            return "This week"
        } else if weekOffset == 1 {
            return "Last week"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: targetWeek)
        }
    }
    
    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Rectangle()
                .fill(color)
                .frame(width: 12, height: 12)
                .cornerRadius(2)
            Text(label)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Monthly Calendar View

struct MonthlyCalendarView: View {
    @ObservedObject var analytics: WorkoutAnalytics
    @EnvironmentObject private var theme: ThemeStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            Text("Monthly Overview")
                .font(Theme.headline)
                .foregroundStyle(Theme.textPrimary)
            
            // Current month
            let calendar = Calendar.current
            let today = Date()
            let startOfMonth = calendar.dateInterval(of: .month, for: today)?.start ?? today
            
            VStack(spacing: DesignSystem.Spacing.sm) {
                // Month header
                HStack {
                    Text(today.formatted(.dateTime.month(.wide).year()))
                        .font(Theme.subheadline)
                        .foregroundStyle(Theme.textPrimary)
                    Spacer()
                    Text("\(analytics.store.workoutsThisMonth) workouts")
                        .font(Theme.caption)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
                
                // Week labels
                HStack(spacing: 0) {
                    ForEach(DayOfWeek.allCases, id: \.rawValue) { day in
                        Text(day.shortName)
                            .font(Theme.caption2)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
                
                // Calendar grid
                let monthDays = daysInMonth(startOfMonth)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: DesignSystem.Spacing.xs) {
                    ForEach(monthDays, id: \.self) { date in
                        monthlyDayCell(for: date)
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
            }
            
            // Legend
            HStack(spacing: DesignSystem.Spacing.lg) {
                legendItem(color: .gray.opacity(DesignSystem.Opacity.subtle), label: "No workout")
                legendItem(color: Theme.accentA.opacity(DesignSystem.Opacity.medium), label: "1 workout")
                legendItem(color: Theme.accentA.opacity(DesignSystem.Opacity.strong), label: "2 workouts")
                legendItem(color: Theme.accentA, label: "3+ workouts")
            }
            .font(Theme.caption2)
            .padding(.top, DesignSystem.Spacing.sm)
            .padding(.horizontal, DesignSystem.Spacing.lg)
        }
        .cardPadding()
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                        .stroke(Theme.strokeOuter, lineWidth: DesignSystem.Border.subtle)
                )
        )
        .cardShadow()
    }
    
    private func monthlyDayCell(for date: Date) -> some View {
        let calendar = Calendar.current
        let today = Date()
        let isToday = calendar.isDateInToday(date)
        let isCurrentMonth = calendar.isDate(date, equalTo: today, toGranularity: .month)
        
        let workoutCount = workoutCount(for: date)
        let intensity = min(workoutCount, 3)
        
        let backgroundColor: Color = {
            if !isCurrentMonth {
                return .clear
            }
            switch intensity {
            case 0: return .gray.opacity(0.2)
            case 1: return Theme.accentA.opacity(0.5)
            case 2: return Theme.accentA.opacity(0.7)
            default: return Theme.accentA
            }
        }()
        
        let dayNumber = calendar.component(.day, from: date)
        
        return VStack(spacing: 2) {
            Text("\(dayNumber)")
                .font(.caption2.weight(isToday ? .bold : .regular))
                .foregroundStyle(isCurrentMonth ? Theme.textPrimary : .secondary)
            
            if workoutCount > 0 {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Text("\(workoutCount)")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(workoutCount >= 3 ? .white : Theme.textPrimary)
                    )
            } else {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 20, height: 20)
            }
        }
        .frame(height: 50)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(isToday ? Theme.accentA : Color.clear, lineWidth: 2)
        )
    }
    
    private func workoutCount(for date: Date) -> Int {
        let calendar = Calendar.current
        return analytics.store.sessions.filter { session in
            calendar.isDate(session.date, inSameDayAs: date)
        }.count
    }
    
    private func daysInMonth(_ startDate: Date) -> [Date] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: startDate) ?? 1..<32
        let firstWeekday = calendar.component(.weekday, from: startDate)
        
        var days: [Date] = []
        
        // Add padding for days before the first day of the month
        let padding = (firstWeekday - 1) % 7
        if padding > 0 {
            let previousMonth = calendar.date(byAdding: .month, value: -1, to: startDate) ?? startDate
            let daysInPreviousMonth = calendar.range(of: .day, in: .month, for: previousMonth)?.count ?? 30
            for i in (daysInPreviousMonth - padding + 1)...daysInPreviousMonth {
                if let date = calendar.date(byAdding: .day, value: i - daysInPreviousMonth, to: startDate) {
                    days.append(date)
                }
            }
        }
        
        // Add days of the current month
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startDate) {
                days.append(date)
            }
        }
        
        // Add padding for days after the last day of the month
        let remaining = 42 - days.count // 6 weeks * 7 days
        if remaining > 0 {
            for i in 1...remaining {
                if let date = calendar.date(byAdding: .day, value: i, to: days.last ?? startDate) {
                    days.append(date)
                }
            }
        }
        
        return days
    }
    
    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Rectangle()
                .fill(color)
                .frame(width: 12, height: 12)
                .cornerRadius(2)
            Text(label)
                .foregroundStyle(.secondary)
        }
    }
}


