import SwiftUI

/// Agent 10: Goal Setting View - UI for setting and tracking workout goals
struct GoalSettingView: View {
    @ObservedObject var goalManager: GoalManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedWeeklyGoal: Int = 0
    @State private var selectedMonthlyGoal: Int = 0
    @State private var showingWeeklyPicker = false
    @State private var showingMonthlyPicker = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Weekly Goal Section
                weeklyGoalSection
                
                // Monthly Goal Section
                monthlyGoalSection
                
                // Goal Predictions
                if goalManager.weeklyGoal > 0 || goalManager.monthlyGoal > 0 {
                    goalPredictionsSection
                }
                
                // Adaptive Suggestions
                adaptiveSuggestionsSection
            }
            .padding()
        }
        .background(ThemeBackground())
        .navigationTitle("Goals")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .onAppear {
            selectedWeeklyGoal = goalManager.weeklyGoal
            selectedMonthlyGoal = goalManager.monthlyGoal
        }
    }
    
    // MARK: - Weekly Goal Section
    
    private var weeklyGoalSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Weekly Goal")
                .font(Theme.headline)
                .foregroundStyle(Theme.textPrimary)
            
            GlassCard(material: .ultraThinMaterial) {
                VStack(spacing: 20) {
                    // Current Progress
                    if goalManager.weeklyGoal > 0 {
                        VStack(spacing: 12) {
                            HStack {
                                Text("Progress")
                                    .font(Theme.subheadline.weight(.medium))
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text("\(goalManager.weeklyProgress) / \(goalManager.weeklyGoal)")
                                    .font(Theme.title3)
                                    .foregroundStyle(Theme.textPrimary)
                            }
                            
                            // Progress Bar
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous)
                                        .fill(Color.gray.opacity(DesignSystem.Opacity.light))
                                    
                                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous)
                                        .fill(Theme.accentA.gradient)
                                        .frame(width: geometry.size.width * goalManager.weeklyProgressPercentage)
                                        .animation(.spring(response: 0.6), value: goalManager.weeklyProgressPercentage)
                                }
                            }
                            .frame(height: 12)
                            
                            if !goalManager.isWeeklyGoalAchieved {
                                HStack {
                                    Image(systemName: "info.circle")
                                        .font(Theme.caption)
                                        .foregroundStyle(.secondary)
                                    Text("\(goalManager.weeklyWorkoutsRemaining) workout(s) remaining")
                                        .font(Theme.caption)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                }
                            } else {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                    Text("Goal Achieved! 🎉")
                                        .font(Theme.subheadline.weight(.semibold))
                                        .foregroundStyle(.green)
                                }
                            }
                        }
                    }
                    
                    // Goal Picker
                    Button {
                        showingWeeklyPicker = true
                    } label: {
                        HStack {
                            Text(goalManager.weeklyGoal == 0 ? "Set Weekly Goal" : "\(goalManager.weeklyGoal) workouts per week")
                                .font(Theme.body.weight(.medium))
                                .foregroundStyle(Theme.textPrimary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(Theme.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous)
                                .fill(Theme.accentA.opacity(DesignSystem.Opacity.subtle))
                        )
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $showingWeeklyPicker) {
            WeeklyGoalPickerView(
                selectedGoal: $selectedWeeklyGoal,
                currentGoal: goalManager.weeklyGoal,
                suggestion: goalManager.getAdaptiveGoalSuggestion(for: .weekly)
            ) { newGoal in
                goalManager.setWeeklyGoal(newGoal)
                showingWeeklyPicker = false
            }
        }
    }
    
    // MARK: - Monthly Goal Section
    
    private var monthlyGoalSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Monthly Goal")
                .font(Theme.headline)
                .foregroundStyle(Theme.textPrimary)
            
            GlassCard(material: .ultraThinMaterial) {
                VStack(spacing: 20) {
                    // Current Progress
                    if goalManager.monthlyGoal > 0 {
                        VStack(spacing: 12) {
                            HStack {
                                Text("Progress")
                                    .font(Theme.subheadline.weight(.medium))
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text("\(goalManager.monthlyProgress) / \(goalManager.monthlyGoal)")
                                    .font(Theme.title3)
                                    .foregroundStyle(Theme.textPrimary)
                            }
                            
                            // Progress Bar
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous)
                                        .fill(Color.gray.opacity(DesignSystem.Opacity.light))
                                    
                                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous)
                                        .fill(Theme.accentB.gradient)
                                        .frame(width: geometry.size.width * goalManager.monthlyProgressPercentage)
                                        .animation(.spring(response: 0.6), value: goalManager.monthlyProgressPercentage)
                                }
                            }
                            .frame(height: 12)
                            
                            if !goalManager.isMonthlyGoalAchieved {
                                HStack {
                                    Image(systemName: "info.circle")
                                        .font(Theme.caption)
                                        .foregroundStyle(.secondary)
                                    Text("\(goalManager.monthlyWorkoutsRemaining) workout(s) remaining")
                                        .font(Theme.caption)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                }
                            } else {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                    Text("Goal Achieved! 🎉")
                                        .font(Theme.subheadline.weight(.semibold))
                                        .foregroundStyle(.green)
                                }
                            }
                        }
                    }
                    
                    // Goal Picker
                    Button {
                        showingMonthlyPicker = true
                    } label: {
                        HStack {
                            Text(goalManager.monthlyGoal == 0 ? "Set Monthly Goal" : "\(goalManager.monthlyGoal) workouts per month")
                                .font(Theme.body.weight(.medium))
                                .foregroundStyle(Theme.textPrimary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(Theme.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Theme.accentB.opacity(0.1))
                        )
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $showingMonthlyPicker) {
            MonthlyGoalPickerView(
                selectedGoal: $selectedMonthlyGoal,
                currentGoal: goalManager.monthlyGoal,
                suggestion: goalManager.getAdaptiveGoalSuggestion(for: .monthly)
            ) { newGoal in
                goalManager.setMonthlyGoal(newGoal)
                showingMonthlyPicker = false
            }
        }
    }
    
    // MARK: - Goal Predictions Section
    
    private var goalPredictionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Goal Predictions")
                .font(Theme.headline)
                .foregroundStyle(Theme.textPrimary)
            
            GlassCard(material: .ultraThinMaterial) {
                VStack(spacing: 16) {
                    if goalManager.weeklyGoal > 0 {
                        let prediction = goalManager.predictWeeklyGoalAchievement()
                        GoalPredictionCard(
                            title: "Weekly Goal",
                            goal: goalManager.weeklyGoal,
                            current: goalManager.weeklyProgress,
                            prediction: prediction
                        )
                    }
                    
                    if goalManager.monthlyGoal > 0 {
                        let prediction = goalManager.predictMonthlyGoalAchievement()
                        GoalPredictionCard(
                            title: "Monthly Goal",
                            goal: goalManager.monthlyGoal,
                            current: goalManager.monthlyProgress,
                            prediction: prediction
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Adaptive Suggestions Section
    
    private var adaptiveSuggestionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Smart Suggestions")
                .font(Theme.headline)
                .foregroundStyle(Theme.textPrimary)
            
            GlassCard(material: .ultraThinMaterial) {
                VStack(alignment: .leading, spacing: 12) {
                    let weeklySuggestion = goalManager.getAdaptiveGoalSuggestion(for: .weekly)
                    let monthlySuggestion = goalManager.getAdaptiveGoalSuggestion(for: .monthly)
                    
                    SuggestionRow(
                        title: "Weekly Goal",
                        suggestion: weeklySuggestion,
                        current: goalManager.weeklyGoal
                    ) {
                        goalManager.setWeeklyGoal(weeklySuggestion)
                    }
                    
                    Divider()
                    
                    SuggestionRow(
                        title: "Monthly Goal",
                        suggestion: monthlySuggestion,
                        current: goalManager.monthlyGoal
                    ) {
                        goalManager.setMonthlyGoal(monthlySuggestion)
                    }
                }
                .padding()
            }
        }
    }
}

// MARK: - Weekly Goal Picker

private struct WeeklyGoalPickerView: View {
    @Binding var selectedGoal: Int
    let currentGoal: Int
    let suggestion: Int
    let onSave: (Int) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(0...7, id: \.self) { goal in
                        Button {
                            selectedGoal = goal
                            onSave(goal)
                        } label: {
                            HStack {
                                Text(goal == 0 ? "No Goal" : "\(goal) workouts per week")
                                    .foregroundStyle(.primary)
                                Spacer()
                                if goal == currentGoal {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(Theme.accentA)
                                }
                                if goal == suggestion && goal != currentGoal {
                                    Text("Suggested")
                                        .font(Theme.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                } header: {
                    Text("Weekly Goals")
                } footer: {
                    Text("Based on your workout history, we suggest \(suggestion) workouts per week.")
                }
            }
            .navigationTitle("Set Weekly Goal")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Monthly Goal Picker

private struct MonthlyGoalPickerView: View {
    @Binding var selectedGoal: Int
    let currentGoal: Int
    let suggestion: Int
    let onSave: (Int) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(Array(stride(from: 0, through: 30, by: 2)), id: \.self) { goal in
                        Button {
                            selectedGoal = goal
                            onSave(goal)
                        } label: {
                            HStack {
                                Text(goal == 0 ? "No Goal" : "\(goal) workouts per month")
                                    .foregroundStyle(.primary)
                                Spacer()
                                if goal == currentGoal {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(Theme.accentB)
                                }
                                if goal == suggestion && goal != currentGoal && abs(goal - suggestion) <= 2 {
                                    Text("Suggested")
                                        .font(Theme.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                } header: {
                    Text("Monthly Goals")
                } footer: {
                    Text("Based on your workout history, we suggest \(suggestion) workouts per month.")
                }
            }
            .navigationTitle("Set Monthly Goal")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Goal Prediction Card

private struct GoalPredictionCard: View {
    let title: String
    let goal: Int
    let current: Int
    let prediction: GoalPrediction
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(Theme.subheadline.weight(.semibold))
                .foregroundStyle(Theme.textPrimary)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(prediction.percentage)%")
                        .font(Theme.title2)
                        .foregroundStyle(prediction.achievable ? .green : .orange)
                    
                    Text(prediction.achievable ? "On Track" : "Needs Effort")
                        .font(Theme.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(prediction.confidence.description)
                        .font(Theme.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                    
                    Text("Confidence")
                        .font(Theme.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous)
                .fill(prediction.achievable ? Color.green.opacity(DesignSystem.Opacity.subtle) : Color.orange.opacity(DesignSystem.Opacity.subtle))
        )
    }
}

// MARK: - Suggestion Row

private struct SuggestionRow: View {
    let title: String
    let suggestion: Int
    let current: Int
    let action: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Theme.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)
                
                Text("Suggested: \(suggestion) workouts")
                    .font(Theme.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if current != suggestion {
                Button {
                    action()
                } label: {
                    Text("Apply")
                        .font(Theme.caption.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous)
                                .fill(Theme.accentA)
                        )
                }
            } else {
                Text("Current")
                    .font(Theme.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

