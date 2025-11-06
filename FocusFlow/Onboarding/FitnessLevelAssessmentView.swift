import SwiftUI

/// Agent 6: Fitness Level Assessment View - Helps users assess their fitness level during onboarding
struct FitnessLevelAssessmentView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Binding var selectedLevel: FitnessLevel?
    @State private var selectedIndex: Int? = nil
    
    enum FitnessLevel: String, CaseIterable {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"
        
        var description: String {
            switch self {
            case .beginner:
                return "New to exercise or returning after a break"
            case .intermediate:
                return "Regular exercise routine, comfortable with basic movements"
            case .advanced:
                return "Very active, comfortable with challenging exercises"
            }
        }
        
        var icon: String {
            switch self {
            case .beginner:
                return "figure.walk"
            case .intermediate:
                return "figure.run"
            case .advanced:
                return "flame.fill"
            }
        }
    }
    
    var body: some View {
        ZStack {
            ThemeBackground()
            
            ScrollView {
                VStack(spacing: horizontalSizeClass == .regular ? 32 : 24) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "figure.strengthtraining.traditional")
                            .font(.system(size: horizontalSizeClass == .regular ? 80 : 64, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(horizontalSizeClass == .regular ? 24 : 20)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large).stroke(.white.opacity(0.18), lineWidth: DesignSystem.Border.standard))
                        
                        Text("Assess Your Fitness Level")
                            .font(horizontalSizeClass == .regular ? .largeTitle.weight(.bold) : .title.weight(.bold))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                        
                        Text("This helps us personalize your workout experience")
                            .font(horizontalSizeClass == .regular ? .title3 : .body)
                            .foregroundStyle(.white.opacity(0.85))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, DesignSystem.Spacing.xl)
                    }
                    .padding(.top, DesignSystem.Spacing.xxl)
                    
                    // Fitness level options
                    VStack(spacing: 16) {
                        ForEach(Array(FitnessLevel.allCases.enumerated()), id: \.element) { index, level in
                            fitnessLevelCard(level: level, index: index)
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                    
                    // Skip option
                    Button {
                        selectedLevel = nil
                        dismiss()
                    } label: {
                        Text("Skip for now")
                            .font(Theme.body.weight(.medium))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    .padding(.top, DesignSystem.Spacing.lg)
                    .padding(.bottom, DesignSystem.Spacing.xxl)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    if let index = selectedIndex {
                        selectedLevel = FitnessLevel.allCases[index]
                    }
                    dismiss()
                }
                .foregroundStyle(.white)
                .disabled(selectedIndex == nil)
            }
        }
    }
    
    private func fitnessLevelCard(level: FitnessLevel, index: Int) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedIndex = index
            }
            Haptics.tap()
        } label: {
            HStack(spacing: 20) {
                Image(systemName: level.icon)
                    .font(Theme.title)
                    .foregroundStyle(selectedIndex == index ? Theme.accentA : .white.opacity(0.7))
                    .frame(width: 50)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(level.rawValue)
                        .font(Theme.title2)
                        .foregroundStyle(.white)
                    
                    Text(level.description)
                        .font(Theme.body)
                        .foregroundStyle(.white.opacity(0.85))
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                if selectedIndex == index {
                    Image(systemName: "checkmark.circle.fill")
                        .font(Theme.title2)
                        .foregroundStyle(Theme.accentA)
                }
            }
            .padding(DesignSystem.Spacing.cardPadding)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                    .fill(selectedIndex == index ? AnyShapeStyle(Theme.accentA.opacity(DesignSystem.Opacity.light)) : AnyShapeStyle(Material.ultraThinMaterial))
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                            .stroke(selectedIndex == index ? Theme.accentA : .white.opacity(DesignSystem.Opacity.borderSubtle), lineWidth: selectedIndex == index ? DesignSystem.Border.emphasis : DesignSystem.Border.standard)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}


