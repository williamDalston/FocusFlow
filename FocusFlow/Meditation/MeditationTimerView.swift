import SwiftUI
import AVFoundation

/// Meditation timer view with duration options and background sounds
struct MeditationTimerView: View {
    @StateObject private var engine = MeditationEngine()
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var theme: ThemeStore
    @State private var showCompletionCelebration = false
    @State private var showConfetti = false
    @State private var motivationalMessage: String = ""
    @State private var isBreathingIn = true
    @State private var breathingScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            ThemeBackground()
            
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.xxl) {
                    // Timer display
                    timerSection
                    
                    // Breathing guide during meditation
                    if engine.phase == .active {
                        breathingGuideSection
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                    
                    // Motivational message
                    if engine.phase == .active && !motivationalMessage.isEmpty {
                        motivationalMessageCard
                            .transition(.opacity.combined(with: .scale))
                    }
                    
                    // Duration selector
                    if engine.phase == .idle || engine.phase == .completed {
                        durationSelector
                            .transition(.opacity.combined(with: .scale))
                    }
                    
                    // Controls
                    controlsSection
                    
                    // Background sound toggle
                    if engine.phase == .active {
                        backgroundSoundToggle
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                .padding(DesignSystem.Spacing.xl)
            }
            .animation(AnimationConstants.smoothEase, value: engine.phase)
            
            // Confetti overlay
            ConfettiView(trigger: $showConfetti)
            
            // Completion celebration overlay
            if showCompletionCelebration {
                completionCelebrationOverlay
                    .transition(.opacity.combined(with: .scale))
                    .zIndex(1000)
            }
        }
        .animation(AnimationConstants.smoothEase, value: engine.phase)
        .navigationTitle("Meditation")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    Haptics.buttonPress()
                    engine.stop()
                    dismiss()
                }
                .foregroundStyle(Theme.accentA)
                .accessibilityLabel("Done")
                .accessibilityHint("Double tap to close the meditation view")
            }
        }
        .onChange(of: engine.phase) { newPhase in
            if newPhase == .active {
                updateMotivationalMessage()
                // Start breathing animation
                withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
                    isBreathingIn.toggle()
                    breathingScale = isBreathingIn ? 1.2 : 1.0
                }
            } else {
                // Stop breathing animation
                isBreathingIn = true
                breathingScale = 1.0
            }
            
            if newPhase == .completed {
                showCompletion()
            }
        }
    }
    
    // MARK: - Timer Section
    
    private var timerSection: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            // Circular progress ring with enhanced styling
            ZStack {
                // Outer glow ring for depth
                Circle()
                    .stroke(
                        Theme.accentA.opacity(DesignSystem.Opacity.glow * 0.3),
                        lineWidth: 14
                    )
                    .frame(width: 230, height: 230)
                    .blur(radius: 4)
                    .accessibilityHidden(true)
                
                // Background circle
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(DesignSystem.Opacity.light),
                                Color.white.opacity(DesignSystem.Opacity.subtle)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 12
                    )
                    .frame(width: 220, height: 220)
                    .accessibilityHidden(true)
                
                // Inner highlight ring
                Circle()
                    .stroke(
                        Color.white.opacity(DesignSystem.Opacity.highlight),
                        lineWidth: 1
                    )
                    .frame(width: 208, height: 208)
                    .accessibilityHidden(true)
                
                // Progress circle with enhanced gradients
                Circle()
                    .trim(from: 0, to: engine.progress)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Theme.accentA,
                                Theme.accentB.opacity(DesignSystem.Opacity.veryStrong * 1.18),
                                Theme.accentC,
                                Theme.accentB.opacity(DesignSystem.Opacity.strong * 1.17)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round, lineJoin: .round)
                    )
                    .frame(width: 220, height: 220)
                    .rotationEffect(.degrees(-90))
                    .animation(AccessibilityHelpers.animation(.linear(duration: 0.1)), value: engine.progress)
                    .shadow(
                        color: Theme.accentA.opacity(DesignSystem.Opacity.medium),
                        radius: 12,
                        x: 0,
                        y: 6
                    )
                    .accessibilityHidden(true)
                
                // Time display with pulsing effect when active
                VStack(spacing: DesignSystem.Spacing.sm) {
                    Text(timeString)
                        .font(.system(size: DesignSystem.IconSize.huge * 1.125, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Theme.accentA,
                                    Theme.accentB.opacity(DesignSystem.Opacity.almostOpaque)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .monospacedDigit()
                        .contentTransition(.numericText())
                        .opacity(engine.phase == .active ? 1.0 : 0.9)
                        .animation(
                            engine.phase == .active 
                                ? .easeInOut(duration: 3.0).repeatForever(autoreverses: true)
                                : .default,
                            value: engine.phase
                        )
                        .accessibilityLabel("\(Int(engine.timeRemaining)) seconds remaining")
                        .accessibilityAddTraits(.updatesFrequently)
                    
                    if engine.phase == .active {
                        HStack(spacing: DesignSystem.Spacing.xs) {
                            Circle()
                                .fill(Theme.accentA)
                                .frame(width: 8, height: 8)
                                .opacity(isBreathingIn ? 1.0 : 0.3)
                                .scaleEffect(isBreathingIn ? 1.2 : 1.0)
                                .animation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true), value: isBreathingIn)
                            
                            Text("Meditating")
                                .font(Theme.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    } else if engine.phase == .completed {
                        Text("Complete")
                            .font(Theme.subheadline)
                            .foregroundStyle(.green)
                    } else {
                        Text("Ready")
                            .font(Theme.subheadline)
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
            }
        }
        .padding(.vertical, DesignSystem.Spacing.lg)
    }
    
    // MARK: - Breathing Guide Section
    
    private var breathingGuideSection: some View {
        GlassCard(material: .ultraThinMaterial) {
            VStack(spacing: DesignSystem.Spacing.lg) {
                // Breathing circle animation
                ZStack {
                    // Outer circle
                    Circle()
                        .stroke(
                            Theme.accentB.opacity(DesignSystem.Opacity.subtle),
                            lineWidth: 3
                        )
                        .frame(width: 140, height: 140)
                    
                    // Animated breathing circle
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: isBreathingIn
                                    ? [
                                        Theme.accentB.opacity(0.6),
                                        Theme.accentB.opacity(0.3)
                                    ]
                                    : [
                                        Theme.accentB.opacity(0.3),
                                        Theme.accentB.opacity(0.6)
                                    ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .scaleEffect(breathingScale)
                        .animation(.easeInOut(duration: 4.0), value: breathingScale)
                }
                
                // Breathing instruction
                VStack(spacing: DesignSystem.Spacing.xs) {
                    Text(isBreathingIn ? "Breathe In" : "Breathe Out")
                        .font(Theme.title3.weight(.semibold))
                        .foregroundStyle(Theme.textPrimary)
                        .transition(.opacity)
                    
                    Text("Follow the circle's rhythm")
                        .font(Theme.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(DesignSystem.Typography.bodyLineHeight - 1.0)
                }
            }
            .padding(DesignSystem.Spacing.cardPadding)
        }
    }
    
    // MARK: - Motivational Message Card
    
    private var motivationalMessageCard: some View {
        GlassCard(material: .ultraThinMaterial) {
            HStack(spacing: DesignSystem.Spacing.md) {
                Image(systemName: "quote.opening")
                    .font(Theme.title3)
                    .foregroundStyle(Theme.accentA)
                
                Text(motivationalMessage)
                    .font(Theme.subheadline)
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding(DesignSystem.Spacing.cardPadding)
        }
    }
    
    // MARK: - Completion Celebration Overlay
    
    private var completionCelebrationOverlay: some View {
        ZStack {
            // Background with gradient
            LinearGradient(
                colors: [
                    Color.black.opacity(0.9),
                    Color.black.opacity(0.85),
                    Theme.accentA.opacity(0.1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.xxl) {
                    // Success icon
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Theme.accentA.opacity(0.3),
                                        Theme.accentB.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                            .blur(radius: 20)
                        
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 80, weight: .bold))
                            .foregroundStyle(.green)
                    }
                    .padding(.top, DesignSystem.Spacing.xxl)
                    
                    // Completion message
                    VStack(spacing: DesignSystem.Spacing.md) {
                        Text("Meditation Complete")
                            .font(Theme.largeTitle.weight(.bold))
                            .foregroundStyle(.white)
                        
                        Text("You've taken time for yourself")
                            .font(Theme.title3)
                            .foregroundStyle(.white.opacity(DesignSystem.Opacity.veryStrong))
                            .multilineTextAlignment(.center)
                    }
                    
                    // Duration card
                    GlassCard(material: .ultraThinMaterial) {
                        VStack(spacing: DesignSystem.Spacing.md) {
                            Text("Duration")
                                .font(Theme.headline)
                                .foregroundStyle(.white.opacity(DesignSystem.Opacity.veryStrong))
                            
                            Text(formatDuration(engine.selectedDuration))
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Theme.accentA, Theme.accentB],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .monospacedDigit()
                        }
                        .padding(DesignSystem.Spacing.cardPadding)
                    }
                    
                    // Action buttons
                    VStack(spacing: DesignSystem.Spacing.md) {
                        Button {
                            Haptics.buttonPress()
                            showCompletionCelebration = false
                            engine.reset()
                        } label: {
                            Label("Meditate Again", systemImage: "arrow.clockwise")
                                .font(Theme.headline)
                                .frame(maxWidth: .infinity)
                                .frame(height: DesignSystem.ButtonSize.large.height)
                        }
                        .buttonStyle(PrimaryProminentButtonStyle())
                        
                        Button {
                            Haptics.buttonPress()
                            showCompletionCelebration = false
                            engine.stop()
                            dismiss()
                        } label: {
                            Text("Done")
                                .font(Theme.headline)
                                .frame(maxWidth: .infinity)
                                .frame(height: DesignSystem.ButtonSize.standard.height)
                        }
                        .buttonStyle(SecondaryGlassButtonStyle())
                    }
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                }
                .padding(DesignSystem.Spacing.xxl)
            }
        }
    }
    
    // MARK: - Duration Selector
    
    private var durationSelector: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Text("Select Duration")
                .font(Theme.headline)
                .foregroundStyle(Theme.textPrimary)
            
            HStack(spacing: DesignSystem.Spacing.md) {
                DurationButton(
                    duration: 60,
                    label: "1 min",
                    isSelected: engine.selectedDuration == 60,
                    action: { engine.selectedDuration = 60 }
                )
                
                DurationButton(
                    duration: 180,
                    label: "3 min",
                    isSelected: engine.selectedDuration == 180,
                    action: { engine.selectedDuration = 180 }
                )
                
                DurationButton(
                    duration: 300,
                    label: "5 min",
                    isSelected: engine.selectedDuration == 300,
                    action: { engine.selectedDuration = 300 }
                )
                
                DurationButton(
                    duration: 600,
                    label: "10 min",
                    isSelected: engine.selectedDuration == 600,
                    action: { engine.selectedDuration = 600 }
                )
            }
        }
        .padding(DesignSystem.Spacing.cardPadding)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous)
                    .fill(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous)
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
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous)
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
        )
        .softShadow()
    }
    
    // MARK: - Controls Section
    
    private var controlsSection: some View {
            VStack(spacing: DesignSystem.Spacing.md) {
                if engine.phase == .idle || engine.phase == .completed {
                    Button {
                        Haptics.buttonPress()
                        withAnimation(AnimationConstants.smoothSpring) {
                            engine.start(duration: engine.selectedDuration)
                        }
                    } label: {
                        Label("Start Meditation", systemImage: "play.fill")
                            .font(Theme.title3.weight(.bold))
                            .frame(maxWidth: .infinity)
                            .frame(height: DesignSystem.ButtonSize.large.height)
                    }
                    .buttonStyle(PrimaryProminentButtonStyle())
                    .accessibilityLabel("Start Meditation")
                    .accessibilityHint("Double tap to begin your meditation session")
                    .transition(.scale.combined(with: .opacity))
                } else if engine.phase == .active {
                HStack(spacing: DesignSystem.Spacing.md) {
                    Button {
                        Haptics.buttonPress()
                        withAnimation(AnimationConstants.quickSpring) {
                            if engine.isPaused {
                                engine.resume()
                            } else {
                                engine.pause()
                            }
                        }
                    } label: {
                        Label(engine.isPaused ? "Resume" : "Pause", 
                              systemImage: engine.isPaused ? "play.fill" : "pause.fill")
                            .font(Theme.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: DesignSystem.ButtonSize.standard.height)
                    }
                    .buttonStyle(SecondaryGlassButtonStyle())
                    .accessibilityLabel(engine.isPaused ? "Resume meditation" : "Pause meditation")
                    .accessibilityHint("Double tap to \(engine.isPaused ? "resume" : "pause") the meditation")
                    
                    Button(role: .destructive) {
                        Haptics.buttonPress()
                        engine.stop()
                    } label: {
                        Text("Stop")
                            .font(Theme.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: DesignSystem.ButtonSize.standard.height)
                    }
                    .buttonStyle(.bordered)
                    .accessibilityLabel("Stop Meditation")
                    .accessibilityHint("Double tap to stop the meditation and return to the main screen")
                }
            }
        }
    }
    
    // MARK: - Background Sound Toggle
    
    private var backgroundSoundToggle: some View {
        Button {
            Haptics.tap()
            engine.toggleBackgroundSound()
        } label: {
            HStack {
                Image(systemName: engine.backgroundSoundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                    .foregroundStyle(engine.backgroundSoundEnabled ? Theme.accentA : .secondary)
                
                Text(engine.backgroundSoundEnabled ? "Background Sound On" : "Background Sound Off")
                    .font(Theme.subheadline)
                    .foregroundStyle(Theme.textPrimary)
                
                Spacer()
            }
            .padding(DesignSystem.Spacing.md)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                        .fill(.ultraThinMaterial)
                    
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Theme.accentA.opacity(DesignSystem.Opacity.highlight * 0.2),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .blendMode(.overlay)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle * 1.5),
                                    Theme.accentA.opacity(DesignSystem.Opacity.light * 0.4),
                                    Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle * 1.5)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: DesignSystem.Border.subtle
                        )
                )
            )
            .softShadow()
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Helpers
    
    private var timeString: String {
        let minutes = Int(engine.timeRemaining) / 60
        let seconds = Int(engine.timeRemaining) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        if minutes > 0 {
            return String(format: "%d min %02d sec", minutes, seconds)
        } else {
            return String(format: "%d sec", seconds)
        }
    }
    
    private func updateMotivationalMessage() {
        let messages = [
            "Find peace in this moment",
            "You are exactly where you need to be",
            "Let go of all expectations",
            "Breathe in calm, breathe out tension",
            "This is your time to recharge",
            "Every breath brings you closer to peace",
            "You are doing great",
            "Trust the process"
        ]
        motivationalMessage = messages.randomElement() ?? messages[0]
    }
    
    private func showCompletion() {
        showConfetti = true
        Haptics.success()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(AnimationConstants.elegantSpring) {
                showCompletionCelebration = true
            }
        }
    }
}

// MARK: - Duration Button

private struct DurationButton: View {
    let duration: TimeInterval
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(Theme.subheadline.weight(.semibold))
                .foregroundStyle(isSelected ? .white : Theme.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    ZStack {
                        if isSelected {
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                                .fill(Theme.accentA.gradient)
                        } else {
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                                .fill(.ultraThinMaterial)
                        }
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                            .stroke(
                                isSelected ? Color.clear : Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle * 1.5),
                                lineWidth: DesignSystem.Border.subtle
                            )
                    )
                )
                .softShadow()
        }
        .buttonStyle(.plain)
    }
}

