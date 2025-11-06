import SwiftUI

/// Agent 1: Pomodoro Timer UI - Beautiful, distraction-free focus timer interface
/// Refactored from WorkoutTimerView for Pomodoro timer functionality
struct FocusTimerView: View {
    @ObservedObject var engine: PomodoroEngine
    @EnvironmentObject private var theme: ThemeStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    @State private var showCompletionConfetti = false
    @State private var showCompletionCelebration = false
    @State private var previousPhase: PomodoroPhase = .idle
    @State private var hasAutoStarted = false
    
    // Confirmation dialog for session stop
    @State private var showingStopConfirmation = false
    
    // Landscape detection
    private var isLandscape: Bool {
        horizontalSizeClass == .compact && verticalSizeClass == .compact
    }
    
    var body: some View {
        ZStack {
            ThemeBackground()
            VStack(spacing: 0) {
                progressBar
                scrollContent
                
                // Sticky control bar at bottom
                if engine.phase != .idle && engine.phase != .completed {
                    stickyControlBar
                        .padding(.horizontal, DesignSystem.Spacing.md)
                        .padding(.top, DesignSystem.Spacing.sm)
                        .padding(.bottom, DesignSystem.Spacing.md)
                        .background(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.1), radius: 8, y: -2)
                        .safeAreaPaddingCompat(.bottom, DesignSystem.Spacing.xs)
                }
            }
            completionOverlayIfNeeded
            ConfettiView(trigger: $showCompletionConfetti)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                EmptyView()
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    Haptics.buttonPress()
                    if engine.phase != .idle && engine.phase != .completed {
                        showingStopConfirmation = true
                    } else {
                        if showCompletionCelebration {
                            showCompletionCelebration = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                dismiss()
                            }
                        } else {
                            dismiss()
                        }
                    }
                }
                .foregroundStyle(Theme.accent)
                .accessibilityLabel("Done")
                .accessibilityHint("Double tap to close the focus timer")
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(focusVoiceOverLabel)
        .dynamicTypeSize(...DynamicTypeSize.accessibility5)
        .confirmationDialog("Stop Focus Session", isPresented: $showingStopConfirmation, titleVisibility: .visible) {
            Button("Stop", role: .destructive) {
                engine.stop()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to stop this focus session?")
        }
        .onChange(of: engine.phase) { newPhase in
            // Phase transition animations
            withAnimation(.easeInOut(duration: 0.2)) {
                // Phase color transitions handled by progress ring
            }
            
            // Enhanced haptic feedback for phase transitions
            if previousPhase != newPhase {
                let phaseString: String
                switch newPhase {
                case .idle:
                    phaseString = "idle"
                case .focus:
                    phaseString = "focus"
                    Haptics.phaseTransitionToExercise()
                    
                    // Show interstitial ad after break completion (natural break point)
                    // Transition from break to focus is a good time to show an ad
                    if previousPhase == .shortBreak || previousPhase == .longBreak {
                        Task { @MainActor in
                            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 second delay
                            InterstitialAdManager.shared.present(from: nil)
                        }
                    }
                case .shortBreak:
                    phaseString = "short break"
                    Haptics.phaseTransitionToRest()
                case .longBreak:
                    phaseString = "long break"
                    Haptics.phaseTransitionToRest()
                case .completed:
                    phaseString = "completed"
                }
                
                AccessibilityAnnouncer.announcePhaseChange(
                    phase: phaseString,
                    exercise: nil,
                    timeRemaining: Int(engine.timeRemaining)
                )
            }
            
            if newPhase == .completed {
                showCompletionConfetti = true
                showCompletionCelebration = true
                
                AccessibilityAnnouncer.announceWorkoutCompletion(
                    duration: engine.currentSessionDuration ?? 0,
                    exercisesCompleted: 0 // Not applicable for Pomodoro
                )
                
                Haptics.workoutComplete()
            }
            
            // Update previous phase for next comparison
            previousPhase = newPhase
        }
        .onAppear {
            // Initialize previous phase
            previousPhase = engine.phase
            
            // Auto-start focus session if idle and not already started
            if engine.phase == .idle && !hasAutoStarted {
                hasAutoStarted = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    engine.start()
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name(AppConstants.NotificationNames.appDidEnterBackground))) { _ in
            engine.handleBackgroundTransition()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name(AppConstants.NotificationNames.appDidBecomeActive))) { _ in
            engine.handleForegroundTransition()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            engine.handleInterruption()
        }
        .sheet(isPresented: $showCompletionCelebration) {
            completionCelebrationSheet
                .iPadOptimizedSheetPresentation()
        }
        .onDisappear {
            // Reset engine when view disappears if not completed
            if engine.phase != .completed {
                engine.stop()
            }
        }
    }
    
    // MARK: - Body Components
    
    @ViewBuilder
    private var progressBar: some View {
        if engine.phase != .idle && engine.phase != .completed {
            ProgressView(value: engine.progress)
                .tint(timerColor)
                .frame(height: 4)
                .animation(AnimationConstants.progressLinear, value: engine.progress)
        }
    }
    
    private var scrollContent: some View {
        ScrollView {
            if isLandscape {
                landscapeLayout
            } else {
                portraitLayout
            }
        }
        .gesture(
            DragGesture(minimumDistance: 50)
                .onEnded { value in
                    let horizontalAmount = value.translation.width
                    
                    // Horizontal swipe (left or right)
                    if abs(horizontalAmount) > 50 {
                        if horizontalAmount > 50 {
                            // Swipe right: Pause/Resume
                            if engine.phase != .idle && engine.phase != .completed {
                                if engine.isPaused {
                                    engine.resume()
                                } else {
                                    engine.pause()
                                }
                                Haptics.buttonPress()
                            }
                        } else if horizontalAmount < -50 {
                            // Swipe left: Skip break (only during break)
                            if engine.phase == .shortBreak || engine.phase == .longBreak {
                                engine.skipBreak()
                                Haptics.buttonPress()
                            }
                        }
                    }
                }
        )
    }
    
    // Portrait layout
    private var portraitLayout: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Timer section with circular progress
            if engine.phase == .idle {
                timerSectionWithCircularProgress
                    .padding(.top, DesignSystem.Spacing.xl)
            } else {
                pomodoroProgressRing
                    .padding(.top, DesignSystem.Spacing.xl)
            }
            
            // Phase indicator
            phaseIndicator
                .padding(.top, DesignSystem.Spacing.lg)
            
            // Cycle progress
            if engine.phase != .idle && engine.phase != .completed {
                cycleProgressView
                    .padding(.top, DesignSystem.Spacing.md)
            }
            
            // Controls section - always show when idle or completed
            if engine.phase == .idle || engine.phase == .completed {
                controlsSection
                    .padding(.top, DesignSystem.Spacing.lg)
            }
            
            // Stats section
            statsSectionIfNeeded
                .padding(.top, DesignSystem.Spacing.lg)
        }
        .padding(.horizontal, DesignSystem.Spacing.xl)
        .padding(.vertical, DesignSystem.Spacing.xl)
        .padding(.bottom, DesignSystem.Spacing.xxxl + DesignSystem.Spacing.md)
    }
    
    // Landscape layout
    private var landscapeLayout: some View {
        HStack(alignment: .top, spacing: LandscapeOptimizer.landscapeSpacing) {
            // Left side: Timer and progress
            VStack(spacing: DesignSystem.Spacing.md) {
                if engine.phase == .idle {
                    timerSectionWithCircularProgress
                        .frame(width: LandscapeOptimizer.landscapeTimerSize, height: LandscapeOptimizer.landscapeTimerSize)
                } else {
                    pomodoroProgressRing
                        .frame(width: LandscapeOptimizer.landscapeTimerSize, height: LandscapeOptimizer.landscapeTimerSize)
                }
                
                statsSectionIfNeeded
            }
            .frame(width: LandscapeOptimizer.landscapeTimerSize + 40)
            
            // Right side: Phase info and controls
            VStack(spacing: DesignSystem.Spacing.md) {
                phaseIndicator
                
                if engine.phase != .idle && engine.phase != .completed {
                    cycleProgressView
                }
                
                if engine.phase == .idle || engine.phase == .completed {
                    controlsSection
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, LandscapeOptimizer.landscapePadding)
        .padding(.vertical, DesignSystem.Spacing.landscapeSpacing)
        .padding(.bottom, DesignSystem.Spacing.xxxl + DesignSystem.Spacing.md)
    }
    
    // MARK: - Timer Section with Circular Progress
    
    private var timerSectionWithCircularProgress: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            // Phase indicator
            Text(phaseTitle)
                .font(Theme.title3.weight(.semibold))
                .foregroundStyle(Theme.textSecondary)
                .textCase(.uppercase)
                .tracking(DesignSystem.Typography.uppercaseTracking)
                .multilineTextAlignment(.center)
            
            // Circular progress ring with timer
            ZStack {
                // Outer glow ring
                Circle()
                    .stroke(
                        timerColor.opacity(DesignSystem.Opacity.glow * 0.3),
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
                
                // Progress ring
                Circle()
                    .trim(from: 0, to: engine.progress)
                    .stroke(
                        LinearGradient(
                            colors: [
                                timerColor,
                                timerColor.opacity(DesignSystem.Opacity.veryStrong * 1.18)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round, lineJoin: .round)
                    )
                    .frame(width: 220, height: 220)
                    .rotationEffect(.degrees(-90))
                    .animation(AccessibilityHelpers.animation(.linear(duration: 0.1)), value: engine.progress)
                    .animation(AccessibilityHelpers.animation(AnimationConstants.smoothEase) ?? .none, value: timerColor)
                    .shadow(
                        color: timerColor.opacity(DesignSystem.Opacity.medium + (timerGlowIntensity * 0.3)),
                        radius: 12 + (timerGlowIntensity * 6),
                        x: 0,
                        y: 6
                    )
                
                // Timer text
                VStack(spacing: DesignSystem.Spacing.sm) {
                    Text(timeString)
                        .font(.system(size: DesignSystem.IconSize.huge * 1.125, weight: .bold, design: .rounded))
                        .dynamicTypeSize(...DynamicTypeSize.accessibility5)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    timerColor,
                                    timerColor.opacity(DesignSystem.Opacity.almostOpaque)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .monospacedDigit()
                        .contentTransition(.numericText())
                        .animation(AccessibilityHelpers.animation(AnimationConstants.smoothEase) ?? .none, value: timerColor)
                        .animation(AccessibilityHelpers.animation(AnimationConstants.quickSpring) ?? .none, value: engine.timeRemaining)
                        .timerTickPulse(trigger: Int(engine.timeRemaining))
                        .shadow(
                            color: timerColor.opacity(DesignSystem.Opacity.glow * timerGlowIntensity * 0.8),
                            radius: 12 + (timerGlowIntensity * 8),
                            x: 0,
                            y: 2
                        )
                        .accessibilityLabel("\(Int(engine.timeRemaining)) seconds remaining")
                        .accessibilityValue(phaseTitle)
                        .accessibilityAddTraits(.updatesFrequently)
                }
            }
            .padding(.vertical, DesignSystem.Spacing.lg)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.xl)
    }
    
    // MARK: - Pomodoro Progress Ring
    
    private var pomodoroProgressRing: some View {
        ZStack {
            // Outer glow ring
            Circle()
                .stroke(
                    timerColor.opacity(DesignSystem.Opacity.glow * 0.3),
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
            
            // Progress ring
            Circle()
                .trim(from: 0, to: engine.progress)
                .stroke(
                    LinearGradient(
                        colors: [
                            timerColor,
                            timerColor.opacity(DesignSystem.Opacity.veryStrong * 1.18)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round, lineJoin: .round)
                )
                .frame(width: 220, height: 220)
                .rotationEffect(.degrees(-90))
                .animation(AccessibilityHelpers.animation(.linear(duration: 0.1)), value: engine.progress)
                .animation(AccessibilityHelpers.animation(AnimationConstants.smoothEase) ?? .none, value: timerColor)
                .shadow(
                    color: timerColor.opacity(DesignSystem.Opacity.medium + (timerGlowIntensity * 0.3)),
                    radius: 12 + (timerGlowIntensity * 6),
                    x: 0,
                    y: 6
                )
            
            // Timer text
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text(timeString)
                    .font(.system(size: DesignSystem.IconSize.huge * 1.125, weight: .bold, design: .rounded))
                    .dynamicTypeSize(...DynamicTypeSize.accessibility5)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                timerColor,
                                timerColor.opacity(DesignSystem.Opacity.almostOpaque)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .animation(AccessibilityHelpers.animation(AnimationConstants.smoothEase) ?? .none, value: timerColor)
                    .animation(AccessibilityHelpers.animation(AnimationConstants.quickSpring) ?? .none, value: engine.timeRemaining)
                    .timerTickPulse(trigger: Int(engine.timeRemaining))
                    .shadow(
                        color: timerColor.opacity(DesignSystem.Opacity.glow * timerGlowIntensity * 0.8),
                        radius: 12 + (timerGlowIntensity * 8),
                        x: 0,
                        y: 2
                    )
                    .accessibilityLabel("\(Int(engine.timeRemaining)) seconds remaining")
                    .accessibilityValue(phaseTitle)
                    .accessibilityAddTraits(.updatesFrequently)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.xl)
    }
    
    // MARK: - Phase Indicator
    
    private var phaseIndicator: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Text(phaseTitle)
                .font(Theme.title2.weight(.bold))
                .foregroundStyle(Theme.textPrimary)
                .multilineTextAlignment(.center)
            
            if engine.phase == .focus {
                Text("Stay focused")
                    .font(Theme.subheadline)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            } else if engine.phase == .shortBreak || engine.phase == .longBreak {
                Text("Take a break")
                    .font(Theme.subheadline)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.lg)
    }
    
    // MARK: - Cycle Progress View
    
    private var cycleProgressView: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Text("Session \(engine.currentSessionNumber) of \(AppConstants.TimingConstants.defaultPomodoroCycleLength)")
                .font(Theme.headline)
                .foregroundStyle(.secondary)
            
            // Cycle progress indicator (dots or progress bar)
            HStack(spacing: DesignSystem.Spacing.xs) {
                ForEach(1...AppConstants.TimingConstants.defaultPomodoroCycleLength, id: \.self) { sessionNumber in
                    Circle()
                        .fill(sessionNumber <= engine.sessionsCompletedInCycle ? Theme.ringFocus : Theme.textSecondary.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.md)
    }
    
    // MARK: - Sticky Control Bar
    
    private var stickyControlBar: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            // Pause/Resume button (primary)
            Button {
                Haptics.buttonPress()
                if engine.isPaused {
                    engine.resume()
                } else {
                    engine.pause()
                }
            } label: {
                Label(engine.isPaused ? "Resume" : "Pause",
                      systemImage: engine.isPaused ? "play.fill" : "pause.fill")
                    .font(Theme.headline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .frame(height: DesignSystem.TouchTarget.comfortable)
            }
            .buttonStyle(PrimaryProminentButtonStyle())
            .accessibilityLabel(engine.isPaused ? "Resume focus session" : "Pause focus session")
            
            // Skip break button (only during breaks)
            if engine.phase == .shortBreak || engine.phase == .longBreak {
                Button {
                    Haptics.buttonPress()
                    engine.skipBreak()
                } label: {
                    Image(systemName: "forward.fill")
                        .font(.system(size: DesignSystem.IconSize.medium, weight: .semibold))
                        .frame(width: DesignSystem.TouchTarget.comfortable)
                        .frame(height: DesignSystem.TouchTarget.comfortable)
                }
                .buttonStyle(SecondaryGlassButtonStyle())
                .accessibilityLabel("Skip break")
                .accessibilityHint("Double tap to skip the break and move to next session")
            }
        }
    }
    
    // MARK: - Controls Section
    
    private var controlsSection: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            if engine.phase == .idle {
                // Start button
                Button {
                    Haptics.buttonPress()
                    engine.start()
                } label: {
                    Label("Start Focus", systemImage: "play.fill")
                        .font(Theme.title3)
                        .fontWeight(DesignSystem.Typography.headlineWeight)
                        .frame(maxWidth: .infinity)
                        .frame(height: DesignSystem.ButtonSize.large.height)
                }
                .buttonStyle(PrimaryProminentButtonStyle())
                .accessibilityHint("Double tap to start a focus session")
            } else if engine.phase == .completed {
                // Session completed
                VStack(spacing: DesignSystem.Spacing.md) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: DesignSystem.IconSize.huge))
                        .foregroundStyle(.green)
                    
                    Text("Focus Session Complete!")
                        .font(Theme.title2)
                        .foregroundStyle(Theme.textPrimary)
                }
                .padding(.vertical, DesignSystem.Spacing.xl)
            }
        }
    }
    
    // MARK: - Stats Section
    
    @ViewBuilder
    private var statsSectionIfNeeded: some View {
        if engine.phase != .idle {
            statsSection
        }
    }
    
    private var statsSection: some View {
        HStack(spacing: DesignSystem.Spacing.xl) {
            StatCard(
                title: "Session",
                value: "\(engine.currentSessionNumber)",
                icon: "clock.fill",
                color: Theme.ringBreakShort
            )
            
            StatCard(
                title: "Progress",
                value: "\(Int(engine.progress * 100))%",
                icon: "chart.bar.fill",
                color: Theme.ringBreakLong
            )
        }
    }
    
    // MARK: - Completion Overlay
    
    @ViewBuilder
    private var completionOverlayIfNeeded: some View {
        if engine.phase == .completed {
            completionOverlay
        }
    }
    
    @ViewBuilder
    private var completionCelebrationSheet: some View {
        let duration = engine.currentSessionDuration ?? 0
        
        VStack(spacing: DesignSystem.Spacing.xl) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: DesignSystem.IconSize.huge * 1.25))
                .foregroundStyle(.green)
            
            Text("Focus Session Complete!")
                .font(Theme.largeTitle)
                .foregroundStyle(Theme.textPrimary)
            
            Text("Great work staying focused!")
                .font(Theme.title3)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
            
            // Stats
            let minutes = Int(duration) / 60
            let seconds = Int(duration) % 60
            
            HStack(spacing: DesignSystem.Spacing.xl) {
                CompletionStatCard(
                    value: String(format: "%d:%02d", minutes, seconds),
                    label: "Time",
                    icon: "clock.fill"
                )
            }
            .padding(.top, DesignSystem.Spacing.lg)
            
            // Action buttons
            Button {
                Haptics.buttonPress()
                showCompletionCelebration = false
                // Show interstitial ad after focus session completion (natural break point)
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
                    InterstitialAdManager.shared.present(from: nil)
                }
                engine.reset()
                engine.start()
            } label: {
                Text("Start Next Session")
                    .font(Theme.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, DesignSystem.Spacing.sm)
            
            Button {
                Haptics.buttonPress()
                showCompletionCelebration = false
                // Show interstitial ad after focus session completion (natural break point)
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
                    InterstitialAdManager.shared.present(from: nil)
                }
                dismiss()
            } label: {
                Text("Done")
                    .font(Theme.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
            }
            .buttonStyle(.bordered)
            .padding(.top, DesignSystem.Spacing.sm)
        }
        .padding(DesignSystem.Spacing.xxl)
        .interactiveDismissDisabled()
    }
    
    private var completionOverlay: some View {
        ZStack {
            Color.black.opacity(DesignSystem.Opacity.strong * 1.17)
                .ignoresSafeArea()
            
            VStack(spacing: DesignSystem.Spacing.xl) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: DesignSystem.IconSize.huge * 1.25))
                    .foregroundStyle(.green)
                
                Text("Focus Session Complete!")
                    .font(Theme.largeTitle)
                    .foregroundStyle(.white)
                
                Text("Great work staying focused!")
                    .font(Theme.title3)
                    .foregroundStyle(.white.opacity(DesignSystem.Opacity.veryStrong))
                    .multilineTextAlignment(.center)
                
                // Stats
                let duration = engine.currentSessionDuration ?? 0
                let minutes = Int(duration) / 60
                let seconds = Int(duration) % 60
                
                HStack(spacing: DesignSystem.Spacing.xl) {
                    CompletionStatCard(
                        value: String(format: "%d:%02d", minutes, seconds),
                        label: "Time",
                        icon: "clock.fill"
                    )
                }
                .padding(.top, DesignSystem.Spacing.lg)
                
                // Action buttons
                Button {
                    Haptics.buttonPress()
                    // Show interstitial ad after focus session completion (natural break point)
                    Task { @MainActor in
                        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
                        InterstitialAdManager.shared.present(from: nil)
                    }
                    engine.reset()
                    engine.start()
                } label: {
                    Text("Start Next Session")
                        .font(Theme.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                }
                .buttonStyle(.borderedProminent)
                .tint(.white)
                .foregroundStyle(.black)
                .padding(.top, DesignSystem.Spacing.sm)
                
                Button {
                    Haptics.buttonPress()
                    // Show interstitial ad after focus session completion (natural break point)
                    Task { @MainActor in
                        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
                        InterstitialAdManager.shared.present(from: nil)
                    }
                    dismiss()
                } label: {
                    Text("Done")
                        .font(Theme.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                }
                .buttonStyle(.bordered)
                .tint(.white)
                .foregroundStyle(.white)
                .padding(.top, DesignSystem.Spacing.sm)
            }
            .padding(DesignSystem.Spacing.xxl)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .padding(.horizontal, DesignSystem.Spacing.xxl)
            .padding(.vertical, DesignSystem.Spacing.xxl)
        }
        .gesture(
            DragGesture(minimumDistance: 50)
                .onEnded { value in
                    // Swipe down to dismiss
                    if value.translation.height > 100 {
                        Haptics.buttonPress()
                        dismiss()
                    }
                }
        )
    }
    
    // MARK: - Helpers
    
    private var phaseTitle: String {
        switch engine.phase {
        case .idle:
            return "Ready to Focus"
        case .focus:
            return "Focus"
        case .shortBreak:
            return "Short Break"
        case .longBreak:
            return "Long Break"
        case .completed:
            return "Session Complete"
        }
    }
    
    private var timeString: String {
        let totalSeconds = Int(engine.timeRemaining.rounded(.up))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    /// Timer color based on time remaining and phase
    private var timerColor: Color {
        // Base color depends on phase - use semantic ring colors
        let baseColor: Color
        switch engine.phase {
        case .focus:
            baseColor = Theme.ringFocus
        case .shortBreak:
            baseColor = Theme.ringBreakShort
        case .longBreak:
            baseColor = Theme.ringBreakLong
        case .idle, .completed:
            return Theme.ringFocus
        }
        
        guard engine.phase != .idle && engine.phase != .completed && !engine.isPaused else {
            return baseColor
        }
        
        let phaseDuration: TimeInterval
        switch engine.phase {
        case .focus:
            phaseDuration = engine.focusDuration
        case .shortBreak:
            phaseDuration = engine.shortBreakDuration
        case .longBreak:
            phaseDuration = engine.longBreakDuration
        default:
            return baseColor
        }
        
        guard phaseDuration > 0 else { return baseColor }
        
        let timeRatio = engine.timeRemaining / phaseDuration
        
        // Use base color with dynamic intensity based on time remaining
        // For more time remaining, use full color; as time decreases, add warning hue
        if timeRatio > 0.5 {
            return baseColor
        } else if timeRatio > 0.25 {
            let yellowProgress = (0.5 - timeRatio) / 0.25
            let hue = 0.33 - (0.33 - 0.17) * yellowProgress
            return Color(hue: hue, saturation: 0.75, brightness: 0.85)
        } else {
            let redProgress = (0.25 - timeRatio) / 0.25
            let hue = 0.17 - (0.17 - 0.0) * redProgress
            let saturation = 0.75 + 0.20 * redProgress
            let brightness = 0.85 - 0.15 * redProgress
            return Color(hue: hue, saturation: saturation, brightness: brightness)
        }
    }
    
    /// Timer glow intensity based on time remaining
    private var timerGlowIntensity: Double {
        guard engine.phase != .idle && engine.phase != .completed && !engine.isPaused else {
            return 0.0
        }
        
        let phaseDuration: TimeInterval
        switch engine.phase {
        case .focus:
            phaseDuration = engine.focusDuration
        case .shortBreak:
            phaseDuration = engine.shortBreakDuration
        case .longBreak:
            phaseDuration = engine.longBreakDuration
        default:
            return 0.0
        }
        
        guard phaseDuration > 0 else { return 0.0 }
        
        let timeRatio = engine.timeRemaining / phaseDuration
        
        if timeRatio <= 0.25 {
            return 1.0 - (timeRatio / 0.25)
        } else if timeRatio <= 0.5 {
            return (0.5 - timeRatio) / 0.25 * 0.3
        } else {
            return 0.0
        }
    }
    
    // MARK: - Accessibility
    
    private var focusVoiceOverLabel: String {
        let timeRemaining = Int(engine.timeRemaining)
        
        switch engine.phase {
        case .idle:
            return "Focus timer ready to start"
        case .focus:
            return "Focus session. \(timeRemaining) seconds remaining."
        case .shortBreak:
            return "Short break. \(timeRemaining) seconds remaining."
        case .longBreak:
            return "Long break. \(timeRemaining) seconds remaining."
        case .completed:
            return "Focus session completed successfully!"
        }
    }
}

// MARK: - Completion Stat Card

private struct CompletionStatCard: View {
    let value: String
    let label: String
    let icon: String
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(DesignSystem.Opacity.highlight * 1.5))
                    .frame(width: DesignSystem.IconSize.statBox + 8, height: DesignSystem.IconSize.statBox + 8)
                
                Image(systemName: icon)
                    .font(Theme.title2)
                    .foregroundStyle(.white.opacity(DesignSystem.Opacity.veryStrong))
                    .frame(width: DesignSystem.IconSize.statBox, height: DesignSystem.IconSize.statBox)
            }
            
            Text(value)
                .font(Theme.title2)
                .foregroundStyle(.white)
                .monospacedDigit()
            
            Text(label)
                .font(Theme.caption)
                .foregroundStyle(.white.opacity(DesignSystem.Opacity.veryStrong))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.lg)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                    .fill(.white.opacity(DesignSystem.Opacity.subtle * 0.6))
                
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(DesignSystem.Opacity.highlight * 0.8),
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
                    .stroke(Color.white.opacity(DesignSystem.Opacity.borderSubtle), lineWidth: DesignSystem.Border.hairline)
            )
        )
    }
}

// MARK: - Stat Card

private struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            ZStack {
                Circle()
                    .fill(color.opacity(DesignSystem.Opacity.highlight))
                    .frame(width: DesignSystem.IconSize.statBox + 8, height: DesignSystem.IconSize.statBox + 8)
                
                Image(systemName: icon)
                    .font(Theme.title2)
                    .foregroundStyle(color)
                    .frame(width: DesignSystem.IconSize.statBox, height: DesignSystem.IconSize.statBox)
            }
            
            Text(value)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
                .monospacedDigit()
                .contentTransition(.numericText())
            
            Text(title)
                .font(Theme.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.lg)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                    .fill(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                color.opacity(DesignSystem.Opacity.highlight * 0.5),
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
                                color.opacity(DesignSystem.Opacity.light * 1.2),
                                color.opacity(DesignSystem.Opacity.subtle),
                                color.opacity(DesignSystem.Opacity.light * 1.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: DesignSystem.Border.standard
                    )
            )
        )
        .softShadow()
    }
}

// MARK: - Compatibility Extension

extension View {
    @ViewBuilder
    func safeAreaPaddingCompat(_ edge: Edge.Set = .all, _ length: CGFloat? = nil) -> some View {
        if #available(iOS 17.0, *) {
            self.safeAreaPadding(edge, length)
        } else {
            self.padding(edge, length ?? 0)
        }
    }
}

