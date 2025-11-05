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
    
    var body: some View {
        ZStack {
            ThemeBackground()
            VStack(spacing: 0) {
                progressBar
                scrollContent
            }
            completionOverlayIfNeeded
            ConfettiView(trigger: $showCompletionConfetti)
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
                let duration = engine.currentSessionDuration ?? 420 // 7 minutes default
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
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("appDidEnterBackground"))) { _ in
            // Agent 6: Handle background transition
            engine.handleBackgroundTransition()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("appDidBecomeActive"))) { _ in
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
                .animation(.linear, value: engine.progress)
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
                            }
                        } else if horizontalAmount < -50 {
                            // Swipe left: Skip rest (only during rest phase)
                            if engine.phase == .rest {
                                engine.skipRest()
                                Haptics.buttonPress()
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
        let duration = engine.currentSessionDuration ?? 420
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
                
                // Progress circle with premium gradient animation
                Circle()
                    .trim(from: 0, to: segmentProgress)
                    .stroke(
                        LinearGradient(
                            colors: [
                                engine.phase == .rest ? Theme.accentB : Theme.accentA,
                                engine.phase == .rest ? Theme.accentB.opacity(0.85) : Theme.accentA.opacity(0.85),
                                engine.phase == .rest ? Theme.accentC : Theme.accentB,
                                engine.phase == .rest ? Theme.accentB.opacity(0.7) : Theme.accentA.opacity(0.7)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round, lineJoin: .round)
                    )
                    .frame(width: 220, height: 220)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.1), value: segmentProgress)
                    .shadow(color: (engine.phase == .rest ? Theme.accentB : Theme.accentA).opacity(DesignSystem.Opacity.medium), radius: 12, x: 0, y: 6)
                    .shadow(color: Theme.glowColor.opacity(DesignSystem.Opacity.glow * 0.8), radius: 8, x: 0, y: 3)
                
                // Timer text with premium styling
                VStack(spacing: DesignSystem.Spacing.sm) {
                    Text(timeString)
                        .font(.system(size: 68, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    engine.phase == .rest ? Theme.accentB : 
                                    (engine.timeRemaining <= 3 && engine.phase != .idle && engine.phase != .preparing && !engine.isPaused ? .red : Theme.accentA),
                                    engine.phase == .rest ? Theme.accentB.opacity(0.9) : 
                                    (engine.timeRemaining <= 3 && engine.phase != .idle && engine.phase != .preparing && !engine.isPaused ? .red.opacity(0.9) : Theme.accentA.opacity(0.9))
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .monospacedDigit()
                        .contentTransition(.numericText())
                        .scaleEffect(engine.phase == .rest ? 0.95 : 1.0)
                        .shadow(color: (engine.phase == .rest ? Theme.accentB : Theme.accentA).opacity(DesignSystem.Opacity.glow * 0.8), radius: 8, x: 0, y: 2)
                        .animation(AnimationConstants.quickSpring, value: engine.phase)
                        .animation(AnimationConstants.quickSpring, value: engine.timeRemaining)
                        .bounce(trigger: engine.timeRemaining <= 1 && engine.timeRemaining > 0)
                        .accessibilityLabel("\(Int(engine.timeRemaining)) seconds remaining")
                        .accessibilityValue("\(engine.phase == .rest ? "Rest" : "Exercise")")
                }
            }
            .padding(.vertical, 16)
            
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
                VStack(spacing: 20) {
                    // Agent 11: Countdown animation
                    if engine.timeRemaining <= 3 && engine.timeRemaining > 0 {
                        PrepCountdownView(timeRemaining: engine.timeRemaining)
                            .frame(height: 200)
                    } else {
                        Image(systemName: "figure.run")
                            .font(.system(size: 64))
                            .foregroundStyle(Theme.accentA)
                            .modifier(SymbolBounceModifier(trigger: engine.timeRemaining))
                    }
                    
                    Text("Prepare to Start")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Theme.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    if let firstExercise = engine.nextExercise {
                        Text("First stage: \(firstExercise.name)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(24)
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
        VStack(spacing: 24) {
            // Agent 11: Breathing guide during rest
            BreathingGuideView(
                exercise: engine.nextExercise,
                duration: engine.restDuration
            )
            
            // Next exercise preview
            if let nextExercise = engine.nextExercise {
                GlassCard(material: .ultraThinMaterial) {
                    VStack(spacing: 16) {
                        Text("Next Exercise")
                            .font(.headline)
                            .foregroundStyle(Theme.textPrimary)
                        
                        Image(systemName: nextExercise.icon)
                            .font(.system(size: 48))
                            .foregroundStyle(Theme.accentA)
                        
                        Text(nextExercise.name)
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(Theme.textPrimary)
                        
                        Text(nextExercise.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(20)
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
        VStack(spacing: 20) {
            GlassCard(material: .ultraThinMaterial) {
                VStack(spacing: 20) {
                    // Exercise icon with Agent 11 animations
                    Image(systemName: exercise.icon)
                        .font(.system(size: 64))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    engine.phase == .exercise ? Theme.accentA : Theme.accentB,
                                    engine.phase == .exercise ? Theme.accentA.opacity(0.8) : Theme.accentB.opacity(0.8)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .modifier(SymbolBounceModifier(trigger: engine.currentExerciseIndex))
                        .modifier(SymbolPulseModifier(trigger: engine.phase == .exercise))
                        .scaleEffect(engine.phase == .exercise ? 1.0 : 0.9)
                        .animation(AnimationConstants.smoothSpring, value: engine.phase)
                        .shadow(color: (engine.phase == .exercise ? Theme.accentA : Theme.accentB).opacity(0.4), radius: 12, x: 0, y: 6)
                    
                    // Exercise name
                    Text(exercise.name)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Theme.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    // Description
                    Text(exercise.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    
                    // Agent 11: Rep counter
                    RepCounterView(repCounter: repCounter, exercise: exercise)
                    
                    // Instructions (shown during exercise)
                    Text(exercise.instructions)
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.leading)
                        .padding(.top, 8)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    
                    // Agent 11: Form feedback system
                    FormFeedbackSystem(
                        exercise: exercise,
                        timeRemaining: engine.timeRemaining
                    )
                }
                .padding(24)
            }
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
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
        VStack(spacing: DesignSystem.Spacing.lg) {
            if engine.phase == .idle {
                // Start button
                Button {
                    Haptics.buttonPress()
                    engine.start()
                } label: {
                    Label("Start Workout", systemImage: "play.fill")
                        .font(Theme.title3)
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
                                .frame(maxWidth: .infinity)
                                .frame(height: DesignSystem.ButtonSize.standard.height)
                        }
                        .buttonStyle(SecondaryGlassButtonStyle())
                    } else if engine.phase == .preparing {
                        Button {
                            Haptics.buttonPress()
                            engine.skipPrep()
                        } label: {
                            Label("Skip Prep", systemImage: "forward.fill")
                                .font(Theme.headline)
                                .frame(maxWidth: .infinity)
                                .frame(height: DesignSystem.ButtonSize.standard.height)
                        }
                        .buttonStyle(SecondaryGlassButtonStyle())
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
                        .frame(maxWidth: .infinity)
                        .frame(height: DesignSystem.ButtonSize.standard.height)
                }
                .buttonStyle(.bordered)
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
            Color.black.opacity(0.7)
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
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                }
                .buttonStyle(.bordered)
                .tint(.white)
                .foregroundStyle(.white)
                .padding(.top, 8)
                
                Button {
                    Haptics.buttonPress()
                    dismiss()
                } label: {
                    Text("Start a New Journey")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                }
                .buttonStyle(.borderedProminent)
                .tint(.white)
                .foregroundStyle(.black)
                .padding(.top, 8)
                }
                .padding(32)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
                .padding(.horizontal, 32)
                .padding(.vertical, 32)
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
                    .font(.title2)
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
                    .font(.title2)
                    .foregroundStyle(color)
                    .frame(width: DesignSystem.IconSize.statBox, height: DesignSystem.IconSize.statBox)
            }
            
            Text(value)
                .font(Theme.title2)
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

