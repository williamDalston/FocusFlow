import SwiftUI

/// Agent 4: Timer UI - Beautiful workout timer interface with exercise name, countdown, and progress
struct WorkoutTimerView: View {
    @ObservedObject var engine: WorkoutEngine
    @ObservedObject var store: WorkoutStore
    @EnvironmentObject private var theme: ThemeStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var showCompletionConfetti = false
    
    var body: some View {
        ZStack {
            ThemeBackground()
            
            VStack(spacing: 0) {
                // Progress bar at top
                if engine.phase != .idle && engine.phase != .completed {
                    ProgressView(value: engine.progress)
                        .tint(Theme.accentA)
                        .frame(height: 4)
                        .animation(.linear, value: engine.progress)
                }
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Main timer display with circular progress
                        timerSectionWithCircularProgress
                        
                        // Current exercise info or prep view
                        if engine.phase == .preparing {
                            prepView
                        } else if let exercise = engine.currentExercise {
                            exerciseCard(exercise: exercise)
                        }
                        
                        // Controls
                        controlsSection
                        
                        // Stats
                        if engine.phase != .idle {
                            statsSection
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 32)
                }
            }
            
            // Completion overlay
            if engine.phase == .completed {
                completionOverlay
            }
            
            ConfettiView(trigger: $showCompletionConfetti)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    if engine.phase != .idle {
                        engine.stop()
                    }
                    dismiss()
                }
                .foregroundStyle(Theme.accentA)
            }
        }
        .onChange(of: engine.phase) { newPhase in
            if newPhase == .completed {
                let duration = engine.currentSessionDuration ?? 420 // 7 minutes default
                store.addSession(duration: duration, exercisesCompleted: 12)
                showCompletionConfetti = true
                
                // Vibrate on completion
                Haptics.success()
            }
        }
        .onDisappear {
            // Reset engine when view disappears if not completed
            if engine.phase != .completed {
                engine.stop()
            }
        }
    }
    
    // MARK: - Timer Section with Circular Progress
    
    private var timerSectionWithCircularProgress: some View {
        VStack(spacing: 20) {
            // Phase indicator
            Text(phaseTitle)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(1)
            
            // Circular progress ring with timer
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 12)
                    .frame(width: 220, height: 220)
                
                // Progress circle
                Circle()
                    .trim(from: 0, to: segmentProgress)
                    .stroke(
                        engine.phase == .rest ? Theme.accentB : Theme.accentA,
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 220, height: 220)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.1), value: segmentProgress)
                
                // Timer text
                VStack(spacing: 8) {
                    Text(timeString)
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            engine.phase == .rest ? Theme.accentB : 
                            (engine.timeRemaining <= 3 && engine.phase != .idle && engine.phase != .preparing && !engine.isPaused ? .red : Theme.accentA)
                        )
                        .monospacedDigit()
                        .contentTransition(.numericText())
                        .scaleEffect(engine.phase == .rest ? 0.95 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: engine.phase)
                }
            }
            .padding(.vertical, 16)
            
            // Exercise counter or next exercise preview
            if engine.phase == .preparing {
                if let firstExercise = engine.nextExercise {
                    Text("First up: \(firstExercise.name)")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
            } else if engine.phase == .exercise || engine.phase == .rest {
                VStack(spacing: 4) {
                    Text("Stage \(stageNumber) of \(engine.exercises.count)")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    if let next = engine.nextExercise {
                        Text("Next: \(next.name)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary.opacity(0.8))
                    } else {
                        Text("Final stage!")
                            .font(.subheadline)
                            .foregroundStyle(.secondary.opacity(0.8))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
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
        GlassCard(material: .ultraThinMaterial) {
            VStack(spacing: 20) {
                Image(systemName: "figure.run")
                    .font(.system(size: 64))
                    .foregroundStyle(Theme.accentA)
                    .symbolEffect(.bounce, value: engine.timeRemaining)
                
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
    
    // MARK: - Exercise Card
    
    private func exerciseCard(exercise: Exercise) -> some View {
        GlassCard(material: .ultraThinMaterial) {
            VStack(spacing: 20) {
                // Exercise icon
                Image(systemName: exercise.icon)
                    .font(.system(size: 64))
                    .foregroundStyle(engine.phase == .exercise ? Theme.accentA : Theme.accentB)
                    .symbolEffect(.bounce, value: engine.currentExerciseIndex)
                    .scaleEffect(engine.phase == .exercise ? 1.0 : 0.9)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: engine.phase)
                
                // Exercise name
                Text(engine.phase == .rest ? "Breathe..." : exercise.name)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.center)
                
                // Description or rest message
                if engine.phase == .rest {
                    Text("Get ready for the next exercise")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                } else {
                    Text(exercise.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    
                    // Instructions (shown during exercise)
                    Text(exercise.instructions)
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.leading)
                        .padding(.top, 8)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .padding(24)
        }
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(engine.phase == .rest ? Theme.accentB.opacity(0.1) : Color.clear)
        )
        .animation(.easeInOut(duration: 0.3), value: engine.phase)
    }
    
    // MARK: - Controls Section
    
    private var controlsSection: some View {
        VStack(spacing: 16) {
            if engine.phase == .idle {
                // Start button
                Button {
                    engine.start()
                    Haptics.tap()
                } label: {
                    Label("Start Workout", systemImage: "play.fill")
                        .font(.title3.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                }
                .buttonStyle(PrimaryProminentButtonStyle())
            } else if engine.phase == .completed {
                // Workout completed
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(.green)
                    
                    Text("Workout Complete!")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Theme.textPrimary)
                }
                .padding(.vertical, 24)
            } else {
                // Pause/Resume and Skip Rest buttons
                HStack(spacing: 12) {
                    Button {
                        if engine.isPaused {
                            engine.resume()
                        } else {
                            engine.pause()
                        }
                        Haptics.tap()
                    } label: {
                        Label(engine.isPaused ? "Resume" : "Pause", 
                              systemImage: engine.isPaused ? "play.fill" : "pause.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                    }
                    .buttonStyle(SecondaryGlassButtonStyle())
                    
                    if engine.phase == .rest {
                        Button {
                            engine.skipRest()
                            Haptics.tap()
                        } label: {
                            Label("Skip Rest", systemImage: "forward.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                        }
                        .buttonStyle(SecondaryGlassButtonStyle())
                    } else if engine.phase == .preparing {
                        Button {
                            engine.skipPrep()
                            Haptics.tap()
                        } label: {
                            Label("Skip Prep", systemImage: "forward.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                        }
                        .buttonStyle(SecondaryGlassButtonStyle())
                    }
                }
                
                // Stop button
                Button(role: .destructive) {
                    engine.stop()
                    dismiss()
                } label: {
                    Text("Stop Workout")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                }
                .buttonStyle(.bordered)
            }
        }
    }
    
    // MARK: - Stats Section
    
    private var statsSection: some View {
        HStack(spacing: 20) {
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
            
            VStack(spacing: 24) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.green)
                
                Text("Journey Complete!")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(.white)
                
                Text("You've reached your destination for today.")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                
                // Streak message
                if store.streak > 0 {
                    Text("You're on a \(store.streak) day streak! 🔥")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.orange)
                        .padding(.top, 8)
                }
                
                // Stats grid
                let duration = engine.currentSessionDuration ?? 0
                let minutes = Int(duration) / 60
                let seconds = Int(duration) % 60
                let calories = engine.exercises.count * 5 // Rough estimate: 5 calories per exercise
                
                HStack(spacing: 20) {
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
                .padding(.top, 16)
                
                Button {
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
                .padding(.top, 16)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .padding(32)
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
}

// MARK: - Completion Stat Card

private struct CompletionStatCard: View {
    let value: String
    let label: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.white.opacity(0.9))
            
            Text(value)
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)
            
            Text(label)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.white.opacity(0.1))
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
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            Text(value)
                .font(.title2.weight(.bold))
                .foregroundStyle(Theme.textPrimary)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

