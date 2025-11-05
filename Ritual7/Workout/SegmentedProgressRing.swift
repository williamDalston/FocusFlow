import SwiftUI

/// Segmented Progress Ring - 12 segments showing workout progress per Apple HIG
/// Phase colors: Prepare = teal/blue, Work = violet/indigo, Rest = mint/green
struct SegmentedProgressRing: View {
    let totalSegments: Int
    let completedSegments: Int
    let currentSegmentProgress: Double // 0.0 to 1.0 for current segment
    let phase: WorkoutPhase
    let timeRemaining: TimeInterval
    
    // Phase colors per spec: Prepare (teal), Work (indigo), Rest (mint)
    private var prepareColor: Color {
        Color(red: 0.2, green: 0.7, blue: 0.8) // Teal
    }
    
    private var workColor: Color {
        Color(red: 0.3, green: 0.4, blue: 0.9) // Indigo
    }
    
    private var restColor: Color {
        Color(red: 0.4, green: 0.9, blue: 0.7) // Mint
    }
    
    private var phaseColor: Color {
        switch phase {
        case .preparing:
            return prepareColor
        case .exercise:
            return workColor
        case .rest:
            return restColor
        default:
            return Color.gray
        }
    }
    
    private let ringSize: CGFloat = 280
    private let ringWidth: CGFloat = 16
    private let segmentGap: CGFloat = 2
    
    var body: some View {
        ZStack {
            // Background ring (all segments)
            ForEach(0..<totalSegments, id: \.self) { index in
                SegmentView(
                    segmentIndex: index,
                    totalSegments: totalSegments,
                    ringSize: ringSize,
                    ringWidth: ringWidth,
                    segmentGap: segmentGap,
                    isCompleted: index < completedSegments,
                    isCurrent: index == completedSegments,
                    currentProgress: index == completedSegments ? currentSegmentProgress : 0,
                    color: phaseColor
                )
            }
            
            // Large remaining-seconds numeral inside ring (30-sec countdown, monospaced)
            Text(timeString)
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .foregroundStyle(phaseColor)
                .monospacedDigit()
                .contentTransition(.numericText())
                .accessibilityLabel("\(Int(timeRemaining)) seconds remaining")
        }
        .frame(width: ringSize, height: ringSize)
        .overlay(alignment: .bottom) {
            // Text under ring: "Step 1 of 12 · 00:30" per spec
            VStack(spacing: DesignSystem.Spacing.xs) {
                let currentStep = completedSegments + 1
                Text("Step \(currentStep) of \(totalSegments) · \(formatTime(timeRemaining))")
                    .font(Theme.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)
                    .monospacedDigit()
                
                // Now/Next line
                if let currentExercise = currentExercise {
                    Text("Now: \(currentExercise.name)")
                        .font(Theme.caption)
                        .foregroundStyle(.secondary)
                }
                
                if let nextExercise = nextExercise {
                    Text("Next: \(nextExercise.name)")
                        .font(Theme.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.top, DesignSystem.Spacing.md)
        }
        .frame(height: ringSize + DesignSystem.Spacing.xl) // Add space for text below
        .crossfadeTransition(duration: 0.2) // 180-220ms crossfade per spec
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }
    
    let currentExercise: Exercise?
    let nextExercise: Exercise?
    
    init(
        totalSegments: Int = 12,
        completedSegments: Int,
        currentSegmentProgress: Double,
        phase: WorkoutPhase,
        timeRemaining: TimeInterval,
        currentExercise: Exercise? = nil,
        nextExercise: Exercise? = nil
    ) {
        self.totalSegments = totalSegments
        self.completedSegments = completedSegments
        self.currentSegmentProgress = currentSegmentProgress
        self.phase = phase
        self.timeRemaining = timeRemaining
        self.currentExercise = currentExercise
        self.nextExercise = nextExercise
    }
    
    private var timeString: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        if minutes > 0 {
            return String(format: "%d:%02d", minutes, seconds)
        } else {
            return String(format: "%d", seconds)
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let seconds = Int(time)
        return "0:\(String(format: "%02d", seconds))"
    }
    
    private var accessibilityLabel: String {
        let segmentNumber = completedSegments + 1
        let exerciseName = currentExercise?.name ?? "Exercise"
        return "Step \(segmentNumber) of \(totalSegments), \(Int(timeRemaining)) seconds remaining, \(exerciseName)"
    }
}

/// Individual segment view for the progress ring
private struct SegmentView: View {
    let segmentIndex: Int
    let totalSegments: Int
    let ringSize: CGFloat
    let ringWidth: CGFloat
    let segmentGap: CGFloat
    let isCompleted: Bool
    let isCurrent: Bool
    let currentProgress: Double
    let color: Color
    
    private var anglePerSegment: Double {
        360.0 / Double(totalSegments)
    }
    
    private var segmentAngle: Double {
        anglePerSegment - Double(segmentGap) * 2.0 / (ringSize / 2) * 180.0 / .pi
    }
    
    private var startAngle: Double {
        Double(segmentIndex) * anglePerSegment - 90.0
    }
    
    var body: some View {
        ZStack {
            // Background segment (always visible)
            Circle()
                .trim(from: 0, to: segmentAngle / 360.0)
                .stroke(
                    Color.gray.opacity(0.2),
                    style: StrokeStyle(lineWidth: ringWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(startAngle))
            
            // Completed segment
            if isCompleted {
                Circle()
                    .trim(from: 0, to: segmentAngle / 360.0)
                    .stroke(
                        color,
                        style: StrokeStyle(lineWidth: ringWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(startAngle))
            }
            
            // Current segment (with progress)
            if isCurrent {
                Circle()
                    .trim(from: 0, to: (segmentAngle / 360.0) * currentProgress)
                    .stroke(
                        color,
                        style: StrokeStyle(lineWidth: ringWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(startAngle))
                    .animation(.linear(duration: 0.1), value: currentProgress)
            }
        }
    }
}

