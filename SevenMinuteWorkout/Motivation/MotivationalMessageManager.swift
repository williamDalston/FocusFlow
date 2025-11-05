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
            messages.append("🌟 Perfect week! You've worked out every day!")
        } else if workoutsThisWeek >= 5 {
            messages.append("🔥 Great week! \(workoutsThisWeek) workouts completed!")
        } else if workoutsThisWeek >= 3 {
            messages.append("💪 Good progress! \(workoutsThisWeek) workouts this week!")
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
            "You've got this! Time for your daily 7-minute workout.",
            "Don't let your streak break! Start your workout now.",
            "Remember why you started. Your future self will thank you.",
            "Just 7 minutes. That's all it takes to stay on track.",
            "Your body can do it. It's your mind you need to convince.",
            "Push through. You're stronger than you think."
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
                "Good morning! Start your day with a 7-minute workout.",
                "Morning energy boost! Time for your workout.",
                "Rise and shine! Your body is ready for movement."
            ]
        case 12..<17:
            messages = [
                "Afternoon energy dip? Boost it with a quick workout!",
                "Perfect time for a midday movement break.",
                "Revitalize your afternoon with a 7-minute workout."
            ]
        case 17..<22:
            messages = [
                "Evening workout time! Finish your day strong.",
                "Unwind with movement. Your 7-minute workout awaits.",
                "End your day on a high note with a workout."
            ]
        default:
            messages = [
                "Late night workout? Your dedication is inspiring!",
                "Night owl power! Time for your workout."
            ]
        }
        
        return messages.randomElement() ?? messages[0]
    }
}


