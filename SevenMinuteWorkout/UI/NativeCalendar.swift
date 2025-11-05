import SwiftUI

struct NativeCalendar: View {
    @Binding var selectedDate: Date
    @State private var currentMonth = Date()
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    private let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: horizontalSizeClass == .regular ? 20 : 16) {
            // Header with month/year and navigation
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.title2.weight(.medium))
                        .foregroundStyle(.primary)
                        .frame(width: 44, height: 44) // Proper touch target
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Text(dateFormatter.string(from: currentMonth))
                    .font(horizontalSizeClass == .regular ? .title2.weight(.semibold) : .title3.weight(.semibold))
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.title2.weight(.medium))
                        .foregroundStyle(.primary)
                        .frame(width: 44, height: 44) // Proper touch target
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            
            // Weekday headers
            HStack(spacing: 0) {
                ForEach(weekdayHeaders, id: \.self) { weekday in
                    Text(weekday)
                        .font(horizontalSizeClass == .regular ? .caption.weight(.semibold) : .caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 16)
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: horizontalSizeClass == .regular ? 12 : 8) {
                ForEach(daysInMonth, id: \.self) { date in
                    if let date = date {
                        Button(action: { 
                            selectedDate = date
                            // Add haptic feedback for better UX
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                        }) {
                            Text(dayFormatter.string(from: date))
                                .font(.system(size: horizontalSizeClass == .regular ? 16 : 14, weight: .medium))
                                .foregroundStyle(foregroundColor(for: date))
                                .frame(width: horizontalSizeClass == .regular ? 44 : 36, height: horizontalSizeClass == .regular ? 44 : 36)
                                .background(backgroundForDate(date))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Select \(date.formatted(date: .complete, time: .omitted))")
                        .accessibilityHint("Tap to view entries for this date")
                    } else {
                        // Empty cell for days outside current month
                        Color.clear
                            .frame(width: horizontalSizeClass == .regular ? 44 : 36, height: horizontalSizeClass == .regular ? 44 : 36)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, horizontalSizeClass == .regular ? 20 : 16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.regularMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(.quaternary, lineWidth: 0.5)
                )
        )
    }
    
    private var weekdayHeaders: [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return calendar.shortWeekdaySymbols
    }
    
    private var daysInMonth: [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: currentMonth) else {
            return []
        }
        
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        let numberOfDays = range.count
        
        var days: [Date?] = []
        
        // Add empty cells for days before the first day of the month
        for _ in 1..<firstWeekday {
            days.append(nil)
        }
        
        // Add days of the month
        for day in 1...numberOfDays {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(date)
            }
        }
        
        return days
    }
    
    private func foregroundColor(for date: Date) -> Color {
        if calendar.isDate(date, inSameDayAs: selectedDate) {
            return .white
        } else if calendar.isDate(date, inSameDayAs: Date()) {
            return .accentColor
        } else if calendar.isDate(date, inSameDayAs: currentMonth) {
            return .primary
        } else {
            return .secondary
        }
    }
    
    private func backgroundForDate(_ date: Date) -> some View {
        Group {
            if calendar.isDate(date, inSameDayAs: selectedDate) {
                Circle()
                    .fill(Color.accentColor)
                    .shadow(color: Color.accentColor.opacity(0.3), radius: 2, x: 0, y: 1)
            } else if calendar.isDate(date, inSameDayAs: Date()) {
                Circle()
                    .fill(Color.accentColor.opacity(0.2))
                    .overlay(
                        Circle()
                            .stroke(Color.accentColor.opacity(0.4), lineWidth: 1)
                    )
            } else {
                Circle()
                    .fill(.clear)
            }
        }
    }
    
    private func previousMonth() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
        }
    }
    
    private func nextMonth() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
        }
    }
}

#Preview {
    NativeCalendar(selectedDate: .constant(Date()))
        .padding()
}
