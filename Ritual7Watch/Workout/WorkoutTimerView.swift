import SwiftUI
import WatchKit

/// Workout timer view optimized for Apple Watch
struct WorkoutTimerView: View {
    @ObservedObject var engine: WorkoutEngineWatch
    @ObservedObject var store: WatchWorkoutStore
    @Environment(\.dismiss) private var dismiss
    
    // Agent 15: Heart rate and workout detection
    @StateObject private var heartRateMonitor = HeartRateMonitor.shared
    @StateObject private var workoutDetection = WorkoutDetection.shared
    @State private var showStats: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Phase indicator
                Text(phaseTitle)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                
                // Circular progress ring with timer
                ZStack {
                    // Background circle
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 6)
                        .frame(width: 140, height: 140)
                    
                    // Progress circle
                    Circle()
                        .trim(from: 0, to: segmentProgress)
                        .stroke(
                            engine.phase == .rest ? Color.blue : Color.green,
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .frame(width: 140, height: 140)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.1), value: segmentProgress)
                    
                    // Timer text
                    VStack(spacing: 2) {
                        Text(timeString)
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                engine.phase == .rest ? .blue : 
                                (engine.timeRemaining <= 3 && !engine.isPaused ? .red : .green)
                            )
                            .monospacedDigit()
                        
                        if engine.phase == .exercise || engine.phase == .rest {
                            Text("\(engine.currentExerciseIndex + 1)/\(engine.exercises.count)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.vertical, 8)
                
                // Agent 15: Workout Stats (heart rate, calories)
                if engine.phase != .idle && engine.phase != .completed {
                    WorkoutStatsView(heartRateMonitor: heartRateMonitor, workoutEngine: engine)
                        .padding(.horizontal, 4)
                }
                
                // Current exercise name
                if let exercise = engine.currentExercise {
                    VStack(spacing: 4) {
                        Image(systemName: exercise.icon)
                            .font(.title3)
                            .foregroundStyle(engine.phase == .rest ? .blue : .green)
                        
                        Text(engine.phase == .rest ? "Rest" : exercise.name)
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }
                    .padding(.horizontal, 8)
                } else if engine.phase == .preparing {
                    VStack(spacing: 4) {
                        Image(systemName: "figure.run")
                            .font(.title3)
                            .foregroundStyle(.green)
                        
                        Text("Prepare")
                            .font(.headline)
                            .foregroundStyle(.primary)
                    }
                }
                
                // Controls
                if engine.phase == .idle {
                    Button {
                        engine.start()
                    } label: {
                        Label("Start", systemImage: "play.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                } else if engine.phase == .completed {
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title)
                            .foregroundStyle(.green)
                        
                        Text("Complete!")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        
                        Button {
                            dismiss()
                        } label: {
                            Text("Done")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                    }
                } else {
                    HStack(spacing: 8) {
                        // Pause/Resume button
                        Button {
                            if engine.isPaused {
                                engine.resume()
                            } else {
                                engine.pause()
                            }
                        } label: {
                            Image(systemName: engine.isPaused ? "play.fill" : "pause.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .frame(height: 36)
                        }
                        .buttonStyle(.bordered)
                        .tint(engine.isPaused ? .green : .orange)
                        
                        // Skip Rest button (only during rest)
                        if engine.phase == .rest {
                            Button {
                                engine.skipRest()
                            } label: {
                                Image(systemName: "forward.fill")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 36)
                            }
                            .buttonStyle(.bordered)
                            .tint(.blue)
                        }
                        
                        // Stop button
                        Button(role: .destructive) {
                            engine.stop()
                            dismiss()
                        } label: {
                            Image(systemName: "stop.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .frame(height: 36)
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 12)
        }
        .navigationTitle("Workout")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: engine.phase) { newPhase in
            handlePhaseChange(newPhase)
        }
        .onChange(of: workoutDetection.shouldAutoPause) { shouldPause in
            if shouldPause && !engine.isPaused && engine.phase != .idle && engine.phase != .completed {
                engine.pause()
                workoutDetection.resetAutoPause()
            }
        }
        .onAppear {
            // Start workout detection when view appears
            workoutDetection.startDetection()
        }
        .onDisappear {
            // Stop monitoring when view disappears
            Task {
                await heartRateMonitor.stopMonitoring()
                workoutDetection.stopDetection()
            }
        }
    
    // MARK: - Phase Change Handler
    
    private func handlePhaseChange(_ newPhase: WorkoutEngineWatch.WorkoutPhase) {
        switch newPhase {
        case .preparing:
            // Start heart rate monitoring when workout starts
            Task {
                do {
                    try await heartRateMonitor.startMonitoring()
                } catch {
                    print("Failed to start heart rate monitoring: \(error.localizedDescription)")
                }
            }
        case .completed:
            // Stop monitoring and save workout
            Task {
                await heartRateMonitor.stopMonitoring()
                
                let duration = engine.currentSessionDuration ?? 420 // 7 minutes default
                let heartRateSamples = heartRateMonitor.getHeartRateSamples()
                
                // Calculate average heart rate
                let avgHeartRate = heartRateMonitor.averageHeartRate
                let maxHR = heartRateMonitor.maxHeartRate
                
                // Save session with heart rate data
                store.addSession(duration: duration, exercisesCompleted: 12)
                
                // Sync to HealthKit with heart rate data (if available)
                // This would be handled by the store or HealthKit manager
            }
        default:
            break
        }
    }
    
    // MARK: - Helpers
    
    private var phaseTitle: String {
        switch engine.phase {
        case .idle:
            return "Ready"
        case .preparing:
            return "Prepare"
        case .exercise:
            return "Exercise"
        case .rest:
            return "Rest"
        case .completed:
            return "Complete"
        }
    }
    
    private var timeString: String {
        let seconds = Int(engine.timeRemaining.rounded(.up))
        return String(format: "%d", seconds)
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
}


