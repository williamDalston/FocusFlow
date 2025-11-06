import SwiftUI
import WatchKit

/// Focus timer view optimized for Apple Watch
/// Refactored from WorkoutTimerView for Pomodoro Timer app
/// Agent 14: Enhanced spacing for better visual comfort
struct FocusTimerView: View {
    @ObservedObject var engine: PomodoroEngineWatch
    @ObservedObject var store: WatchFocusStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var showStats: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.comfortable) {
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
                            phaseColor,
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .frame(width: 140, height: 140)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.1), value: segmentProgress)
                    
                    // Timer text
                    VStack(spacing: DesignSystem.Spacing.tight) {
                        Text(timeString)
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                engine.timeRemaining <= 3 && !engine.isPaused && engine.phase == .focus ? .red : phaseColor
                            )
                            .monospacedDigit()
                        
                        if engine.phase == .focus {
                            Text("Session \(engine.currentSessionNumber)/\(engine.cycleLength)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.vertical, DesignSystem.Spacing.xs)
                
                // Phase description
                VStack(spacing: DesignSystem.Spacing.tight) {
                    Image(systemName: phaseIcon)
                        .font(.title3)
                        .foregroundStyle(phaseColor)
                    
                    Text(phaseDescription)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
                .padding(.horizontal, DesignSystem.Spacing.xs)
                
                // Controls
                if engine.phase == .idle {
                    Button {
                        engine.start()
                    } label: {
                        Label("Start Focus", systemImage: "play.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                } else if engine.phase == .completed {
                    VStack(spacing: DesignSystem.Spacing.xs) {
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
                    HStack(spacing: DesignSystem.Spacing.xs) {
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
                        
                        // Skip Break button (only during breaks)
                        if engine.phase == .shortBreak || engine.phase == .longBreak {
                            Button {
                                engine.skipBreak()
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
            .padding(.horizontal, DesignSystem.Spacing.xs)
            .padding(.vertical, DesignSystem.Spacing.comfortable)
        }
        .navigationTitle("Focus")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: engine.phase) { newPhase in
            handlePhaseChange(newPhase)
        }
        // Note: Digital crown integration would be implemented here for future enhancement
        // This would allow users to adjust timer duration using the digital crown
    }
    
    // MARK: - Phase Change Handler
    
    private func handlePhaseChange(_ newPhase: PomodoroPhase) {
        switch newPhase {
        case .focus:
            // Focus session started
            break
        case .completed:
            // Session completed - save to store
            if let duration = engine.currentSessionDuration {
                store.addSession(
                    duration: duration,
                    phaseType: .focus,
                    completed: true
                )
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
        case .focus:
            return "Focus"
        case .shortBreak:
            return "Short Break"
        case .longBreak:
            return "Long Break"
        case .completed:
            return "Complete"
        }
    }
    
    private var phaseDescription: String {
        switch engine.phase {
        case .idle:
            return "Ready to Focus"
        case .focus:
            return "Stay Focused"
        case .shortBreak:
            return "Take a Break"
        case .longBreak:
            return "Long Break Time"
        case .completed:
            return "Session Complete"
        }
    }
    
    private var phaseIcon: String {
        switch engine.phase {
        case .idle:
            return "brain.head.profile"
        case .focus:
            return "brain.head.profile"
        case .shortBreak:
            return "cup.and.saucer"
        case .longBreak:
            return "cup.and.saucer.fill"
        case .completed:
            return "checkmark.circle.fill"
        }
    }
    
    private var phaseColor: Color {
        switch engine.phase {
        case .idle:
            return .blue
        case .focus:
            return .blue
        case .shortBreak:
            return .green
        case .longBreak:
            return .green
        case .completed:
            return .green
        }
    }
    
    private var timeString: String {
        let minutes = Int(engine.timeRemaining) / 60
        let seconds = Int(engine.timeRemaining) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private var segmentProgress: Double {
        guard engine.phase != .idle && engine.phase != .completed else { return 0 }
        
        let segmentDuration: TimeInterval
        switch engine.phase {
        case .focus:
            segmentDuration = engine.focusDuration
        case .shortBreak:
            segmentDuration = engine.shortBreakDuration
        case .longBreak:
            segmentDuration = engine.longBreakDuration
        default:
            return 0
        }
        
        guard segmentDuration > 0 else { return 0 }
        return 1.0 - (engine.timeRemaining / segmentDuration)
    }
}

