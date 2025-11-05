import SwiftUI

/// Agent 5: Instruction Guide - Exercise instruction views with demonstrations and tips
struct ExerciseGuideView: View {
    let exercise: Exercise
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var theme: ThemeStore
    
    var body: some View {
        ZStack {
            ThemeBackground()
            
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.xl) {
                    // Exercise header
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        Image(systemName: exercise.icon)
                            .font(.system(size: DesignSystem.IconSize.huge * 1.25, weight: .bold))
                            .foregroundStyle(Theme.accentA)
                            .accessibilityLabel("Exercise icon for \(exercise.name)")
                        
                        Text(exercise.name)
                            .font(Theme.largeTitle)
                            .foregroundStyle(Theme.textPrimary)
                            .accessibilityAddTraits(.isHeader)
                        
                        Text(exercise.description)
                            .font(Theme.title3)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, DesignSystem.Spacing.xxl)
                    .frame(maxWidth: .infinity)
                    .accessibilityElement(children: .combine)
                    
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
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
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
    
    private var instructionsCard: some View {
        GlassCard(material: .ultraThinMaterial) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                HStack {
                    Image(systemName: "list.bullet.rectangle")
                        .font(.title2)
                        .foregroundStyle(Theme.accentA)
                    
                    Text("How to Perform")
                        .font(Theme.title2)
                        .foregroundStyle(Theme.textPrimary)
                    
                    Spacer()
                    
                    // Difficulty badge
                    Text(exercise.intensityLevel.displayName)
                        .font(Theme.caption)
                        .foregroundStyle(.white)
                        .padding(.horizontal, DesignSystem.Spacing.md)
                        .padding(.vertical, DesignSystem.Spacing.xs)
                        .background(
                            Capsule()
                                .fill(Theme.accentB)
                        )
                }
                
                Text(exercise.instructions)
                    .font(Theme.body)
                    .foregroundStyle(Theme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityLabel("Instructions: \(exercise.instructions)")
            }
            .cardPadding()
        }
    }
    
    private var breathingCard: some View {
        GlassCard(material: .ultraThinMaterial) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                HStack {
                    Image(systemName: "wind")
                        .font(.title2)
                        .foregroundStyle(Theme.accentC)
                    
                    Text("Breathing")
                        .font(Theme.title2)
                        .foregroundStyle(Theme.textPrimary)
                    
                    Spacer()
                }
                
                Text(exercise.breathingCues)
                    .font(Theme.body)
                    .foregroundStyle(Theme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityLabel("Breathing cues: \(exercise.breathingCues)")
            }
            .cardPadding()
        }
    }
    
    private var muscleGroupsCard: some View {
        GlassCard(material: .ultraThinMaterial) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                HStack {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.title2)
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
                        .font(.title2)
                        .foregroundStyle(.orange)
                    
                    Text("Common Mistakes")
                        .font(Theme.title2)
                        .foregroundStyle(Theme.textPrimary)
                    
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    ForEach(exercise.commonMistakes, id: \.self) { mistake in
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
                        .font(.title2)
                        .foregroundStyle(Theme.accentB)
                    
                    Text("Modifications")
                        .font(Theme.title2)
                        .foregroundStyle(Theme.textPrimary)
                    
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                    ForEach(exercise.modifications) { modification in
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
                        .font(.title2)
                        .foregroundStyle(.red)
                    
                    Text("Safety")
                        .font(Theme.title2)
                        .foregroundStyle(Theme.textPrimary)
                    
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    ForEach(exercise.safetyWarnings, id: \.self) { warning in
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
                        .font(.title2)
                        .foregroundStyle(.yellow)
                    
                    Text("Tips")
                        .font(Theme.title2)
                        .foregroundStyle(Theme.textPrimary)
                    
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    ForEach(tipsForExercise(exercise.name), id: \.self) { tip in
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
            ForEach(exercise.muscleGroups, id: \.self) { muscle in
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
                    .font(.title2)
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
