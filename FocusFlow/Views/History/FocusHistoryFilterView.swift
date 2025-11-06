import SwiftUI

/// Agent 13: Focus History Filter View - Filter view for focus history with date range selection
/// Refactored from WorkoutHistoryFilterView for Pomodoro Timer app
struct FocusHistoryFilterView: View {
    @Binding var selectedDateRange: DateRange
    @Binding var customStartDate: Date
    @Binding var customEndDate: Date
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                ThemeBackground()
                
                Form {
                    Section {
                        ForEach(DateRange.allCases, id: \.self) { range in
                            Button {
                                selectedDateRange = range
                                Haptics.tap()
                            } label: {
                                HStack {
                                    Image(systemName: range.icon)
                                        .foregroundStyle(Theme.accentA)
                                        .frame(width: DesignSystem.IconSize.large)
                                    
                                    Text(range.displayName)
                                        .font(Theme.body)
                                        .foregroundStyle(Theme.textPrimary)
                                    
                                    Spacer()
                                    
                                    if selectedDateRange == range {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(Theme.accentA)
                                            .font(Theme.headline)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    } header: {
                        Text("Date Range")
                            .font(Theme.headline)
                            .foregroundStyle(Theme.textPrimary)
                    }
                    
                    if selectedDateRange == .custom {
                        Section {
                            DatePicker(
                                "Start Date",
                                selection: $customStartDate,
                                displayedComponents: [.date]
                            )
                            .datePickerStyle(.compact)
                            
                            DatePicker(
                                "End Date",
                                selection: $customEndDate,
                                displayedComponents: [.date]
                            )
                            .datePickerStyle(.compact)
                        } header: {
                            Text("Custom Range")
                                .font(Theme.headline)
                                .foregroundStyle(Theme.textPrimary)
                        } footer: {
                            Text("Select a custom date range for filtering focus sessions")
                                .font(Theme.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Filter Focus Sessions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                        Haptics.tap()
                    }
                    .font(Theme.headline)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                        Haptics.tap()
                    }
                    .font(Theme.headline)
                    .foregroundStyle(Theme.accentA)
                }
            }
        }
    }
}

