import SwiftUI

/// Agent 16: Hero Focus Card - Exceptional hero card with exceptional design, animations, and intelligent features
/// 
/// This component displays the main Pomodoro timer card on the home screen with:
/// - Current Pomodoro preset information
/// - Estimated focus time based on preset
/// - Cycle progress indicator (1/4, 2/4, 3/4, 4/4)
/// - Today's focus streak
/// - Smart preset suggestions
/// - Beautiful glassmorphism design
/// - Smooth animations and micro-interactions
/// - Full accessibility support
///
/// Usage:
/// ```swift
/// HeroFocusCard(
///     focusStore: focusStore,
///     preferencesStore: preferencesStore,
///     onStartFocus: { /* start focus */ },
///     onCustomize: { /* customize preset */ },
///     onViewHistory: { /* view history */ }
/// )
/// ```
struct HeroFocusCard: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    @ObservedObject var focusStore: FocusStore
    @ObservedObject var preferencesStore: FocusPreferencesStore
    
    let onStartFocus: () -> Void
    let onCustomize: () -> Void
    let onViewHistory: () -> Void
    
    // Agent 16: First-time user tracking
    @AppStorage("hasSeenQuickStartButton") private var hasSeenQuickStartButton = false
    @AppStorage("hasCompletedFirstFocus") private var hasCompletedFirstFocus = false
    
    // Agent 16: State for animations
    @State private var showReadyToStartAnimation = false
    @State private var pulseAnimation = false
    @State private var hasAppeared = false
    
    // Agent 16: Track if this is first focus session (passed from parent)
    let isFirstFocus: Bool
    
    init(
        focusStore: FocusStore,
        preferencesStore: FocusPreferencesStore,
        onStartFocus: @escaping () -> Void,
        onCustomize: @escaping () -> Void,
        onViewHistory: @escaping () -> Void,
        isFirstFocus: Bool = false
    ) {
        self.focusStore = focusStore
        self.preferencesStore = preferencesStore
        self.onStartFocus = onStartFocus
        self.onCustomize = onCustomize
        self.onViewHistory = onViewHistory
        self.isFirstFocus = isFirstFocus
    }
    
    // Agent 16: Computed properties for intelligent features
    private var currentPreset: PomodoroPreset {
        preferencesStore.preferences.selectedPreset
    }
    
    private var estimatedFocusTime: Int {
        let duration = preferencesStore.preferences.useCustomIntervals
            ? preferencesStore.preferences.customFocusDuration
            : currentPreset.focusDuration
        return Int(duration / 60)
    }
    
    private var cycleProgress: (completed: Int, total: Int) {
        focusStore.getCurrentCycleProgress()
    }
    
    private var todayStreak: Int {
        focusStore.streak
    }
    
    private var presetDescription: String {
        currentPreset.description
    }
    
    // Agent 16: Smart suggestion based on time of day
    private var suggestedPreset: PomodoroPreset? {
        let hour = Calendar.current.component(.hour, from: Date())
        // Morning: Classic, Afternoon: Deep Work, Evening: Short Sprints
        if hour < 12 {
            return .classic
        } else if hour < 17 {
            return .deepWork
        } else {
            return .shortSprints
        }
    }
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Agent 16: Title with dark scrim behind text
            ZStack {
                // Dark scrim (10-12% black)
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                    .fill(Color.black.opacity(DesignSystem.Opacity.scrim))
                    .blur(radius: DesignSystem.BlurRadius.medium)
                    .padding(.horizontal, -DesignSystem.Spacing.md)
                    .padding(.vertical, -DesignSystem.Spacing.sm)
                
                VStack(spacing: DesignSystem.Spacing.xs) {
                    // Agent 16: Preset name with icon
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        Image(systemName: currentPreset.icon)
                            .font(.system(size: DesignSystem.IconSize.medium, weight: DesignSystem.IconWeight.strong))
                            .foregroundStyle(Theme.accent)
                        
                        Text(currentPreset.displayName)
                            .font(.system(size: DesignSystem.Hierarchy.primaryTitle, weight: DesignSystem.Hierarchy.primaryWeight, design: .rounded))
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Agent 16: Preset description
                    Text(presetDescription)
                        .font(Theme.subheadline)
                        .foregroundStyle(.secondary.opacity(DesignSystem.Hierarchy.secondaryOpacity))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
            .fadeSlideIn(delay: 0.1, direction: .up)
            
            // Agent 16: Cycle progress indicator
            if cycleProgress.completed > 0 {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Text("Cycle Progress")
                        .font(Theme.caption)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text("\(cycleProgress.completed)/\(cycleProgress.total)")
                        .font(Theme.caption.weight(.semibold))
                        .foregroundStyle(Theme.accent)
                    
                    // Agent 16: Progress dots
                    HStack(spacing: DesignSystem.Spacing.xs / 2) {
                        ForEach(1...cycleProgress.total, id: \.self) { index in
                            Circle()
                                .fill(index <= cycleProgress.completed ? Theme.accent : Color.secondary.opacity(0.3))
                                .frame(width: 6, height: 6)
                        }
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.sm)
                .padding(.vertical, DesignSystem.Spacing.xs)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous)
                        .fill(Color.secondary.opacity(0.1))
                )
                .fadeSlideIn(delay: 0.15, direction: .up)
            }
            
            // Agent 16: Metrics row (estimated time / streak)
            HStack(spacing: DesignSystem.Spacing.md) {
                // Estimated focus time
                Label("~\(estimatedFocusTime) min", systemImage: "clock.fill")
                    .font(Theme.caption)
                    .foregroundStyle(Theme.ringFocus)
                
                // Today's streak
                if todayStreak > 0 {
                    Label("\(todayStreak) day streak", systemImage: "flame.fill")
                        .font(Theme.caption)
                        .foregroundStyle(Theme.ringBreakShort)
                }
            }
            .fadeSlideIn(delay: 0.2, direction: .up)
            
            // Agent 16: Primary CTA - Start Focus Session
            VStack(spacing: DesignSystem.Spacing.xs) {
                // Agent 16: "Ready to start?" confirmation text for first focus
                if isFirstFocus && !hasCompletedFirstFocus && showReadyToStartAnimation {
                    Text("Ready to start?")
                        .font(Theme.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.accent)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                        .fadeSlideIn(delay: 0.25, direction: .down)
                }
                
                Button(action: {
                    // Agent 16: Haptic feedback before starting
                    Haptics.buttonPress()
                    
                    // Agent 16: Mark button as seen when tapped
                    if !hasSeenQuickStartButton {
                        hasSeenQuickStartButton = true
                    }
                    
                    onStartFocus()
                }) {
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        Image(systemName: "play.fill")
                            .font(.system(size: DesignSystem.IconSize.medium, weight: DesignSystem.IconWeight.strong))
                        Text("Start Focus")
                            .font(Theme.headline)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 60) // Agent 16: 60pt for maximum prominence
                }
                .buttonStyle(PrimaryProminentButtonStyle())
                .accessibilityLabel("Start Focus Session")
                .accessibilityHint("Double tap to begin your \(estimatedFocusTime)-minute focus session")
                .accessibilityAddTraits(.isButton)
                // Agent 16: Enhanced visual prominence - stronger glow and shadow
                .shadow(color: Theme.enhancedShadow.opacity(DesignSystem.Opacity.medium * 1.3), 
                       radius: DesignSystem.Shadow.button.radius * 1.2, 
                       y: DesignSystem.Shadow.button.y * 1.1)
                .shadow(color: Theme.accent.opacity(DesignSystem.Opacity.glow * 1.5), 
                       radius: DesignSystem.Shadow.soft.radius * 1.5, 
                       y: DesignSystem.Shadow.soft.y)
                .glowModifier(color: Theme.accent, radius: 20) // Agent 16: Increased glow radius
                // Agent 16: Subtle pulse animation on first visit only (respects Reduce Motion)
                .scaleEffect(reduceMotion ? 1.0 : (pulseAnimation ? 1.02 : 1.0))
                .animation(reduceMotion ? nil : AnimationConstants.smoothSpring, value: pulseAnimation)
                .fadeSlideIn(delay: 0.3, direction: .up)
            }
            
            // Agent 16: Quick action buttons
            HStack(spacing: DesignSystem.Spacing.sm) {
                // Customize preset button
                Button(action: {
                    Haptics.tap()
                    onCustomize()
                }) {
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: DesignSystem.IconSize.small))
                        Text("Customize")
                            .font(Theme.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, DesignSystem.Spacing.sm)
                    .padding(.vertical, DesignSystem.Spacing.xs)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.button, style: .continuous)
                            .fill(Color.secondary.opacity(0.1))
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .accessibilityLabel("Customize Preset")
                .accessibilityHint("Double tap to customize your Pomodoro timer settings")
                
                // View history button
                Button(action: {
                    Haptics.tap()
                    onViewHistory()
                }) {
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: DesignSystem.IconSize.small))
                        Text("History")
                            .font(Theme.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, DesignSystem.Spacing.sm)
                    .padding(.vertical, DesignSystem.Spacing.xs)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.button, style: .continuous)
                            .fill(Color.secondary.opacity(0.1))
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .accessibilityLabel("View History")
                .accessibilityHint("Double tap to view your focus session history")
                
                Spacer()
            }
            .fadeSlideIn(delay: 0.35, direction: .up)
        }
        .padding(DesignSystem.Spacing.cardPadding)
        .background(
            ZStack {
                // Agent 16: Animated gradient background using theme colors
                AnimatedGradientBackground(
                    colors: [
                        Theme.accent.opacity(DesignSystem.Opacity.subtle * 1.0),
                        Theme.ringFocus.opacity(DesignSystem.Opacity.subtle * 0.67),
                        Theme.ringBreakShort.opacity(DesignSystem.Opacity.subtle * 0.83),
                        Theme.accent.opacity(DesignSystem.Opacity.subtle * 1.0)
                    ],
                    duration: 10.0
                )
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous))
                
                // Base material for glassmorphism
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
        // Agent 16: Card shadow using DesignSystem tokens
        .shadow(
            color: Color.black.opacity(DesignSystem.Shadow.card.opacity),
            radius: DesignSystem.Shadow.card.radius,
            x: 0,
            y: DesignSystem.Shadow.card.y
        )
        .scaleEntrance(delay: 0, springResponse: 0.6)
        .shimmer() // Using shimmer from AnimationModifiers
        .onAppear {
            hasAppeared = true
            
            // Agent 16: Show "Ready to start?" animation for first focus
            if isFirstFocus && !hasCompletedFirstFocus {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(AnimationConstants.smoothSpring) {
                        showReadyToStartAnimation = true
                    }
                }
            }
            
            // Agent 16: Start pulse animation on first visit only (respects Reduce Motion)
            if !hasSeenQuickStartButton && !reduceMotion {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation(
                        Animation.easeInOut(duration: 2.0)
                            .repeatForever(autoreverses: true)
                    ) {
                        pulseAnimation = true
                    }
                }
                
                // Agent 16: Stop pulse after 10 seconds or when user interacts
                DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                    withAnimation(AnimationConstants.smoothEase) {
                        pulseAnimation = false
                    }
                    hasSeenQuickStartButton = true
                }
            } else if !hasSeenQuickStartButton {
                // Agent 16: Mark as seen even if Reduce Motion is enabled (no animation)
                hasSeenQuickStartButton = true
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        ThemeBackground()
        
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.lg) {
                HeroFocusCard(
                    focusStore: FocusStore(),
                    preferencesStore: FocusPreferencesStore(),
                    onStartFocus: { print("Start focus") },
                    onCustomize: { print("Customize") },
                    onViewHistory: { print("View history") },
                    isFirstFocus: false
                )
                .padding(.horizontal, DesignSystem.Spacing.md)
            }
            .padding(.vertical, DesignSystem.Spacing.lg)
        }
    }
}
