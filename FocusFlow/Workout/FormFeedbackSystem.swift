import Foundation
import SwiftUI

/// Agent 11: Form Feedback System - Provides real-time form guidance during exercises
/// Shows visual cues and tips for proper exercise form

struct FormFeedbackSystem: View {
    let exercise: Exercise
    let timeRemaining: TimeInterval
    @State private var currentTipIndex: Int = 0
    @State private var showTip: Bool = false
    
    private var tips: [String] {
        getFormTips(for: exercise)
    }
    
    var body: some View {
        if !tips.isEmpty && showTip {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.caption)
                    
                    Text("Form Tip")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.textPrimary)
                }
                
                Text(tips[currentTipIndex])
                    .font(Theme.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(DesignSystem.Spacing.md)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous)
                        .fill(.ultraThinMaterial)
                    
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.green.opacity(DesignSystem.Opacity.highlight * 0.5),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .blendMode(.overlay)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.green.opacity(DesignSystem.Opacity.light * 1.5),
                                    Color.green.opacity(DesignSystem.Opacity.subtle),
                                    Color.green.opacity(DesignSystem.Opacity.light * 1.5)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: DesignSystem.Border.standard
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous)
                        .stroke(Color.green.opacity(DesignSystem.Opacity.glow * 0.8), lineWidth: DesignSystem.Border.hairline)
                        .blur(radius: 1)
                )
            )
            .softShadow()
            .transition(.scale.combined(with: .opacity))
        }
    }
    
    private func getFormTips(for exercise: Exercise) -> [String] {
        switch exercise.name {
        case "Jumping Jacks":
            return [
                "Land softly on your toes to protect your joints",
                "Keep your arms fully extended overhead",
                "Maintain a steady rhythm"
            ]
        case "Wall Sit":
            return [
                "Keep your back flat against the wall",
                "Ensure your knees are at 90 degrees",
                "Don't let your knees go past your toes"
            ]
        case "Push-up":
            return [
                "Keep your core engaged throughout",
                "Lower until your chest nearly touches the floor",
                "Keep your body in a straight line"
            ]
        case "Abdominal Crunch":
            return [
                "Don't pull on your neck with your hands",
                "Lift with your abs, not your neck",
                "Keep your lower back on the ground"
            ]
        case "Squat":
            return [
                "Keep your weight in your heels",
                "Don't let your knees go past your toes",
                "Lower as if sitting in a chair"
            ]
        case "Plank":
            return [
                "Keep your body in a straight line",
                "Don't let your hips sag or rise",
                "Engage your core throughout"
            ]
        case "Lunge":
            return [
                "Keep your front knee over your ankle",
                "Don't let your front knee go past your toes",
                "Keep your torso upright"
            ]
        case "Push-up and Rotation":
            return [
                "Complete the push-up with proper form first",
                "Rotate your whole body, not just your arms",
                "Keep your core engaged during rotation"
            ]
        case "Side Plank":
            return [
                "Keep your body in a straight line",
                "Don't let your hips sag",
                "Engage your core and glutes"
            ]
        default:
            return [
                "Focus on proper form over speed",
                "Breathe steadily throughout",
                "Listen to your body"
            ]
        }
    }
}

extension FormFeedbackSystem {
    func showTip(at index: Int) -> some View {
        var view = self
        view._currentTipIndex = State(initialValue: index)
        view._showTip = State(initialValue: true)
        return view
    }
    
    func hideTip() -> some View {
        var view = self
        view._showTip = State(initialValue: false)
        return view
    }
}

