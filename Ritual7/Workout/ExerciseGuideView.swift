import SwiftUI

/// Agent 5: Instruction Guide - Exercise instruction views with demonstrations and tips
struct ExerciseGuideView: View {
    let exercise: Exercise
    let exercises: [Exercise]?
    let currentIndex: Int?
    
    @State private var currentExercise: Exercise
    @State private var currentIndexState: Int
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @EnvironmentObject private var theme: ThemeStore
    
    init(exercise: Exercise, exercises: [Exercise]? = nil, currentIndex: Int? = nil) {
        self.exercise = exercise
        self.exercises = exercises
        self.currentIndex = currentIndex
        _currentExercise = State(initialValue: exercise)
        _currentIndexState = State(initialValue: currentIndex ?? 0)
    }
    
    var body: some View {
        ZStack {
            ThemeBackground()
            
            ScrollView {
                if horizontalSizeClass == .regular {
                    // iPad: Two-column layout for better use of space
                    iPadLayout
                } else {
                    // iPhone: Single column layout
                    iPhoneLayout
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                // Previous/Next navigation in toolbar for easier access
                if let exercises = exercises, exercises.count > 1 {
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Button {
                            if currentIndexState > 0 {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentIndexState -= 1
                                    currentExercise = exercises[currentIndexState]
                                }
                                Haptics.tap()
                            }
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: DesignSystem.IconSize.large, weight: .semibold))
                                .foregroundStyle(currentIndexState > 0 ? Theme.accentA : .secondary)
                                .frame(width: DesignSystem.TouchTarget.comfortable, height: DesignSystem.TouchTarget.comfortable)
                                .contentShape(Rectangle())
                        }
                        .disabled(currentIndexState <= 0)
                        .accessibilityLabel("Previous exercise")
                        .accessibilityTouchTarget()
                        
                        // Exercise counter in toolbar (compact)
                        Text("\(currentIndexState + 1)/\(exercises.count)")
                            .font(Theme.caption.weight(.semibold))
                            .foregroundStyle(Theme.textPrimary)
                            .monospacedDigit()
                            .padding(.horizontal, DesignSystem.Spacing.xs)
                        
                        Button {
                            if currentIndexState < exercises.count - 1 {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentIndexState += 1
                                    currentExercise = exercises[currentIndexState]
                                }
                                Haptics.tap()
                            }
                        } label: {
                            Image(systemName: "chevron.right")
                                .font(.system(size: DesignSystem.IconSize.large, weight: .semibold))
                                .foregroundStyle(currentIndexState < exercises.count - 1 ? Theme.accentA : .secondary)
                                .frame(width: DesignSystem.TouchTarget.comfortable, height: DesignSystem.TouchTarget.comfortable)
                                .contentShape(Rectangle())
                        }
                        .disabled(currentIndexState >= exercises.count - 1)
                        .accessibilityLabel("Next exercise")
                        .accessibilityTouchTarget()
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    // Show interstitial ad after viewing exercise guide (natural break point)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        InterstitialAdManager.shared.present(from: nil)
                    }
                    dismiss()
                    Haptics.tap()
                }
                .font(Theme.headline)
                .foregroundStyle(Theme.accentA)
                .accessibilityLabel("Done")
            }
        }
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
        .accessibilityElement(children: .contain)
    }
    
    // MARK: - iPad Layout (Two-Column)
    
    private var iPadLayout: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            // Exercise header (full width)
            exerciseHeader
                .padding(.bottom, DesignSystem.Spacing.lg)
            
            // Two-column content layout
            HStack(alignment: .top, spacing: DesignSystem.Spacing.xl) {
                // Left column
                VStack(spacing: DesignSystem.Spacing.xl) {
                    instructionsCard
                    breathingCard
                    muscleGroupsCard
                    durationCard
                }
                .frame(maxWidth: .infinity)
                
                // Right column
                VStack(spacing: DesignSystem.Spacing.xl) {
                    commonMistakesCard
                    modificationsCard
                    safetyCard
                    tipsCard
                }
                .frame(maxWidth: .infinity)
            }
        }
        .contentPadding()
        .padding(.bottom, DesignSystem.Spacing.xxl)
        .frame(maxWidth: 1200)  // Max width for optimal reading
        .frame(maxWidth: .infinity)  // Center horizontally
    }
    
    // MARK: - iPhone Layout (Single Column)
    
    private var iPhoneLayout: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            // Exercise header
            exerciseHeader
            
            // Instructions card
            instructionsCard
            
            // Breathing cues card
            breathingCard
            
            // Muscle groups card
            muscleGroupsCard
            
            // Common mistakes card
            commonMistakesCard
            
            // Modifications card
            modificationsCard
            
            // Safety warnings card
            safetyCard
            
            // Tips card
            tipsCard
            
            // Duration info
            durationCard
        }
        .contentPadding()
        .padding(.bottom, DesignSystem.Spacing.xxl)
    }
    
    // MARK: - Exercise Header
    
    private var exerciseHeader: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: currentExercise.icon)
                .font(.system(
                    size: horizontalSizeClass == .regular 
                        ? DesignSystem.IconSize.huge * 1.75  // Larger on iPad
                        : DesignSystem.IconSize.huge * 1.25,
                    weight: .bold
                ))
                .foregroundStyle(Theme.accentA)
                .accessibilityLabel("Exercise icon for \(currentExercise.name)")
            
            Text(currentExercise.name)
                .font(horizontalSizeClass == .regular 
                    ? Theme.largeTitle.weight(.bold)  // Bolder on iPad
                    : Theme.largeTitle
                )
                .foregroundStyle(Theme.textPrimary)
                .accessibilityAddTraits(.isHeader)
            
            Text(currentExercise.description)
                .font(horizontalSizeClass == .regular 
                    ? Theme.title2  // Larger on iPad
                    : Theme.title3
                )
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            // Navigation buttons if exercises list is provided
            if let exercises = exercises, exercises.count > 1 {
                VStack(spacing: DesignSystem.Spacing.sm) {
                    // Exercise counter - more prominent and centered
                    Text("\(currentIndexState + 1) of \(exercises.count)")
                        .font(Theme.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.textPrimary)
                        .monospacedDigit()
                        .padding(.horizontal, DesignSystem.Spacing.md)
                        .padding(.vertical, DesignSystem.Spacing.xs)
                        .background(
                            Capsule()
                                .fill(Theme.accentA.opacity(DesignSystem.Opacity.subtle * 0.5))
                        )
                    
                    // Navigation buttons (only show on iPhone, iPad uses toolbar)
                    if horizontalSizeClass != .regular {
                        HStack(spacing: DesignSystem.Spacing.sm) {
                            // Previous button
                            Button {
                                if currentIndexState > 0 {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        currentIndexState -= 1
                                        currentExercise = exercises[currentIndexState]
                                    }
                                    Haptics.tap()
                                }
                            } label: {
                                HStack(spacing: DesignSystem.Spacing.xs) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: DesignSystem.IconSize.medium, weight: .semibold))
                                    Text("Previous")
                                        .font(Theme.subheadline.weight(.semibold))
                                }
                                .foregroundStyle(currentIndexState > 0 ? Theme.accentA : .secondary)
                                .frame(maxWidth: .infinity)
                                .frame(height: DesignSystem.ButtonSize.large.height)
                            }
                            .buttonStyle(SecondaryGlassButtonStyle())
                            .disabled(currentIndexState <= 0)
                            .accessibilityLabel("Previous exercise")
                            .accessibilityTouchTarget()
                            
                            // Next button
                            Button {
                                if currentIndexState < exercises.count - 1 {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        currentIndexState += 1
                                        currentExercise = exercises[currentIndexState]
                                    }
                                    Haptics.tap()
                                }
                            } label: {
                                HStack(spacing: DesignSystem.Spacing.xs) {
                                    Text("Next")
                                        .font(Theme.subheadline.weight(.semibold))
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: DesignSystem.IconSize.medium, weight: .semibold))
                                }
                                .foregroundStyle(currentIndexState < exercises.count - 1 ? Theme.accentA : .secondary)
                                .frame(maxWidth: .infinity)
                                .frame(height: DesignSystem.ButtonSize.large.height)
                            }
                            .buttonStyle(SecondaryGlassButtonStyle())
                            .disabled(currentIndexState >= exercises.count - 1)
                            .accessibilityLabel("Next exercise")
                            .accessibilityTouchTarget()
                        }
                    }
                }
                .padding(.top, DesignSystem.Spacing.lg)
                .padding(.horizontal, DesignSystem.Spacing.md)
            }
        }
        .padding(.top, DesignSystem.Spacing.xxl)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }
    
    // MARK: - Card Views
    
    private var instructionsCard: some View {
        GlassCard(material: .ultraThinMaterial) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                HStack {
                    Image(systemName: "list.bullet.rectangle")
                        .font(Theme.title2)
                        .foregroundStyle(Theme.accentA)
                    
                    Text("How to Perform")
                        .font(Theme.title2)
                        .foregroundStyle(Theme.textPrimary)
                    
                    Spacer()
                    
                    // Difficulty badge
                    Text(currentExercise.intensityLevel.displayName)
                        .font(Theme.caption)
                        .foregroundStyle(.white)
                        .padding(.horizontal, DesignSystem.Spacing.md)
                        .padding(.vertical, DesignSystem.Spacing.xs)
                        .background(
                            Capsule()
                                .fill(Theme.accentB)
                        )
                }
                
                Text(currentExercise.instructions)
                    .font(Theme.body)
                    .foregroundStyle(Theme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityLabel("Instructions: \(currentExercise.instructions)")
            }
            .cardPadding()
        }
    }
    
    private var breathingCard: some View {
        GlassCard(material: .ultraThinMaterial) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                HStack {
                    Image(systemName: "wind")
                        .font(Theme.title2)
                        .foregroundStyle(Theme.accentC)
                    
                    Text("Breathing")
                        .font(Theme.title2)
                        .foregroundStyle(Theme.textPrimary)
                    
                    Spacer()
                }
                
                Text(currentExercise.breathingCues)
                    .font(Theme.body)
                    .foregroundStyle(Theme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityLabel("Breathing cues: \(currentExercise.breathingCues)")
            }
            .cardPadding()
        }
    }
    
    private var muscleGroupsCard: some View {
        GlassCard(material: .ultraThinMaterial) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                HStack {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(Theme.title2)
                        .foregroundStyle(Theme.accentA)
                    
                    Text("Targets")
                        .font(Theme.title2)
                        .foregroundStyle(Theme.textPrimary)
                    
                    Spacer()
                }
                
                // Muscle group tags in a flow layout
                muscleGroupTags
            }
            .cardPadding()
        }
    }
    
    private var commonMistakesCard: some View {
        GlassCard(material: .ultraThinMaterial) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(Theme.title2)
                        .foregroundStyle(.orange)
                    
                    Text("Common Mistakes")
                        .font(Theme.title2)
                        .foregroundStyle(Theme.textPrimary)
                    
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    ForEach(currentExercise.commonMistakes, id: \.self) { mistake in
                        HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: DesignSystem.IconSize.small))
                                .foregroundStyle(.orange)
                                .padding(.top, DesignSystem.Spacing.xs * 0.5)
                            
                            Text(mistake)
                                .font(Theme.body)
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }
                }
            }
            .cardPadding()
        }
    }
    
    private var modificationsCard: some View {
        GlassCard(material: .ultraThinMaterial) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                HStack {
                    Image(systemName: "slider.horizontal.3")
                        .font(Theme.title2)
                        .foregroundStyle(Theme.accentB)
                    
                    Text("Modifications")
                        .font(Theme.title2)
                        .foregroundStyle(Theme.textPrimary)
                    
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                    ForEach(currentExercise.modifications) { modification in
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                            Text(modification.difficulty.displayName)
                                .font(Theme.headline)
                                .foregroundStyle(Theme.accentB)
                            
                            Text(modification.description)
                                .font(Theme.body)
                                .foregroundStyle(Theme.textSecondary)
                        }
                            .padding(.vertical, DesignSystem.Spacing.sm)
                            .padding(.horizontal, DesignSystem.Spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                                    .fill(Theme.accentB.opacity(DesignSystem.Opacity.subtle * 0.67))
                            )
                    }
                }
            }
            .cardPadding()
        }
    }
    
    private var safetyCard: some View {
        GlassCard(material: .ultraThinMaterial) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                HStack {
                    Image(systemName: "shield.fill")
                        .font(Theme.title2)
                        .foregroundStyle(.red)
                    
                    Text("Safety")
                        .font(Theme.title2)
                        .foregroundStyle(Theme.textPrimary)
                    
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    ForEach(currentExercise.safetyWarnings, id: \.self) { warning in
                        HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
                            Image(systemName: "exclamationmark.shield.fill")
                                .font(.system(size: DesignSystem.IconSize.small))
                                .foregroundStyle(.red)
                                .padding(.top, DesignSystem.Spacing.xs * 0.5)
                            
                            Text(warning)
                                .font(Theme.body)
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }
                }
            }
            .cardPadding()
        }
    }
    
    private var tipsCard: some View {
        GlassCard(material: .ultraThinMaterial) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .font(Theme.title2)
                        .foregroundStyle(.yellow)
                    
                    Text("Tips")
                        .font(Theme.title2)
                        .foregroundStyle(Theme.textPrimary)
                    
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    ForEach(tipsForExercise(currentExercise.name), id: \.self) { tip in
                        HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
                            Image(systemName: "circle.fill")
                                .font(.system(size: DesignSystem.Spacing.xs * 0.75))
                                .foregroundStyle(Theme.accentA)
                                .padding(.top, DesignSystem.Spacing.xs * 0.75)
                            
                            Text(tip)
                                .font(Theme.body)
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }
                }
            }
            .cardPadding()
        }
    }
    
    private var muscleGroupTags: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            ForEach(currentExercise.muscleGroups, id: \.self) { muscle in
                Text(muscle.displayName)
                    .font(Theme.caption)
                    .foregroundStyle(Theme.accentA)
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.vertical, DesignSystem.Spacing.xs * 0.75)
                    .background(
                        Capsule()
                            .fill(Theme.accentA.opacity(DesignSystem.Opacity.subtle * 0.75))
                    )
            }
        }
    }
    
    private var durationCard: some View {
        GlassCard(material: .ultraThinMaterial) {
            HStack(spacing: DesignSystem.Spacing.md) {
                Image(systemName: "clock.fill")
                    .font(Theme.title2)
                    .foregroundStyle(Theme.accentB)
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text("Duration")
                        .font(Theme.headline)
                        .foregroundStyle(Theme.textPrimary)
                    
                    Text("30 seconds")
                        .font(Theme.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            .cardPadding()
        }
    }
    
    private func tipsForExercise(_ exerciseName: String) -> [String] {
        switch exerciseName {
        case "Jumping Jacks":
            return [
                "Keep your core engaged throughout",
                "Land softly to protect your joints",
                "Maintain a steady rhythm"
            ]
        case "Wall Sit":
            return [
                "Keep your back flat against the wall",
                "Ensure your knees don't go past your toes",
                "Breathe steadily and hold the position"
            ]
        case "Push-up":
            return [
                "Keep your body in a straight line",
                "Lower slowly and push up with control",
                "Modify on knees if needed"
            ]
        case "Abdominal Crunch":
            return [
                "Don't pull on your neck",
                "Focus on lifting with your abs",
                "Keep your lower back on the ground"
            ]
        case "Step-up onto Chair":
            return [
                "Use a sturdy, stable chair",
                "Step up with your entire foot",
                "Keep your core engaged for balance"
            ]
        case "Squat":
            return [
                "Keep your weight in your heels",
                "Chest up, shoulders back",
                "Go as low as comfortable"
            ]
        case "Triceps Dip on Chair":
            return [
                "Keep your shoulders away from your ears",
                "Lower slowly with control",
                "Use your legs for assistance if needed"
            ]
        case "Plank":
            return [
                "Keep your body in a straight line",
                "Don't let your hips sag or rise",
                "Breathe normally"
            ]
        case "High Knees / Running in Place":
            return [
                "Pump your arms as you run",
                "Bring knees up high",
                "Maintain a brisk pace"
            ]
        case "Lunge":
            return [
                "Keep your front knee over your ankle",
                "Lower back knee toward the ground",
                "Push through your front heel to return"
            ]
        case "Push-up and Rotation":
            return [
                "Complete the push-up first",
                "Rotate your whole body, not just your arms",
                "Keep your core tight during rotation"
            ]
        case "Side Plank":
            return [
                "Stack your feet or stagger for stability",
                "Keep your body in a straight line",
                "Don't let your hips sag"
            ]
        default:
            return [
                "Focus on proper form over speed",
                "Listen to your body and rest if needed",
                "Breathe steadily throughout"
            ]
        }
    }
}
