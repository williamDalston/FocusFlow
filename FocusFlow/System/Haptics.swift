import UIKit

/// Enhanced haptic feedback system for better mobile experience
enum Haptics {
    // Basic haptics
    static func tap()     { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
    static func gentle()  { UIImpactFeedbackGenerator(style: .soft).impactOccurred() }
    static func success() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
    
    // Workout-specific haptics with different intensities
    static func exerciseStart() {
        // Strong, motivating haptic for exercise start
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
        
        // Add a second quick tap for emphasis
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let secondGenerator = UIImpactFeedbackGenerator(style: .medium)
            secondGenerator.impactOccurred()
        }
    }
    
    static func restStart() {
        // Gentle haptic for rest period
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.prepare()
        generator.impactOccurred()
    }
    
    static func workoutComplete() {
        // Celebration pattern: success + medium + light
        let notificationGenerator = UINotificationFeedbackGenerator()
        notificationGenerator.prepare()
        notificationGenerator.notificationOccurred(.success)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
            mediumGenerator.impactOccurred()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let lightGenerator = UIImpactFeedbackGenerator(style: .light)
            lightGenerator.impactOccurred()
        }
    }
    
    static func phaseTransition() {
        // Medium haptic for phase transitions
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
    
    static func buttonPress() {
        // Light haptic for button presses throughout the app
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
    
    static func countdownTick() {
        // Very light haptic for countdown ticks
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred()
    }
    
    // Agent 7: Additional haptics for states and feedback
    static func error() {
        // Error haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
    }
    
    static func warning() {
        // Warning haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
    }
    
    static func refresh() {
        // Light haptic for pull-to-refresh
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
    
    // Phase transition haptics per Apple HIG + fitness app patterns
    static func medium() {
        // .medium at start/end of each phase per spec
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
    
    static func heavy() {
        // .heavy on final exercise per spec
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
    }
    
    // Agent 29: Enhanced phase transition haptics with distinct patterns
    static func phaseTransitionToExercise() {
        // Distinct pattern for transitioning to exercise: medium + quick light tap
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            let lightGenerator = UIImpactFeedbackGenerator(style: .light)
            lightGenerator.impactOccurred()
        }
    }
    
    static func phaseTransitionToRest() {
        // Softer pattern for rest transition: soft + gentle medium
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.prepare()
        generator.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
            mediumGenerator.impactOccurred()
        }
    }
    
    static func phaseTransitionToPrep() {
        // Light pattern for preparation phase
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
    
    // Agent 29: Haptic patterns for different workout events
    static func exerciseCompleted() {
        // Celebration pattern for completing an exercise: medium + success
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            let notificationGenerator = UINotificationFeedbackGenerator()
            notificationGenerator.prepare()
            notificationGenerator.notificationOccurred(.success)
        }
    }
    
    static func milestoneReached() {
        // Special pattern for milestones: heavy + medium + light (ascending pattern)
        let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
        heavyGenerator.prepare()
        heavyGenerator.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
            mediumGenerator.impactOccurred()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let lightGenerator = UIImpactFeedbackGenerator(style: .light)
            lightGenerator.impactOccurred()
        }
    }
    
    static func warningCountdown() {
        // Subtle pattern for countdown warnings (last 3 seconds)
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred()
    }
}
