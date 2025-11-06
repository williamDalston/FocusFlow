import SwiftUI

/// Agent 3: Exercise Selector View - Select exercises for custom workout
struct ExerciseSelectorView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedExerciseIds: Set<UUID>
    
    private let allExercises = Exercise.sevenMinuteWorkout
    
    var body: some View {
        NavigationStack {
            ZStack {
                ThemeBackground()
                
                List {
                    ForEach(allExercises) { exercise in
                        ExerciseSelectionRow(
                            exercise: exercise,
                            isSelected: selectedExerciseIds.contains(exercise.id)
                        ) {
                            if selectedExerciseIds.contains(exercise.id) {
                                selectedExerciseIds.remove(exercise.id)
                            } else {
                                selectedExerciseIds.insert(exercise.id)
                            }
                            Haptics.tap()
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Select Exercises")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Clear All") {
                        selectedExerciseIds.removeAll()
                        Haptics.tap()
                    }
                    .foregroundStyle(.secondary)
                    .disabled(selectedExerciseIds.isEmpty)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(Theme.accentA)
                    .fontWeight(.semibold)
                }
            }
            .safeAreaInset(edge: .bottom) {
                if !selectedExerciseIds.isEmpty {
                    VStack(spacing: 8) {
                        Text("\(selectedExerciseIds.count) exercise\(selectedExerciseIds.count == 1 ? "" : "s") selected")
                            .font(Theme.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.textPrimary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignSystem.Spacing.md)
                    .background(.ultraThinMaterial)
                    .overlay(
                        Rectangle()
                            .fill(Theme.strokeOuter)
                            .frame(height: 0.5)
                            .opacity(0.5),
                        alignment: .top
                    )
                }
            }
        }
    }
}

// MARK: - Exercise Selection Row

private struct ExerciseSelectionRow: View {
    let exercise: Exercise
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: exercise.icon)
                    .font(Theme.title2)
                    .foregroundStyle(isSelected ? Theme.accentA : Theme.textSecondary)
                    .frame(width: DesignSystem.IconSize.xlarge)
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name)
                        .font(Theme.headline)
                        .foregroundStyle(Theme.textPrimary)
                    
                    Text(exercise.description)
                        .font(Theme.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Theme.accentA)
                        .font(Theme.title3)
                } else {
                    Image(systemName: "circle")
                        .foregroundStyle(.secondary)
                        .font(Theme.title3)
                }
            }
            .padding(.vertical, DesignSystem.Spacing.xs)
        }
        .buttonStyle(.plain)
    }
}


