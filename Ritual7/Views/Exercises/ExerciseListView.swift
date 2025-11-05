import SwiftUI

/// Agent 1: Missing Views - Comprehensive exercise list view with filtering by muscle group and search functionality
struct ExerciseListView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var searchText = ""
    @State private var selectedMuscleGroup: Exercise.MuscleGroup?
    @State private var selectedExercise: Exercise?
    @State private var showingFilter = false
    
    private var allExercises = Exercise.sevenMinuteWorkout
    
    private var filteredExercises: [Exercise] {
        var exercises = allExercises
        
        // Filter by muscle group
        if let muscleGroup = selectedMuscleGroup {
            exercises = exercises.filter { exercise in
                exercise.muscleGroups.contains(muscleGroup)
            }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            exercises = exercises.filter { exercise in
                exercise.name.localizedCaseInsensitiveContains(searchText) ||
                exercise.description.localizedCaseInsensitiveContains(searchText) ||
                exercise.instructions.localizedCaseInsensitiveContains(searchText) ||
                exercise.muscleGroups.contains { $0.displayName.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        return exercises
    }
    
    private var muscleGroups: [Exercise.MuscleGroup] {
        Array(Set(allExercises.flatMap { $0.muscleGroups })).sorted { $0.displayName < $1.displayName }
    }
    
    var body: some View {
        ZStack {
            ThemeBackground()
            
            VStack(spacing: 0) {
                // Search and filter bar
                searchAndFilterBar
                
                // Content
                if filteredExercises.isEmpty {
                    emptyStateView
                } else {
                    exerciseList
                }
            }
        }
        .navigationTitle("Exercises")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if horizontalSizeClass == .regular {
                    EmptyView()
                } else {
                    Button("Done") {
                        dismiss()
                        Haptics.tap()
                    }
                    .font(Theme.headline)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        showingFilter = true
                        Haptics.tap()
                    } label: {
                        Label("Filter by Muscle Group", systemImage: "line.3.horizontal.decrease.circle")
                    }
                    
                    if selectedMuscleGroup != nil || !searchText.isEmpty {
                        Divider()
                        
                        Button(role: .destructive) {
                            selectedMuscleGroup = nil
                            searchText = ""
                            Haptics.tap()
                        } label: {
                            Label("Clear Filters", systemImage: "xmark.circle")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(Theme.headline)
                }
            }
        }
        .sheet(isPresented: $showingFilter) {
            MuscleGroupFilterView(
                muscleGroups: muscleGroups,
                selectedMuscleGroup: $selectedMuscleGroup
            )
        }
        .sheet(item: $selectedExercise) { exercise in
            NavigationStack {
                if let index = filteredExercises.firstIndex(where: { $0.id == exercise.id }) {
                    ExerciseGuideView(
                        exercise: exercise,
                        exercises: filteredExercises,
                        currentIndex: index
                    )
                } else {
                    ExerciseGuideView(exercise: exercise)
                }
            }
        }
    }
    
    // MARK: - Search and Filter Bar
    
    private var searchAndFilterBar: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Search bar
            HStack(spacing: DesignSystem.Spacing.md) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                
                TextField("Search exercises...", text: $searchText)
                    .textFieldStyle(.plain)
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                        Haptics.tap()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(DesignSystem.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                            .stroke(Theme.strokeOuter, lineWidth: DesignSystem.Border.subtle)
                    )
            )
            
            // Filter chips
            if selectedMuscleGroup != nil || !searchText.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DesignSystem.Spacing.md) {
                        if let muscleGroup = selectedMuscleGroup {
                            ExerciseFilterChip(
                                title: muscleGroup.displayName,
                                isActive: true,
                                action: {
                                    selectedMuscleGroup = nil
                                    Haptics.tap()
                                }
                            )
                        }
                        
                        if !searchText.isEmpty {
                            ExerciseFilterChip(
                                title: "Search: \"\(searchText)\"",
                                isActive: true,
                                action: {
                                    searchText = ""
                                    Haptics.tap()
                                }
                            )
                        }
                        
                        Button {
                            selectedMuscleGroup = nil
                            searchText = ""
                            Haptics.tap()
                        } label: {
                            HStack(spacing: DesignSystem.Spacing.xs) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(Theme.caption)
                                Text("Clear All")
                                    .font(Theme.caption)
                            }
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, DesignSystem.Spacing.md)
                            .padding(.vertical, DesignSystem.Spacing.sm)
                            .background(
                                Capsule()
                                    .fill(.ultraThinMaterial)
                            )
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                }
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.vertical, DesignSystem.Spacing.md)
        .background(.ultraThinMaterial)
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        EmptyStateView.noExercisesFound {
            selectedMuscleGroup = nil
            searchText = ""
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Exercise List
    
    private var exerciseList: some View {
        List {
            // Summary section
            if !filteredExercises.isEmpty {
                Section {
                    ExerciseSummaryView(exercises: filteredExercises)
                }
            }
            
            // Exercises list
            Section {
                ForEach(Array(filteredExercises.enumerated()), id: \.element.id) { index, exercise in
                    ExerciseCard(exercise: exercise)
                        .contentShape(Rectangle())
                        .staggeredEntrance(index: index, delay: 0.05)
                        .cardLift()
                        .onTapGesture {
                            selectedExercise = exercise
                            Haptics.tap()
                        }
                }
            } header: {
                Text("Exercises (\(filteredExercises.count))")
                    .font(Theme.headline)
                    .foregroundStyle(Theme.textPrimary)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
    }
}

// MARK: - Exercise Card

struct ExerciseCard: View {
    let exercise: Exercise
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Theme.accentA.opacity(DesignSystem.Opacity.subtle),
                                Theme.accentB.opacity(DesignSystem.Opacity.subtle * 0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: DesignSystem.IconSize.xxlarge + 8, height: DesignSystem.IconSize.xxlarge + 8)
                
                Image(systemName: exercise.icon)
                    .font(Theme.title2)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Theme.accentA, Theme.accentB],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            // Content
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                HStack {
                    Text(exercise.name)
                        .font(Theme.headline)
                        .foregroundStyle(Theme.textPrimary)
                    
                    Spacer()
                    
                    // Order badge
                    Text("\(exercise.order)")
                        .font(Theme.caption)
                        .foregroundStyle(Theme.accentA)
                        .monospacedDigit()
                        .frame(width: DesignSystem.Spacing.xxl, height: DesignSystem.Spacing.xxl)
                        .background(
                            Circle()
                                .fill(Theme.accentA.opacity(DesignSystem.Opacity.subtle))
                        )
                }
                
                Text(exercise.description)
                    .font(Theme.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                
                // Muscle groups
                if !exercise.muscleGroups.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: DesignSystem.Spacing.xs) {
                            ForEach(exercise.muscleGroups, id: \.self) { muscleGroup in
                                Text(muscleGroup.displayName)
                                    .font(Theme.caption2)
                                    .foregroundStyle(Theme.accentB)
                                    .padding(.horizontal, DesignSystem.Spacing.sm)
                                    .padding(.vertical, DesignSystem.Spacing.xs * 0.75)
                                    .background(
                                        Capsule()
                                            .fill(Theme.accentB.opacity(DesignSystem.Opacity.subtle * 0.75))
                                    )
                            }
                        }
                    }
                }
            }
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(Theme.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.md)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                    .fill(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Theme.accentA.opacity(DesignSystem.Opacity.highlight * 0.3),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blendMode(.overlay)
            }
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle * 1.5),
                                Theme.accentA.opacity(DesignSystem.Opacity.light * 0.5),
                                Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle * 1.5)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: DesignSystem.Border.subtle
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                    .stroke(Theme.glowColor.opacity(DesignSystem.Opacity.glow * 0.6), lineWidth: DesignSystem.Border.hairline)
                    .blur(radius: 1)
            )
        )
        .softShadow()
    }
}

// MARK: - Exercise Summary View

struct ExerciseSummaryView: View {
    let exercises: [Exercise]
    
    private var totalExercises: Int { exercises.count }
    private var muscleGroups: Set<Exercise.MuscleGroup> {
        Set(exercises.flatMap { $0.muscleGroups })
    }
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: DesignSystem.Spacing.md) {
            SummaryCard(
                title: "Total",
                value: "\(totalExercises)",
                icon: "figure.run",
                color: Theme.accentA
            )
            
            SummaryCard(
                title: "Muscle Groups",
                value: "\(muscleGroups.count)",
                icon: "figure.strengthtraining.traditional",
                color: Theme.accentB
            )
        }
        .padding(.vertical, DesignSystem.Spacing.sm)
    }
}

// MARK: - Exercise Filter Chip

struct ExerciseFilterChip: View {
    let title: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Text(title)
                    .font(Theme.caption)
                if isActive {
                    Image(systemName: "xmark.circle.fill")
                        .font(Theme.caption2)
                }
            }
            .foregroundStyle(isActive ? Theme.textPrimary : .secondary)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(
                Capsule()
                    .fill(isActive ? AnyShapeStyle(Theme.accentA.opacity(DesignSystem.Opacity.subtle)) : AnyShapeStyle(Material.ultraThinMaterial))
                    .overlay(
                        Capsule()
                            .stroke(isActive ? Theme.accentA.opacity(DesignSystem.Opacity.light) : Theme.strokeOuter, lineWidth: DesignSystem.Border.subtle)
                    )
            )
        }
    }
}

// MARK: - Muscle Group Filter View

struct MuscleGroupFilterView: View {
    let muscleGroups: [Exercise.MuscleGroup]
    @Binding var selectedMuscleGroup: Exercise.MuscleGroup?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                ThemeBackground()
                
                Form {
                    Section {
                        Button {
                            selectedMuscleGroup = nil
                            Haptics.tap()
                        } label: {
                            HStack {
                                Image(systemName: "circle")
                                    .foregroundStyle(Theme.accentA)
                                    .frame(width: DesignSystem.IconSize.statBox)
                                
                                Text("All Muscle Groups")
                                    .font(Theme.body)
                                    .foregroundStyle(Theme.textPrimary)
                                
                                Spacer()
                                
                                if selectedMuscleGroup == nil {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(Theme.accentA)
                                        .font(Theme.headline)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        
                        ForEach(muscleGroups, id: \.self) { muscleGroup in
                            Button {
                                selectedMuscleGroup = muscleGroup
                                Haptics.tap()
                            } label: {
                                HStack {
                                    Image(systemName: "figure.strengthtraining.traditional")
                                        .foregroundStyle(Theme.accentA)
                                        .frame(width: DesignSystem.IconSize.statBox)
                                    
                                    Text(muscleGroup.displayName)
                                        .font(Theme.body)
                                        .foregroundStyle(Theme.textPrimary)
                                    
                                    Spacer()
                                    
                                    if selectedMuscleGroup == muscleGroup {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(Theme.accentA)
                                            .font(Theme.headline)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    } header: {
                        Text("Muscle Groups")
                            .font(Theme.headline)
                            .foregroundStyle(Theme.textPrimary)
                    } footer: {
                        Text("Filter exercises by the muscle groups they target")
                            .font(Theme.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Filter Exercises")
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

