import Foundation
import SwiftUI

/// Agent 7: Manages motivational messages and personalized encouragement
@MainActor
final class MotivationalMessageManager: ObservableObject {
    static let shared = MotivationalMessageManager()
    
    @Published var dailyQuote: String = ""
    @Published var personalizedMessage: String?
    
    private let lastQuoteDateKey = "motivation.lastQuoteDate"
    private let lastQuoteIndexKey = "motivation.lastQuoteIndex"
    
    private init() {
        loadDailyQuote()
    }
    
    /// Load or generate today's quote
    func loadDailyQuote() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastDate = UserDefaults.standard.object(forKey: lastQuoteDateKey) as? Date
        
        if let lastDate = lastDate, calendar.isDate(lastDate, inSameDayAs: today) {
            // Same day, use cached quote
            dailyQuote = UserDefaults.standard.string(forKey: "motivation.dailyQuote") ?? Quotes.today()
        } else {
            // New day, get new quote
            dailyQuote = Quotes.today()
            UserDefaults.standard.set(today, forKey: lastQuoteDateKey)
            UserDefaults.standard.set(dailyQuote, forKey: "motivation.dailyQuote")
        }
    }
    
    /// Get a personalized message based on user's progress
    func getPersonalizedMessage(streak: Int, totalWorkouts: Int, workoutsThisWeek: Int) -> String? {
        var messages: [String] = []
        
        // Streak-based messages
        if streak > 0 {
            messages.append(Quotes.forStreak(streak))
        }
        
        // Weekly progress messages
        if workoutsThisWeek >= 7 {
            messages.append("🌟 Seven days of dedication! You've honored your commitment every single day. This is what transformation looks like.")
        } else if workoutsThisWeek >= 5 {
            messages.append("🔥 \(workoutsThisWeek) workouts this week! You're building momentum and proving that consistency creates change.")
        } else if workoutsThisWeek >= 3 {
            messages.append("💪 \(workoutsThisWeek) workouts completed this week! Each one is a step closer to the person you're becoming. Keep going!")
        }
        
        // Milestone messages
        if totalWorkouts > 0 && [5, 10, 25, 50, 100].contains(totalWorkouts) {
            messages.append(Quotes.forWorkoutCompletion(totalWorkouts: totalWorkouts))
        }
        
        return messages.randomElement()
    }
    
    /// Get encouragement message for when user hasn't worked out today
    func getNoWorkoutTodayMessage() -> String {
        let messages = [
            "The best time to honor your commitment is now. Your future self is counting on the choices you make today.",
            "Remember why you started. That reason still matters, and it's waiting for you to take action right now.",
            "Just 7 minutes can change your entire day. You have the power to choose growth over comfort.",
            "Your body is ready. Your mind is capable. The only thing standing between you and your workout is a single decision.",
            "Every champion chooses to show up even when they don't feel like it. Today is your chance to be a champion.",
            "The version of you who completes this workout is stronger than the version who doesn't. Which one will you choose?",
            "Progress isn't made in your comfort zone. Take that first step. Your discipline is stronger than your excuses.",
            "You've come this far. Don't let today be the day you stop. Your consistency is your superpower—use it."
        ]
        return messages.randomElement() ?? messages[0]
    }
    
    /// Get motivational message for workout completion
    func getWorkoutCompletionMessage(streak: Int, totalWorkouts: Int) -> String {
        var message = "🎉 Workout complete! "
        
        if streak > 0 {
            message += Quotes.forStreak(streak)
        } else {
            message += Quotes.forWorkoutCompletion(totalWorkouts: totalWorkouts)
        }
        
        return message
    }
    
    /// Get reminder message based on time of day
    func getTimeBasedReminderMessage() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        let messages: [String]
        
        switch hour {
        case 5..<12:
            messages = [
                "Good morning! Start your day by investing in yourself. Your Ritual7 is waiting.",
                "Morning is when champions are made. Take these 7 minutes to set the tone for an extraordinary day.",
                "Rise and shine! Your body is ready for movement, your mind is ready for growth. Time to honor your commitment.",
                "Every sunrise is a new beginning. Make this morning count with your workout."
            ]
        case 12..<17:
            messages = [
                "Afternoon energy dip? Transform it into strength. Your Ritual7 will recharge both body and mind.",
                "Perfect time for a midday reset. Give yourself the gift of movement and renewed energy.",
                "Revitalize your afternoon with purpose. This workout is a choice to prioritize your well-being.",
                "The middle of the day is when discipline shines brightest. Show yourself what you're made of."
            ]
        case 17..<22:
            messages = [
                "Evening workout time! Finish your day knowing you chose growth over comfort. That's how champions end their day.",
                "Unwind with intention. Your Ritual7 is a celebration of what your body can do, not a punishment.",
                "End your day on a high note. Every workout completed is a victory, and this one is yours to claim.",
                "Evening is when you prove to yourself that your commitment matters more than your fatigue."
            ]
        default:
            messages = [
                "Late night dedication! Your commitment to yourself doesn't watch the clock. That's what makes you unstoppable.",
                "Night owl power! While others sleep, you're building your future self. Your discipline is inspiring.",
                "The late hours are when true dedication shows. You're here, ready to invest in yourself. That's powerful."
            ]
        }
        
        return messages.randomElement() ?? messages[0]
    }
}


