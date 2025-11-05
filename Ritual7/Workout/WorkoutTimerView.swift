import SwiftUI

/// Agent 4 & 8 & 11: Timer UI - Beautiful workout timer interface with exercise name, countdown, and progress
/// Enhanced with smooth animations, micro-interactions, and Agent 11 features
struct WorkoutTimerView: View {
    @ObservedObject var engine: WorkoutEngine
    @ObservedObject var store: WorkoutStore
    @EnvironmentObject private var theme: ThemeStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    @State private var showCompletionConfetti = false
    @StateObject private var repCounter = RepCounter()
    @StateObject private var voiceCues = VoiceCuesManager.shared
    @State private var showCompletionCelebration = false
    @AppStorage("hasSeenGestureHint") private var hasSeenGestureHint = false
    @State private var showGestureHint = false
    @State private var previousPhase: WorkoutPhase = .idle
    @State private var hasAutoStarted = false
    
    // Agent 24: Contextual hints for first-time users
    @ObservedObject private var onboardingManager = OnboardingManager.shared
    @State private var showWorkoutTimerHint = false
    @State private var showPauseHint = false
    @State private var showProgressHint = false
    
    // Agent 25: Confirmation dialog for workout stop
    @State private var showingStopConfirmation = false
    
    // Agent 29: Landscape detection
    private var isLandscape: Bool {
        horizontalSizeClass == .compact && verticalSizeClass == .compact
    }
    
    var body: some View {
        ZStack {
            ThemeBackground()
            VStack(spacing: 0) {
                progressBar
                scrollContent
                
                // Agent 29: Sticky control bar at bottom (thumb zone optimized, ≥48pt hit targets per spec)
                if engine.phase != .idle && engine.phase != .completed {
                    VStack(spacing: DesignSystem.Spacing.sm) {
                        // "Now/Next" line above control bar per spec
                        nowNextLine
                        
                        stickyControlBar
                    }
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.top, DesignSystem.Spacing.sm)
                    .padding(.bottom, DesignSystem.Spacing.md)
                    .background(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 8, y: -2)
                    // Agent 29: Ensure proper safe area padding for modern devices
                    .safeAreaPaddingCompat(.bottom, DesignSystem.Spacing.xs)
                }
            }
            completionOverlayIfNeeded
            ConfettiView(trigger: $showCompletionConfetti)
            
            // Gesture hints overlay
            if showGestureHint {
                gestureHintsOverlay
            }
            
            // Agent 24: Contextual hints for first-time users
            // DISABLED during active workout phases to prevent blocking view
            // Only show hints during idle or completed phases
            if engine.phase == .idle || engine.phase == .completed {
                VStack {
                    if showWorkoutTimerHint {
                        ContextualHintView(
                            feature: .workoutTimer,
                            onDismiss: {
                                showWorkoutTimerHint = false
                                onboardingManager.markHintAsSeen(for: .workoutTimer)
                            }
                        )
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    if showPauseHint {
                        ContextualHintView(
                            feature: .pause,
                            onDismiss: {
                                showPauseHint = false
                                onboardingManager.markHintAsSeen(for: .pause)
                            }
                        )
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    if showProgressHint {
                        ContextualHintView(
                            feature: .progress,
                            onDismiss: {
                                showProgressHint = false
                                onboardingManager.markHintAsSeen(for: .progress)
                            }
                        )
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    Spacer()
                }
                .padding(.top, DesignSystem.Spacing.lg)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // Agent 29: Allow rotation - optimize for both portrait and landscape
            ToolbarItem(placement: .principal) {
                EmptyView()
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    Haptics.buttonPress()
                    // Agent 25: Show confirmation before stopping
                    if engine.phase != .idle && engine.phase != .completed {
                        showingStopConfirmation = true
                    } else {
                        // If completion celebration sheet is showing, dismiss it first
                        if showCompletionCelebration {
                            showCompletionCelebration = false
                            // Dismiss the view after a brief delay to allow sheet animation
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                dismiss()
                            }
                        } else {
                            dismiss()
                        }
                    }
                }
                .foregroundStyle(Theme.accentA)
                .accessibilityLabel("Done")
                .accessibilityHint("Double tap to close the workout view")
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(workoutVoiceOverLabel)
        .dynamicTypeSize(...DynamicTypeSize.accessibility5)
        // Agent 25: Confirmation dialog for workout stop
        .confirmationDialog("Stop Workout", isPresented: $showingStopConfirmation, titleVisibility: .visible) {
            Button("Stop", role: .destructive) {
                // Agent 25: Stop workout with undo support
                engine.stop()
                
                // Agent 25: Show toast with undo option
                ToastManager.shared.show(
                    message: "Workout stopped",
                    onUndo: {
                        if engine.undoStop() {
                            Haptics.success()
                        }
                    }
                )
                
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to stop this workout? This action can be undone.")
        }
        .undoToast() // Agent 25: Enable undo toast notifications
        .onChange(of: engine.phase) { newPhase in
            // Phase transition animations (180-220ms ease-in-out per spec)
            withAnimation(.easeInOut(duration: 0.2)) {
                // Phase color crossfade handled by segmented ring
            }
            
            // Agent 29: Enhanced haptic feedback for phase transitions
            if previousPhase != newPhase {
                // Agent 28: Announce phase changes via VoiceOver
                let phaseString: String
                switch newPhase {
                case .idle:
                    phaseString = "idle"
                case .preparing:
                    phaseString = "preparing"
                    // Agent 29: Light haptic for preparation
                    Haptics.phaseTransitionToPrep()
                case .exercise:
                    phaseString = "exercise"
                    // Agent 29: Distinct pattern for exercise transition
                    Haptics.phaseTransitionToExercise()
                case .rest:
                    phaseString = "rest"
                    // Agent 29: Softer pattern for rest transition
                    Haptics.phaseTransitionToRest()
                case .completed:
                    phaseString = "completed"
                }
                
                AccessibilityAnnouncer.announcePhaseChange(
                    phase: phaseString,
                    exercise: engine.currentExercise?.name,
                    timeRemaining: Int(engine.timeRemaining)
                )
            }
            
            if newPhase == .completed {
                let duration = engine.currentSessionDuration ?? AppConstants.TimingConstants.defaultWorkoutDuration
                // Get start date from engine
                let startDate = engine.sessionStartDate ?? Date().addingTimeInterval(-duration)
                let exercisesCompleted = engine.exercises.count
                
                store.addSession(duration: duration, exercisesCompleted: exercisesCompleted, startDate: startDate)
                
                // Update personal best asynchronously to avoid SwiftUI warnings
                Task { @MainActor in
                    _ = store.updatePersonalBest(duration: duration, exercisesCompleted: exercisesCompleted)
                }
                
                showCompletionConfetti = true
                showCompletionCelebration = true
                
                // Agent 11: Voice cue for completion
                let stats = WorkoutStats(
                    exercisesCompleted: engine.exercises.count,
                    duration: duration
                )
                voiceCues.speakCompletion(stats: stats)
                
                // Agent 28: Announce workout completion with stats via VoiceOver
                AccessibilityAnnouncer.announceWorkoutCompletion(
                    duration: duration,
                    exercisesCompleted: engine.exercises.count
                )
                
                // Agent 29: Celebration pattern for workout completion
                Haptics.workoutComplete()
            } else if newPhase == .exercise {
                // Agent 11: Start rep counting for new exercise
                if let exercise = engine.currentExercise {
                    repCounter.startTracking(for: exercise)
                    // Trigger voice cue immediately when phase changes to exercise
                    // Wait for voice to finish before starting timer (handled in engine)
                    voiceCues.speakExerciseTransition(to: exercise, phase: .exercise) {
                        // Voice finished - timer will start now (handled in engine)
                    }
                }
                
                // Agent 24: DISABLED - Don't show hints during active exercises to prevent blocking view
                // Hints will be shown only during idle/completed phases
            }
            
            // Update previous phase for next comparison
            previousPhase = newPhase
        }
        .onAppear {
            // Initialize previous phase
            previousPhase = engine.phase
            
            // Agent 24: Show contextual hints for first-time users
            if onboardingManager.shouldShowHint(for: .workoutTimer) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(AnimationConstants.smoothSpring) {
                        showWorkoutTimerHint = true
                    }
                }
            }
            
            // Auto-start workout if idle and not already started
            if engine.phase == .idle && !hasAutoStarted {
                hasAutoStarted = true
                // Small delay to ensure view is fully presented
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    engine.start()
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name(AppConstants.NotificationNames.appDidEnterBackground))) { _ in
            // Agent 6: Handle background transition
            engine.handleBackgroundTransition()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name(AppConstants.NotificationNames.appDidBecomeActive))) { _ in
            // Agent 6: Handle foreground transition
            engine.handleForegroundTransition()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            // Agent 6: Handle interruption (phone call, etc.)
            engine.handleInterruption()
        }
        .sheet(isPresented: $showCompletionCelebration) {
            completionCelebrationSheet
        }
        .onAppear {
            // Show gesture hints on first use
            if !hasSeenGestureHint && engine.phase == .exercise {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    showGestureHint = true
                }
            }
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
                .tint(Theme.accentA)
                .frame(height: 4)
                .animation(AnimationConstants.progressLinear, value: engine.progress)
        }
    }
    
    private var scrollContent: some View {
        ScrollView {
            // Agent 29: Optimize layout for landscape vs portrait
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
                    let verticalAmount = value.translation.height
                    
                    // Horizontal swipe (left or right)
                    if abs(horizontalAmount) > abs(verticalAmount) {
                        if horizontalAmount > 50 {
                            // Swipe right: Pause/Resume
                            if engine.phase != .idle && engine.phase != .completed {
                                if engine.isPaused {
                                    engine.resume()
                                } else {
                                    engine.pause()
                                }
                                Haptics.buttonPress()
                                // Dismiss gesture hint if showing
                                if showGestureHint {
                                    showGestureHint = false
                                    hasSeenGestureHint = true
                                }
                            }
                        } else if horizontalAmount < -50 {
                            // Swipe left: Skip rest (only during rest phase)
                            if engine.phase == .rest {
                                engine.skipRest()
                                Haptics.buttonPress()
                                // Dismiss gesture hint if showing
                                if showGestureHint {
                                    showGestureHint = false
                                    hasSeenGestureHint = true
                                }
                            }
                        }
                    }
                }
        )
    }
    
    // Agent 29: Portrait layout (original)
    private var portraitLayout: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Exercise name prominently displayed at top during countdown (immediately visible)
            if engine.phase == .preparing, let nextExercise = engine.nextExercise {
                VStack(spacing: DesignSystem.Spacing.xs) {
                    Text("Next Exercise")
                        .font(Theme.caption.weight(.semibold))
                        .foregroundStyle(Theme.textSecondary)
                        .textCase(.uppercase)
                        .tracking(DesignSystem.Typography.uppercaseTracking)
                    
                    Text(nextExercise.name)
                        .font(Theme.title2.weight(.bold))
                        .foregroundStyle(Theme.textPrimary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, DesignSystem.Spacing.md)
                .padding(.horizontal, DesignSystem.Spacing.lg)
            }
            
            // Timer section with circular progress (shows when idle or before workout starts)
            if engine.phase == .idle {
                timerSectionWithCircularProgress
                    .padding(.top, DesignSystem.Spacing.xl)
            } else {
                // Segmented progress ring (12 segments per spec)
                segmentedProgressRing
                    .padding(.top, engine.phase == .preparing ? DesignSystem.Spacing.md : DesignSystem.Spacing.xl)
            }
            
            // Exercise/prep view (simplified)
            exerciseOrPrepView
                .padding(.top, DesignSystem.Spacing.lg)
            
            // Controls section - always show when idle or completed
            if engine.phase == .idle || engine.phase == .completed {
                controlsSection
                    .padding(.top, DesignSystem.Spacing.lg)
            }
            
            statsSectionIfNeeded
                .padding(.top, DesignSystem.Spacing.lg)
        }
        .padding(.horizontal, DesignSystem.Spacing.xl)
        .padding(.vertical, DesignSystem.Spacing.xl)
        .padding(.bottom, DesignSystem.Spacing.xxxl + DesignSystem.Spacing.md) // Space for sticky control bar (96pt)
    }
    
    // Agent 29: Landscape layout (optimized for horizontal viewing)
    private var landscapeLayout: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            // Exercise name prominently displayed at top during countdown (immediately visible in landscape too)
            if engine.phase == .preparing, let nextExercise = engine.nextExercise {
                VStack(spacing: DesignSystem.Spacing.xs) {
                    Text("Next Exercise")
                        .font(Theme.caption.weight(.semibold))
                        .foregroundStyle(Theme.textSecondary)
                        .textCase(.uppercase)
                        .tracking(DesignSystem.Typography.uppercaseTracking)
                    
                    Text(nextExercise.name)
                        .font(Theme.title2.weight(.bold))
                        .foregroundStyle(Theme.textPrimary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, DesignSystem.Spacing.xs)
                .padding(.horizontal, LandscapeOptimizer.landscapePadding)
            }
            
            HStack(alignment: .top, spacing: LandscapeOptimizer.landscapeSpacing) {
                // Left side: Timer and progress
                VStack(spacing: DesignSystem.Spacing.md) {
                    if engine.phase == .idle {
                        timerSectionWithCircularProgress
                            .frame(width: LandscapeOptimizer.landscapeTimerSize, height: LandscapeOptimizer.landscapeTimerSize)
                            .padding(.top, DesignSystem.Spacing.md)
                    } else {
                        segmentedProgressRing
                            .frame(width: LandscapeOptimizer.landscapeTimerSize, height: LandscapeOptimizer.landscapeTimerSize)
                            .padding(.top, engine.phase == .preparing ? DesignSystem.Spacing.xs : DesignSystem.Spacing.md)
                    }
                    
                    statsSectionIfNeeded
                }
                .frame(width: LandscapeOptimizer.landscapeTimerSize + 40)
                
                // Right side: Exercise info and controls
                VStack(spacing: DesignSystem.Spacing.md) {
                    exerciseOrPrepView
                    
                    if engine.phase == .idle || engine.phase == .completed {
                        controlsSection
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, LandscapeOptimizer.landscapePadding)
        .padding(.vertical, LandscapeOptimizer.landscapeSpacing)
        .padding(.bottom, DesignSystem.Spacing.xxxl + DesignSystem.Spacing.md) // Space for sticky control bar (96pt)
        .gesture(
            DragGesture(minimumDistance: 50)
                .onEnded { value in
                    let horizontalAmount = value.translation.width
                    let verticalAmount = value.translation.height
                    
                    // Horizontal swipe (left or right)
                    if abs(horizontalAmount) > abs(verticalAmount) {
                        if horizontalAmount > 50 {
                            // Swipe right: Pause/Resume
                            if engine.phase != .idle && engine.phase != .completed {
                                if engine.isPaused {
                                    engine.resume()
                                } else {
                                    engine.pause()
                                }
                                Haptics.buttonPress()
                                // Dismiss gesture hint if showing
                                if showGestureHint {
                                    showGestureHint = false
                                    hasSeenGestureHint = true
                                }
                            }
                        } else if horizontalAmount < -50 {
                            // Swipe left: Skip rest (only during rest phase)
                            if engine.phase == .rest {
                                engine.skipRest()
                                Haptics.buttonPress()
                                // Dismiss gesture hint if showing
                                if showGestureHint {
                                    showGestureHint = false
                                    hasSeenGestureHint = true
                                }
                            }
                        }
                    }
                }
        )
    }
    
    @ViewBuilder
    private var exerciseOrPrepView: some View {
        if engine.phase == .idle {
            // Show welcome message when idle
            idleWelcomeView
        } else if engine.phase == .preparing {
            prepView
        } else if engine.phase == .rest {
            restView
        } else if let exercise = engine.currentExercise {
            exerciseCard(exercise: exercise)
        }
    }
    
    // MARK: - Idle Welcome View
    
    private var idleWelcomeView: some View {
        GlassCard(material: .ultraThinMaterial) {
            VStack(spacing: DesignSystem.Spacing.lg) {
                Image(systemName: "figure.run")
                    .font(.system(size: DesignSystem.IconSize.huge, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Theme.accentA, Theme.accentB],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text("Ready to Start")
                    .font(Theme.title2.weight(.bold))
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text("Your workout will begin automatically")
                    .font(Theme.subheadline)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(DesignSystem.Typography.bodyLineHeight - 1.0)
                
                Text("\(engine.exercises.count) exercises • ~\(Int(engine.totalWorkoutDuration / 60)) minutes")
                    .font(Theme.caption)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(DesignSystem.Spacing.cardPadding)
        }
    }
    
    @ViewBuilder
    private var statsSectionIfNeeded: some View {
        if engine.phase != .idle {
            statsSection
        }
    }
    
    @ViewBuilder
    private var completionOverlayIfNeeded: some View {
        if engine.phase == .completed {
            completionOverlay
        }
    }
    
    @ViewBuilder
    private var completionCelebrationSheet: some View {
        // Agent 11: Enhanced completion celebration
        let calendar = Calendar.current
        let today = Date()
        let hasWorkoutToday = store.sessions.contains { calendar.isDate($0.date, inSameDayAs: today) }
        
        // Agent 2: Check personal best and achievements
        let duration = engine.currentSessionDuration ?? AppConstants.TimingConstants.defaultWorkoutDuration
        let exercisesCompleted = engine.exercises.count
        let isPersonalBest = store.isPersonalBest(duration: duration, exercisesCompleted: exercisesCompleted)
        
        // Get unlocked achievements from AchievementManager
        // Check achievements with a fresh manager instance (will load from persistence)
        let achievementManager = AchievementManager(store: store)
        let _ = achievementManager.checkAchievements()
        // Convert Achievement enum to String array for WorkoutCompletionStats
        let unlockedAchievements = achievementManager.unlockedAchievements.map { $0.rawValue }
        
        let stats = WorkoutCompletionStats(
            duration: duration,
            exercisesCompleted: exercisesCompleted,
            estimatedCalories: engine.exercises.count * 5,
            repsCompleted: repCounter.currentReps,
            currentStreak: store.streak,
            isStreakDay: hasWorkoutToday,
            isPersonalBest: isPersonalBest,
            unlockedAchievements: unlockedAchievements
        )
        CompletionCelebrationView(
            workoutStats: stats,
            onDismiss: {
                showCompletionCelebration = false
                dismiss()
            },
            onStartNew: {
                showCompletionCelebration = false
                engine.reset()
                engine.start()
            }
        )
        .interactiveDismissDisabled()
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
            
            // Circular progress ring with timer (Master Designer Polish)
            ZStack {
                // Outer glow ring for depth
                Circle()
                    .stroke(
                        (engine.phase == .rest ? Theme.accentB : Theme.accentA).opacity(DesignSystem.Opacity.glow * 0.3),
                        lineWidth: 14
                    )
                    .frame(width: 230, height: 230)
                    .blur(radius: 4)
                    .accessibilityHidden(true)
                
                // Background circle with refined styling
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
                
                // Agent 19: Progress circle with color transitions and enhanced glow
                Circle()
                    .trim(from: 0, to: segmentProgress)
                    .stroke(
                        LinearGradient(
                            colors: [
                                engine.phase == .rest ? Theme.accentB : timerColor,
                                engine.phase == .rest ? Theme.accentB.opacity(DesignSystem.Opacity.veryStrong * 1.18) : timerColor.opacity(DesignSystem.Opacity.veryStrong * 1.18),
                                engine.phase == .rest ? Theme.accentC : timerColor.opacity(DesignSystem.Opacity.strong),
                                engine.phase == .rest ? Theme.accentB.opacity(DesignSystem.Opacity.strong * 1.17) : timerColor.opacity(DesignSystem.Opacity.strong * 1.17)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round, lineJoin: .round)
                    )
                    .frame(width: 220, height: 220)
                    .rotationEffect(.degrees(-90))
                    .animation(AccessibilityHelpers.animation(.linear(duration: 0.1)), value: segmentProgress)
                    // Agent 19: Smooth color transitions for progress ring
                    .animation(AccessibilityHelpers.animation(AnimationConstants.smoothEase) ?? .none, value: timerColor)
                    // Agent 19: Enhanced glow effect when time is running low
                    .shadow(
                        color: timerColor.opacity(DesignSystem.Opacity.medium + (timerGlowIntensity * 0.3)),
                        radius: 12 + (timerGlowIntensity * 6),
                        x: 0,
                        y: 6
                    )
                    .shadow(
                        color: timerColor.opacity(DesignSystem.Opacity.glow * 0.8 + (timerGlowIntensity * 0.4)),
                        radius: 8 + (timerGlowIntensity * 4),
                        x: 0,
                        y: 3
                    )
                
                // Agent 19: Timer text with enhanced styling, color transitions, pulse, and glow
                VStack(spacing: DesignSystem.Spacing.sm) {
                    Text(timeString)
                        .font(.system(size: DesignSystem.IconSize.huge * 1.125, weight: .bold, design: .rounded)) // 72pt timer display (increased from 68pt for prominence)
                        .dynamicTypeSize(...DynamicTypeSize.accessibility5) // Support Dynamic Type for accessibility
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    engine.phase == .rest ? Theme.accentB : timerColor,
                                    engine.phase == .rest ? Theme.accentB.opacity(DesignSystem.Opacity.almostOpaque) : timerColor.opacity(DesignSystem.Opacity.almostOpaque)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .monospacedDigit()
                        .contentTransition(.numericText())
                        .scaleEffect(engine.phase == .rest ? 0.95 : 1.0)
                        // Agent 19: Smooth color transitions
                        .animation(AccessibilityHelpers.animation(AnimationConstants.smoothEase) ?? .none, value: timerColor)
                        .animation(AccessibilityHelpers.animation(AnimationConstants.quickSpring) ?? .none, value: engine.phase)
                        .animation(AccessibilityHelpers.animation(AnimationConstants.quickSpring) ?? .none, value: engine.timeRemaining)
                        // Agent 19: Tick pulse animation on each second
                        .timerTickPulse(trigger: Int(engine.timeRemaining))
                        // Agent 19: Glow effect when time is running low
                        .shadow(
                            color: timerColor.opacity(DesignSystem.Opacity.glow * timerGlowIntensity * 0.8),
                            radius: 12 + (timerGlowIntensity * 8),
                            x: 0,
                            y: 2
                        )
                        .shadow(
                            color: timerColor.opacity(DesignSystem.Opacity.glow * timerGlowIntensity * 0.6),
                            radius: 20 + (timerGlowIntensity * 12),
                            x: 0,
                            y: 4
                        )
                        .bounce(trigger: engine.timeRemaining <= 1 && engine.timeRemaining > 0)
                        .accessibilityLabel("\(Int(engine.timeRemaining)) seconds remaining")
                        .accessibilityValue("\(engine.phase == .rest ? "Rest" : "Exercise")")
                        .accessibilityAddTraits(.updatesFrequently)
                        .dynamicTypeSize(...DynamicTypeSize.accessibility5)
                }
            }
            .padding(.vertical, DesignSystem.Spacing.lg)
            
            // Exercise counter or next exercise preview
            if engine.phase == .preparing {
                if let firstExercise = engine.nextExercise {
                    Text("First up: \(firstExercise.name)")
                        .font(Theme.headline)
                        .foregroundStyle(.secondary)
                }
            } else if engine.phase == .exercise || engine.phase == .rest {
                VStack(spacing: DesignSystem.Spacing.xs) {
                    Text("Stage \(stageNumber) of \(engine.exercises.count)")
                        .font(Theme.headline)
                        .foregroundStyle(.secondary)
                    
                    if let next = engine.nextExercise {
                        Text("Next: \(next.name)")
                            .font(Theme.subheadline)
                            .foregroundStyle(.secondary.opacity(DesignSystem.Opacity.veryStrong))
                    } else {
                        Text("Final stage!")
                            .font(Theme.subheadline)
                            .foregroundStyle(.secondary.opacity(DesignSystem.Opacity.veryStrong))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.xl)
    }
    
    // MARK: - Segmented Progress Ring (12 segments per spec)
    
    private var segmentedProgressRing: some View {
        SegmentedProgressRing(
            totalSegments: 12,
            completedSegments: completedSegmentCount,
            currentSegmentProgress: currentSegmentProgressValue,
            phase: engine.phase,
            timeRemaining: engine.timeRemaining,
            currentExercise: engine.currentExercise,
            nextExercise: engine.nextExercise
        )
        .animation(.easeInOut(duration: 0.2), value: engine.phase) // 180-220ms transition
        .animation(.easeInOut(duration: 0.2), value: completedSegmentCount)
    }
    
    /// Number of completed segments (completed exercises)
    private var completedSegmentCount: Int {
        switch engine.phase {
        case .preparing:
            return 0
        case .exercise:
            return engine.currentExerciseIndex
        case .rest:
            return engine.currentExerciseIndex + 1
        default:
            return 0
        }
    }
    
    /// Progress for current segment (0.0 to 1.0)
    private var currentSegmentProgressValue: Double {
        guard engine.phase != .idle && engine.phase != .completed else { return 0 }
        
        let segmentDuration: TimeInterval
        switch engine.phase {
        case .preparing:
            segmentDuration = engine.prepDuration
        case .exercise:
            segmentDuration = engine.exerciseDuration
        case .rest:
            segmentDuration = engine.restDuration
        default:
            return 0
        }
        
        guard segmentDuration > 0 else { return 0 }
        return 1.0 - (engine.timeRemaining / segmentDuration)
    }
    
    // Legacy segment progress (kept for backward compatibility)
    private var segmentProgress: Double {
        currentSegmentProgressValue
    }
    
    // MARK: - Sticky Control Bar (≥48pt hit targets per spec)
    
    private var stickyControlBar: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            // Back button (only during exercise, not on first exercise)
            if engine.phase == .exercise && engine.currentExerciseIndex > 0 {
                Button {
                    Haptics.buttonPress()
                    engine.goToPreviousExercise()
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: DesignSystem.IconSize.medium, weight: .semibold))
                        .frame(width: DesignSystem.TouchTarget.comfortable)
                        .frame(height: DesignSystem.TouchTarget.comfortable)
                }
                .buttonStyle(SecondaryGlassButtonStyle())
                .accessibilityLabel("Previous exercise")
                .accessibilityHint("Double tap to go back to the previous exercise")
            }
            
            // Pause/Resume (primary, takes remaining space)
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
            .accessibilityLabel(engine.isPaused ? "Resume workout" : "Pause workout")
            .accessibilityHint("Double tap to \(engine.isPaused ? "resume" : "pause") the workout")
            
            // Next/Skip button
            if engine.phase == .rest {
                // Skip rest button
                Button {
                    Haptics.buttonPress()
                    engine.skipRest()
                } label: {
                    Image(systemName: "forward.fill")
                        .font(.system(size: DesignSystem.IconSize.medium, weight: .semibold))
                        .frame(width: DesignSystem.TouchTarget.comfortable)
                        .frame(height: DesignSystem.TouchTarget.comfortable)
                }
                .buttonStyle(SecondaryGlassButtonStyle())
                .accessibilityLabel("Skip rest")
                .accessibilityHint("Double tap to skip the rest period and move to next exercise")
            } else if engine.phase == .exercise && engine.nextExercise != nil {
                // Next exercise button (only if there's a next exercise)
                Button {
                    Haptics.buttonPress()
                    engine.skipExercise()
                } label: {
                    Image(systemName: "arrow.right")
                        .font(.system(size: DesignSystem.IconSize.medium, weight: .semibold))
                        .frame(width: DesignSystem.TouchTarget.comfortable)
                        .frame(height: DesignSystem.TouchTarget.comfortable)
                }
                .buttonStyle(SecondaryGlassButtonStyle())
                .accessibilityLabel("Next exercise")
                .accessibilityHint("Double tap to skip to the next exercise")
            }
            
            // Volume control (toggle voice cues)
            Button {
                Haptics.buttonPress()
                voiceCues.voiceEnabled.toggle()
                voiceCues.saveSettings()
            } label: {
                Image(systemName: voiceCues.voiceEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                    .font(.system(size: DesignSystem.IconSize.medium))
                    .foregroundStyle(voiceCues.voiceEnabled ? Theme.accentA : .secondary)
                    .frame(width: DesignSystem.TouchTarget.comfortable)
                    .frame(height: DesignSystem.TouchTarget.comfortable)
            }
            .buttonStyle(SecondaryGlassButtonStyle())
            .accessibilityLabel(voiceCues.voiceEnabled ? "Voice cues on" : "Voice cues off")
            .accessibilityHint("Double tap to toggle voice cues")
        }
    }
    
    // MARK: - Now/Next Line
    
    private var nowNextLine: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Now line - only show during exercise
            if engine.phase == .exercise, let currentExercise = engine.currentExercise {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Circle()
                        .fill(Theme.accentA)
                        .frame(width: 6, height: 6)
                    Text("Now:")
                        .font(Theme.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                    Text(currentExercise.name)
                        .font(Theme.caption.weight(.semibold))
                        .foregroundStyle(Theme.textPrimary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Next line - show during exercise or rest
            if let nextExercise = engine.nextExercise {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Circle()
                        .fill(Theme.accentB.opacity(0.6))
                        .frame(width: 6, height: 6)
                    Text("Next:")
                        .font(Theme.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                    Text(nextExercise.name)
                        .font(Theme.caption.weight(.semibold))
                        .foregroundStyle(Theme.textPrimary)
                        .lineLimit(1)
                }
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.xs)
    }
    
    // MARK: - Agent 19: Timer Color Transitions
    
    /// Agent 19: Computed property for timer color based on time remaining
    /// Returns a color that transitions from green → yellow → red as time runs out
    private var timerColor: Color {
        guard engine.phase != .idle && engine.phase != .preparing && engine.phase != .completed && !engine.isPaused else {
            return Theme.accentA
        }
        
        let segmentDuration: TimeInterval
        switch engine.phase {
        case .exercise:
            segmentDuration = engine.exerciseDuration
        case .rest:
            segmentDuration = engine.restDuration
        default:
            return Theme.accentA
        }
        
        guard segmentDuration > 0 else { return Theme.accentA }
        
        let timeRatio = engine.timeRemaining / segmentDuration
        
        // Green → Yellow → Red transition using HSB color space
        // Green: hue ~0.33 (120°), Yellow: hue ~0.17 (60°), Red: hue ~0.0 (0°)
        if timeRatio > 0.5 {
            // Pure green (accentA) when > 50% time remaining
            return Theme.accentA
        } else if timeRatio > 0.25 {
            // Yellow transition (50% to 25% of time remaining)
            // Interpolate from green (hue ~0.33) to yellow (hue ~0.17)
            let yellowProgress = (0.5 - timeRatio) / 0.25 // 0.0 to 1.0
            let hue = 0.33 - (0.33 - 0.17) * yellowProgress // Green to yellow
            return Color(hue: hue, saturation: 0.75, brightness: 0.85)
        } else {
            // Red transition (25% to 0% of time remaining)
            // Interpolate from yellow (hue ~0.17) to red (hue ~0.0)
            let redProgress = (0.25 - timeRatio) / 0.25 // 0.0 to 1.0
            let hue = 0.17 - (0.17 - 0.0) * redProgress // Yellow to red
            let saturation = 0.75 + 0.20 * redProgress // Increase saturation as it gets redder
            let brightness = 0.85 - 0.15 * redProgress // Slightly darker for red
            return Color(hue: hue, saturation: saturation, brightness: brightness)
        }
    }
    
    /// Agent 19: Computed property for timer glow intensity based on time remaining
    private var timerGlowIntensity: Double {
        guard engine.phase != .idle && engine.phase != .preparing && engine.phase != .completed && !engine.isPaused else {
            return 0.0
        }
        
        let segmentDuration: TimeInterval
        switch engine.phase {
        case .exercise:
            segmentDuration = engine.exerciseDuration
        case .rest:
            segmentDuration = engine.restDuration
        default:
            return 0.0
        }
        
        guard segmentDuration > 0 else { return 0.0 }
        
        let timeRatio = engine.timeRemaining / segmentDuration
        
        // Glow increases as time runs out, especially in the last 25%
        if timeRatio <= 0.25 {
            return 1.0 - (timeRatio / 0.25) // 0.0 to 1.0 as time approaches 0
        } else if timeRatio <= 0.5 {
            return (0.5 - timeRatio) / 0.25 * 0.3 // Subtle glow from 50% to 25%
        } else {
            return 0.0
        }
    }
    
    private var stageNumber: Int {
        switch engine.phase {
        case .preparing:
            return 0
        case .exercise:
            return engine.currentExerciseIndex + 1
        case .rest:
            return engine.currentExerciseIndex + 1
        default:
            return 0
        }
    }
    
    // MARK: - Prep View
    
    private var prepView: some View {
        ZStack {
            GlassCard(material: .ultraThinMaterial) {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    // Agent 11: Countdown animation
                    if engine.timeRemaining <= 3 && engine.timeRemaining > 0 {
                        PrepCountdownView(timeRemaining: engine.timeRemaining)
                            .frame(height: 200)
                    } else {
                        Image(systemName: "figure.run")
                            .font(.system(size: DesignSystem.IconSize.huge, weight: .bold))
                            .foregroundStyle(Theme.accentA)
                            .modifier(SymbolBounceModifier(trigger: engine.timeRemaining))
                    }
                    
                    Text("Prepare to Start")
                        .font(Theme.title2.weight(.bold))
                        .foregroundStyle(Theme.textPrimary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                    
                    // Exercise name is now shown at top of screen, so we don't need to repeat it here
                    // But show a subtle reminder if it's not the first exercise
                    if let nextExercise = engine.nextExercise {
                        if engine.currentExerciseIndex > 0 {
                            Text("Next: \(nextExercise.name)")
                                .font(Theme.subheadline)
                                .foregroundStyle(Theme.textSecondary)
                                .multilineTextAlignment(.center)
                                .lineSpacing(DesignSystem.Typography.bodyLineHeight - 1.0)
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Get ready!")
                                .font(Theme.subheadline)
                                .foregroundStyle(Theme.textSecondary)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding(DesignSystem.Spacing.cardPadding)
            }
        }
        .onAppear {
            // Agent 11: Voice cue for preparation
            if let exercise = engine.nextExercise {
                voiceCues.speakExerciseTransition(to: exercise, phase: .preparing)
            }
        }
    }
    
    // MARK: - Rest View
    
    private var restView: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            // Agent 11: Breathing guide during rest
            BreathingGuideView(
                exercise: engine.nextExercise,
                duration: engine.restDuration
            )
            
            // Next exercise preview
            if let nextExercise = engine.nextExercise {
                GlassCard(material: .ultraThinMaterial) {
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        Text("Next Exercise")
                            .font(Theme.headline)
                            .foregroundStyle(Theme.textPrimary)
                        
                        Image(systemName: nextExercise.icon)
                            .font(.system(size: DesignSystem.IconSize.xxlarge, weight: .bold))
                            .foregroundStyle(Theme.accentA)
                        
                        Text(nextExercise.name)
                            .font(Theme.title3.weight(.semibold))
                            .foregroundStyle(Theme.textPrimary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                        
                        Text(nextExercise.description)
                            .font(Theme.caption)
                            .foregroundStyle(Theme.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(DesignSystem.Typography.captionLineHeight - 1.0)
                            .lineLimit(3)
                    }
                    .padding(DesignSystem.Spacing.cardPadding)
                }
            }
        }
        .onAppear {
            // Agent 11: Voice cue for rest
            if let exercise = engine.nextExercise {
                voiceCues.speakExerciseTransition(to: exercise, phase: .rest)
            }
        }
    }
    
    // MARK: - Exercise Card
    
    private func exerciseCard(exercise: Exercise) -> some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            GlassCard(material: .ultraThinMaterial) {
                VStack(spacing: DesignSystem.Spacing.xl) {
                    // Exercise icon with Agent 11 animations
                    Image(systemName: exercise.icon)
                        .font(.system(size: DesignSystem.IconSize.huge, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    engine.phase == .exercise ? Theme.accentA : Theme.accentB,
                                    engine.phase == .exercise ? Theme.accentA.opacity(DesignSystem.Opacity.veryStrong * 1.11) : Theme.accentB.opacity(DesignSystem.Opacity.veryStrong * 1.11)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .modifier(SymbolBounceModifier(trigger: engine.currentExerciseIndex))
                        .modifier(SymbolPulseModifier(trigger: engine.phase == .exercise))
                        .scaleEffect(engine.phase == .exercise ? 1.0 : 0.9)
                        .animation(AnimationConstants.elegantSpring, value: engine.phase)
                        .shadow(color: (engine.phase == .exercise ? Theme.accentA : Theme.accentB).opacity(DesignSystem.Opacity.glow * 0.8), 
                               radius: DesignSystem.Shadow.medium.radius, 
                               x: 0, y: DesignSystem.Shadow.medium.y)
                        .shadow(color: (engine.phase == .exercise ? Theme.accentA : Theme.accentB).opacity(DesignSystem.Opacity.medium), 
                               radius: DesignSystem.Shadow.verySoft.radius * 1.5, 
                               x: 0, y: DesignSystem.Shadow.verySoft.y * 1.5)
                    
                    // Exercise name
                    Text(exercise.name)
                        .font(Theme.title2.weight(.bold))
                        .foregroundStyle(Theme.textPrimary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(DesignSystem.Typography.titleLineHeight - 1.0)
                        .frame(maxWidth: .infinity)
                    
                    // Description - centered below timer
                    Text(exercise.description)
                        .font(Theme.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(DesignSystem.Typography.bodyLineHeight - 1.0)
                        .frame(maxWidth: .infinity)
                        .padding(.top, DesignSystem.Spacing.xs)
                    
                    // Agent 11: Rep counter
                    RepCounterView(repCounter: repCounter, exercise: exercise)
                    
                    // Instructions (shown during exercise)
                    Text(exercise.instructions)
                        .font(Theme.subheadline) // Increased from caption for better readability during workouts
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(DesignSystem.Typography.bodyLineHeight - 1.0) // Updated to match subheadline line height
                        .padding(.top, DesignSystem.Spacing.sm)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    
                    // Agent 11: Form feedback system
                    FormFeedbackSystem(
                        exercise: exercise,
                        timeRemaining: engine.timeRemaining
                    )
                }
                .padding(DesignSystem.Spacing.cardPadding)
            }
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .animation(AnimationConstants.smoothEase, value: engine.phase)
        }
        .onAppear {
            // Agent 11: Start rep counting (voice cue is triggered in onChange handler for timing)
            repCounter.startTracking(for: exercise)
            // Form guidance is spoken after a delay to not overlap with "Go!"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                voiceCues.speakFormGuidance(for: exercise)
            }
        }
        .onDisappear {
            repCounter.stopTracking()
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
                    Label(ButtonLabel.startWorkout.text, systemImage: "play.fill")
                        .font(Theme.title3)
                        .fontWeight(DesignSystem.Typography.headlineWeight)
                        .frame(maxWidth: .infinity)
                        .frame(height: DesignSystem.ButtonSize.large.height)
                }
                .buttonStyle(PrimaryProminentButtonStyle())
                .accessibilityHint(MicrocopyManager.shared.tooltip(for: .startWorkout))
            } else if engine.phase == .completed {
                // Workout completed
                VStack(spacing: DesignSystem.Spacing.md) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: DesignSystem.IconSize.huge))
                        .foregroundStyle(.green)
                    
                    Text("Workout Complete!")
                        .font(Theme.title2)
                        .foregroundStyle(Theme.textPrimary)
                }
                .padding(.vertical, DesignSystem.Spacing.xl)
            } else {
                // Pause/Resume and Skip Rest buttons
                HStack(spacing: DesignSystem.Spacing.md) {
                    Button {
                        Haptics.buttonPress()
                        if engine.isPaused {
                            engine.resume()
                        } else {
                            engine.pause()
                        }
                    } label: {
                        Label(engine.isPaused ? ButtonLabel.resume.text : ButtonLabel.pause.text, 
                              systemImage: engine.isPaused ? "play.fill" : "pause.fill")
                            .font(Theme.headline)
                            .fontWeight(DesignSystem.Typography.headlineWeight)
                            .frame(maxWidth: .infinity)
                            .frame(height: DesignSystem.ButtonSize.standard.height)
                    }
                    .buttonStyle(SecondaryGlassButtonStyle())
                    .accessibilityLabel(engine.isPaused ? "Resume workout" : "Pause workout")
                    .accessibilityHint(engine.isPaused ? MicrocopyManager.shared.tooltip(for: .resumeWorkout) : MicrocopyManager.shared.tooltip(for: .pauseWorkout))
                    
                    if engine.phase == .rest {
                        Button {
                            Haptics.buttonPress()
                            engine.skipRest()
                        } label: {
                            Label(ButtonLabel.skipRest.text, systemImage: "forward.fill")
                                .font(Theme.headline)
                                .fontWeight(DesignSystem.Typography.headlineWeight)
                                .frame(maxWidth: .infinity)
                                .frame(height: DesignSystem.ButtonSize.standard.height)
                        }
                        .buttonStyle(SecondaryGlassButtonStyle())
                        .accessibilityLabel("Skip Rest")
                        .accessibilityHint(MicrocopyManager.shared.tooltip(for: .skipRest))
                        .accessibilityAddTraits(.isButton)
                    } else if engine.phase == .preparing {
                        Button {
                            Haptics.buttonPress()
                            engine.skipPrep()
                        } label: {
                            Label(ButtonLabel.skipPrep.text, systemImage: "forward.fill")
                                .font(Theme.headline)
                                .fontWeight(DesignSystem.Typography.headlineWeight)
                                .frame(maxWidth: .infinity)
                                .frame(height: DesignSystem.ButtonSize.standard.height)
                        }
                        .buttonStyle(SecondaryGlassButtonStyle())
                        .accessibilityLabel("Skip Preparation")
                        .accessibilityHint(MicrocopyManager.shared.tooltip(for: .skipPrep))
                        .accessibilityAddTraits(.isButton)
                    }
                }
                
                // Agent 25: Stop button with confirmation
                Button(role: .destructive) {
                    // Agent 25: Show confirmation before stopping
                    showingStopConfirmation = true
                    Haptics.buttonPress()
                } label: {
                    Text("Stop Workout")
                        .font(Theme.headline)
                        .fontWeight(DesignSystem.Typography.headlineWeight)
                        .frame(maxWidth: .infinity)
                        .frame(height: DesignSystem.ButtonSize.standard.height)
                }
                .buttonStyle(.bordered)
                .accessibilityLabel("Stop Workout")
                .accessibilityHint("Double tap to stop the current workout and return to the main screen.")
                .accessibilityAddTraits(.isButton)
            }
        }
    }
    
    // MARK: - Stats Section
    
    private var statsSection: some View {
        HStack(spacing: DesignSystem.Spacing.xl) {
            StatCard(
                title: "Remaining",
                value: "\(engine.exercisesRemaining)",
                icon: "figure.run",
                color: Theme.accentB
            )
            
            StatCard(
                title: "Progress",
                value: "\(Int(engine.progress * 100))%",
                icon: "chart.bar.fill",
                color: Theme.accentC
            )
        }
    }
    
    // MARK: - Completion Overlay
    
    private var completionOverlay: some View {
        ZStack {
            Color.black.opacity(DesignSystem.Opacity.strong * 1.17)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.xl) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: DesignSystem.IconSize.huge * 1.25))
                    .foregroundStyle(.green)
                
                Text("Journey Complete!")
                    .font(Theme.largeTitle)
                    .foregroundStyle(.white)
                
                Text("You've reached your destination for today.")
                    .font(Theme.title3)
                    .foregroundStyle(.white.opacity(DesignSystem.Opacity.veryStrong))
                    .multilineTextAlignment(.center)
                
                // Streak message
                if store.streak > 0 {
                    Text("You're on a \(store.streak) day streak! 🔥")
                        .font(Theme.title3)
                        .foregroundStyle(.orange)
                        .monospacedDigit()
                        .padding(.top, DesignSystem.Spacing.sm)
                }
                
                // Stats grid
                let duration = engine.currentSessionDuration ?? 0
                let minutes = Int(duration) / 60
                let seconds = Int(duration) % 60
                let calories = engine.exercises.count * 5 // Rough estimate: 5 calories per exercise
                
                HStack(spacing: DesignSystem.Spacing.xl) {
                    CompletionStatCard(
                        value: String(format: "%d:%02d", minutes, seconds),
                        label: "Time",
                        icon: "clock.fill"
                    )
                    
                    CompletionStatCard(
                        value: "\(engine.exercises.count)",
                        label: "Stages",
                        icon: "figure.run"
                    )
                    
                    CompletionStatCard(
                        value: "~\(calories)",
                        label: "Calories",
                        icon: "flame.fill"
                    )
                }
                .padding(.top, DesignSystem.Spacing.lg)
                
                // Share button
                Button {
                    Haptics.buttonPress()
                    let duration = engine.currentSessionDuration ?? 0
                    let calories = engine.exercises.count * 5
                    
                    // Get the most recent session (just added)
                    if let mostRecentSession = store.sessions.first {
                        WorkoutShareManager.shared.shareWorkoutCompletion(
                            session: mostRecentSession,
                            streak: store.streak,
                            calories: calories,
                            from: nil
                        )
                    } else {
                        // Fallback if session not found
                        WorkoutShareManager.shared.shareWorkoutCompletion(
                            duration: duration,
                            exercisesCompleted: engine.exercises.count,
                            calories: calories,
                            streak: store.streak,
                            from: nil
                        )
                    }
                } label: {
                    Label("Share Workout", systemImage: "square.and.arrow.up")
                        .font(Theme.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                }
                .buttonStyle(.bordered)
                .tint(.white)
                .foregroundStyle(.white)
                .padding(.top, DesignSystem.Spacing.sm)
                
                Button {
                    Haptics.buttonPress()
                    dismiss()
                } label: {
                    Text("Start a New Journey")
                        .font(Theme.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                }
                .buttonStyle(.borderedProminent)
                .tint(.white)
                .foregroundStyle(.black)
                .padding(.top, DesignSystem.Spacing.sm)
                }
                .padding(DesignSystem.Spacing.xxl)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous)
                        .fill(.ultraThinMaterial)
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
                .cardShadow()
                .padding(.horizontal, DesignSystem.Spacing.xxl)
                .padding(.vertical, DesignSystem.Spacing.xxl)
            }
            .gesture(
                DragGesture(minimumDistance: 50)
                    .onEnded { value in
                        // Swipe down to dismiss completion overlay
                        if value.translation.height > 100 {
                            Haptics.buttonPress()
                            dismiss()
                        }
                    }
            )
        }
    }
    
    // MARK: - Helpers
    
    private var phaseTitle: String {
        switch engine.phase {
        case .idle:
            return "Ready to Begin"
        case .preparing:
            return "Preparing"
        case .exercise:
            return "Exercise \(engine.currentExerciseIndex + 1) of \(engine.exercises.count)"
        case .rest:
            return "Rest"
        case .completed:
            return "Workout Complete"
        }
    }
    
    private var timeString: String {
        let seconds = Int(engine.timeRemaining.rounded(.up))
        return String(format: "%d", seconds)
    }
    
    // MARK: - Gesture Hints Overlay
    
    private var gestureHintsOverlay: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Spacer()
            
            VStack(spacing: DesignSystem.Spacing.md) {
                // Swipe right hint (pause/resume)
                if !engine.isPaused {
                    HStack(spacing: DesignSystem.Spacing.md) {
                        Image(systemName: "arrow.left")
                            .font(Theme.title2)
                            .foregroundStyle(Theme.accentA)
                            .modifier(SymbolBounceModifier(trigger: showGestureHint))
                        
                        Text("Swipe right to pause")
                            .font(Theme.subheadline)
                            .foregroundStyle(.white)
                        
                        Image(systemName: "arrow.right")
                            .font(Theme.title2)
                            .foregroundStyle(Theme.accentA)
                            .modifier(SymbolBounceModifier(trigger: showGestureHint))
                    }
                    .padding(DesignSystem.Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                                    .stroke(Theme.accentA.opacity(DesignSystem.Opacity.medium), lineWidth: DesignSystem.Border.standard)
                            )
                    )
                    .shadow(color: Theme.accentA.opacity(DesignSystem.Opacity.subtle), 
                           radius: DesignSystem.Shadow.medium.radius, 
                           y: DesignSystem.Shadow.medium.y)
                }
                
                // Swipe left hint (skip rest)
                if engine.phase == .rest {
                    HStack(spacing: DesignSystem.Spacing.md) {
                        Image(systemName: "arrow.left")
                            .font(Theme.title2)
                            .foregroundStyle(Theme.accentB)
                            .modifier(SymbolBounceModifier(trigger: showGestureHint))
                        
                        Text("Swipe left to skip rest")
                            .font(Theme.subheadline)
                            .foregroundStyle(.white)
                        
                        Image(systemName: "arrow.right")
                            .font(Theme.title2)
                            .foregroundStyle(Theme.accentB)
                            .modifier(SymbolBounceModifier(trigger: showGestureHint))
                    }
                    .padding(DesignSystem.Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                                    .stroke(Theme.accentB.opacity(DesignSystem.Opacity.medium), lineWidth: DesignSystem.Border.standard)
                            )
                    )
                    .shadow(color: Theme.accentB.opacity(DesignSystem.Opacity.subtle), 
                           radius: DesignSystem.Shadow.medium.radius, 
                           y: DesignSystem.Shadow.medium.y)
                }
                
                // Dismiss button
                Button {
                    withAnimation {
                        showGestureHint = false
                        hasSeenGestureHint = true
                    }
                } label: {
                    Text("Got it")
                        .font(Theme.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                        .padding(.vertical, DesignSystem.Spacing.sm)
                }
                .buttonStyle(.bordered)
                .tint(.white)
            }
            .padding(DesignSystem.Spacing.xl)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Theme.accentA.opacity(DesignSystem.Opacity.light),
                                        Theme.accentB.opacity(DesignSystem.Opacity.light)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: DesignSystem.Border.standard
                            )
                    )
            )
            .shadow(color: Theme.shadow.opacity(DesignSystem.Opacity.medium), 
                   radius: DesignSystem.Shadow.large.radius, 
                   y: DesignSystem.Shadow.large.y)
            .padding(DesignSystem.Spacing.lg)
            .transition(.scale.combined(with: .opacity))
            .onTapGesture {
                // Dismiss on tap outside
                withAnimation {
                    showGestureHint = false
                    hasSeenGestureHint = true
                }
            }
            
            Spacer()
        }
        .background(
            Color.black.opacity(DesignSystem.Opacity.medium)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        showGestureHint = false
                        hasSeenGestureHint = true
                    }
                }
        )
    }
    
    // MARK: - Accessibility
    
    private var workoutVoiceOverLabel: String {
        let exerciseName = engine.currentExercise?.name ?? "workout"
        let timeRemaining = Int(engine.timeRemaining)
        
        switch engine.phase {
        case .idle:
            return "Workout ready to start"
        case .preparing:
            return "Preparing to start workout. \(timeRemaining) seconds remaining."
        case .exercise:
            return "\(exerciseName). \(timeRemaining) seconds remaining."
        case .rest:
            return "Rest period. \(timeRemaining) seconds remaining. Get ready for the next exercise."
        case .completed:
            return "Workout completed successfully!"
        }
    }
}

// MARK: - Completion Stat Card (Master Designer Polish)

private struct CompletionStatCard: View {
    let value: String
    let label: String
    let icon: String
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            // Icon with premium styling
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
                
                // Subtle highlight
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

// MARK: - Stat Card (Master Designer Polish)

private struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            // Icon with premium styling
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
                .font(.system(size: 36, weight: .bold, design: .rounded))  // Enhanced hero metric typography
                .foregroundStyle(Theme.textPrimary)
                .monospacedDigit()
                .contentTransition(.numericText())
                .shadow(color: Theme.shadow.opacity(DesignSystem.Opacity.subtle * 0.5), 
                       radius: DesignSystem.Shadow.verySoft.radius * 0.5, 
                       x: 0, y: DesignSystem.Shadow.verySoft.y * 0.25)
            
            Text(title)
                .font(Theme.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.lg)
        .background(
            ZStack {
                // Base material
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                    .fill(.ultraThinMaterial)
                
                // Subtle gradient overlay
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
                // Refined border with gradient
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
            .overlay(
                // Subtle glow
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                    .stroke(color.opacity(DesignSystem.Opacity.glow * 0.6), lineWidth: DesignSystem.Border.hairline)
                    .blur(radius: 1)
            )
        )
        .softShadow()
    }
}

// MARK: - Symbol Effect Modifiers (iOS 17+ compatibility)

struct SymbolBounceModifier: ViewModifier {
    let trigger: AnyHashable
    
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content
                .symbolEffect(.bounce, value: trigger)
        } else {
            content
        }
    }
}

struct SymbolPulseModifier: ViewModifier {
    let trigger: Bool
    
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content
                .symbolEffect(.pulse, value: trigger)
        } else {
            content
        }
    }
}

// MARK: - Compatibility Extension for safeAreaPadding

extension View {
    /// Compatibility wrapper for safeAreaPadding that works on iOS 14+ and iOS 17+
    @ViewBuilder
    func safeAreaPaddingCompat(_ edge: Edge.Set = .all, _ length: CGFloat? = nil) -> some View {
        if #available(iOS 17.0, *) {
            self.safeAreaPadding(edge, length)
        } else {
            // Fallback: Use padding with safeAreaInsets
            self.padding(edge, length ?? 0)
        }
    }
}

