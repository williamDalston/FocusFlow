import SwiftUI

/// Hero Workout Card - Single hero card with primary CTA per Apple HIG + fitness app patterns
/// North Star: Make "start a 7-minute workout now" instant, obvious, and safe
/// Agent 22: Primary Action Visibility Enhancement
struct HeroWorkoutCard: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @StateObject private var engine = WorkoutEngine()
    
    let onStartWorkout: () -> Void
    let onCustomize: () -> Void
    let onViewExercises: () -> Void
    let onViewHistory: () -> Void
    
    // Optional metrics
    let estimatedCalories: Int?
    let estimatedDuration: TimeInterval?
    
    // Agent 22: First-time user tracking
    @AppStorage("hasSeenQuickStartButton") private var hasSeenQuickStartButton = false
    @AppStorage("hasCompletedFirstWorkout") private var hasCompletedFirstWorkout = false
    
    // Agent 22: State for first-time animations
    @State private var showReadyToStartAnimation = false
    @State private var pulseAnimation = false
    
    // Agent 22: Track if this is first workout (passed from parent)
    let isFirstWorkout: Bool
    
    init(
        onStartWorkout: @escaping () -> Void,
        onCustomize: @escaping () -> Void,
        onViewExercises: @escaping () -> Void,
        onViewHistory: @escaping () -> Void,
        estimatedCalories: Int? = 84,
        estimatedDuration: TimeInterval? = 420, // 7 minutes
        isFirstWorkout: Bool = false
    ) {
        self.onStartWorkout = onStartWorkout
        self.onCustomize = onCustomize
        self.onViewExercises = onViewExercises
        self.onViewHistory = onViewHistory
        self.estimatedCalories = estimatedCalories
        self.estimatedDuration = estimatedDuration
        self.isFirstWorkout = isFirstWorkout
    }
    
    @State private var hasAppeared = false
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Title with 10-12% dark scrim behind text
            ZStack {
                // Dark scrim (10-12% black)
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                    .fill(Color.black.opacity(DesignSystem.Opacity.scrim))
                    .blur(radius: DesignSystem.BlurRadius.medium)
                    .padding(.horizontal, -DesignSystem.Spacing.md)
                    .padding(.vertical, -DesignSystem.Spacing.sm)
                
                VStack(spacing: DesignSystem.Spacing.xs) {
                    // Agent 23: Increased title size for prominence
                    Text("7\u{2011}Minute Workout") // Non-breaking hyphen (U+2011)
                        .font(.system(size: DesignSystem.Hierarchy.primaryTitle, weight: DesignSystem.Hierarchy.primaryWeight, design: .rounded))
                        .foregroundStyle(.primary) // Use .primary per spec
                        .multilineTextAlignment(.center)
                        .allowsTightening(false) // Prevent hyphen splits
                    
                    // Agent 23: Reduced visual weight of subtitle
                    Text("12 moves · 7 min · No equipment")
                        .font(Theme.subheadline)
                        .foregroundStyle(.secondary.opacity(DesignSystem.Hierarchy.secondaryOpacity))
                        .multilineTextAlignment(.center)
                }
            }
            .fadeSlideIn(delay: 0.1, direction: .up)
            
            // Agent 22: Primary CTA: Start Workout (full-width, 60pt tall for maximum prominence)
            VStack(spacing: DesignSystem.Spacing.xs) {
                // Agent 22: "Ready to start?" confirmation text for first workout
                if isFirstWorkout && !hasCompletedFirstWorkout && showReadyToStartAnimation {
                    Text("Ready to start?")
                        .font(Theme.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.accentA)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                        .fadeSlideIn(delay: 0.15, direction: .down)
                }
                
                Button(action: {
                    // Agent 25: Validate exercise selection before starting
                    let exercises = engine.exercises
                    let validation = InputValidator.validateWorkoutStart(exercises: exercises)
                    
                    if !validation.isValid {
                        // Show error message
                        ToastManager.shared.show(
                            message: validation.errorMessage ?? "Cannot start workout"
                        )
                        Haptics.tap()
                        return
                    }
                    
                    // Agent 22: Mark button as seen when tapped
                    if !hasSeenQuickStartButton {
                        hasSeenQuickStartButton = true
                    }
                    onStartWorkout()
                }) {
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        Image(systemName: "play.fill")
                            .font(.system(size: DesignSystem.IconSize.medium, weight: DesignSystem.IconWeight.strong))
                        Text("Start Workout")
                            .font(Theme.headline)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 60) // Agent 22: Increased to 60pt for maximum prominence (56-60pt range)
                }
                .buttonStyle(PrimaryProminentButtonStyle())
                .disabled(engine.phase != .idle && engine.phase != .completed)
                .accessibilityLabel("Start Workout")
                .accessibilityHint("Double tap to begin your 7-minute workout")
                .accessibilityAddTraits(.isButton)
                // Agent 22: Enhanced visual prominence - stronger glow and shadow
                .shadow(color: Theme.enhancedShadow.opacity(DesignSystem.Opacity.medium * 1.3), 
                       radius: DesignSystem.Shadow.button.radius * 1.2, 
                       y: DesignSystem.Shadow.button.y * 1.1)
                .shadow(color: Theme.accentA.opacity(DesignSystem.Opacity.glow * 1.5), 
                       radius: DesignSystem.Shadow.soft.radius * 1.5, 
                       y: DesignSystem.Shadow.soft.y)
                .glowModifier(color: Theme.accentA, radius: 20) // Agent 22: Increased glow radius from 15 to 20
                // Agent 22: Subtle pulse animation on first visit only (respects Reduce Motion)
                .scaleEffect(reduceMotion ? 1.0 : (pulseAnimation ? 1.02 : 1.0))
                .animation(reduceMotion ? nil : AnimationConstants.smoothSpring, value: pulseAnimation)
                .fadeSlideIn(delay: 0.2, direction: FadeSlideIn.SlideDirection.up)
            }
            
            // Tiny metrics row (kcal / time)
            if let calories = estimatedCalories, let duration = estimatedDuration {
                HStack(spacing: DesignSystem.Spacing.md) {
                    Label("~\(calories) kcal", systemImage: "flame.fill")
                        .font(Theme.caption)
                        .foregroundStyle(Theme.accentB)
                    Label("~\(Int(duration / 60)) min", systemImage: "clock.fill")
                        .font(Theme.caption)
                        .foregroundStyle(Theme.accentC)
                }
                .fadeSlideIn(delay: 0.3, direction: .up)
            }
        }
        .padding(DesignSystem.Spacing.cardPadding)
        .background(
            ZStack {
                // Animated gradient background
                AnimatedGradientBackground(
                    colors: [
                        Theme.accentA.opacity(DesignSystem.Opacity.subtle * 1.0),
                        Theme.accentB.opacity(DesignSystem.Opacity.subtle * 0.67),
                        Theme.accentC.opacity(DesignSystem.Opacity.subtle * 0.83),
                        Theme.accentA.opacity(DesignSystem.Opacity.subtle * 1.0)
                    ],
                    duration: 10.0
                )
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous))
                
                // Base material
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous)
                    .fill(.ultraThinMaterial)
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous)
                .stroke(
                    Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle),
                    lineWidth: DesignSystem.Border.subtle
                )
        )
        .cardShadow() // Single shadow token: y:8, blur:24, 18% black
        .scaleEntrance(delay: 0, springResponse: 0.6)
        .shimmer()
        .onAppear {
            hasAppeared = true
            
            // Agent 22: Show "Ready to start?" animation for first workout
            if isFirstWorkout && !hasCompletedFirstWorkout {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(AnimationConstants.smoothSpring) {
                        showReadyToStartAnimation = true
                    }
                }
            }
            
            // Agent 22: Start pulse animation on first visit only (respects Reduce Motion)
            if !hasSeenQuickStartButton && !reduceMotion {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation(
                        Animation.easeInOut(duration: 2.0)
                            .repeatForever(autoreverses: true)
                    ) {
                        pulseAnimation = true
                    }
                }
                
                // Agent 22: Stop pulse after 10 seconds or when user interacts
                DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                    withAnimation(AnimationConstants.smoothEase) {
                        pulseAnimation = false
                    }
                    hasSeenQuickStartButton = true
                }
            } else if !hasSeenQuickStartButton {
                // Agent 22: Mark as seen even if Reduce Motion is enabled (no animation)
                hasSeenQuickStartButton = true
            }
        }
    }
}

