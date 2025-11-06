import Foundation
import SwiftUI

/// Agent 7: Motivational Quotes Manager - Manages motivational quotes shown during breaks
class MotivationalQuotesManager {
    static let shared = MotivationalQuotesManager()
    
    private let quotes: [FocusMotivationalQuote] = [
        FocusMotivationalQuote(
            text: "The way to get started is to quit talking and begin doing.",
            author: "Walt Disney"
        ),
        FocusMotivationalQuote(
            text: "Focus on being productive instead of busy.",
            author: "Tim Ferriss"
        ),
        FocusMotivationalQuote(
            text: "Concentration is the secret of strength.",
            author: "Ralph Waldo Emerson"
        ),
        FocusMotivationalQuote(
            text: "The successful warrior is the average man with laser-like focus.",
            author: "Bruce Lee"
        ),
        FocusMotivationalQuote(
            text: "You don't have to be great to start, but you have to start to be great.",
            author: "Zig Ziglar"
        ),
        FocusMotivationalQuote(
            text: "The future depends on what you do today.",
            author: "Mahatma Gandhi"
        ),
        FocusMotivationalQuote(
            text: "Focus is saying no to a hundred good ideas.",
            author: "Steve Jobs"
        ),
        FocusMotivationalQuote(
            text: "Progress, not perfection.",
            author: "Unknown"
        ),
        FocusMotivationalQuote(
            text: "The secret of getting ahead is getting started.",
            author: "Mark Twain"
        ),
        FocusMotivationalQuote(
            text: "Small steps every day lead to big results.",
            author: "Unknown"
        ),
        FocusMotivationalQuote(
            text: "Concentrate all your thoughts upon the work at hand. The sun's rays do not burn until brought to a focus.",
            author: "Alexander Graham Bell"
        ),
        FocusMotivationalQuote(
            text: "It's not about time, it's about energy and focus.",
            author: "Gary Keller"
        ),
        FocusMotivationalQuote(
            text: "Discipline is choosing between what you want now and what you want most.",
            author: "Abraham Lincoln"
        ),
        FocusMotivationalQuote(
            text: "The best time to plant a tree was 20 years ago. The second best time is now.",
            author: "Chinese Proverb"
        ),
        FocusMotivationalQuote(
            text: "Focus on the journey, not the destination.",
            author: "Greg Anderson"
        ),
        FocusMotivationalQuote(
            text: "Success is the sum of small efforts repeated day in and day out.",
            author: "Robert Collier"
        ),
        FocusMotivationalQuote(
            text: "You are what you do, not what you say you'll do.",
            author: "Carl Jung"
        ),
        FocusMotivationalQuote(
            text: "The only way to do great work is to love what you do.",
            author: "Steve Jobs"
        ),
        FocusMotivationalQuote(
            text: "Don't watch the clock; do what it does. Keep going.",
            author: "Sam Levenson"
        ),
        FocusMotivationalQuote(
            text: "Focus on progress, not perfection.",
            author: "Unknown"
        ),
        FocusMotivationalQuote(
            text: "Productivity is never an accident. It is always the result of a commitment to excellence, intelligent planning, and focused effort.",
            author: "Paul J. Meyer"
        ),
        FocusMotivationalQuote(
            text: "Concentration and mental toughness are the margins of victory.",
            author: "Bill Russell"
        ),
        FocusMotivationalQuote(
            text: "The most successful people are those who are good at plan B.",
            author: "James Yorke"
        ),
        FocusMotivationalQuote(
            text: "Focus on solutions, not problems.",
            author: "Unknown"
        ),
        FocusMotivationalQuote(
            text: "The future belongs to those who believe in the beauty of their dreams.",
            author: "Eleanor Roosevelt"
        ),
        FocusMotivationalQuote(
            text: "You can't have a million-dollar dream with a minimum-wage work ethic.",
            author: "Stephen C. Hogan"
        ),
        FocusMotivationalQuote(
            text: "The only limit to our realization of tomorrow will be our doubts of today.",
            author: "Franklin D. Roosevelt"
        ),
        FocusMotivationalQuote(
            text: "It does not matter how slowly you go as long as you do not stop.",
            author: "Confucius"
        ),
        FocusMotivationalQuote(
            text: "The best preparation for tomorrow is doing your best today.",
            author: "H. Jackson Brown Jr."
        )
    ]
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Get a random motivational quote
    func randomQuote() -> FocusMotivationalQuote {
        quotes.randomElement() ?? quotes[0]
    }
    
    /// Get all quotes
    func allQuotes() -> [FocusMotivationalQuote] {
        quotes
    }
    
    /// Get a quote for a specific mood or context
    func quoteForContext(_ context: QuoteContext) -> FocusMotivationalQuote {
        // For now, just return a random quote
        // Could be enhanced to filter by context
        return randomQuote()
    }
}

// MARK: - Motivational Quote

struct FocusMotivationalQuote: Identifiable {
    let id = UUID()
    let text: String
    let author: String
}

// MARK: - Quote Context

enum QuoteContext {
    case startOfDay
    case afterBreak
    case midSession
    case endOfDay
    case motivation
}

