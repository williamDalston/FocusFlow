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
    func getPersonalizedMessage(streak: Int, totalSessions: Int, sessionsThisWeek: Int) -> String? {
        var messages: [String] = []
        
        // Streak-based messages
        if streak > 0 {
            messages.append(Quotes.forStreak(streak))
        }
        
        // Weekly progress messages
        if sessionsThisWeek >= 7 {
            messages.append("🌟 Seven days of dedication! You've honored your commitment every single day. This is what transformation looks like.")
        } else if sessionsThisWeek >= 5 {
            messages.append("🔥 \(sessionsThisWeek) focus sessions this week! You're building momentum and proving that consistency creates change.")
        } else if sessionsThisWeek >= 3 {
            messages.append("💪 \(sessionsThisWeek) focus sessions completed this week! Each one is a step closer to your goals. Keep going!")
        }
        
        // Milestone messages
        if totalSessions > 0 && [5, 10, 25, 50, 100].contains(totalSessions) {
            messages.append(Quotes.forSessionCompletion(totalSessions: totalSessions))
        }
        
        return messages.randomElement()
    }
    
    /// Get a personalized message based on user's progress (deprecated - use getPersonalizedMessage with new parameters)
    func getPersonalizedMessage(streak: Int, totalWorkouts: Int, workoutsThisWeek: Int) -> String? {
        return getPersonalizedMessage(streak: streak, totalSessions: totalWorkouts, sessionsThisWeek: workoutsThisWeek)
    }
    
    /// Get encouragement message for when user hasn't completed a focus session today
    func getNoWorkoutTodayMessage() -> String {
        let messages = [
            "The best time to honor your commitment is now. Your future self is counting on the choices you make today.",
            "Remember why you started. That reason still matters, and it's waiting for you to take action right now.",
            "Just one focus session can change your entire day. You have the power to choose growth over comfort.",
            "Your mind is ready. Your focus is capable. The only thing standing between you and a focus session is a single decision.",
            "Every champion chooses to show up even when they don't feel like it. Today is your chance to be a champion.",
            "The version of you who completes this focus session is stronger than the version who doesn't. Which one will you choose?",
            "Progress isn't made in your comfort zone. Take that first step. Your discipline is stronger than your excuses.",
            "You've come this far. Don't let today be the day you stop. Your consistency is your superpower—use it."
        ]
        return messages.randomElement() ?? messages.first ?? "Keep pushing forward!"
    }
    
    /// Get motivational message for focus session completion
    func getSessionCompletionMessage(streak: Int, totalSessions: Int) -> String {
        var message = "🎉 Focus session complete! "
        
        if streak > 0 {
            message += Quotes.forStreak(streak)
        } else {
            message += Quotes.forSessionCompletion(totalSessions: totalSessions)
        }
        
        return message
    }
    
    /// Get motivational message for workout completion (deprecated - use getSessionCompletionMessage)
    func getWorkoutCompletionMessage(streak: Int, totalWorkouts: Int) -> String {
        return getSessionCompletionMessage(streak: streak, totalSessions: totalWorkouts)
    }
    
    /// Get reminder message based on time of day
    func getTimeBasedReminderMessage() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        let messages: [String]
        
        switch hour {
        case 5..<12:
            messages = [
                "Good morning! Start your day by investing in yourself. Your focus session is waiting.",
                "Morning is when champions are made. Take this time to set the tone for an extraordinary day.",
                "Rise and shine! Your mind is ready for focus, ready for growth. Time to honor your commitment.",
                "Every sunrise is a new beginning. Make this morning count with a focus session."
            ]
        case 12..<17:
            messages = [
                "Afternoon energy dip? Transform it into strength. Your focus session will recharge your mind.",
                "Perfect time for a midday reset. Give yourself the gift of focused time and renewed energy.",
                "Revitalize your afternoon with purpose. This focus session is a choice to prioritize your well-being.",
                "The middle of the day is when discipline shines brightest. Show yourself what you're made of."
            ]
        case 17..<22:
            messages = [
                "Evening focus time! Finish your day knowing you chose growth over comfort. That's how champions end their day.",
                "Unwind with intention. Your focus session is a celebration of what your mind can do.",
                "End your day on a high note. Every focus session completed is a victory, and this one is yours to claim.",
                "Evening is when you prove to yourself that your commitment matters more than your fatigue."
            ]
        default:
            messages = [
                "Late night dedication! Your commitment to yourself doesn't watch the clock. That's what makes you unstoppable.",
                "Night owl power! While others sleep, you're building your future self. Your discipline is inspiring.",
                "The late hours are when true dedication shows. You're here, ready to invest in yourself. That's powerful."
            ]
        }
        
        return messages.randomElement() ?? messages.first ?? "Keep pushing forward!"
    }
}


