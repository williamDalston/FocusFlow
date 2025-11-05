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
                VStack(spacing: 24) {
                    // Exercise header
                    VStack(spacing: 16) {
                        Image(systemName: exercise.icon)
                            .font(.system(size: 80))
                            .foregroundStyle(Theme.accentA)
                            .accessibilityLabel("Exercise icon for \(exercise.name)")
                        
                        Text(exercise.name)
                            .font(.largeTitle.weight(.bold))
                            .foregroundStyle(Theme.textPrimary)
                            .accessibilityAddTraits(.isHeader)
                        
                        Text(exercise.description)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 32)
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
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
                .foregroundStyle(Theme.accentA)
                .accessibilityLabel("Done")
            }
        }
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
        .accessibilityElement(children: .contain)
    }
    
    private var instructionsCard: some View {
        GlassCard(material: .ultraThinMaterial) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "list.bullet.rectangle")
                        .font(.title2)
                        .foregroundStyle(Theme.accentA)
                    
                    Text("How to Perform")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(Theme.textPrimary)
                    
                    Spacer()
                    
                    // Difficulty badge
                    Text(exercise.difficultyLevel)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Theme.accentB)
                        )
                }
                
                Text(exercise.instructions)
                    .font(.body)
                    .foregroundStyle(Theme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityLabel("Instructions: \(exercise.instructions)")
            }
            .padding(24)
        }
    }
    
    private var breathingCard: some View {
        GlassCard(material: .ultraThinMaterial) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "wind")
                        .font(.title2)
                        .foregroundStyle(Theme.accentC)
                    
                    Text("Breathing")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(Theme.textPrimary)
                    
                    Spacer()
                }
                
                Text(exercise.breathingCues)
                    .font(.body)
                    .foregroundStyle(Theme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityLabel("Breathing cues: \(exercise.breathingCues)")
            }
            .padding(24)
        }
    }
    
    private var muscleGroupsCard: some View {
        GlassCard(material: .ultraThinMaterial) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.title2)
                        .foregroundStyle(Theme.accentA)
                    
                    Text("Targets")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(Theme.textPrimary)
                    
                    Spacer()
                }
                
                // Muscle group tags in a flow layout
                muscleGroupTags
            }
            .padding(24)
        }
    }
    
    private var commonMistakesCard: some View {
        GlassCard(material: .ultraThinMaterial) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.title2)
                        .foregroundStyle(.orange)
                    
                    Text("Common Mistakes")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(Theme.textPrimary)
                    
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(exercise.commonMistakes, id: \.self) { mistake in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(.orange)
                                .padding(.top, 2)
                            
                            Text(mistake)
                                .font(.body)
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }
                }
            }
            .padding(24)
        }
    }
    
    private var modificationsCard: some View {
        GlassCard(material: .ultraThinMaterial) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "slider.horizontal.3")
                        .font(.title2)
                        .foregroundStyle(Theme.accentB)
                    
                    Text("Modifications")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(Theme.textPrimary)
                    
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(Array(exercise.modifications.keys.sorted()), id: \.self) { level in
                        if let modification = exercise.modifications[level] {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(level)
                                    .font(.headline)
                                    .foregroundStyle(Theme.accentB)
                                
                                Text(modification)
                                    .font(.body)
                                    .foregroundStyle(Theme.textSecondary)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(Theme.accentB.opacity(0.1))
                            )
                        }
                    }
                }
            }
            .padding(24)
        }
    }
    
    private var safetyCard: some View {
        GlassCard(material: .ultraThinMaterial) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "shield.fill")
                        .font(.title2)
                        .foregroundStyle(.red)
                    
                    Text("Safety")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(Theme.textPrimary)
                    
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(exercise.safetyWarnings, id: \.self) { warning in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "exclamationmark.shield.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(.red)
                                .padding(.top, 2)
                            
                            Text(warning)
                                .font(.body)
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }
                }
            }
            .padding(24)
        }
    }
    
    private var tipsCard: some View {
        GlassCard(material: .ultraThinMaterial) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .font(.title2)
                        .foregroundStyle(.yellow)
                    
                    Text("Tips")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(Theme.textPrimary)
                    
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(tipsForExercise(exercise.name), id: \.self) { tip in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 6))
                                .foregroundStyle(Theme.accentA)
                                .padding(.top, 6)
                            
                            Text(tip)
                                .font(.body)
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }
                }
            }
            .padding(24)
        }
    }
    
    private var muscleGroupTags: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], alignment: .leading, spacing: 8) {
            ForEach(exercise.muscleGroups, id: \.self) { muscle in
                Text(muscle)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Theme.accentA)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Theme.accentA.opacity(0.15))
                    )
            }
        }
    }
    
    private var durationCard: some View {
        GlassCard(material: .ultraThinMaterial) {
            HStack {
                Image(systemName: "clock.fill")
                    .font(.title2)
                    .foregroundStyle(Theme.accentB)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Duration")
                        .font(.headline)
                        .foregroundStyle(Theme.textPrimary)
                    
                    Text("30 seconds")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            .padding(24)
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

