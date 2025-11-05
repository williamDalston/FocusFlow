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
}
