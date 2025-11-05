import SwiftUI

/// Agent 24: Reusable Onboarding Step View Component
/// Provides consistent styling and layout for onboarding steps
struct OnboardingStepView: View {
    let step: OnboardingStep
    let isLastStep: Bool
    let onNext: () -> Void
    let onSkip: (() -> Void)?
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    var body: some View {
        let isIPad = horizontalSizeClass == .regular
        
        VStack(spacing: isIPad ? DesignSystem.Spacing.xxl : DesignSystem.Spacing.xl) {
            Spacer()
            
            // Icon with gradient background
            iconView(isIPad: isIPad)
            
            // Title
            Text(step.title)
                .font(isIPad ? Theme.largeTitle : Theme.title)
                .foregroundStyle(Theme.textOnDark)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.8)
                .lineLimit(2)
                .padding(.horizontal, isIPad ? DesignSystem.Spacing.xxl : DesignSystem.Spacing.xl)
                .padding(.top, DesignSystem.Spacing.lg)
            
            // Description
            Text(step.description)
                .font(isIPad ? Theme.title2 : Theme.title3)
                .foregroundStyle(Theme.textSecondaryOnDark)
                .multilineTextAlignment(.center)
                .lineSpacing(DesignSystem.Typography.bodyLineHeight - 1.0)
                .padding(.horizontal, isIPad ? DesignSystem.Spacing.xxxl : DesignSystem.Spacing.xxl)
                .padding(.top, DesignSystem.Spacing.lg)
                .minimumScaleFactor(0.85)
            
            // Additional content (if any)
            if let additionalContent = step.additionalContent {
                additionalContent
                    .padding(.horizontal, isIPad ? DesignSystem.Screen.sidePaddingIPad : DesignSystem.Screen.sidePadding)
                    .padding(.top, DesignSystem.Spacing.lg)
            }
            
            Spacer()
            
            // Action buttons
            actionButtons(isIPad: isIPad)
        }
    }
    
    // MARK: - Icon View
    
    private func iconView(isIPad: Bool) -> some View {
        Image(systemName: step.icon)
            .font(.system(
                size: isIPad ? DesignSystem.IconSize.huge * 1.25 : DesignSystem.IconSize.huge,
                weight: .bold
            ))
            .foregroundStyle(
                LinearGradient(
                    colors: step.iconColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .padding(isIPad ? DesignSystem.Spacing.xl : DesignSystem.Spacing.lg)
            .background(
                .ultraThinMaterial,
                in: RoundedRectangle(
                    cornerRadius: DesignSystem.CornerRadius.xlarge,
                    style: .continuous
                )
            )
            .overlay(
                RoundedRectangle(
                    cornerRadius: DesignSystem.CornerRadius.xlarge,
                    style: .continuous
                )
                .stroke(
                    LinearGradient(
                        colors: [
                            Theme.strokeOuter,
                            step.iconColors.first?.opacity(DesignSystem.Opacity.light) ?? Theme.accentA.opacity(DesignSystem.Opacity.light),
                            Theme.strokeOuter
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: DesignSystem.Border.standard
                )
            )
            .shadow(
                color: Theme.enhancedShadow.opacity(DesignSystem.Opacity.medium),
                radius: DesignSystem.Shadow.medium.radius,
                y: DesignSystem.Shadow.medium.y
            )
    }
    
    // MARK: - Action Buttons
    
    private func actionButtons(isIPad: Bool) -> some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            // Primary action button
            Button {
                Haptics.tap()
                onNext()
            } label: {
                Text(isLastStep ? step.primaryActionTitle : "Next")
                    .fontWeight(DesignSystem.Typography.headlineWeight)
                    .frame(maxWidth: .infinity)
                    .frame(height: DesignSystem.ButtonSize.large.height)
            }
            .buttonStyle(PrimaryProminentButtonStyle())
            .padding(.horizontal, isIPad ? DesignSystem.Screen.sidePaddingIPad : DesignSystem.Screen.sidePadding)
            
            // Skip button (if not last step and skip handler provided)
            if !isLastStep, let onSkip = onSkip {
                Button {
                    Haptics.tap()
                    onSkip()
                } label: {
                    Text("Skip")
                        .font(Theme.body)
                        .foregroundStyle(Theme.textSecondaryOnDark)
                        .padding(.vertical, DesignSystem.Spacing.sm)
                }
                .padding(.horizontal, isIPad ? DesignSystem.Screen.sidePaddingIPad : DesignSystem.Screen.sidePadding)
            }
        }
        .padding(.bottom, isIPad ? DesignSystem.Spacing.xxxl : DesignSystem.Spacing.xxl)
    }
}

// MARK: - Onboarding Step Model

struct OnboardingStep {
    let title: String
    let description: String
    let icon: String
    let iconColors: [Color]
    let primaryActionTitle: String
    let additionalContent: AnyView?
    
    init(
        title: String,
        description: String,
        icon: String,
        iconColors: [Color] = [Theme.accentA, Theme.accentB, Theme.accentC],
        primaryActionTitle: String = "Get Started",
        additionalContent: AnyView? = nil
    ) {
        self.title = title
        self.description = description
        self.icon = icon
        self.iconColors = iconColors
        self.primaryActionTitle = primaryActionTitle
        self.additionalContent = additionalContent
    }
}

