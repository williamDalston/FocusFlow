import Foundation
import SwiftUI

/// Agent 7: Motivational Quotes Manager - Manages motivational quotes shown during breaks
class MotivationalQuotesManager {
    static let shared = MotivationalQuotesManager()
    
    private let quotes: [MotivationalQuote] = [
        MotivationalQuote(
            text: "The way to get started is to quit talking and begin doing.",
            author: "Walt Disney"
        ),
        MotivationalQuote(
            text: "Focus on being productive instead of busy.",
            author: "Tim Ferriss"
        ),
        MotivationalQuote(
            text: "Concentration is the secret of strength.",
            author: "Ralph Waldo Emerson"
        ),
        MotivationalQuote(
            text: "The successful warrior is the average man with laser-like focus.",
            author: "Bruce Lee"
        ),
        MotivationalQuote(
            text: "You don't have to be great to start, but you have to start to be great.",
            author: "Zig Ziglar"
        ),
        MotivationalQuote(
            text: "The future depends on what you do today.",
            author: "Mahatma Gandhi"
        ),
        MotivationalQuote(
            text: "Focus is saying no to a hundred good ideas.",
            author: "Steve Jobs"
        ),
        MotivationalQuote(
            text: "Progress, not perfection.",
            author: "Unknown"
        ),
        MotivationalQuote(
            text: "The secret of getting ahead is getting started.",
            author: "Mark Twain"
        ),
        MotivationalQuote(
            text: "Small steps every day lead to big results.",
            author: "Unknown"
        ),
        MotivationalQuote(
            text: "Concentrate all your thoughts upon the work at hand. The sun's rays do not burn until brought to a focus.",
            author: "Alexander Graham Bell"
        ),
        MotivationalQuote(
            text: "It's not about time, it's about energy and focus.",
            author: "Gary Keller"
        ),
        MotivationalQuote(
            text: "Discipline is choosing between what you want now and what you want most.",
            author: "Abraham Lincoln"
        ),
        MotivationalQuote(
            text: "The best time to plant a tree was 20 years ago. The second best time is now.",
            author: "Chinese Proverb"
        ),
        MotivationalQuote(
            text: "Focus on the journey, not the destination.",
            author: "Greg Anderson"
        ),
        MotivationalQuote(
            text: "Success is the sum of small efforts repeated day in and day out.",
            author: "Robert Collier"
        ),
        MotivationalQuote(
            text: "You are what you do, not what you say you'll do.",
            author: "Carl Jung"
        ),
        MotivationalQuote(
            text: "The only way to do great work is to love what you do.",
            author: "Steve Jobs"
        ),
        MotivationalQuote(
            text: "Don't watch the clock; do what it does. Keep going.",
            author: "Sam Levenson"
        ),
        MotivationalQuote(
            text: "Focus on progress, not perfection.",
            author: "Unknown"
        ),
        MotivationalQuote(
            text: "Productivity is never an accident. It is always the result of a commitment to excellence, intelligent planning, and focused effort.",
            author: "Paul J. Meyer"
        ),
        MotivationalQuote(
            text: "Concentration and mental toughness are the margins of victory.",
            author: "Bill Russell"
        ),
        MotivationalQuote(
            text: "The most successful people are those who are good at plan B.",
            author: "James Yorke"
        ),
        MotivationalQuote(
            text: "Focus on solutions, not problems.",
            author: "Unknown"
        ),
        MotivationalQuote(
            text: "The future belongs to those who believe in the beauty of their dreams.",
            author: "Eleanor Roosevelt"
        ),
        MotivationalQuote(
            text: "You can't have a million-dollar dream with a minimum-wage work ethic.",
            author: "Stephen C. Hogan"
        ),
        MotivationalQuote(
            text: "The only limit to our realization of tomorrow will be our doubts of today.",
            author: "Franklin D. Roosevelt"
        ),
        MotivationalQuote(
            text: "It does not matter how slowly you go as long as you do not stop.",
            author: "Confucius"
        ),
        MotivationalQuote(
            text: "The best preparation for tomorrow is doing your best today.",
            author: "H. Jackson Brown Jr."
        )
    ]
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Get a random motivational quote
    func randomQuote() -> MotivationalQuote {
        quotes.randomElement() ?? quotes[0]
    }
    
    /// Get all quotes
    func allQuotes() -> [MotivationalQuote] {
        quotes
    }
    
    /// Get a quote for a specific mood or context
    func quoteForContext(_ context: QuoteContext) -> MotivationalQuote {
        // For now, just return a random quote
        // Could be enhanced to filter by context
        return randomQuote()
    }
}

// MARK: - Motivational Quote

struct MotivationalQuote: Identifiable {
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

