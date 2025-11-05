import SwiftUI

/// Agent 4 & 8 & 11: Timer UI - Beautiful workout timer interface with exercise name, countdown, and progress
/// Enhanced with smooth animations, micro-interactions, and Agent 11 features
struct WorkoutTimerView: View {
    @ObservedObject var engine: WorkoutEngine
    @ObservedObject var store: WorkoutStore
    @EnvironmentObject private var theme: ThemeStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var showCompletionConfetti = false
    @StateObject private var repCounter = RepCounter()
    @StateObject private var voiceCues = VoiceCuesManager.shared
    @State private var showCompletionCelebration = false
    @AppStorage("hasSeenGestureHint") private var hasSeenGestureHint = false
    @State private var showGestureHint = false
    
    var body: some View {
        ZStack {
            ThemeBackground()
            VStack(spacing: 0) {
                progressBar
                scrollContent
            }
            completionOverlayIfNeeded
            ConfettiView(trigger: $showCompletionConfetti)
            
            // Gesture hints overlay
            if showGestureHint {
                gestureHintsOverlay
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // Lock rotation to portrait during workout
            ToolbarItem(placement: .principal) {
                EmptyView()
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    Haptics.buttonPress()
                    if engine.phase != .idle {
                        engine.stop()
                    }
                    dismiss()
                }
                .foregroundStyle(Theme.accentA)
                .accessibilityLabel("Done")
                .accessibilityHint("Double tap to close the workout view")
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(workoutVoiceOverLabel)
        .dynamicTypeSize(...DynamicTypeSize.accessibility5)
        .onChange(of: engine.phase) { newPhase in
            if newPhase == .completed {
                let duration = engine.currentSessionDuration ?? AppConstants.TimingConstants.defaultWorkoutDuration
                // Get start date from engine
                let startDate = engine.sessionStartDate ?? Date().addingTimeInterval(-duration)
                store.addSession(duration: duration, exercisesCompleted: 12, startDate: startDate)
                showCompletionConfetti = true
                showCompletionCelebration = true
                
                // Agent 11: Voice cue for completion
                let stats = WorkoutStats(
                    exercisesCompleted: engine.exercises.count,
                    duration: duration
                )
                voiceCues.speakCompletion(stats: stats)
                
                // Vibrate on completion
                Haptics.success()
            } else if newPhase == .exercise {
                // Agent 11: Start rep counting for new exercise
                if let exercise = engine.currentExercise {
                    repCounter.startTracking(for: exercise)
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
            VStack(spacing: DesignSystem.Spacing.xxl) {
                timerSectionWithCircularProgress
                exerciseOrPrepView
                controlsSection
                statsSectionIfNeeded
            }
            .padding(.horizontal, DesignSystem.Spacing.xl)
            .padding(.vertical, DesignSystem.Spacing.xxl)
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
    
    @ViewBuilder
    private var exerciseOrPrepView: some View {
        if engine.phase == .preparing {
            prepView
        } else if engine.phase == .rest {
            restView
        } else if let exercise = engine.currentExercise {
            exerciseCard(exercise: exercise)
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
                .font(Theme.title3)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(DesignSystem.Typography.uppercaseTracking)
            
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
    
    private var segmentProgress: Double {
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
                        .font(Theme.title2)
                        .foregroundStyle(Theme.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    if let firstExercise = engine.nextExercise {
                        Text("First stage: \(firstExercise.name)")
                            .font(Theme.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
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
                            .foregroundStyle(.secondary)
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
                        .animation(AnimationConstants.smoothSpring, value: engine.phase)
                        .shadow(color: (engine.phase == .exercise ? Theme.accentA : Theme.accentB).opacity(DesignSystem.Opacity.medium), radius: DesignSystem.Shadow.verySoft.radius * 1.5, x: 0, y: DesignSystem.Shadow.verySoft.y * 1.5)
                    
                    // Exercise name
                    Text(exercise.name)
                        .font(Theme.title2.weight(.bold))
                        .foregroundStyle(Theme.textPrimary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(DesignSystem.Typography.titleLineHeight - 1.0)
                    
                    // Description
                    Text(exercise.description)
                        .font(Theme.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(DesignSystem.Typography.bodyLineHeight - 1.0)
                    
                    // Agent 11: Rep counter
                    RepCounterView(repCounter: repCounter, exercise: exercise)
                    
                    // Instructions (shown during exercise)
                    Text(exercise.instructions)
                        .font(Theme.caption)
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(DesignSystem.Typography.captionLineHeight - 1.0)
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
            // Agent 11: Start rep counting and voice cues
            repCounter.startTracking(for: exercise)
            voiceCues.speakExerciseTransition(to: exercise, phase: .exercise)
            voiceCues.speakFormGuidance(for: exercise)
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
                    Label("Start Workout", systemImage: "play.fill")
                        .font(Theme.title3)
                        .fontWeight(DesignSystem.Typography.headlineWeight)
                        .frame(maxWidth: .infinity)
                        .frame(height: DesignSystem.ButtonSize.large.height)
                }
                .buttonStyle(PrimaryProminentButtonStyle())
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
                        Label(engine.isPaused ? "Resume" : "Pause", 
                              systemImage: engine.isPaused ? "play.fill" : "pause.fill")
                            .font(Theme.headline)
                            .fontWeight(DesignSystem.Typography.headlineWeight)
                            .frame(maxWidth: .infinity)
                            .frame(height: DesignSystem.ButtonSize.standard.height)
                    }
                    .buttonStyle(SecondaryGlassButtonStyle())
                    .accessibilityLabel(engine.isPaused ? "Resume workout" : "Pause workout")
                    .accessibilityHint("Double tap to \(engine.isPaused ? "resume" : "pause") the workout")
                    
                    if engine.phase == .rest {
                        Button {
                            Haptics.buttonPress()
                            engine.skipRest()
                        } label: {
                            Label("Skip Rest", systemImage: "forward.fill")
                                .font(Theme.headline)
                                .fontWeight(DesignSystem.Typography.headlineWeight)
                                .frame(maxWidth: .infinity)
                                .frame(height: DesignSystem.ButtonSize.standard.height)
                        }
                        .buttonStyle(SecondaryGlassButtonStyle())
                        .accessibilityLabel("Skip Rest")
                        .accessibilityHint("Double tap to skip the rest period and move to the next exercise.")
                        .accessibilityAddTraits(.isButton)
                    } else if engine.phase == .preparing {
                        Button {
                            Haptics.buttonPress()
                            engine.skipPrep()
                        } label: {
                            Label("Skip Prep", systemImage: "forward.fill")
                                .font(Theme.headline)
                                .fontWeight(DesignSystem.Typography.headlineWeight)
                                .frame(maxWidth: .infinity)
                                .frame(height: DesignSystem.ButtonSize.standard.height)
                        }
                        .buttonStyle(SecondaryGlassButtonStyle())
                        .accessibilityLabel("Skip Preparation")
                        .accessibilityHint("Double tap to skip the preparation countdown and start the workout immediately.")
                        .accessibilityAddTraits(.isButton)
                    }
                }
                
                // Stop button
                Button(role: .destructive) {
                    Haptics.buttonPress()
                    engine.stop()
                    dismiss()
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
            return "Get Ready"
        case .preparing:
            return "The Journey Begins"
        case .exercise:
            return "Stage \(engine.currentExerciseIndex + 1) of \(engine.exercises.count)"
        case .rest:
            return "Rest Stop"
        case .completed:
            return "Complete"
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
                            .font(.title2)
                            .foregroundStyle(Theme.accentA)
                            .modifier(SymbolBounceModifier(trigger: showGestureHint))
                        
                        Text("Swipe right to pause")
                            .font(Theme.subheadline)
                            .foregroundStyle(.white)
                        
                        Image(systemName: "arrow.right")
                            .font(.title2)
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
                            .font(.title2)
                            .foregroundStyle(Theme.accentB)
                            .modifier(SymbolBounceModifier(trigger: showGestureHint))
                        
                        Text("Swipe left to skip rest")
                            .font(Theme.subheadline)
                            .foregroundStyle(.white)
                        
                        Image(systemName: "arrow.right")
                            .font(.title2)
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

