import Foundation

/// Agent 7: Motivational quotes for workouts
enum Quotes {
    static let all = [
        "Every workout is a step toward your best self.",
        "You don't have to be great to start, but you have to start to be great.",
        "The only bad workout is the one you didn't do.",
        "Strength doesn't come from what you can do. It comes from overcoming what you once thought you couldn't.",
        "Your body can do it. It's your mind you need to convince.",
        "7 minutes today is better than 0 minutes tomorrow.",
        "Progress, not perfection.",
        "The pain you feel today is the strength you feel tomorrow.",
        "Don't stop when you're tired. Stop when you're done.",
        "Sweat is just fat crying.",
        "You are stronger than you think.",
        "The best project you'll ever work on is you.",
        "Motivation gets you started. Habit keeps you going.",
        "It's not about having time. It's about making time.",
        "Fall in love with the process, and the results will come.",
        "The only workout you'll regret is the one you skipped.",
        "Your future self will thank you.",
        "Every champion was once a beginner.",
        "Success is the sum of small efforts repeated day in and day out.",
        "The hardest part is starting. Once you get going, it's easy.",
        "You've got this! 💪",
        "Push yourself because no one else is going to do it for you.",
        "Great things never come from comfort zones.",
        "Be stronger than your excuses.",
        "The difference between try and triumph is just a little 'umph'!",
        "Your workout is your me-time. Make it count.",
        "Sweat now, shine later.",
        "Fitness is not about being better than someone else. It's about being better than you used to be.",
        "The only way to do great work is to love what you do.",
        "You're one workout away from a good mood."
    ]

    static func today() -> String {
        let dayIndex = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return all[dayIndex % all.count]
    }
    
    static func random() -> String {
        return all.randomElement() ?? all[0]
    }
    
    /// Get a motivational message based on streak
    static func forStreak(_ streak: Int) -> String {
        switch streak {
        case 1:
            return "Great start! You've completed your first day. Keep it going!"
        case 7:
            return "🔥 Amazing! You've hit a 7-day streak! You're building a powerful habit."
        case 14:
            return "🌟 Incredible! Two weeks strong! You're unstoppable!"
        case 30:
            return "🎉 Phenomenal! 30 days of consistency! You've transformed your routine."
        case 50:
            return "💪 Outstanding! 50 days! You're a true fitness champion!"
        case 100:
            return "🏆 Legendary! 100 days! You've achieved something extraordinary!"
        default:
            if streak > 100 {
                return "🏅 Beyond incredible! \(streak) days strong! You're an inspiration!"
            } else if streak >= 30 {
                return "🌟 You're on fire! \(streak) days and counting!"
            } else if streak >= 7 {
                return "🔥 Amazing streak! \(streak) days strong!"
            } else {
                return "💪 Keep it up! Day \(streak) of your journey!"
            }
        }
    }
    
    /// Get a motivational message for workout completion
    static func forWorkoutCompletion(totalWorkouts: Int) -> String {
        switch totalWorkouts {
        case 1:
            return "🎉 First workout complete! You've taken the first step!"
        case 5:
            return "🌟 5 workouts done! You're building momentum!"
        case 10:
            return "🔥 10 workouts! You're on a roll!"
        case 25:
            return "💪 25 workouts! You're making this a habit!"
        case 50:
            return "🏆 50 workouts! You're unstoppable!"
        case 100:
            return "🏅 100 workouts! You're a fitness champion!"
        default:
            if totalWorkouts > 100 {
                return "🌟 Beyond amazing! \(totalWorkouts) workouts completed!"
            } else if totalWorkouts >= 50 {
                return "🔥 Incredible! \(totalWorkouts) workouts strong!"
            } else if totalWorkouts >= 10 {
                return "💪 Great progress! \(totalWorkouts) workouts done!"
            } else {
                return "🎉 Awesome! Keep going!"
            }
        }
    }
}
